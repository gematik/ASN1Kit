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
final class IntExtASN1EncodingTest: XCTestCase {
    func testEnumerated_toASN1() {
        // 0x0080 = 8388607
        let expected = Data([0x0A, 0x03, 0x7F, 0xFF, 0xFF])
        expect(try 8_388_607.asn1encode(tag: .universal(.enumerated)).serialize()) == expected
    }

    func testInt_0x80_toASN1() {
        // 0x80 = -128
        let expected = Data([0x80])
        expect(try (-128).asn1encode(tag: nil).data.primitive) == expected
    }

    func testInt_0x0080_toASN1() {
        // tag::encodeSwiftPrimitives[]
        // 0x0080 = 128
        let expected = Data([0x00, 0x80])
        expect(try 128.asn1encode(tag: nil).data.primitive) == expected
        // end::encodeSwiftPrimitives[]
    }

    func testInt_0x7FFFFF_toASN1() {
        // 0x7FFFFF = 8388607
        let expected = Data([0x7F, 0xFF, 0xFF])
        expect { try 8_388_607.asn1encode(tag: nil).data.primitive } == expected
    }

    func testInt_min_32639_toASN1() {
        let expected = Data([0x80, 0x81])
        expect { try (-32639).asn1encode(tag: nil).data.primitive } == expected
    }

    func testInt_0xff78_toASN1() {
        // 0xff78 = -136
        let expected = Data([0xFF, 0x78])
        expect { try (-136).asn1encode(tag: nil).data.primitive } == expected
    }

    func testInt_0x800001_toASN1() {
        // 0x800001 = -8388607
        let expected = Data([0x80, 0x00, 0x01])
        expect { try (-8_388_607).asn1encode(tag: nil).data.primitive } == expected
    }

    func testMinInt_toASN1() {
        let size = MemoryLayout<Int>.size
        var bytes = [UInt8](repeating: 0x0, count: size)
        bytes[0] = 0x80
        let expected = Data(bytes)
        expect { try Int.min.asn1encode(tag: nil).data.primitive } == expected
    }

    func testMaxInt_toASN1() {
        // Test ASN1Integer Int.max
        let size = MemoryLayout<Int>.size
        var bytes = [UInt8](repeating: 0xFF, count: size)
        bytes[0] = 0x80 ^ bytes[0]
        let expected = Data(bytes)
        expect { try Int.max.asn1encode(tag: nil).data.primitive } == expected
    }

    func testUInt_0x0080_toASN1() {
        // tag::encodeSwiftPrimitives[]
        // 0x0080 = 128
        let expected = Data([0x00, 0x80])
        expect(try UInt(128).asn1encode(tag: nil).data.primitive) == expected
        // end::encodeSwiftPrimitives[]
    }

    func testUInt_0x7FFFFF_toASN1() {
        // 0x7FFFFF = 8388607
        let expected = Data([0x7F, 0xFF, 0xFF])
        expect { try UInt(8_388_607).asn1encode(tag: nil).data.primitive } == expected
    }

    func testMinUInt_toASN1() {
        // Test ASN1Integer UInt.min
        let expected = Data([0x00])
        expect { try UInt.min.asn1encode(tag: nil).data.primitive } == expected
    }

    func testMaxUInt_toASN1() {
        // Test ASN1Integer UInt.max
        let size = MemoryLayout<UInt>.size
        let bytes = [UInt8](repeating: 0xFF, count: size)
        let expected = Data([0x00] + bytes)
        expect { try UInt.max.asn1encode(tag: nil).data.primitive } == expected
    }

    static var allTests = [
        ("testEnumerated_toASN1", testEnumerated_toASN1),
        ("testInt_0x80_toASN1", testInt_0x80_toASN1),
        ("testInt_0x0080_toASN1", testInt_0x0080_toASN1),
        ("testInt_0x7FFFFF_toASN1", testInt_0x7FFFFF_toASN1),
        ("testInt_min_32639_toASN1", testInt_min_32639_toASN1),
        ("testInt_0xff78_toASN1", testInt_0xff78_toASN1),
        ("testInt_0x800001_toASN1", testInt_0x800001_toASN1),
        ("testMinInt_toASN1", testMinInt_toASN1),
        ("testMaxInt_toASN1", testMaxInt_toASN1),
        ("testUInt_0x0080_toASN1", testInt_0x0080_toASN1),
        ("testIInt_0x7FFFFF_toASN1", testInt_0x7FFFFF_toASN1),
        ("testMinUInt_toASN1", testMinUInt_toASN1),
        ("testMaxUInt_toASN1", testMaxUInt_toASN1),
    ]
}
