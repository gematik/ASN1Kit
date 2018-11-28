//
// Created by Arjan Duijzer on 20/04/2017.
// Copyright (c) 2017 Gematik. All rights reserved.
//

import Foundation

/**
    Data extensions to map Data blocks to other Models
*/
extension Data {
    //swiftlint:disable todo
    /**
        Parse ASN.1 Data block as Integer

        TODO handle Int overflow

        - Returns: Signed Integer or nil when block is too short.
    */
    public var asn1integer: Int? {
        guard !self.isEmpty else {
            return nil
        }

        let firstByte = self[0]

        var substrahendInteger = Int(firstByte & 0x80)

        let sub = self.subdata(in: 1..<self.count)
        let value = sub.reduce(Int(firstByte & 0x7f)) { integer, byte in
            substrahendInteger <<= 8
            return Int(integer << 8 | Int(byte & 0xff))
        }
        return value - substrahendInteger
    }
    //swiftlint:enable todo
}
