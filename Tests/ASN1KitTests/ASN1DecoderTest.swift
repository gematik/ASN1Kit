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
import GemCommonsKit
import Nimble
import XCTest

final class ASN1DecoderTest: XCTestCase { // swiftlint:disable:this type_body_length
    func testASN1Decoder() {
        let bundle = Bundle(for: ASN1DecoderTest.self)
        guard let rawData = try? bundle.testResourceFilePath(in: "Resources", for: "asn1_decoder_test.der")
            .readFileContents() else {
            Nimble.fail("Could not read test data [Resources/asn1_decoder_test.der]")
            return
        }

        guard let asn1object = try? ASN1Decoder.decode(asn1: rawData) else {
            Nimble.fail("Could not decode [asn1_decoder_test.der]")
            return
        }

        expect(asn1object.length) == rawData.count - 4 // subtract 4 for tag and length bytes
        expect(asn1object.tag) == ASN1DecodedTag.applicationTag(2)
        expect(asn1object.tag.isApplicationSpecific) == true
        expect(asn1object.tag.isContextSpecific) == false
        expect(asn1object.tag.isUniversal) == false
        expect(asn1object.data.constructed).to(beTrue())
        expect(asn1object.constructed).to(beTrue())
        expect(asn1object.data.items).to(haveCount(6))
    }

    func testASN1DecodeLength_short_notation() {
        let data = Data([0x3]) // length = 3
        let scanner = DataScanner(data: data)
        expect(try ASN1Decoder.decodeLength(from: scanner)) == 3
    }

    func testASN1DecodeLength_long_notation() {
        let data = Data([0x82, 0x01, 0xB3]) // length = 435
        let scanner = DataScanner(data: data)
        expect(try ASN1Decoder.decodeLength(from: scanner)) == 435
    }

    func testASN1DecodeLength_indefinite() {
        let data = Data([0x80, 0x01, 0xB3]) // length = infinite (0x80)
        let scanner = DataScanner(data: data)
        expect(try ASN1Decoder.decodeLength(from: scanner)) == -1
    }

    func testASN1DecodeLength_too_long_notation() {
        // When length is bigger than UInt.size expect (unsupported) exception
        let maxSize = MemoryLayout<UInt>.size
        let lengthByte = 0x80 | UInt8(maxSize + 1)

        let data = Data([lengthByte, 0x01, 0xB3, 0xFF, 0xE1, 0x10, 0x9, 0x8, 0x7, 0x6]) // length = too long for UInt
        let scanner = DataScanner(data: data)
        expect(try ASN1Decoder.decodeLength(from: scanner)).to(throwError(ASN1Error.unsupported(
            "Length data invalid(/too long): [0x\(data[1 ..< data.count].hexString())]"
        )))
    }

    func testASN1DecodeTagNumber_applicationTag_1() {
        // Application tag 0x2
        let data = Data([0x82, 0x01, 0x34]) // tag should be 0x2
        expect(try ASN1Decoder.decodeTagNumber(from: 0x62, with: DataScanner(data: data))) == .applicationTag(0x2)
    }

    func testASN1DecodeTagNumber_applicationTag_2() {
        // Application tag 0x11
        let data = Data([0x04, 0x3F, 0xFF, 0x2F, 0x06])
        expect(try ASN1Decoder.decodeTagNumber(from: 0x51, with: DataScanner(data: data))) == .applicationTag(0x11)
    }

    func testASN1DecodeTagNumber_taggedObject_1() {
        // Tagged object
        let data = Data([0x03, 0x01, 0x05, 0x01])
        expect(try ASN1Decoder.decodeTagNumber(from: 0x91, with: DataScanner(data: data))) == .taggedTag(0x11)
    }

    func testASN1DecodeTagNumber_taggedObject_2() {
        // Tagged object
        let data = Data([0x81, 0x83])
        expect(try ASN1Decoder.decodeTagNumber(from: 0xAB, with: DataScanner(data: data))) == .taggedTag(11)
    }

    func testASN1DecodeTagNumber_universalTag() {
        // Universal tagged object
        let data = Data([0x81, 0x83])
        expect(try ASN1Decoder.decodeTagNumber(from: 0x10, with: DataScanner(data: data)))
            == .universal(ASN1Tag.sequence)
    }

