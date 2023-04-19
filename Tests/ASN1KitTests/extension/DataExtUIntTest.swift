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

class DataExtUIntTest: XCTestCase {
    func testDataToUInt() {
        let bytes: [UInt8] = [0x40, 0x00, 0x00, 0x81]
        let data = Data(bytes)

        expect(data.unsignedIntValue) == 0x4000_0081
    }

    func testDataToUInt_min() {
        let bytes: [UInt8] = [0x0]
        let data = Data(bytes)

        expect(data.unsignedIntValue) == UInt.min
    }

    func testDataToUInt_max() {
        let uintSize = MemoryLayout<UInt>.size
        var data = Data()
        for _ in 0 ..< uintSize {
            data.append(Data([0xFF]))
        }

        expect(data.unsignedIntValue) == UInt.max
    }

    func testDataToUInt_overflow() {
        let uintSize = MemoryLayout<UInt>.size + 1
        var data = Data()
        for _ in 0 ..< uintSize {
            data.append(Data([0xFF]))
        }

        expect(data.unsignedIntValue).to(beNil())
    }

    static var allTests = [
        ("testDataToUInt", testDataToUInt),
        ("testDataToUInt_min", testDataToUInt_min),
        ("testDataToUInt_max", testDataToUInt_max),
        ("testDataToUInt_overflow", testDataToUInt_overflow),
    ]
}
