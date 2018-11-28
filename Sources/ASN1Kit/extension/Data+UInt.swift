//
// Created by Arjan Duijzer on 12/04/2017.
// Copyright (c) 2017 Gematik. All rights reserved.
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
        guard self.count <= maxSize else {
            return nil
        }
        return self.reduce(0 as UInt) { number, byte in
            return (number << 8) | UInt(byte & 0xff)
        }
    }
}