    func testASN1DecodeTagNumber_privateTag() {
        let data = Data([0x3, 0x2, 0x1, 03])
        let scanner = DataScanner(data: data)
        expect(try ASN1Decoder.decodeTagNumber(from: 0xCD, with: scanner)) == .privateTag(0xD)
    }

    func testASN1DecodeTagNumber_long() {
        // Application specific object
        let data = Data([0x4C, 0x13])
        expect(try ASN1Decoder.decodeTagNumber(from: 0x7F, with: DataScanner(data: data))) == .applicationTag(76)
    }

    func testASN1DecodeTagNumber_longer() {
        // Application specific object
        let data = Data([0xCC, 0x13])
        expect(try ASN1Decoder.decodeTagNumber(from: 0x7F, with: DataScanner(data: data))) == .applicationTag(9747)
    }

    func testASN1DecodeTagNumber_too_long() {
        // Test tagNo larger than UInt.size
        let size = Int(ceil(Double(MemoryLayout<UInt>.size * 8) / 7.0)) + 1
        var bytes = [UInt8](repeating: 0x0, count: size)
        for idx in 0 ..< size - 1 {
            bytes[idx] = 0x80 | UInt8(idx + 1)
        }
        let data = Data(bytes)

        expect(try ASN1Decoder.decodeTagNumber(from: 0x7F, with: DataScanner(data: data)))
            .to(throwError(ASN1Error.unsupported("ASN1Decoder bounced on too big Tag number (> UInt.max)")))
    }

    func testASN1DecodeTagNumber_unsupported_long_notation() {
        // Universal tag with 0x1f > tagNr
        let data = Data([0x1D, 0x2, 0x2, 0x1])
        let scanner = DataScanner(data: data)

        expect(try ASN1Decoder.decodeTagNumber(from: 0x1F, with: scanner))
            .to(throwError(ASN1Error.malformedEncoding("Tag value is invalid: [0x1d]")))
    }

    func testASN1DecodeTagNumber_Bool() {
        // Primitive Bool
        let data = Data([0x1, 0xFF])
        expect(try ASN1Decoder.decodeTagNumber(from: 0x1, with: DataScanner(data: data)))
            == .universal(ASN1Tag.boolean)
    }

    func testASN1DecodeTagNumber_Integer() {
        // Primitive Integer
        let data = Data([0x3, 0x3, 0xD4, 0xFF])
        expect(try ASN1Decoder.decodeTagNumber(from: 0x2, with: DataScanner(data: data)))
            == .universal(ASN1Tag.integer)
    }

    func testASN1DecodeTagNumber_IA5String() {
        // Primitive IA5String
        let data = Data([0x5, 0x53, 0x6D, 0x69, 0x74, 0x68]) // "Smith"
        expect(try ASN1Decoder.decodeTagNumber(from: 0x16, with: DataScanner(data: data)))
            == .universal(ASN1Tag.ia5String)
    }

    func testASN1DecodeTagNumber_OctetString_constructed() {
        // Constructed OctetString
        let data = Data([0x7, 0x4, 0x5, 0x53, 0x6D, 0x69, 0x74, 0x68]) // Constructed Octet "536D697468"
        expect(try ASN1Decoder.decodeTagNumber(from: 0x24, with: DataScanner(data: data)))
            == .universal(ASN1Tag.octetString)
    }

    func testASN1DecodeTagNumber_OctetString() {
        // Primitive OctetString
        let data = Data([0x5, 0x53, 0x6D, 0x69, 0x74, 0x68]) // Octet "536D697468"
        expect(try ASN1Decoder.decodeTagNumber(from: 0x4, with: DataScanner(data: data)))
            == .universal(ASN1Tag.octetString)
    }

    func testASN1DecodeTagNumber_Sequence() {
        // Constructed Sequence
        // Seq (
        //  Integer 132
        //  IA5String "Hello"
        // )
        let data = Data([0x6, 0x2, 0x1, 0x84, 0x16, 0x5, 0x48, 0x65, 0x6C, 0x6C, 0x6F])
        expect(try ASN1Decoder.decodeTagNumber(from: 0x30, with: DataScanner(data: data)))
            == .universal(ASN1Tag.sequence)
    }

