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

import Foundation

extension ASN1Object {
    /// Wrap an ASN1Object to build a ASN1 tree/document
    /// - Parameters:
    ///     - tag: The ASN1 Tag to wrap around the receiver
    ///     - constructed: Whether the wrapping tag should be constructed or implicit. (default: true)
    /// - Returns: The wrapped Tag
    public func wrap(with tag: ASN1DecodedTag, constructed: Bool = true) -> ASN1Object {
        if constructed {
            return ASN1Primitive(data: .constructed([self]), tag: tag)
        }
        /// Implicit
        return ASN1Primitive(data: data, tag: tag)
    }
}

extension ASN1Object {
    /// DER encode the ASN1Object model to an ASN.1 serialized data blob
    /// - Throws: ASN1EncodingError
    /// - Returns: the serialized ASN.1 data
    public func serialize() throws -> Data {
        let tagLen = tag.length
        let lenLen = length.lengthSize
        let len = length + tagLen + lenLen

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        let outputStream = OutputStream(toBuffer: buffer, capacity: len)
        outputStream.open()
        let bytesWritten = write(to: outputStream)
        outputStream.close()

        guard bytesWritten == len else {
            buffer.deallocate()
            throw ASN1Error.internalInconsistency(
                "Internal inconsistency error: Number of bytes written [\(bytesWritten)] " +
                    "is not equal to required length [\(len)]"
            )
        }
        return Data(bytesNoCopy: buffer, count: len, deallocator: .free)
    }

    internal func write(to output: OutputStream) -> Int {
        Self.write(tag: tag, constructed: data.constructed, to: output) +
            Self.write(length: length, to: output) +
            Self.write(data: data, to: output)
    }

    private static func write(tag: ASN1DecodedTag,
                              constructed: Bool,
                              to output: OutputStream) -> Int {
        tag.write(to: output, constructed: constructed)
    }

    internal static func write(length: Int, to output: OutputStream) -> Int {
        if length < 0x80 {
            // short notation
            var byte: [UInt8] = [UInt8(length)]
            return output.write(&byte, maxLength: 1)
        } else {
            // long notation
            let len = length.lengthSize - 1
            var bytes = [UInt8(0x80 | len)]
            for idx in (0 ..< len).reversed() {
                bytes.append(UInt8((length & Int(0xFF << (idx * 8))) >> (idx * 8)))
            }
            return output.write(&bytes, maxLength: bytes.count)
        }
    }

    private static func write(data: ASN1Data, to output: OutputStream) -> Int {
        data.write(to: output)
    }
}

extension ASN1DecodedTag {
    internal func write(to output: OutputStream, constructed: Bool) -> Int {
        switch self {
        case let .universal(tag):
            let byte = tag.rawValue | UInt8(constructed ? ASN1Tag.constructed : ASN1Tag.universal)
            return output.write(byte: byte)
        case let .applicationTag(tag):
            return tag.write(to: output, clazz: ASN1Tag.application, constructed: constructed)
        case let .taggedTag(tag):
            return tag.write(to: output, clazz: ASN1Tag.tagged, constructed: constructed)
        case let .privateTag(tag):
            return tag.write(to: output, clazz: ASN1Tag.private, constructed: constructed)
        }
    }
}

extension UInt {
    internal func write(to output: OutputStream,
                        clazz: UInt8,
                        constructed: Bool) -> Int {
        if self < 0x1F {
            // short notation
            var byte = [UInt8(self) |
                clazz |
                UInt8(constructed ? ASN1Tag.constructed : ASN1Tag.universal)]
            return output.write(&byte, maxLength: 1)
        } else {
            // Long notation
            let len = tagNoLength
            let firstByte = clazz |
                UInt8(constructed ? ASN1Tag.constructed : ASN1Tag.universal) |
                0x1F
            var byteCount = output.write(byte: firstByte)

            for idx in (0 ..< len - 1).reversed() {
                var byte = UInt8((self >> UInt(idx * 7)) & 0x7F) | UInt8(0x80)
                // unset the 8th bit in the last written byte
                if idx == 0 {
                    byte &= 0x7F
                }
                byteCount += output.write(byte: byte)
            }
            // unset the 8th bit in the last written byte
            return byteCount
        }
    }
}

extension ASN1Data {
    internal func write(to output: OutputStream) -> Int {
        switch self {
        case let .primitive(data):
            // Write primitive
            if !data.isEmpty {
                return data.withUnsafeBytes { bytes in
                    // swiftlint:disable:next force_unwrapping
                    let ptr = bytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
                    return output.write(ptr, maxLength: data.count)
                }
            } else {
                // Not writing NULL
                return 0
            }
        case let .constructed(items):
            // Write constructed items
            return items.reduce(0) { acc, item in
                acc + item.write(to: output)
            }
        }
    }
}
