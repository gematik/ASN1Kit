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

class BitStringASN1EncodingTest: XCTestCase {
    func testBitStringEncoding() {
        let expected = Data([0x03, 0x04, 0x03, 0xB, 0xB, 0xF8])
        let bitString = Data([0xB, 0xB, 0xFF])

        expect(try bitString.asn1bitStringEncode(unused: 3).serialize()) == expected
    }

    func testBitStringEncodingNoUnused() {
        let expected = Data([0x03, 0x04, 0x00, 0xB, 0xB, 0xFF])
        let bitString = Data([0xB, 0xB, 0xFF])

        expect(try bitString.asn1bitStringEncode().serialize()) == expected
    }

    func testBitStringDecodingPrimitive() {
        let serialized = Data([0x03, 0x04, 0x04, 0xB, 0xB, 0x0F])
        let expected = Data([0xB, 0xB, 0x0])

        expect(try Data(from: ASN1Decoder.decode(asn1: serialized))) == expected
    }

    func testBitStringDecodingConstructed() {
        // tag::decodeSerializedData[]
        let expected = Data([0xB, 0xB, 0x0])
        let serialized = Data([0x23, 0x0C,
                               0x03, 0x02, 0x00, 0x0B,
                               0x03, 0x02, 0x00, 0x0B,
                               0x03, 0x02, 0x04, 0x0F])
        expect(try Data(from: ASN1Decoder.decode(asn1: serialized))) == expected
        // end::decodeSerializedData[]
    }

    static var allTests = [
        ("testBitStringEncoding", testBitStringEncoding),
        ("testBitStringEncodingNoUnused", testBitStringEncodingNoUnused),
        ("testBitStringDecodingPrimitive", testBitStringDecodingPrimitive),
        ("testBitStringDecodingConstructed", testBitStringDecodingConstructed),
    ]
}
