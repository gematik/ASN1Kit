//
// Created by Arjan Duijzer on 20/04/2017.
// Copyright (c) 2017 Gematik. All rights reserved.
//

@testable import ASN1Kit
import XCTest

// https://www.strozhevsky.com/free_docs/asn1_by_simple_words.pdf
final class DataExtASN1IntTest: XCTestCase {
    func testASN1DataToInt_0x80() {
        //0x80 = -128
        let data = Data(bytes: [0x80])
        XCTAssertEqual(data.asn1integer, -128)
    }

    func testASN1DataToInt_0x0080() {
        //0x0080 = 128
        let data = Data(bytes: [0x00, 0x80])
        XCTAssertEqual(data.asn1integer, 128)
    }

    func testASN1DataToInt_0x7FFFFF() {
        //0x7FFFFF = 8388607
        let data = Data(bytes: [0x7F, 0xFF, 0xFF])
        XCTAssertEqual(data.asn1integer, 8388607)
    }

    func testASN1DataToInt_0xff78() {
        //0xff78 = -136
        let data = Data(bytes: [0xff, 0x78])
        XCTAssertEqual(data.asn1integer, -136)
    }

    func testASN1DataToInt_0x800001() {
        //0x800001 = -8388607
        let data = Data(bytes: [0x80, 0x00, 0x01])
        XCTAssertEqual(data.asn1integer, -8388607)
    }

    static var allTests = [
        ("testASN1DataToInt_0x80", testASN1DataToInt_0x80),
        ("testASN1DataToInt_0x0080", testASN1DataToInt_0x0080),
        ("testASN1DataToInt_0x7FFFFF", testASN1DataToInt_0x7FFFFF),
        ("testASN1DataToInt_0xff78", testASN1DataToInt_0xff78),
        ("testASN1DataToInt_0x800001", testASN1DataToInt_0x800001)
    ]
}
