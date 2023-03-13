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

final class UIntExtTagNoTest: XCTestCase {
    func testTagNoLength() {
        let shortNo: UInt = 0x1E
        expect(shortNo.tagNoLength) == 1

        let longNo31: UInt = 0x1F
        expect(longNo31.tagNoLength) == 2

        let longNo: UInt = 76
        expect(longNo.tagNoLength) == 2

        let longNo127: UInt = 127
        expect(longNo127.tagNoLength) == 2

        let longNo128: UInt = 128
        expect(longNo128.tagNoLength) == 3

        let longNo255: UInt = 255
        expect(longNo255.tagNoLength) == 3

        let longNo256: UInt = 256
        expect(longNo256.tagNoLength) == 3
    }

    static var allTests = [
        ("testTagNoLength", testTagNoLength),
    ]
}
