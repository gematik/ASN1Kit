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
import GemCommonsKit

extension Int: ASN1EncodableType {
    public func asn1encode(tag: ASN1DecodedTag?) throws -> ASN1Object {
        let intSize = MemoryLayout<Int>.size
        var littleEndian = self.littleEndian
        return withUnsafePointer(to: &littleEndian) { unbound -> Data in
            unbound.withMemoryRebound(to: UInt8.self, capacity: intSize) { bytes -> Data in
                var shift = 0
                if self == Int.min {
                    shift = intSize
                } else {
                    // find out how many bytes we need (minimum) for DER-encoding
                    var value = (self < 0) ? UInt(self * -1) : UInt(self)
                    repeat {
                        shift += 1
                        value >>= 8
                    } while value > 0 || (
                        (self >= 0 && bytes[shift - 1] & 0x80 == 0x80) || // Check positive bounds
                            (self < 0 && bytes[shift - 1] & 0x80 != 0x80) // Check negative bounds
                    )
                }
                let data = Data(bytes: bytes, count: shift)
                return Data(data.reversed()) // Return BigEndian
            }
        }.asn1encode(tag: tag ?? .universal(.integer))
    }
}

extension UInt: ASN1EncodableType {
    public func asn1encode(tag: ASN1DecodedTag?) throws -> ASN1Object {
        let uintSize = MemoryLayout<UInt>.size
        var littleEndian = self.littleEndian
        return withUnsafePointer(to: &littleEndian) { unbound -> Data in
            unbound.withMemoryRebound(to: UInt8.self, capacity: uintSize) { bytes -> Data in
                var shift = 0
                // find out how many bytes we need (minimum) for DER-encoding
                var value = UInt(self)
                repeat {
                    shift += 1
                    value >>= 8
                } while value > 0
                var data = Data(bytes: bytes, count: shift)
                if shift > 0, bytes[shift - 1] & 0x80 != 0 {
                    data.append(contentsOf: [0x00])
                }
                return Data(data.reversed()) // Return BigEndian
            }
        }.asn1encode(tag: tag ?? .universal(.integer))
    }
}
