//
// Created by Arjan Duijzer on 19/04/2017.
// Copyright (c) 2017 Gematik. All rights reserved.
//

@testable import ASN1Kit
import XCTest

final class DataScannerTest: XCTestCase {
    func testDataScanner() {
        let data = Data(bytes: [0x62, 0x82, 0x01, 0x34, 0x82, 0x01, 0x78, 0x83, 0x02, 0x3F, 0x00, 0x8A, 0x01, 0x05,
                                0x84, 0x07, 0xD2, 0x76, 0x00, 0x01, 0x44, 0x80, 0x00, 0xA1, 0x81, 0xD4, 0x91, 0x03])
        let scanner = DataScanner(data: data)

        XCTAssertFalse(scanner.isComplete)
        let subdata = scanner.scan(distance: 2)
        XCTAssertFalse(scanner.isComplete)
        XCTAssertEqual(subdata, Data(bytes: [0x62, 0x82]))

        let sub2 = scanner.scan(distance: 2)
        XCTAssertFalse(scanner.isComplete)
        XCTAssertEqual(sub2, Data(bytes: [0x01, 0x34]))

        let sub2end = scanner.scanToEnd()
        XCTAssertTrue(scanner.isComplete)
        XCTAssertEqual(sub2end, Data(bytes: [0x82, 0x01, 0x78, 0x83, 0x02, 0x3F, 0x00, 0x8A, 0x01, 0x05, 0x84, 0x07,
                                             0xD2, 0x76, 0x00, 0x01, 0x44, 0x80, 0x00, 0xA1, 0x81, 0xD4, 0x91, 0x03]))

        scanner.rollback(distance: 2)
        let sub3 = scanner.scan(distance: 1)
        XCTAssertFalse(scanner.isComplete)
        XCTAssertEqual(sub3, Data(bytes: [0x91]))

        let scanEnd = scanner.scanToEnd()
        XCTAssertTrue(scanner.isComplete)
        XCTAssertEqual(scanEnd, Data(bytes: [0x03]))

        /// Rollback all the way
        scanner.rollback(distance: data.count)
        XCTAssertFalse(scanner.isComplete)
        XCTAssertEqual(scanner.scan(distance: 2), Data(bytes: [0x62, 0x82]))

        /// Rollback more than length
        scanner.rollback(distance: 1000)
        XCTAssertFalse(scanner.isComplete)
        XCTAssertEqual(scanner.scan(distance: 2), Data(bytes: [0x62, 0x82]))
        XCTAssertFalse(scanner.isComplete)

        /// Scan 1 more than length
        let tooMuchData = scanner.scan(distance: data.count - 1)
        XCTAssertFalse(scanner.isComplete)
        XCTAssertNil(tooMuchData)

        let scanAfterwards = scanner.scan(distance: 1)
        XCTAssertFalse(scanner.isComplete)
        XCTAssertEqual(scanAfterwards, Data(bytes: [0x01]))
    }

    static var allTests = [
        ("testDataScanner", testDataScanner)
    ]
}
