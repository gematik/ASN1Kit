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

import Foundation

@testable import ASN1Kit
import Nimble
import XCTest

final class ASN1ObjectExtEncodingTest: XCTestCase {
    func testASN1Encoding() {
        let bundle = Bundle(for: ASN1ObjectExtEncodingTest.self)
        guard let rawData = try? bundle.testResourceFilePath(in: "Resources", for: "asn1_decoder_test.der")
            .readFileContents() else {
            Nimble.fail("Could not read test data [Resources/asn1_decoder_test.der]")
            return
        }

        guard let obj = try? ASN1Decoder.decode(asn1: rawData) else {
            Nimble.fail("Could not decode [asn1_decoder_test.der]")
            return
        }

        expect { try obj.serialize() } == rawData
    }

    static var allTests = [
        ("testASN1Encoding", testASN1Encoding),
    ]
}
