//
// Copyright (c) 2019 gematik GmbH
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

class BitStringASN1EncodingTest: XCTestCase {

    func testBitStringEncoding() {
        let string = "0A3B5F291CD"
        let expected = Data(bytes: [0x3, 0x7, 0x04, 0x0A, 0x3B, 0x5F, 0x29, 0x1C, 0xD0])

        // Encode
        expect {
            try string.bitString().serialize()
        } == expected

        // Decode
        expect {
            let asn1 = try ASN1Decoder.decode(asn1: expected)
            return try String(from: asn1)
        } == string
    }

    func testBitStringDecodingConstructed() {
        let expected = "0A3B5F291CD"
        let serialized = Data(bytes: [0x23, 0xc, 0x3, 0x3, 0x0, 0x0A, 0x3B, 0x3, 0x5, 0x4, 0x5F, 0x29, 0x1C, 0xD0])

        expect {
            let asn1 = try ASN1Decoder.decode(asn1: serialized)
            return try String(from: asn1)
        } == expected
    }

    func testBitStringDecodingConstructed_2() {
        let expected = "0B0B0"
        let serialized = Data(bytes: [0x23, 0x0C,
                                      0x03, 0x02, 0x00, 0x0B,
                                      0x03, 0x02, 0x00, 0x0B,
                                      0x03, 0x02, 0x04, 0x0F])
        expect {
            let asn1 = try ASN1Decoder.decode(asn1: serialized)
            return try String(from: asn1)
        } == expected
    }

    static var allTests = [
        ("testBitStringEncoding", testBitStringEncoding),
        ("testBitStringDecodingConstructed", testBitStringDecodingConstructed),
        ("testBitStringDecodingConstructed_2", testBitStringDecodingConstructed_2)
    ]
}
