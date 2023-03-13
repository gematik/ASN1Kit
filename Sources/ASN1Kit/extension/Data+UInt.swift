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
 Data extension Data+UInt
 */
extension Data {
    /**
         Map *Data* block self to `UInt`

         - Discussion:
           Combines the bytes `[UInt8]` to `UInt` by shifting the bytes in most significant byte order (Big-endian).
           The length of byte array should not be greater than `sizeof(UInt)` so not to overflow the return value.

         - SeeAlso: https://en.wikipedia.org/wiki/Endianness

         - Note: In case of overflow **nil** is returned

         - Returns: `UInt` value or `nil`
     */
    public var unsignedIntValue: UInt? {
        let maxSize = MemoryLayout<UInt>.size
        guard count <= maxSize else {
            return nil
        }
        return reduce(0 as UInt) { number, byte in
            (number << 8) | UInt(byte & 0xFF)
        }
    }
}
