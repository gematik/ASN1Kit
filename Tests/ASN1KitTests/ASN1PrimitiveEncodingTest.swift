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
import Foundation
import Nimble
import XCTest

class ASN1PrimitiveEncodingTest: XCTestCase {
    func testASN1EncodePrimitiveTag() {
        let data = Data([0x1, 0x2, 0x3, 0x4, 0x8])
        let tag = ASN1Primitive(data: .primitive(data), tag: .universal(ASN1Tag.octetString))

        let output = OutputStreamBuffer(chunkSize: 10)
        expect(tag.write(to: output)) == 7
        let expected = Data([0x4, 0x5]) + data
        expect(output.buffer) == expected
    }

    func testASN1EncodeTaggedPrimitiveTag() {
        let data = Data([0x1, 0x2, 0x3, 0x4, 0x8])
        let implicitTag = ASN1Primitive(data: .primitive(data), tag: .taggedTag(3))

        let output = OutputStreamBuffer(chunkSize: 10)
        expect(implicitTag.write(to: output)) == 7
        let expected = Data([0x83, 0x5]) + data
        expect(output.buffer) == expected

        expect(try ASN1Decoder.decode(asn1: output.buffer).asEquatable()) == implicitTag.asEquatable()
        expect(try ASN1Decoder.decode(asn1: output.buffer).originalEncoding) == expected
    }

    static var allTests = [
        ("testASN1EncodePrimitiveTag", testASN1EncodePrimitiveTag),
        ("testASN1EncodeTaggedPrimitiveTag", testASN1EncodeTaggedPrimitiveTag),
    ]
}
