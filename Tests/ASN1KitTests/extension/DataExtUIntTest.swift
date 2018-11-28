//
// Created by Arjan Duijzer on 12/04/2017.
// Copyright (c) 2017 Gematik. All rights reserved.
//

@testable import ASN1Kit
import Nimble
import XCTest

class DataExtUIntTest: XCTestCase {
    func testDataToUInt() {
        let bytes: [UInt8] = [0x40, 0x00, 0x00, 0x81]
        let data = Data(bytes: bytes)

        expect(data.unsignedIntValue) == 0x40000081
    }

    func testDataToUInt_min() {
        let bytes: [UInt8] = [0x0]
        let data = Data(bytes: bytes)

        expect(data.unsignedIntValue) == UInt.min
    }

    func testDataToUInt_max() {
        let uintSize = MemoryLayout<UInt>.size
        var data = Data()
        for _ in 0..<uintSize {
            data.append(Data(bytes: [0xFF]))
        }

        expect(data.unsignedIntValue) == UInt.max
    }

    func testDataToUInt_overflow() {
        let uintSize = MemoryLayout<UInt>.size + 1
        var data = Data()
        for _ in 0..<uintSize {
            data.append(Data(bytes: [0xFF]))
        }

        expect(data.unsignedIntValue).to(beNil())
    }

    static var allTests = [
        ("testDataToUInt", testDataToUInt),
        ("testDataToUInt_min", testDataToUInt_min),
        ("testDataToUInt_max", testDataToUInt_max),
        ("testDataToUInt_overflow", testDataToUInt_overflow)
    ]
}
