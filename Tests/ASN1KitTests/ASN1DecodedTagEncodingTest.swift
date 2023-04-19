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
import DataKit
import GemCommonsKit
import Nimble
import XCTest

final class ASN1DecodedTagEncodingTest: XCTestCase {
    func testASN1EncodePrivateTag_shortNotation() {
        let outputStream = OutputStreamBuffer(chunkSize: 10)

        //
        // Test primitive private tag 0x0
        let tag = ASN1DecodedTag.privateTag(0x0)
        expect(tag.write(to: outputStream, constructed: false)) == 1
        let bytesWritten = outputStream.buffer
        let bytesExpected = Data([0xC0])

        expect(bytesWritten) == bytesExpected
        expect {
            try ASN1Decoder.decodeTagNumber(
                from: bytesWritten[0],
                with: DataScanner(data: Data())
            )
        } == tag
    }

    func testASN1EncodeApplicationTag_shortNotation() {
        let outputStream = OutputStreamBuffer(chunkSize: 10)

        //
        // Test Constructed Application tag 0x1E
        let tag = ASN1DecodedTag.applicationTag(0x1E)
        expect(tag.write(to: outputStream, constructed: true)) == 1
        let bytesWritten = outputStream.buffer
        let bytesExpected = Data([0x7E])

        expect(bytesWritten) == bytesExpected
        expect {
            try ASN1Decoder.decodeTagNumber(
                from: bytesWritten[0],
                with: DataScanner(data: Data())
            )
        } == tag
    }

    func testASN1EncodeApplicationTag_longNotation_0() {
        let outputStream = OutputStreamBuffer(chunkSize: 10)

        //
        // Test Constructed Application tag 0x0
        let tag = ASN1DecodedTag.applicationTag(0x0)
        expect(tag.write(to: outputStream, constructed: true)) == 1
        let bytesWritten = outputStream.buffer
        let bytesExpected = Data([0x60])

        expect(bytesWritten) == bytesExpected
        expect {
            try ASN1Decoder.decodeTagNumber(
                from: bytesWritten[0],
                with: DataScanner(data: Data())
            )
        } == tag
    }

    func testASN1EncodeApplicationTag_longNotation_1() {
        let outputStream = OutputStreamBuffer(chunkSize: 10)

        //
        // Test Constructed Application tag 0x1FF
        let tag = ASN1DecodedTag.applicationTag(0x1FF)
        expect(tag.write(to: outputStream, constructed: true)) == 3
        let bytesWritten = outputStream.buffer
        let bytesExpected = Data([0x7F, 0x83, 0x7F])

        expect(bytesWritten) == bytesExpected
        expect {
            try ASN1Decoder.decodeTagNumber(
                from: bytesWritten[0],
                with: DataScanner(data: bytesWritten.subdata(in: 1 ..< bytesWritten.count))
            )
        } == tag
    }

    func testASN1EncodeApplicationTag_longNotation_2() {
        let outputStream = OutputStreamBuffer(chunkSize: 10)
        //
        // Test Constructed Application tag 9747
        let tag = ASN1DecodedTag.applicationTag(9747)
        expect(tag.write(to: outputStream, constructed: true)) == 3
        let bytesWritten = outputStream.buffer
        let bytesExpected = Data([0x7F, 0xCC, 0x13])
        expect(bytesWritten) == bytesExpected
        expect {
            try ASN1Decoder.decodeTagNumber(
                from: bytesWritten[0],
                with: DataScanner(data: bytesWritten.subdata(in: 1 ..< bytesWritten.count))
            )
        } == tag
    }

    func testASN1EncodeApplicationTag_longNotation_3() {
        let outputStream = OutputStreamBuffer(chunkSize: 10)
        //
        // Test Constructed Application tag 0xFFFFFF
        let tag = ASN1DecodedTag.applicationTag(0xFFFFFF)
        expect(tag.write(to: outputStream, constructed: false)) == 5
        let bytesWritten = outputStream.buffer
        let bytesExpected = Data([0x5F, 0x87, 0xFF, 0xFF, 0x7F])
        expect(bytesWritten) == bytesExpected
        expect {
            try ASN1Decoder.decodeTagNumber(
                from: bytesWritten[0],
                with: DataScanner(data: bytesWritten.subdata(in: 1 ..< bytesWritten.count))
            )
        } == tag
    }

    func testASN1EncodeApplicationTag_longNotation_4() {
        let outputStream = OutputStreamBuffer(chunkSize: 10)
        //
        // Test Constructed Application tag 0xF7F7F7F7_7F7F7F7F
        let tag = ASN1DecodedTag.applicationTag(0xF7F7_F7F7_7F7F_7F7F)
        expect(tag.write(to: outputStream, constructed: false)) == 11
        let bytesWritten = outputStream.buffer
        let bytesExpected = Data([0x5F, 0x81, 0xF7, 0xFB, 0xFD, 0xFE, 0xF7, 0xFB, 0xFD, 0xFE, 0x7F])
        expect(bytesWritten) == bytesExpected
        expect {
            try ASN1Decoder.decodeTagNumber(
                from: bytesWritten[0],
                with: DataScanner(data: bytesWritten.subdata(in: 1 ..< bytesWritten.count))
            )
        } == tag
    }

