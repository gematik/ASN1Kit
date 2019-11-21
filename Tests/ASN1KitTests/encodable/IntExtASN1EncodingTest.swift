//
// Copyright (c) 2019 gematik - Gesellschaft für Telematikanwendungen der Gesundheitskarte mbH
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

@testable import ASN1Kit
import Nimble
import XCTest

// https://www.strozhevsky.com/free_docs/asn1_by_simple_words.pdf
final class IntExtASN1EncodingTest: XCTestCase {
    func testInt_0x80_toASN1() {
        //0x80 = -128
        let expected = Data(bytes: [0x80])
        expect {
            try (-128).asn1encode(tag: nil).data.primitive
        } == expected
    }

    func testInt_0x0080_toASN1() {
        //0x0080 = 128
        let expected = Data(bytes: [0x00, 0x80])
        expect {
            try 128.asn1encode(tag: nil).data.primitive
        } == expected
    }

    func testInt_0x7FFFFF_toASN1() {
        //0x7FFFFF = 8388607
        let expected = Data(bytes: [0x7F, 0xFF, 0xFF])
        expect { try 8388607.asn1encode(tag: nil).data.primitive } == expected
    }

    func testInt_min_32639_toASN1() {
        let expected = Data(bytes: [0x80, 0x81])
        expect { try (-32639).asn1encode(tag: nil).data.primitive } == expected
    }

    func testInt_0xff78_toASN1() {
        //0xff78 = -136
        let expected = Data(bytes: [0xff, 0x78])
        expect { try (-136).asn1encode(tag: nil).data.primitive } == expected
    }

    func testInt_0x800001_toASN1() {
        //0x800001 = -8388607
        let expected = Data(bytes: [0x80, 0x00, 0x01])
        expect { try (-8388607).asn1encode(tag: nil).data.primitive } == expected
    }

    func testMinInt_toASN1() {
        let size = MemoryLayout<Int>.size
        var bytes = [UInt8](repeating: 0x0, count: size)
        bytes[0] = 0x80
        let expected = Data(bytes: bytes)
        expect { try Int.min.asn1encode(tag: nil).data.primitive } == expected
    }

    func testMaxInt_toASN1() {
        // Test ASN1Integer Int.max
        let size = MemoryLayout<Int>.size
        var bytes = [UInt8](repeating: 0xff, count: size)
        bytes[0] = 0x80 ^ bytes[0]
        let expected = Data(bytes: bytes)
        expect { try Int.max.asn1encode(tag: nil).data.primitive } == expected
    }

    static var allTests = [
        ("testInt_0x80_toASN1", testInt_0x80_toASN1),
        ("testInt_0x0080_toASN1", testInt_0x0080_toASN1),
        ("testInt_0x7FFFFF_toASN1", testInt_0x7FFFFF_toASN1),
        ("testInt_min_32639_toASN1", testInt_min_32639_toASN1),
        ("testInt_0xff78_toASN1", testInt_0xff78_toASN1),
        ("testInt_0x800001_toASN1", testInt_0x800001_toASN1),
        ("testMinInt_toASN1", testMinInt_toASN1),
        ("testMaxInt_toASN1", testMaxInt_toASN1)
    ]
}
