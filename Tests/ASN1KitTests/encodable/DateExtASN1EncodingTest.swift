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

class DateExtASN1EncodingTest: XCTestCase {
    static let bundleName = "Resources"

    let bundle = Bundle(for: DateExtASN1EncodingTest.self)

    func resource(file: String) -> String {
        bundle.testResourceFilePath(in: DateExtASN1EncodingTest.bundleName, for: file)
    }

    // 1550832076 -> 02/22/2019 @ 10:41:16am (UTC)
    // 673573540  -> 05/06/1991 @ 11:45:48pm (UTC)
    // 673573540.301  -> 05/06/1991 @ 11:45:48.301pm (UTC)
    // 1604493908 -> 11/04/2020 @ 12:45:08pm (UTC)

    typealias TestCase = (String, String, Date, ASN1DecodedTag, Bool) // swiftlint:disable:this large_tuple
    static let tests: [TestCase] = [
        ("Test generalizedTime Z", "generalized_time_1991-05-06_23-45-40Z.der",
         Date(timeIntervalSince1970: 673_573_540), .universal(.generalizedTime), true),
        ("Test generalizedTime -0700", "generalized_time_1991-05-06_16-45-40-0700.der",
         Date(timeIntervalSince1970: 673_573_540), .universal(.generalizedTime), false),
        ("Test UTCTime Z", "utctime_91-05-06_23-45-40Z.der",
         Date(timeIntervalSince1970: 673_573_540), .universal(.utcTime), true),
        ("Test UTCTime -0700", "utctime_91-05-06_16-45-40-0700.der",
         Date(timeIntervalSince1970: 673_573_540), .universal(.utcTime), false),
        ("Test UTCTime Z 2019", "utctime_19-02-22_10-41-16Z.der",
         Date(timeIntervalSince1970: 1_550_832_076), .universal(.utcTime), true),
        ("Test UTCTime Z 2020", "utctime_20-11-04_12-45-08Z.der",
         Date(timeIntervalSince1970: 1_604_493_908), .universal(.utcTime), true),
        ("Test generalizedTime A", "A_generalized_time_1985-11-06_21-06-27.3.der",
         Date(timeIntervalSince1970: 500_159_187.3), .universal(.generalizedTime), false),
        ("Test generalizedTime B", "B_generalized_time_1985-11-06_21-06-27.3Z.der",
         Date(timeIntervalSince1970: 500_159_187.3), .universal(.generalizedTime), false),
        ("Test generalizedTime C", "C_generalized_time_1985-11-07_02-06-27.3-0500.der",
         Date(timeIntervalSince1970: 500_177_187.3), .universal(.generalizedTime), false),
        ("Test generalizedTime D", "D_generalized_time_1985-11-06_21-06.456.der",
         Date(timeIntervalSince1970: 500_159_187.36), .universal(.generalizedTime), false),
        ("Test generalizedTime E", "E_generalized_time_1985-11-06_21.14159.der",
         Date(timeIntervalSince1970: 500_159_309.724), .universal(.generalizedTime), false),
    ]

    func testParameterized() {
        DateExtASN1EncodingTest.tests.forEach { (testCase: TestCase) in
            let testName = testCase.0
            let errors = Nimble.gatherFailingExpectations(silently: true) {
                encodingTest(
                    fileName: testCase.1,
                    date: testCase.2,
                    tag: testCase.3,
                    also: testCase.4
                )
            }
            if !errors.isEmpty {
                Nimble.fail("Test: [\(testName)] failed!")
                errors.forEach { assertion in
                    Nimble.fail(String(describing: assertion))
                }
            }
        }
    }

    func encodingTest(fileName: String, date: Date, tag: ASN1DecodedTag, also encode: Bool = true) {
        let path = resource(file: fileName)
        guard let data = try? path.readFileContents() else {
            Nimble.fail("Could not read test data [Resources/\(fileName)]")
            return
        }

        if encode {
            expect(try date.asn1encode(tag: tag).serialize()) == data
        }
        expect {
            let data = try ASN1Decoder.decode(asn1: data)
            return try Date(from: data)
        } == date
    }

    static var allTests = [
        ("testParameterized", testParameterized),
    ]
}
