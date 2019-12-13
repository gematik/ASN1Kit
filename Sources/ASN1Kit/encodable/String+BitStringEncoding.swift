//
// Copyright (c) 2019 gematik GmbH
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import DataKit
import Foundation

extension String {
    /// Encode Hex String as ASN1 Bit String
    public func bitString() throws -> ASN1Object {
        let string: String
        let padding: UInt8
        if self.count % 2 != 0 {
            string = self + "0"
            padding = 0x4
        } else {
            string = self
            padding = 0x0
        }

        let data = try Data(hex: string)

        return ASN1Primitive(data: .primitive(Data(bytes: [padding]) + data), tag: .universal(.bitString))
    }

    /// Parse an ASN.1 bitString into String
    ///
    /// - Parameter asn1: the bitString ASN1 encoded object
    /// - Returns: the bitString
    public static func from(bitString asn1: ASN1Object) -> String {
        return asn1.data.fold(primitive, constructed)
    }

    internal static func primitive(_ data: Data) -> String {
        let padding: UInt8 = data[0]
        let length = data.count

        return data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> String in
            let raw = UnsafeMutableRawPointer(mutating: bytes)
            var ptr = Data(bytesNoCopy: raw, count: data.count, deallocator: .none)
            ptr[length - 1] = ptr[length - 1] & (0xff << padding)

            let string = ptr[1..<ptr.count].hexString()
            if padding > 3 {
                return string[0..<string.count - 1]
            }
            return string
        }
    }

    internal static func constructed(_ bitStrings: [ASN1Object]) -> String {
        return bitStrings.reduce(String()) { acc, str in
            let bitString = from(bitString: str)
            return acc + bitString
        }
    }
}
