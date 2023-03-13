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

class ASN1LengthEncodingTest: XCTestCase {
    func testASN1EncodeLength_short_notation() {
        let outputStream = OutputStreamBuffer(chunkSize: 10)

        expect(ASN1Primitive.write(length: 3, to: outputStream)) == 1

        let data = Data([0x3]) // length = 3
        expect(outputStream.buffer) == data
    }

    func testASN1EncodeLength_long_notation() {
        let outputStream = OutputStreamBuffer(chunkSize: 10)

        expect(ASN1Primitive.write(length: 435, to: outputStream)) == 3

        let data = Data([0x82, 0x01, 0xB3]) // length = 435
        expect(outputStream.buffer) == data
    }

    static var allTests = [
        ("testASN1EncodeLength_short_notation", testASN1EncodeLength_short_notation),
        ("testASN1EncodeLength_long_notation", testASN1EncodeLength_long_notation),
    ]
}
