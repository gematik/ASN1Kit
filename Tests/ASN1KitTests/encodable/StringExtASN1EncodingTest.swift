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

class StringExtASN1EncodingTest: XCTestCase {
    let bundle = Bundle(for: StringExtASN1EncodingTest.self)

    static let bundleName = "Resources"
    static let asciiText = "\0 01234567890\tabcdefghijklmnopqrstuvwxyz" +
        " ABCDEFGHIJKLMNOPQRSTUVWXYZ \n\r []{}`\"!@#$%^&*()_+=/\\>.,< ~;:"

    func testStringASCIIEncoding() {
        let path = bundle.testResourceFilePath(in: StringExtASN1EncodingTest.bundleName, for: "ascii_text.txt.der")
        guard let data = try? path.readFileContents() else {
            Nimble.fail("Could not read test data [Resources/ascii_text.txt.der]")
            return
        }

        expect(try StringExtASN1EncodingTest.asciiText.asn1encode(tag: .universal(.ia5String)).serialize()) == data

        let nonAscii = "🔔⬇️🛂🐱😂"
        expect(try nonAscii.asn1encode(tag: .universal(.ia5String)).serialize())
            .to(throwError(errorType: ASN1Error.self))
    }

    func testStringASCIIDecoding() {
        let path = bundle.testResourceFilePath(in: StringExtASN1EncodingTest.bundleName, for: "ascii_text.txt.der")
        guard let data = try? path.readFileContents() else {
            Nimble.fail("Could not read test data [Resources/ascii_text.txt.der]")
            return
        }

        expect {
            let asn1object = try ASN1Decoder.decode(asn1: data)
            return try String(from: asn1object)
        } == StringExtASN1EncodingTest.asciiText
    }

    // swiftlint:disable:next large_tuple
    typealias TestCase = (String, String, String, ASN1DecodedTag, String.Encoding)

    static let tests: [TestCase] = [
        ("UTF8 to ASN.1 Test", "text.utf8.txt.der", "text.utf8.txt", .universal(.utf8String), .utf8),
        ("UTF16 to ASN.1 Test", "text.utf16BE.txt.der", "text.utf16BE.txt", .universal(.bmpString), .utf16BigEndian),
        ("UTF32 to ASN.1 Test", "text.utf32BE.txt.der", "text.utf32BE.txt", .universal(.universalString),
         .utf32BigEndian),
        ("UTF8 (special) to ASN.1 Test", "special.utf8.txt.der", "special.utf8.txt", .universal(.utf8String), .utf8),
        ("UTF16 (special) to ASN.1 Test", "special.utf16BE.txt.der", "special.utf16BE.txt", .universal(.bmpString),
         .utf16BigEndian),
        ("UTF32 (special) to ASN.1 Test", "special.utf32BE.txt.der", "special.utf32BE.txt",
         .universal(.universalString), .utf32BigEndian),
    ]

    func testParameterized() {
        StringExtASN1EncodingTest.tests.forEach { (testCase: TestCase) in
            let testName = testCase.0
            let errors = Nimble.gatherFailingExpectations(silently: true) {
                encodingTest(
                    encodedFileName: testCase.1,
                    contentsFileName: testCase.2,
                    tag: testCase.3,
                    encoding: testCase.4
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

    func encodingTest(encodedFileName: String, contentsFileName: String, tag: ASN1DecodedTag, encoding: String.Encoding,
                      bundleName: String = StringExtASN1EncodingTest.bundleName) {
        let encodedFilePath = bundle.testResourceFilePath(in: bundleName, for: encodedFileName)
        let contentsFilePath = bundle.testResourceFilePath(in: bundleName, for: contentsFileName)
        guard let encodedData = try? encodedFilePath.readFileContents(),
              let stringData = try? contentsFilePath.readFileContents(),
              let string = String(data: stringData, encoding: encoding)
        else {
            Nimble.fail("Could not read test data [\(bundleName)/\(encodedFileName)] " +
                "or [\(bundleName)/\(contentsFileName)]")
            return
        }

        expect(try string.asn1encode(tag: tag).serialize()) == encodedData

        expect {
            let asn1object = try ASN1Decoder.decode(asn1: encodedData)
            return try String(from: asn1object)
        } == string
    }

    static var allTests = [
        ("testStringASCIIEncoding", testStringASCIIEncoding),
        ("testStringASCIIDecoding", testStringASCIIDecoding),
        ("testParameterized", testParameterized),
    ]
}