    func testASN1DecodeTagNumber_Set() {
        // Constructed Set
        // Set (
        //  [1] IMPLICIT Integer 105
        //  [2] IMPLICIT Bool false
        // )
        let data = Data([0x6, 0x81, 0x1, 0x69, 0x82, 0x1, 0x0])
        expect(try ASN1Decoder.decodeTagNumber(from: 0x31, with: DataScanner(data: data)))
            == .universal(ASN1Tag.set)
    }

    func testASN1DecodeIndefiniteLengthObject() {
        // expect exception for now - unsupported
        let data = Data([0x6, 0x80, 0x40, 0x20, 0x50, 0x0, 0x0])
        expect(try ASN1Decoder.decode(asn1: data))
            .to(throwError(ASN1Error.unsupported("BER indefinite length encoding is unsupported")))
    }

    func testASN1DecodeConstructedObject() {
        let data = Data([0xA2, 0x7, 0x43, 0x5, 0x4A, 0x6F, 0x6E, 0x65, 0x73])
        guard let asn1 = try? ASN1Decoder.decode(asn1: data) else {
            Nimble.fail("Could not decode Constructed object")
            return
        }
        expect(asn1.tag) == ASN1DecodedTag.taggedTag(2)
        expect(asn1.tagNo) == 2
        expect(asn1.tag.isContextSpecific) == true
        expect(asn1.tag.isApplicationSpecific) == false
        expect(asn1.tag.isUniversal) == false
        expect(asn1.constructed).to(beTrue())
        expect(asn1.length) == data.count - 2 // subtract 2 for tag and length bytes
        if case let .constructed(items) = asn1.data {
            let implicitObject = items[0]
            // Tagged non-constructed object is implicitly an Octet String
            expect(implicitObject.tag) == .applicationTag(0x3)
            expect(implicitObject.tagNo) == 3
            expect(implicitObject.length) == 5
            expect(implicitObject.constructed).to(beFalse())
            expect(implicitObject.data).to(equalASN1(.primitive(Data([0x4A, 0x6F, 0x6E, 0x65, 0x73]))))
        } else {
            Nimble.fail("No Constructed items")
            return
        }
    }

