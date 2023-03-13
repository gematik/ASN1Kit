//
// Copyright (c) 2023 gematik GmbH
//
// Licensed under the Apache License, Version 2.0 (the License);
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an 'AS IS' BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import DataKit
import Foundation
import GemCommonsKit

/**
 ASN.1 (DER) Decoder implementation according to the X.690-0207 (Abstract Syntax Notation One) specification.

 For more info, please find the complete
 [X.690-0207.pdf](https://www.itu.int/ITU-T/studygroups/com17/languages/X.690-0207.pdf) specification.
 */
public class ASN1Decoder {
    /**
         Decode a *Data* octet byte-stream to an ASN.1 Object

         - Parameter data: The input data to parse according to the ASN.1 specification

         - SeeAlso: `ASN1Object`

         - Returns: ASN1Object or nil when parsing failed.
     */
    public class func decode(asn1 data: Data) throws -> ASN1Object {
        let scanner = DataScanner(data: data)

        return try decode(from: scanner)
    }

    private class func decode(from scanner: DataScanner) throws -> ASN1Primitive {
        scanner.mark()
        defer { scanner.unmark() }

        guard let firstByte = scanner.scan(distance: 1)?[0] else {
            throw ASN1Error.malformedEncoding("Scanner has no bytes left to decode")
        }

        if firstByte == 0x0 {
            DLog("Decoding ASN.1 object bounced unexpected on NULL (0x0) marker")
            throw ASN1Error.malformedEncoding("Decoding ASN.1 object bounced unexpected on NULL (0x0) marker")
        }

        let tagNo = try decodeTagNumber(from: firstByte, with: scanner)
        let constructed = (firstByte & ASN1Tag.constructed) != 0x0
        let length = try decodeLength(from: scanner)

        guard length != -1 else {
            throw ASN1Error.unsupported("BER indefinite length encoding is unsupported")
        }

        var object = try tagNo.createObject(tag: tagNo, length: length, constructed: constructed, scanner: scanner)
        object.originalEncoding = scanner.marked
        return object
    }

    class func decodeLength(from scanner: DataScanner) throws -> Int {
        guard let data = scanner.scan(distance: 1) else {
            DLog("Decoding ASN.1 Scanner has no bytes left")
            throw ASN1Error.malformedEncoding("Scanner has no bytes left [length]")
        }

        let firstByte = data[0]
        // check for indefinite
        if firstByte == 0x80 {
            return -1
        }

        // check for short or long notation
        if firstByte & 0x80 != 0 {
            // long
            let octets = firstByte & 0x7F
            guard let lengthBytes = scanner.scan(distance: Int(octets)) else {
                throw ASN1Error.malformedEncoding("Scanner has insufficient bytes left to decode long-length notation")
            }
            guard let length = lengthBytes.unsignedIntValue else {
                throw ASN1Error.unsupported("Length data invalid(/too long): [0x\(lengthBytes.hexString())]")
            }
            return Int(length)
        } else {
            // short
            return Int(firstByte)
        }
    }

    /**
         Determine the tagNo and/or type tag when possible

         - Parameters
             - tag: the first byte
             - scanner: The current data and position. Leaving the scanner position ready for the next scan operation

         - Returns: Enum case with the found TagNo and/or the type of the tag
     */
    class func decodeTagNumber(from tag: UInt8, with scanner: DataScanner) throws -> ASN1DecodedTag {
        // Bottom 5 bits is tagNo
        let tagNo: UInt // = tag & 0x1f
        if tag & 0x1F == 0x1F {
            // Long notation
            var longTagNo: UInt = 0
            var end = false
            let maxSize = Int(ceil(Double(MemoryLayout<UInt>.size) * 8.0 / 7.0))
            var idx = 0
            repeat {
                guard let byte = scanner.scan(distance: 1)?[0] else {
                    DLog("Decoding ASN.1 Scanner has no bytes left")
                    throw ASN1Error.malformedEncoding("Scanner has no bytes left to decode long tag number")
                }
                // Overflow check
                guard idx < maxSize else {
                    throw ASN1Error.unsupported("ASN1Decoder bounced on too big Tag number (> UInt.max)")
                }
                idx += 1
                end = (byte & 0x80 == 0x0)
                let value = byte & 0x7F

                if longTagNo == 0 {
                    longTagNo = UInt(value)
                } else {
                    longTagNo <<= 7
                    longTagNo |= UInt(value)
                }

            } while !end
            tagNo = longTagNo
        } else {
            tagNo = UInt(tag & 0x1F)
        }
        // Private Tag
        if tag & ASN1Tag.private == ASN1Tag.private {
            return .privateTag(tagNo)
        } else {
            // Application Tag
            if tag & ASN1Tag.application == ASN1Tag.application {
                return .applicationTag(tagNo)
            }
            // Tagged object
            if tag & ASN1Tag.tagged == ASN1Tag.tagged {
                return .taggedTag(tagNo)
            }
        }
        guard let tag = ASN1Tag(rawValue: UInt8(tagNo)) else {
            throw ASN1Error.malformedEncoding("Tag value is invalid: [0x\(String(tagNo, radix: 16))]")
        }
        return .universal(tag)
    }

