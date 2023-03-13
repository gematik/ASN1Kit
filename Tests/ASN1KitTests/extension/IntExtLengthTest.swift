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

final class IntExtLengthTest: XCTestCase {
    func testLengthSize() {
        let short = 100
        expect(short.lengthSize) == 1

        let long = 0xFA
        expect(long.lengthSize) == 2

        let veryLong = 0xEE45
        expect(veryLong.lengthSize) == 3
    }

    static var allTests = [
        ("testLengthSize", testLengthSize),
    ]
}
