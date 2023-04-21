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

class ArrayExtASN1EncodingTest: XCTestCase {
    func testArrayEncoding() {
        // tag::constructAndEncode[]
        let data = Data([0x0, 0x1, 0x2, 0x4]) as ASN1EncodableType
        let data2 = Data([0x4, 0x3, 0x2, 0x1]) as ASN1EncodableType
        let array = [data, data2]

        let expected = Data([0x30, 0xC, 0x4, 0x4, 0x0, 0x1, 0x2, 0x4, 0x4, 0x4, 0x4, 0x3, 0x2, 0x1])
        expect(try array.asn1encode().serialize()) == expected
        // end::constructAndEncode[]

        expect(try Array(from: ASN1Decoder.decode(asn1: expected)).map(Data.asn1decoded)) == array as? [Data]
    }

    static var allTests = [
        ("testArrayEncoding", testArrayEncoding),
    ]
}
