//
// Created by Arjan Duijzer on 18/04/2017.
// Copyright (c) 2017 Gematik. All rights reserved.
//

import Foundation
import GemCommonsKit

/**
    ASN.1 Error type
*/
public enum ASN1DecoderError {
    /// When the byte-stream encountered an unexpected byte or length
    case malformedEncoding(String)
}

extension ASN1DecoderError: Error {
}

/**
    ASN.1 Decoder implementation according to the X.690-0207 (Abstract Syntax Notation One) specification.

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
    public class func decode(asn1 data: Data) -> ASN1Object? {
        let scanner = DataScanner(data: data)

        return decode(from: scanner)
    }

    private class func decode(from scanner: DataScanner) -> ASN1Object? {
        guard let firstByte = scanner.scan(distance: 1)?[0] else {
            return nil
        }

        if firstByte == 0x0 {
            DLog("Decoding ASN.1 object bounced unexpected on NULL (0x0) marker")
            return nil
        }

        guard let tagNo = try? decodeTagNumber(from: firstByte, with: scanner) else {
            DLog("Decoding ASN.1 object could not find the Tag number")
            return nil
        }

        let constructed = (firstByte & ASN1Tag.constructed) != 0x0

        guard let length = try? decodeLength(from: scanner) else {
            DLog("Decoding ASN.1 cannot decode length")
            return nil
        }

        // Application Tag
        if firstByte & ASN1Tag.application != 0x0 {
            return createApplicationSpecific(tag: tagNo, length: length, constructed: constructed, scanner: scanner)
        }
        // Tagged object
        if firstByte & ASN1Tag.tagged != 0x0 {
            return createTaggedObject(tag: tagNo, length: length, constructed: constructed, scanner: scanner)
        }
        guard let tag = ASN1Tag(rawValue: UInt8(tagNo)) else {
            DLog("Decoding ASN.1 Unsupported tag nr: \(tagNo)")
            return nil
        }
        if constructed {
            return createConstructedObject(tag: tag, length: length, scanner: scanner)
        } else {
            return createPrimitive(tag: tag, length: length, scanner: scanner)
        }
    }

    internal class func decodeLength(from scanner: DataScanner) throws -> Int {
        guard let data = scanner.scan(distance: 1) else {
            DLog("Decoding ASN.1 Scanner has no bytes left")
            throw ASN1DecoderError.malformedEncoding("Scanner has no bytes left")
        }

        let firstByte = data[0]
        // check for short or long notation
        if firstByte & 0x80 != 0 {
            // long
            let octets = firstByte & 0x7f
            guard let lengthBytes = scanner.scan(distance: Int(octets)),
                  let length = lengthBytes.unsignedIntValue else {
                throw ASN1DecoderError.malformedEncoding("Length data INVALID")
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

        - Returns: Tuple with the found TagNo and/or the type of the tag
    */
    internal class func decodeTagNumber(from tag: UInt8, with scanner: DataScanner) throws -> UInt {
        // Bottom 5 bits is tagNo
        let tagNo = tag & 0x1f
        if tagNo == 0x1f {
            // Long notation
            var longTagNo: UInt = 0
            var end = false

            repeat {
                guard let byte = scanner.scan(distance: 1)?[0] else {
                    DLog("Decoding ASN.1 Scanner has no bytes left")
                    throw ASN1DecoderError.malformedEncoding("Scanner has no bytes left")
                }
                end = (byte & 0x80 == 0x0)
                let value = byte & 0x7f
                if longTagNo == 0 {
                    longTagNo = UInt(value)
                } else {
                    longTagNo <<= 7
                    longTagNo |= UInt(value)
                }

            } while (!end)

            return longTagNo
        } else {
            return UInt(tagNo)
        }
    }

    private class func createApplicationSpecific(tag: UInt, length: Int, constructed: Bool, scanner: DataScanner)
                    -> ASN1ApplicationSpecific? {
        guard let tagged = createTaggedObject(
                tag: tag,
                length: length,
                constructed: constructed,
                scanner: scanner
        ) else {
            return nil
        }
        return ASN1ApplicationSpecificObject(primitive: tagged)
    }

    private class func createTaggedObject(tag: UInt, length: Int, constructed: Bool, scanner: DataScanner)
                    -> ASN1TaggedObject? {
        if constructed {
            guard let constructedObject = createConstructedObject(
                    tag: ASN1Tag.set,
                    length: length,
                    scanner: scanner
            ) as? ASN1Sequence else {
                return nil
            }

            return ASN1TaggedStructure(
                    primitive: ASN1Primitive(data: Data.empty, type: .implicit, constructed: true),
                    tagNo: tag,
                    objects: constructedObject.items
            )
        } else {
            // Can be implicit null
            guard length > 0 else {
                return ASN1TaggedStructure(
                        primitive: ASN1Primitive(data: Data.empty, type: .implicit, constructed: false),
                        tagNo: tag,
                        objects: []
                )
            }
            guard let data = scanner.scan(distance: length) else {
                return nil
            }
            return ASN1TaggedStructure(
                    primitive: ASN1Primitive(data: data, type: .implicit, constructed: false),
                    tagNo: tag,
                    objects: []
            )
        }
    }

    private class func createConstructedObject(tag: ASN1Tag, length: Int, scanner: DataScanner) -> ASN1Object? {
        switch tag {
        case .set: fallthrough //swiftlint:disable:this no_fallthrough_only
        case .sequence:
            return createSequence(from: scanner, length: length)
        case .octetString:
            DLog("Decoding ASN.1 CONSTRUCTED Octet String is unsupported")
            return nil // TODO //swiftlint:disable:this todo
        case .external:
            DLog("Decoding ASN.1 External Tag is unsupported")
            return nil // TODO //swiftlint:disable:this todo
        default: return nil
        }
    }

    private class func createSequence(from scanner: DataScanner, length: Int) -> ASN1Sequence? {
        guard let data = scanner.scan(distance: length) else {
            DLog("Decoding ASN.1 Scanner has no bytes left")
            return nil
        }

        let sequenceScanner = DataScanner(data: data)
        var items = [ASN1Object]()

        repeat {
            if let object = decode(from: sequenceScanner) {
                items.append(object)
            }

        } while (!sequenceScanner.isComplete)

        let primitive = ASN1Primitive(data: Data.empty, type: .sequence, constructed: true)
        return ASN1SequenceStruct(primitive: primitive, items: items)
    }

    private class func createPrimitive(tag: ASN1Tag, length: Int, scanner: DataScanner) -> ASN1Object? {
        guard length > 0 else {
            return ASN1Primitive(data: Data.empty, type: .null, constructed: false)
        }
        guard let data = scanner.scan(distance: length) else {
            DLog("Decoding ASN.1 Scanner has no bytes left")
            return nil
        }
        return ASN1Primitive(data: data, type: tag, constructed: false)
    }
}
