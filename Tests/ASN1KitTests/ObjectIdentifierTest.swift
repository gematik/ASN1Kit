//
//  Copyright (c) 2019 gematik - Gesellschaft für Telematikanwendungen der Gesundheitskarte mbH
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//     http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

@testable import ASN1Kit
import Nimble
import XCTest

class ObjectIdentifierTest: XCTestCase {

    /// (OID as String, ASN1 Serialized format, also test backwards decoding)
    typealias EncodingTestCase = (String, Data, Bool)

    let invalidOIDs = ["-1.456.33", "3.2.124543", "0.-1", "1.002", "0", "1", "2",
                       "00001.0", "0.", "1.", "2.", "0.40", "1.40", "1.1.-30", "{}", "{1 -3}"]

    func testParsingInvalidOIDsParameterized() {
        invalidOIDs.forEach { oid in
            let errors = Nimble.gatherFailingExpectations(silently: true) {
                expect {
                    try ObjectIdentifier.from(string: oid)
                }.to(throwError(errorType: ASN1Error.self))
            }
            if !errors.isEmpty {
                Nimble.fail("OID (parsing): [\(oid)] should have failed!")
                errors.forEach { assertion in
                    Nimble.fail(String(describing: assertion))
                }
            }
        }
    }

    let encodingTests: [EncodingTestCase] = [
        ("2.100.3", Data(bytes: [0x6, 0x3, 0x81, 0x34, 0x3]), true),
        ("0.39", Data(bytes: [0x6, 0x1, 0x27]), true),
        ("1.0", Data(bytes: [0x6, 0x1, 0x28]), true),
        ("1.39", Data(bytes: [0x6, 0x1, 0x4f]), true),
        ("2.0", Data(bytes: [0x6, 0x1, 0x50]), true),
        ("2.39", Data(bytes: [0x6, 0x1, 0x77]), true),
        ("2.339", Data(bytes: [0x6, 0x2, 0x83, 0x23]), true),

        ("2.339.643", Data(bytes: [0x6, 0x4, 0x83, 0x23, 0x85, 0x03]), true),
        ("{2 339 643}", Data(bytes: [0x6, 0x4, 0x83, 0x23, 0x85, 0x03]), false),
        ("urn:oid:2.339.643", Data(bytes: [0x6, 0x4, 0x83, 0x23, 0x85, 0x03]), false),
        ("{iso(1) identified-organisation(3) dod(6) internet(1) private(4) enterprise(1)}",
                Data(bytes: [0x6, 0x5, 0x2b, 0x6, 0x1, 0x4, 0x1]), false),
        ("2.339.113549", Data(bytes: [0x6, 0x5, 0x83, 0x23, 0x86, 0xf7, 0x0d]), true),
        ("2.339.49152", Data(bytes: [0x6, 0x5, 0x83, 0x23, 0x83, 0x80, 0x0]), true),

        ("2.16.840.1.101.3.4.3.14", Data(bytes: [0x6, 0x9,
                                                 0x60, //2.16
                                                 0x86, 0x48, // 840
                                                 0x1, // 1
                                                 0x65, // 101
                                                 0x3, // 3
                                                 0x4, // 4
                                                 0x3, // 3
                                                 0xe  // 14
        ]), true),
        ("1.2.840.10045.4.3.2", Data(bytes: [0x6, 0x8,
                                             0x2A, // 1.2
                                             0x86, 0x48, // 840
                                             0xce, 0x3d, // 10045
                                             0x4, // 4
                                             0x3, // 3
                                             0x2 // 2
        ]), true)
    ]

    func testEncodingParameterized() {
        encodingTests.forEach { (testCase: EncodingTestCase) in
            let testName = testCase.0
            let errors = Nimble.gatherFailingExpectations(silently: true) {
                encodingTest(
                        oid: testCase.0,
                        expected: testCase.1
                )
            }
            if !errors.isEmpty {
                Nimble.fail("Test (encoding): [\(testName)] failed!")
                errors.forEach { assertion in
                    Nimble.fail(String(describing: assertion))
                }
            }
        }
    }

    func encodingTest(oid: String, expected asn1: Data) {
        expect {
            try ObjectIdentifier.from(string: oid).asn1encode(tag: nil).serialize()
        } == asn1
    }

    func testDecodingParameterized() {
        encodingTests.filter { $0.2 }.forEach { (testCase: EncodingTestCase) in
            let testName = testCase.0
            let errors = Nimble.gatherFailingExpectations(silently: true) {
                decodingTest(
                        oid: testCase.1,
                        expected: testCase.0
                )
            }
            if !errors.isEmpty {
                Nimble.fail("Test (decoding): [\(testName)] failed!")
                errors.forEach { assertion in
                    Nimble.fail(String(describing: assertion))
                }
            }
        }
    }

    func decodingTest(oid asn1: Data, expected oid: String) {
        expect {
            let decodedOID = try ASN1Decoder.decode(asn1: asn1)
            return try ObjectIdentifier(from: decodedOID).rawValue
        } == oid
    }

    static var allTests = [
        ("testEncodingParameterized", testEncodingParameterized),
        ("testDecodingParameterized", testDecodingParameterized),
        ("testParsingInvalidOIDsParameterized", testParsingInvalidOIDsParameterized)
    ]
}