    // swiftlint:disable:next strict_fileprivate
    fileprivate class func createTaggedObject(
        tag: ASN1DecodedTag,
        length: Int,
        constructed: Bool,
        scanner: DataScanner
    ) throws
        -> ASN1Primitive {
        if constructed {
            let constructedObject = try createConstructedObject(
                tag: ASN1Tag.set,
                length: length,
                scanner: scanner
            )

            guard constructedObject.constructed else {
                throw ASN1Error.malformedEncoding("Unexpected type encountered while expecting a constructed tag")
            }

            return ASN1Primitive(data: constructedObject.data, tag: tag)
        } else {
            // Can be implicit null
            guard length > 0 else {
                return ASN1Primitive(
                    data: .primitive(Data.empty),
                    tag: tag
                )
            }
            guard let data = scanner.scan(distance: length) else {
                throw ASN1Error.malformedEncoding("Scanner has no bytes left [tagged object]")
            }
            // ASN1 tagged object is implicit octetString
            return ASN1Primitive(data: .primitive(data), tag: tag)
        }
    }

    // swiftlint:disable:next strict_fileprivate
    fileprivate class func createConstructedObject(tag: ASN1Tag, length: Int,
                                                   scanner: DataScanner) throws -> ASN1Primitive {
        switch tag {
        case .set:
            return try tag.toConstructed(with: decodeItems(from: scanner, length: length))
        case .sequence:
            return try tag.toConstructed(with: decodeItems(from: scanner, length: length))
        case .octetString:
            return try tag.toConstructed(with: decodeItems(from: scanner, length: length))
        case .bitString:
            return try tag.toConstructed(with: decodeItems(from: scanner, length: length))
        case .external:
            DLog("Decoding ASN.1 External Tag is unsupported")
            // TODO: //swiftlint:disable:this todo
            throw ASN1Error.unsupported("Decoding ASN.1 External Tag is unsupported")
        default:
            throw ASN1Error.unsupported("Decoding tag: [0x\(String(tag.rawValue, radix: 16))] " +
                "as a constructed type is unsupported")
        }
    }

    private class func decodeItems(from scanner: DataScanner, length: Int) throws -> [ASN1Primitive] {
        if length == 0 {
            // allow empty sequences as for example can occur in certificates with
            // zero-length subject names
            return [ASN1Primitive]()
        }

        guard let data = scanner.scan(distance: length) else {
            DLog("Scanner has no bytes left to decode sequence")
            throw ASN1Error.malformedEncoding("Scanner has no bytes left to decode sequence")
        }

        let sequenceScanner = DataScanner(data: data)
        var items = [ASN1Primitive]()

        while !sequenceScanner.isComplete {
            let object = try decode(from: sequenceScanner)
            items.append(object)
        }

        return items
    }

    // swiftlint:disable:next strict_fileprivate
    fileprivate class func createPrimitive(tag: ASN1Tag, length: Int, scanner: DataScanner) throws -> ASN1Primitive {
        guard length > 0 else {
            let tag: ASN1Tag = tag == .octetString ? .octetString : .null
            return tag.toPrimitive(with: Data.empty)
        }
        guard let data = scanner.scan(distance: length) else {
            DLog("Decoding ASN.1 Scanner has no bytes left")
            throw ASN1Error.malformedEncoding(
                "Scanner has no bytes left to decode primitive: [0x\(String(tag.rawValue, radix: 16))]"
            )
        }
        return tag.toPrimitive(with: data)
    }
}

extension ASN1Tag {
    // swiftlint:disable:next strict_fileprivate
    fileprivate func toPrimitive(with data: Data) -> ASN1Primitive {
        ASN1Primitive(data: .primitive(data), tag: .universal(self))
    }

    // swiftlint:disable:next strict_fileprivate
    fileprivate func toConstructed(with items: [ASN1Primitive]) -> ASN1Primitive {
        ASN1Primitive(data: .constructed(items), tag: .universal(self))
    }
}

extension ASN1DecodedTag {
    // swiftlint:disable:next strict_fileprivate
    fileprivate func createObject(tag _: ASN1DecodedTag, length len: Int, constructed flag: Bool, scanner: DataScanner)
        throws -> ASN1Primitive {
        switch self {
        case .applicationTag: fallthrough // swiftlint:disable:this no_fallthrough_only
        case .taggedTag: fallthrough // swiftlint:disable:this no_fallthrough_only
        case .privateTag:
            return try ASN1Decoder.createTaggedObject(
                tag: self,
                length: len,
                constructed: flag,
                scanner: scanner
            )
        case let .universal(asn1tag):
            if flag {
                return try ASN1Decoder.createConstructedObject(
                    tag: asn1tag,
                    length: len,
                    scanner: scanner
                )
            } else {
                return try ASN1Decoder.createPrimitive(
                    tag: asn1tag,
                    length: len,
                    scanner: scanner
                )
            }
        }
    }
}