    func testASN1DecodeTaggedNull() {
        // implicit null
        let expected: ASN1Object = ASN1Primitive(
            data: .primitive(Data.empty),
            tag: ASN1DecodedTag.taggedTag(0x15)
        )

        let data = Data([0x95, 0x0])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodeTaggedNull_long() {
        // implicit null
        let expected: ASN1Object = ASN1Primitive(data: .primitive(Data.empty), tag: .taggedTag(0x45))

        let data = Data([0x9F, 0x45, 0x0])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodeTaggedImplicit() {
        // implicit octetString
        let octets = Data([0x45, 0xEE, 0x3E, 0x4])
        let expected: ASN1Object = ASN1Primitive(data: .primitive(octets), tag: .taggedTag(0x1))

        let data = Data([0x81, 0x4]) + octets
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodeTaggedImplicit_long() {
        // implicit octetString
        let octets = Data([0x45, 0xEE, 0x3E, 0x4])
        let expected: ASN1Object = ASN1Primitive(data: .primitive(octets), tag: .taggedTag(0x22C5))

        let data = Data([0x9F, 0xC5, 0x45, 0x4]) + octets
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodeTaggedConstructed() {
        // SET {name IA5String, ok BOOLEAN}
        let items = [
            ASN1Primitive(
                data: .primitive(Data([0x53, 0x6D, 0x69, 0x74, 0x68])),
                tag: .universal(.ia5String)
            ),
            ASN1Primitive(data: .primitive(Data([0xFF])), tag: .universal(.boolean)),
        ]
        let expected = ASN1Primitive(data: .constructed(items), tag: .taggedTag(0x18))
        let data = Data([0xB8, 0xA, 0x16, 0x5, 0x53, 0x6D, 0x69, 0x74, 0x68, 0x1, 0x1, 0xFF])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodeTaggedConstructed_long() {
        // SET {name IA5String, ok BOOLEAN}
        let items = [
            ASN1Primitive(
                data: .primitive(Data([0x53, 0x6D, 0x69, 0x74, 0x68])),
                tag: .universal(.ia5String)
            ),
            ASN1Primitive(data: .primitive(Data([0xFF])), tag: .universal(.boolean)),
        ]
        let expected = ASN1Primitive(data: .constructed(items), tag: .taggedTag(0x3F79))
        let data = Data([0xBF, 0xFE, 0x79, 0xA, 0x16, 0x5, 0x53, 0x6D, 0x69, 0x74, 0x68, 0x1, 0x1, 0xFF])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodePrimitiveBool() {
        let expected: ASN1Object = ASN1Primitive(data: .primitive(Data([0xFF])), tag: .universal(.boolean))

        let data = Data([0x1, 0x1, 0xFF])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodePrimitiveIA5String() {
        let expected = ASN1Primitive(
            data: .primitive(Data([0x48, 0x65, 0x6C, 0x6C, 0x6F])),
            tag: .universal(.ia5String)
        )
        let data = Data([0x16, 0x5, 0x48, 0x65, 0x6C, 0x6C, 0x6F])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodePrimitiveInteger() {
        // https://www.strozhevsky.com/free_docs/asn1_by_simple_words.pdf
        // 0x80 = -128
        // 0x0080 = 128
        // 0x7FFFFF = 8388607
        // 0xff78 = -136
        // 0x800001 = -8388607

        let expected = ASN1Primitive(
            data: .primitive(Data([0x1, 0xD5, 0x80])),
            tag: .universal(.integer)
        )
        let data = Data([0x2, 0x3, 0x1, 0xD5, 0x80])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
        expect(expected.tag.isUniversal) == true
        expect(expected.tag.isApplicationSpecific) == false
        expect(expected.tag.isContextSpecific) == false
    }

    func testASN1DecodePrimitiveNull() {
        let expected = ASN1Primitive(data: .primitive(Data.empty), tag: .universal(.null))
        let data = Data([0x5, 0x0])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodePrimitiveOctetString() {
        let expected = ASN1Primitive(data: .primitive(Data([0xDF, 0x0])), tag: .universal(.octetString))
        let data = Data([0x4, 0x2, 0xDF, 0x0])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodePrimitiveZeroLengthOctetString() {
        let expected = ASN1Primitive(data: .primitive(Data.empty), tag: .universal(.octetString))
        let data = Data([0x4, 0x0])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodeConstructedOctetString() {
        let expected = ASN1Primitive(
            data: .constructed([
                ASN1Primitive(data: .primitive(Data([0xDF, 0x0])), tag: .universal(.octetString)),
                ASN1Primitive(data: .primitive(Data([0xEF, 0xFF])), tag: .universal(.octetString)),
                ASN1Primitive(data: .primitive(Data([0xCF, 0x7F])), tag: .universal(.octetString)),
            ]),
            tag: .universal(.octetString)
        )
        let data = Data([0x24, 0xC, 0x4, 0x2, 0xDF, 0x0, 0x4, 0x2, 0xEF, 0xFF, 0x4, 0x2, 0xCF, 0x7F])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodeConstructedSet() {
        // SET {name IA5String, ok BOOLEAN}
        let items = [
            ASN1Primitive(
                data: .primitive(Data([0x53, 0x6D, 0x69, 0x74, 0x68])),
                tag: .universal(.ia5String)
            ),
            ASN1Primitive(data: .primitive(Data([0xFF])), tag: .universal(.boolean)),
        ]
        let expected = ASN1Primitive(data: .constructed(items), tag: .universal(.set))
        let data = Data([0x31, 0xA, 0x16, 0x5, 0x53, 0x6D, 0x69, 0x74, 0x68, 0x1, 0x1, 0xFF])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodeConstructedSequence() {
        // SEQUENCE {name IA5String, ok BOOLEAN}
        let items = [
            ASN1Primitive(
                data: .primitive(Data([0x53, 0x6D, 0x69, 0x74, 0x68])),
                tag: .universal(.ia5String)
            ),
            ASN1Primitive(data: .primitive(Data([0xFF])), tag: .universal(.boolean)),
        ]
        let expected = ASN1Primitive(data: .constructed(items), tag: .universal(.sequence))
        let data = Data([0x30, 0xA, 0x16, 0x5, 0x53, 0x6D, 0x69, 0x74, 0x68, 0x1, 0x1, 0xFF])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    func testASN1DecodeEmptySequence() {
        // SEQUENCE {}
        let expected = ASN1Primitive(data: .constructed([]), tag: .universal(.sequence))
        let data = Data([0x30, 0x00])
        expect(try ASN1Decoder.decode(asn1: data).asEquatable()) == expected.asEquatable()
    }

    static var allTests = [
        ("testASN1Decoder", testASN1Decoder),
        ("testASN1DecodeLength_short_notation", testASN1DecodeLength_short_notation),
        ("testASN1DecodeLength_long_notation", testASN1DecodeLength_long_notation),
        ("testASN1DecodeLength_indefinite", testASN1DecodeLength_indefinite),
        ("testASN1DecodeLength_too_long_notation", testASN1DecodeLength_too_long_notation),
        ("testASN1DecodeTagNumber_applicationTag_1", testASN1DecodeTagNumber_applicationTag_1),
        ("testASN1DecodeTagNumber_applicationTag_2", testASN1DecodeTagNumber_applicationTag_2),
        ("testASN1DecodeTagNumber_taggedObject_1", testASN1DecodeTagNumber_taggedObject_1),
        ("testASN1DecodeTagNumber_taggedObject_2", testASN1DecodeTagNumber_taggedObject_2),
        ("testASN1DecodeTagNumber_universalTag", testASN1DecodeTagNumber_universalTag),
        ("testASN1DecodeTagNumber_privateTag", testASN1DecodeTagNumber_privateTag),
        ("testASN1DecodeTagNumber_long", testASN1DecodeTagNumber_long),
        ("testASN1DecodeTagNumber_longer", testASN1DecodeTagNumber_longer),
        ("testASN1DecodeTagNumber_too_long", testASN1DecodeTagNumber_too_long),
        ("testASN1DecodeTagNumber_unsupported_long_notation", testASN1DecodeTagNumber_unsupported_long_notation),
        ("testASN1DecodeTagNumber_Bool", testASN1DecodeTagNumber_Bool),
        ("testASN1DecodeTagNumber_Integer", testASN1DecodeTagNumber_Integer),
        ("testASN1DecodeTagNumber_IA5String", testASN1DecodeTagNumber_IA5String),
        ("testASN1DecodeTagNumber_OctetString_constructed", testASN1DecodeTagNumber_OctetString_constructed),
        ("testASN1DecodeTagNumber_OctetString", testASN1DecodeTagNumber_OctetString),
        ("testASN1DecodeTagNumber_Sequence", testASN1DecodeTagNumber_Sequence),
        ("testASN1DecodeTagNumber_Set", testASN1DecodeTagNumber_Set),
        ("testASN1DecodeIndefiniteLengthObject", testASN1DecodeIndefiniteLengthObject),
        ("testASN1DecodeConstructedObject", testASN1DecodeConstructedObject),
        ("testASN1DecodeTaggedNull", testASN1DecodeTaggedNull),
        ("testASN1DecodeTaggedNull_long", testASN1DecodeTaggedNull_long),
        ("testASN1DecodeTaggedImplicit", testASN1DecodeTaggedImplicit),
        ("testASN1DecodeTaggedImplicit_long", testASN1DecodeTaggedImplicit_long),
        ("testASN1DecodeTaggedConstructed", testASN1DecodeTaggedConstructed),
        ("testASN1DecodeTaggedConstructed_long", testASN1DecodeTaggedConstructed_long),
        ("testASN1DecodePrimitiveBool", testASN1DecodePrimitiveBool),
        ("testASN1DecodePrimitiveIA5String", testASN1DecodePrimitiveIA5String),
        ("testASN1DecodePrimitiveInteger", testASN1DecodePrimitiveInteger),
        ("testASN1DecodePrimitiveNull", testASN1DecodePrimitiveNull),
        ("testASN1DecodePrimitiveOctetString", testASN1DecodePrimitiveOctetString),
        ("testASN1DecodePrimitiveZeroLengthOctetString", testASN1DecodePrimitiveZeroLengthOctetString),
        ("testASN1DecodeConstructedOctetString", testASN1DecodeConstructedOctetString),
        ("testASN1DecodeConstructedSet", testASN1DecodeConstructedSet),
        ("testASN1DecodeConstructedSequence", testASN1DecodeConstructedSequence),
        ("testASN1DecodeEmptySequence", testASN1DecodeEmptySequence),
    ]
}

// swiftlint:disable:this file_length
