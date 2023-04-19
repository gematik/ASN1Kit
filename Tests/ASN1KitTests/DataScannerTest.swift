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

final class DataScannerTest: XCTestCase {
    func testDataScanner() {
        let data = Data([0x62, 0x82, 0x01, 0x34, 0x82, 0x01, 0x78, 0x83, 0x02, 0x3F, 0x00, 0x8A, 0x01, 0x05,
                         0x84, 0x07, 0xD2, 0x76, 0x00, 0x01, 0x44, 0x80, 0x00, 0xA1, 0x81, 0xD4, 0x91, 0x03])
        let scanner = DataScanner(data: data)

        expect(scanner.isComplete).to(beFalse())
        let subdata = scanner.scan(distance: 2)
        expect(scanner.isComplete).to(beFalse())
        expect(subdata) == Data([0x62, 0x82])

        let sub2 = scanner.scan(distance: 2)
        expect(scanner.isComplete).to(beFalse())
        expect(sub2) == Data([0x01, 0x34])

        let sub2end = scanner.scanToEnd()
        expect(scanner.isComplete).to(beTrue())
        expect(sub2end) == Data([0x82, 0x01, 0x78, 0x83, 0x02, 0x3F, 0x00, 0x8A, 0x01, 0x05, 0x84, 0x07,
                                 0xD2, 0x76, 0x00, 0x01, 0x44, 0x80, 0x00, 0xA1, 0x81, 0xD4, 0x91, 0x03])

        scanner.rollback(distance: 2)
        let sub3 = scanner.scan(distance: 1)
        expect(scanner.isComplete).to(beFalse())
        expect(sub3) == Data([0x91])

        let scanEnd = scanner.scanToEnd()
        expect(scanner.isComplete).to(beTrue())
        expect(scanEnd) == Data([0x03])

        /// Rollback all the way
        scanner.rollback(distance: data.count)
        expect(scanner.isComplete).to(beFalse())
        expect(scanner.scan(distance: 2)) == Data([0x62, 0x82])

        /// Rollback more than length
        scanner.rollback(distance: 1000)
        expect(scanner.isComplete).to(beFalse())
        expect(scanner.scan(distance: 2)) == Data([0x62, 0x82])
        expect(scanner.isComplete).to(beFalse())

        /// Scan 1 more than length
        let tooMuchData = scanner.scan(distance: data.count - 1)
        expect(scanner.isComplete).to(beFalse())
        expect(tooMuchData).to(beNil())

        let scanAfterwards = scanner.scan(distance: 1)
        expect(scanner.isComplete).to(beFalse())
        expect(scanAfterwards) == Data([0x01])
    }

    static var allTests = [
        ("testDataScanner", testDataScanner),
    ]
}
