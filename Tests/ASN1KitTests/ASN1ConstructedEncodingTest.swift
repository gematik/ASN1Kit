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

class ASN1ConstructedEncodingTest: XCTestCase {
    func testASN1EncodeTaggedConstructedTag() {
        // tag::encodeSwiftPrimitives2[]
        let data = Data([0x1, 0x2, 0x3, 0x4, 0x8])
        let tag1 = ASN1Primitive(data: .primitive(data), tag: .taggedTag(3)) // context-specific class tag
        let tag2 = ASN1Primitive(data: .primitive(data), tag: .universal(ASN1Tag.octetString))
        let implicitTag = ASN1Primitive(data: .constructed([tag1, tag2]), tag: .taggedTag(83))

        expect(implicitTag.data.items?.first?.tag) == .taggedTag(3)
        // end::encodeSwiftPrimitives2[]

        let output = OutputStreamBuffer(chunkSize: 20)
        expect(implicitTag.write(to: output)) == 17
        let expected = Data([0xBF, 0x53, 0xE]) + Data([0x83, 0x5]) + data + Data([0x4, 0x5]) + data
        expect(output.buffer) == expected

        expect(try ASN1Decoder.decode(asn1: output.buffer).asEquatable()) == implicitTag.asEquatable()
    }

    static var allTests = [
        ("testASN1EncodeTaggedPrimitiveTag", testASN1EncodeTaggedConstructedTag),
    ]
}
