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

class ArrayExtASN1EncodingTest: XCTestCase {

    func testArrayEncoding() {
        let data = Data(bytes: [0x0, 0x1, 0x2, 0x4])
        let data2 = Data(bytes: [0x4, 0x3, 0x2, 0x1])
        let array: [ASN1EncodableType] = [data, data2]

        let expected = Data(bytes: [0x30, 0xc, 0x4, 0x4, 0x0, 0x1, 0x2, 0x4, 0x4, 0x4, 0x4, 0x3, 0x2, 0x1])
        expect {
            try array.asn1encode().serialize()
        } == expected

        expect {
            try Array(from: ASN1Decoder.decode(asn1: expected)).map(Data.asn1decoded)
        } == array as! [Data] //swiftlint:disable:this force_cast
    }

    static var allTests = [
        ("testArrayEncoding", testArrayEncoding)
    ]
}