    func testASN1EncodeApplicationTag_longNotation_5() {
        let outputStream = OutputStreamBuffer(chunkSize: 10)
        //
        // Test Constructed Application tag 127
        let tag = ASN1DecodedTag.applicationTag(127)
        expect(tag.write(to: outputStream, constructed: true)) == 2
        let bytesWritten = outputStream.buffer
        let bytesExpected = Data([0x7F, 0x7F])
        expect(bytesWritten) == bytesExpected
        expect {
            try ASN1Decoder.decodeTagNumber(
                from: bytesWritten[0],
                with: DataScanner(data: bytesWritten.subdata(in: 1 ..< bytesWritten.count))
            )
        } == tag
    }

    func testASN1EncodeApplicationTag_longNotation_6() {
        let outputStream = OutputStreamBuffer(chunkSize: 10)
        //
        // Test Constructed Application tag 128
        let tag = ASN1DecodedTag.applicationTag(128)
        expect(tag.write(to: outputStream, constructed: true)) == 3
        let bytesWritten = outputStream.buffer
        let bytesExpected = Data([0x7F, 0x81, 0x0])
        expect(bytesWritten) == bytesExpected
        expect {
            try ASN1Decoder.decodeTagNumber(
                from: bytesWritten[0],
                with: DataScanner(data: bytesWritten.subdata(in: 1 ..< bytesWritten.count))
            )
        } == tag
    }

    func testASN1EncodeApplicationTag_longNotation_7() {
        let outputStream = OutputStreamBuffer(chunkSize: 10)
        //
        // Test Constructed Application tag 255
        let tag = ASN1DecodedTag.applicationTag(255)
        expect(tag.write(to: outputStream, constructed: true)) == 3
        let bytesWritten = outputStream.buffer
        let bytesExpected = Data([0x7F, 0x81, 0x7F])
        expect(bytesWritten) == bytesExpected
        expect {
            try ASN1Decoder.decodeTagNumber(
                from: bytesWritten[0],
                with: DataScanner(data: bytesWritten.subdata(in: 1 ..< bytesWritten.count))
            )
        } == tag
    }

    func testASN1EncodeApplicationTag_longNotation_8() {
        let outputStream = OutputStreamBuffer(chunkSize: 10)
        //
        // Test Constructed Application tag 256
        let tag = ASN1DecodedTag.applicationTag(256)
        expect(tag.write(to: outputStream, constructed: true)) == 3
        let bytesWritten = outputStream.buffer
        let bytesExpected = Data([0x7F, 0x82, 0x0])
        expect(bytesWritten) == bytesExpected
        expect {
            try ASN1Decoder.decodeTagNumber(
                from: bytesWritten[0],
                with: DataScanner(data: bytesWritten.subdata(in: 1 ..< bytesWritten.count))
            )
        } == tag
    }

    func testASN1EncodeApplicationTag_longNotation_max() {
        let outputStream = OutputStreamBuffer(chunkSize: 20)

        //
        // Test Constructed Application tag 0xFFFFFFFF_FFFFFFFF
        expect(0xFFFF_FFFF_FFFF_FFFF) == UInt.max

        let tag = ASN1DecodedTag.applicationTag(0xFFFF_FFFF_FFFF_FFFF)
        expect(tag.write(to: outputStream, constructed: true)) == 11
        let bytesWritten = outputStream.buffer
        let bytesExpected = Data([0x7F, 0x81, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F])

        expect(bytesWritten) == bytesExpected
        expect {
            try ASN1Decoder.decodeTagNumber(
                from: bytesWritten[0],
                with: DataScanner(data: bytesWritten.subdata(in: 1 ..< bytesWritten.count))
            )
        } == tag
    }

    static var allTests = [
        ("testASN1EncodePrivateTag_shortNotation", testASN1EncodePrivateTag_shortNotation),
        ("testASN1EncodeApplicationTag_shortNotation", testASN1EncodeApplicationTag_shortNotation),
        ("testASN1EncodeApplicationTag_longNotation_0", testASN1EncodeApplicationTag_longNotation_0),
        ("testASN1EncodeApplicationTag_longNotation_1", testASN1EncodeApplicationTag_longNotation_1),
        ("testASN1EncodeApplicationTag_longNotation_2", testASN1EncodeApplicationTag_longNotation_2),
        ("testASN1EncodeApplicationTag_longNotation_3", testASN1EncodeApplicationTag_longNotation_3),
        ("testASN1EncodeApplicationTag_longNotation_4", testASN1EncodeApplicationTag_longNotation_4),
        ("testASN1EncodeApplicationTag_longNotation_5", testASN1EncodeApplicationTag_longNotation_5),
        ("testASN1EncodeApplicationTag_longNotation_6", testASN1EncodeApplicationTag_longNotation_6),
        ("testASN1EncodeApplicationTag_longNotation_7", testASN1EncodeApplicationTag_longNotation_7),
        ("testASN1EncodeApplicationTag_longNotation_8", testASN1EncodeApplicationTag_longNotation_8),
        ("testASN1EncodeApplicationTag_longNotation_max", testASN1EncodeApplicationTag_longNotation_max),
    ]
}
