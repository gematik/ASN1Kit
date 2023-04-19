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

class DataExtASN1EncodingTest: XCTestCase {
    func testDataEncoding() {
        let data = Data([0x0, 0x1, 0x2, 0x4])
        let expected = Data([0x4, 0x4, 0x0, 0x1, 0x2, 0x4])
        // test encoding
        expect(try data.asn1encode().serialize()) == expected

        // test decoding
        expect(try Data(from: ASN1Decoder.decode(asn1: expected))) == data
    }

    func testTaggedDataEncoding() {
        let data = Data([0x0, 0x1, 0x2, 0x4])
        // tag 95
        let expected = Data([0x5F, 0x5F, 0x4, 0x0, 0x1, 0x2, 0x4])

        // test encoding
        expect(try data.asn1encode(tag: .applicationTag(95)).serialize()) == expected

        // test decoding
        expect(try Data(from: ASN1Decoder.decode(asn1: expected))) == data
    }

    func testConstructedDataDecoding() {
        let data = Data([0x0, 0x1, 0x2, 0x4])
        let object = ASN1Primitive(
            data: .constructed(
                [ASN1Primitive(data: .primitive(data), tag: .universal(.octetString))]
            ),
            tag: .universal(.octetString)
        )

        expect(try Data(from: object)) == data
    }

    static var allTests = [
        ("testDataEncoding", testDataEncoding),
        ("testTaggedDataEncoding", testTaggedDataEncoding),
        ("testConstructedDataDecoding", testConstructedDataDecoding),
    ]
}
