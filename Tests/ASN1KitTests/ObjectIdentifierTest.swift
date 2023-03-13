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

class ObjectIdentifierTest: XCTestCase {
    /// (OID as String, ASN1 Serialized format, also test backwards decoding)
    typealias EncodingTestCase = (String, Data, Bool) // swiftlint:disable:this large_tuple

    let invalidOIDs = ["-1.456.33", "3.2.124543", "0.-1", "1.002", "0", "1", "2",
                       "00001.0", "0.", "1.", "2.", "0.40", "1.40", "1.1.-30", "{}", "{1 -3}"]

    func testParsingInvalidOIDsParameterized() {
        for oid in invalidOIDs {
            expect(try ObjectIdentifier.from(string: oid)).to(throwError())
            expect(try ObjectIdentifier(rawValue: oid)).to(beNil())
        }
    }

    let encodingTests: [EncodingTestCase] = [
        ("2.100.3", Data([0x6, 0x3, 0x81, 0x34, 0x3]), true),
        ("0.39", Data([0x6, 0x1, 0x27]), true),
        ("1.0", Data([0x6, 0x1, 0x28]), true),
        ("1.39", Data([0x6, 0x1, 0x4F]), true),
        ("2.0", Data([0x6, 0x1, 0x50]), true),
        ("2.39", Data([0x6, 0x1, 0x77]), true),
        ("2.339", Data([0x6, 0x2, 0x83, 0x23]), true),

        ("2.339.643", Data([0x6, 0x4, 0x83, 0x23, 0x85, 0x03]), true),
        ("{2 339 643}", Data([0x6, 0x4, 0x83, 0x23, 0x85, 0x03]), false),
        ("urn:oid:2.339.643", Data([0x6, 0x4, 0x83, 0x23, 0x85, 0x03]), false),
        ("{iso(1) identified-organisation(3) dod(6) internet(1) private(4) enterprise(1)}",
         Data([0x6, 0x5, 0x2B, 0x6, 0x1, 0x4, 0x1]), false),
        ("2.339.113549", Data([0x6, 0x5, 0x83, 0x23, 0x86, 0xF7, 0x0D]), true),
        ("2.339.49152", Data([0x6, 0x5, 0x83, 0x23, 0x83, 0x80, 0x0]), true),

        ("2.16.840.1.101.3.4.3.14", Data([0x6, 0x9,
                                          0x60, // 2.16
                                          0x86, 0x48, // 840
                                          0x1, // 1
                                          0x65, // 101
                                          0x3, // 3
                                          0x4, // 4
                                          0x3, // 3
                                          0xE, // 14
            ]), true),
        ("1.2.840.10045.4.3.2", Data([0x6, 0x8,
                                      0x2A, // 1.2
                                      0x86, 0x48, // 840
                                      0xCE, 0x3D, // 10045
                                      0x4, // 4
                                      0x3, // 3
                                      0x2, // 2
            ]), true),
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
        expect(try ObjectIdentifier.from(string: oid).asn1encode(tag: nil).serialize()) == asn1
        expect(try ObjectIdentifier(rawValue: oid)?.asn1encode(tag: nil).serialize()) == asn1
    }

    func testDecodingParameterized() {
        encodingTests.filter(\.2).forEach { (testCase: EncodingTestCase) in
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

    func testBrainpoolP256r1OID() throws {
        let asn1data = Data([0x06, 0x09, 0x2B, 0x24, 0x03, 0x03, 0x02, 0x08, 0x01, 0x01, 0x07])
        let expectedOid = try ObjectIdentifier.from(string: "1.3.36.3.3.2.8.1.1.7")
        expect(try ObjectIdentifier(from: ASN1Decoder.decode(asn1: asn1data))) == expectedOid
        expect { try expectedOid.asn1encode().serialize() } == asn1data
    }

    func testSecp256primev1OID() throws {
        let asn1data = Data([0x6, 0x8, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x03, 0x01, 0x07])
        let expectedOid = try ObjectIdentifier.from(string: "1 2 840 10045 3 1 7")
        expect(try ObjectIdentifier(from: ASN1Decoder.decode(asn1: asn1data))) == expectedOid
        expect { try expectedOid.asn1encode().serialize() } == asn1data
    }

    func testCreateSEC1ASN1PrivateKeyBrainpoolP256r1() throws {
        // swiftlint:disable line_length
        let asn1structure = create(tag: .universal(.sequence), data: ASN1Data.constructed([
            try (1 as Int).asn1encode(tag: nil),
            try Data(hex: "83456d98dea3435c166385a4e644ebca588e8a0aa7c811f51fcc736368630206").asn1encode(),
            try create(
                tag: .taggedTag(0x0),
                data: ASN1Data.constructed([ObjectIdentifier.from(string: "1.3.36.3.3.2.8.1.1.7").asn1encode()])
            ),
            try create(
                tag: .taggedTag(0x1),
                data: ASN1Data
                    .constructed(
                        [Data(
                            hex: "04ab68e9435dca456983930a62770461ac7f0c5e5dfc6d93032702e32131682480a21e1df599ccd1832037101def5926069de865ee48bbc3ed92da273efe935cc7"
                        )
                        .asn1bitStringEncode()]
                    )
            ),
        ]))

        let expectedSerializedKey =
            try Data(
                hex: "3078020101042083456D98DEA3435C166385A4E644EBCA588E8A0AA7C811F51FCC736368630206A00B06092B2403030208010107A14403420004AB68E9435DCA456983930A62770461AC7F0C5E5DFC6D93032702E32131682480A21E1DF599CCD1832037101DEF5926069DE865EE48BBC3ED92DA273EFE935CC7"
            )
        // swiftlint:enable line_length
        expect(try asn1structure.serialize()) == expectedSerializedKey
    }

    func decodingTest(oid asn1: Data, expected oid: String) {
        expect {
            let decodedOID = try ASN1Decoder.decode(asn1: asn1)
            return try ObjectIdentifier(from: decodedOID).rawValue
        } == oid
        expect {
            let decodedOID = try ASN1Decoder.decode(asn1: asn1)
            return try String(describing: ObjectIdentifier(from: decodedOID))
        } == oid
    }

    static var allTests = [
        ("testEncodingParameterized", testEncodingParameterized),
        ("testDecodingParameterized", testDecodingParameterized),
        ("testParsingInvalidOIDsParameterized", testParsingInvalidOIDsParameterized),
    ]
}
