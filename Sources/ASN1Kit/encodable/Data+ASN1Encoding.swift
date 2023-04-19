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

extension Data: ASN1CodableType {
    public init(from asn1: ASN1Object) throws {
        switch (asn1.tag, asn1.data) {
        case let (ASN1DecodedTag.universal(.bitString), .primitive(data)):
            try self.init(bitString: data)
        case let (_, .primitive(data)):
            self.init(data)
        case let (_, .constructed(items)):
            try self.init(items.reduce(Data()) { acc, obj in
                let data = try Data(from: obj)
                return acc + data
            })
        }
    }

    public init(bitString: Data) throws {
        guard !bitString.isEmpty else {
            throw ASN1Error.malformedEncoding("BitString: insufficient bytes")
        }
        guard let firstByte = bitString.first, firstByte < 8 else {
            throw ASN1Error.malformedEncoding("BitString: missing or invalid unused bits")
        }

        var data: Data

        if bitString.count == 1 {
            guard firstByte == 0 else {
                throw ASN1Error.malformedEncoding("BitString: invalid encoding of empty string")
            }
            data = Data()
        } else {
            data = Data(bitString[1...])
            data[data.count - 1] = (data.last ?? 0x0) & 0xFF << firstByte
        }
        self.init(data)
    }

    public static func asn1decoded(_ object: ASN1Object) throws -> Data {
        try Data(from: object)
    }

    public func asn1encode(tag: ASN1DecodedTag? = nil) -> ASN1Object {
        ASN1Primitive(data: .primitive(self), tag: tag ?? .universal(.octetString))
    }

    public func asn1bitStringEncode(unused bits: Int = 0, tag: ASN1DecodedTag? = nil) throws -> ASN1Object {
        guard bits < 8, bits >= 0 else {
            throw ASN1Error.malformedEncoding("BitString: invalid unused bits: \(bits)")
        }
        var bytes = Data()
        bytes.append(UInt8(bits))
        bytes.append(self)
        bytes[bytes.count - 1] = (bytes.last ?? 0x0) & 0xFF << bits
        return ASN1Primitive(data: .primitive(bytes), tag: tag ?? .universal(.bitString))
    }
}
