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

/**
 Data extensions to map Data blocks to other Models
 */
extension Data {
    /**
         Parse ASN.1 Data block as Integer

         - Returns: Signed Integer or nil when block is too short (e.g. empty) or too big > Int.max.
     */
    public var asn1integer: Int? {
        guard !isEmpty else {
            return nil
        }

        let maxSize = MemoryLayout<Int>.size
        guard maxSize >= count else {
            return nil
        }
        let firstByte = self[0]

        var substrahendInteger = Int(firstByte & 0x80)

        let sub = subdata(in: 1 ..< count)
        let value = sub.reduce(Int(firstByte & 0x7F)) { integer, byte in
            substrahendInteger <<= 8
            return Int(integer << 8 | Int(byte))
        }
        return value &- substrahendInteger
    }
}
