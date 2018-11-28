//
// Created by Adriaan Duijzer on 28.11.18.
//

@testable import ASN1Kit
import GemCommonsKit
//import Nimble
import XCTest

final class ASN1ObjectTest: XCTestCase {
    func testTagNoLength() {
        let shortNo: UInt = 0x14
        XCTAssertEqual(shortNo.tagNoLength, Int(1))

        let longNo: UInt = 76
        XCTAssertEqual(longNo.tagNoLength, 2)
    }

    func testLengthSize() {
        let short = 100
        XCTAssertEqual(short.lengthSize, 1)

        let long = 0xfa
        XCTAssertEqual(long.lengthSize, 2)

        let veryLong = 0xee45
        XCTAssertEqual(veryLong.lengthSize, 3)
    }

    static var allTests = [
        ("testTagNoLength", testTagNoLength),
        ("testLengthSize", testLengthSize)
    ]
}
