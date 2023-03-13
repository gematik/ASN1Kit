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

@testable import ASN1Kit
import Nimble
import XCTest

// https://www.strozhevsky.com/free_docs/asn1_by_simple_words.pdf
final class DataExtASN1IntTest: XCTestCase {
    func testASN1DataToInt_0x80() {
        // 0x80 = -128
        let data = Data([0x80])
        expect(data.asn1integer) == -128
    }

    func testASN1DataToInt_0x0080() {
        // 0x0080 = 128
        let data = Data([0x00, 0x80])
        expect(data.asn1integer) == 128
    }

    func testASN1DataToInt_0x7FFFFF() {
        // 0x7FFFFF = 8388607
        let data = Data([0x7F, 0xFF, 0xFF])
        expect(data.asn1integer) == 8_388_607
    }

    func testASN1DataToInt_0xff78() {
        // 0xff78 = -136
        let data = Data([0xFF, 0x78])
        expect(data.asn1integer) == -136
    }

    func testASN1DataToInt_0x800001() {
        // 0x800001 = -8388607
        let data = Data([0x80, 0x00, 0x01])
        expect(data.asn1integer) == -8_388_607
    }

    func testASN1DataToMinInt() {
        let size = MemoryLayout<Int>.size
        var bytes = [UInt8](repeating: 0x0, count: size)
        bytes[0] = 0x80
        let data = Data(bytes)
        expect(data.asn1integer) == Int.min
    }

    func testASN1DataToMaxInt() {
        // Test ASN1Integer Int.max
        let size = MemoryLayout<Int>.size
        var bytes = [UInt8](repeating: 0xFF, count: size)
        bytes[0] = 0x80 ^ bytes[0]
        let data = Data(bytes)
        expect(data.asn1integer) == Int.max
    }

    func testASN1DataExceedingMaxInt() {
        // Test ASN1Integer larger than Int.size
        let size = MemoryLayout<Int>.size + 1
        var bytes = [UInt8](repeating: 0x0, count: size)
        for idx in 0 ..< size {
            bytes[idx] = 0x80 | UInt8(idx + 1)
        }
        let data = Data(bytes)

        expect(data.asn1integer).to(beNil())
    }

    static var allTests = [
        ("testASN1DataToInt_0x80", testASN1DataToInt_0x80),
        ("testASN1DataToInt_0x0080", testASN1DataToInt_0x0080),
        ("testASN1DataToInt_0x7FFFFF", testASN1DataToInt_0x7FFFFF),
        ("testASN1DataToInt_0xff78", testASN1DataToInt_0xff78),
        ("testASN1DataToInt_0x800001", testASN1DataToInt_0x800001),
        ("testASN1DataToMinInt", testASN1DataToMinInt),
        ("testASN1DataToMaxInt", testASN1DataToMaxInt),
        ("testASN1DataExceedingMaxInt", testASN1DataExceedingMaxInt),
    ]
}
