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

class BoolExtASN1EncodingTest: XCTestCase {
    func testBoolEncodingTrue() {
        let expected = Data([0x1, 0x1, 0xFF])
        // test encoding
        expect(try (true as Bool).asn1encode().serialize()) == expected

        // test decoding
        expect(try Bool(from: ASN1Decoder.decode(asn1: expected))) == true
    }

    func testBoolEncodingFalse() {
        let expected = Data([0x1, 0x1, 0x0])
        // test encoding
        expect(try (false as Bool).asn1encode().serialize()) == expected

        // test decoding
        expect(try Bool(from: ASN1Decoder.decode(asn1: expected))) == false
    }

    func testBoolDecoding() {
        /// (DER encoded, Expected Bool)
        var tests = [(Data, Bool)]()
        tests.append((Data([0x1, 0x1, 0x0]), false))
        for idx in 1 ... 0xFF {
            tests.append((Data([0x1, 0x1, UInt8(idx & 0xFF)]), true))
        }

        tests.forEach { test in
            expect {
                let asn1 = try ASN1Decoder.decode(asn1: test.0)
                return try Bool(from: asn1)
            } == test.1
        }
    }

    static var allTests = [
        ("testBoolEncodingTrue", testBoolEncodingTrue),
        ("testBoolEncodingFalse", testBoolEncodingFalse),
        ("testBoolDecoding", testBoolDecoding),
    ]
}
