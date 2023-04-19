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

import XCTest

#if !os(macOS) && !os(iOS)
/// Run all ASN1Kit tests
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(IntExtLengthTest.allTests),
        testCase(ASN1DecoderTest.allTests),
        testCase(DataExtASN1IntTest.allTests),
        testCase(DataScannerTest.allTests),
        testCase(DataExtUIntTest.allTests),
        testCase(IntExtLengthTest.allTests),
        testCase(UIntExtTagNoTest.allTests),
        testCase(ASN1ObjectExtEncodingTest.allTests),
        testCase(ASN1DecodedTagEncodingTest.allTests),
        testCase(ASN1LengthEncodingTest.allTests),
        testCase(ASN1PrimitiveEncodingTest.allTests),
        testCase(ASN1ConstructedEncodingTest.allTests),
        testCase(ArrayExtASN1EncodingTest.allTests),
        testCase(DataExtASN1EncodingTest.allTests),
        testCase(StringExtASN1EncodingTest.allTest),
        testCase(DateExtASN1EncodingTest.allTests),
        testCase(BoolExtASN1EncodingTest.allTests),
        testCase(BitStringASN1EncodingTest.allTests),
        testCase(ObjectIdentifierTest.allTests),
        testCase(IntExtASN1EncodingTest.allTests),
    ]
}
#endif
