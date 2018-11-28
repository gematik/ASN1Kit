//
// Created by Arjan Duijzer on 18/04/2017.
// Copyright (c) 2017 Gematik. All rights reserved.
//

@testable import ASN1Kit
import GemCommonsKit
import Nimble
import XCTest

final class ASN1DecoderTest: XCTestCase { //swiftlint:disable:this type_body_length

    func testASN1Decoder() {
        let bundle = Bundle(for: ASN1DecoderTest.self)
        guard let rawData = try? bundle.testResourceFilePath(in: "Resources", for: "asn1_decoder_test.der")
                .readFileContents() else {
            Nimble.fail("Could not read test data [Resources/asn1_decoder_test.der]")
            return
        }

        guard let asn1object = ASN1Decoder.decode(asn1: rawData) as? ASN1ApplicationSpecific else {
            Nimble.fail("Could not decode [asn1_decoder_test.der]")
            return
        }

        XCTAssertEqual(asn1object.length, 0x134)
        XCTAssertEqual(asn1object.type, .implicit)
        XCTAssertEqual(asn1object.data.count, 0)
        XCTAssertTrue(asn1object.constructed)

        XCTAssertNotNil(asn1object.value)
    }

    func testASN1DecodeLength_short_notation() {
        let data = Data(bytes: [0x62, 0x3]) // length = 3

        let scanner = DataScanner(data: data)
        _ = scanner.scan(distance: 1)
        guard let length = try? ASN1Decoder.decodeLength(from: scanner) else {
            XCTFail("Could not decode length")
            return
        }
        XCTAssertEqual(length, 3)
    }

    func testASN1DecodeLength_long_notation() {
        let data = Data(bytes: [0x62, 0x82, 0x01, 0xb3]) // length = 435
        let scanner = DataScanner(data: data)
        _ = scanner.scan(distance: 1)
        guard let length = try? ASN1Decoder.decodeLength(from: scanner) else {
            XCTFail("Could not decode length (long notation)")
            return
        }
        XCTAssertEqual(length, 435)
    }

    func testASN1DecodeTagNumber_applicationTag_1() {
        // Application tag 0x2
        let data = Data(bytes: [0x82, 0x01, 0x34]) // tag should be 0x2
        guard let applicationTag = try? ASN1Decoder.decodeTagNumber(from: 0x62, with: DataScanner(data: data)) else {
            XCTFail("Could not decode application tag No (1)")
            return
        }
        XCTAssertEqual(applicationTag, 0x2)
    }

    func testASN1DecodeTagNumber_applicationTag_2() {
        // Application tag 0x11
        let data = Data(bytes: [0x04, 0x3F, 0xFF, 0x2F, 0x06])
        guard let applicationTag = try? ASN1Decoder.decodeTagNumber(from: 0x51, with: DataScanner(data: data)) else {
            XCTFail("Could not decode application tag No (2)")
            return
        }
        XCTAssertEqual(applicationTag, 0x11)
    }

    func testASN1DecodeTagNumber_taggedObject_1() {
        // Tagged object
        let data = Data(bytes: [0x03, 0x01, 0x05, 0x01])
        guard let tagNo = try? ASN1Decoder.decodeTagNumber(from: 0x91, with: DataScanner(data: data)) else {
            XCTFail("Could not decode Tagged object TagNo (1)")
            return
        }
        XCTAssertEqual(tagNo, 0x11)
    }

    func testASN1DecodeTagNumber_taggedObject_2() {
        // Tagged object
        let data = Data(bytes: [0x81, 0x83])
        guard let tagNo = try? ASN1Decoder.decodeTagNumber(from: 0xAB, with: DataScanner(data: data)) else {
            XCTFail("Could not decode Tagged object TagNo (2)")
            return
        }
        XCTAssertEqual(tagNo, 11)
    }

    func testASN1DecodeTagNumber_long() {
        // Application specific object
        let data = Data(bytes: [0x4C, 0x13])
        guard let tagNo = try? ASN1Decoder.decodeTagNumber(from: 0x7F, with: DataScanner(data: data)) else {
            XCTFail("Could not decode long TagNo")
            return
        }
        XCTAssertEqual(tagNo, 76)
    }

    func testASN1DecodeTagNumber_very_long() {
        // Application specific object
        let data = Data(bytes: [0xCC, 0x13])
        guard let tagNo = try? ASN1Decoder.decodeTagNumber(from: 0x7F, with: DataScanner(data: data)) else {
            XCTFail("Could not decode very long tagNo")
            return
        }
        XCTAssertEqual(tagNo, 9747)
    }

    func testASN1DecodeTagNumber_Bool() {
        // Primitive Bool
        let data = Data(bytes: [0x1, 0xff])
        guard let tagNo = try? ASN1Decoder.decodeTagNumber(from: 0x1, with: DataScanner(data: data)) else {
            XCTFail("Could not decode tagNo (Bool)")
            return
        }
        XCTAssertEqual(tagNo, ASN1Tag.boolean.unsignedIntValue)
    }

    func testASN1DecodeTagNumber_Integer() {
        // Primitive Integer
        let data = Data(bytes: [0x3, 0x3, 0xd4, 0xff])
        guard let tagNo = try? ASN1Decoder.decodeTagNumber(from: 0x2, with: DataScanner(data: data)) else {
            XCTFail("Could not decode TagNo (Integer)")
            return
        }
        XCTAssertEqual(tagNo, ASN1Tag.integer.unsignedIntValue)
    }

    func testASN1DecodeTagNumber_IA5String() {
        // Primitive IA5String
        let data = Data(bytes: [0x5, 0x53, 0x6d, 0x69, 0x74, 0x68]) // "Smith"
        guard let tagNo = try? ASN1Decoder.decodeTagNumber(from: 0x16, with: DataScanner(data: data)) else {
            XCTFail("Could not decode tagNo (ia5String")
            return
        }
        XCTAssertEqual(tagNo, ASN1Tag.ia5String.unsignedIntValue)
    }

    func testASN1DecodeTagNumber_OctetString_constructed() {
        // Constructed OctetString
        let data = Data(bytes: [0x7, 0x4, 0x5, 0x53, 0x6d, 0x69, 0x74, 0x68]) // Constructed Octet "536D697468"
        guard let tagNo = try? ASN1Decoder.decodeTagNumber(from: 0x24, with: DataScanner(data: data)) else {
            XCTFail("Could not decode tagNo (OctetString - constructed)")
            return
        }
        XCTAssertEqual(tagNo, ASN1Tag.octetString.unsignedIntValue)
    }

    func testASN1DecodeTagNumber_OctetString() {
        // Primitive OctetString
        let data = Data(bytes: [0x5, 0x53, 0x6d, 0x69, 0x74, 0x68]) // Octet "536D697468"
        guard let tagNo = try? ASN1Decoder.decodeTagNumber(from: 0x4, with: DataScanner(data: data)) else {
            XCTFail("Could not decode tagNO (OctetString)")
            return
        }
        XCTAssertEqual(tagNo, ASN1Tag.octetString.unsignedIntValue)
    }

    func testASN1DecodeTagNumber_Sequence() {
        // Constructed Sequence
        // Seq (
        //  Integer 132
        //  IA5String "Hello"
        // )
        let data = Data(bytes: [0x6, 0x2, 0x1, 0x84, 0x16, 0x5, 0x48, 0x65, 0x6c, 0x6c, 0x6f])
        guard let tagNo = try? ASN1Decoder.decodeTagNumber(from: 0x30, with: DataScanner(data: data)) else {
            XCTFail("Could not decode tagNo (sequence)")
            return
        }
        XCTAssertEqual(tagNo, ASN1Tag.sequence.unsignedIntValue)
    }

    func testASN1DecodeTagNumber_Set() {
        // Constructed Set
        // Set (
        //  [1] IMPLICIT Integer 105
        //  [2] IMPLICIT Bool false
        // )
        let data = Data(bytes: [0x6, 0x81, 0x1, 0x69, 0x82, 0x1, 0x0])
        guard let tagNo = try? ASN1Decoder.decodeTagNumber(from: 0x31, with: DataScanner(data: data)) else {
            XCTFail("Could not decode tagNo (set)")
            return
        }
        XCTAssertEqual(tagNo, ASN1Tag.set.unsignedIntValue)
    }

    func testASN1DecodeConstructedObject() {
        let data = Data(bytes: [0xa2, 0x7, 0x43, 0x5, 0x4A, 0x6f, 0x6e, 0x65, 0x73])
        guard let asn1 = ASN1Decoder.decode(asn1: data) else {
            XCTFail("Could not decode Constructed object")
            return
        }
        guard let taggedObject = asn1 as? ASN1TaggedObject else {
            XCTFail("Wrong type of object")
            return
        }
        XCTAssertEqual(taggedObject.type, .implicit)
        XCTAssertEqual(taggedObject.tagNo, 2)
        XCTAssertTrue(taggedObject.constructed)
        XCTAssertEqual(taggedObject.length, 7)
        XCTAssertTrue(taggedObject.data.isEmpty)
        guard let constructedObject = taggedObject.value[0] as? ASN1ApplicationSpecific else {
            XCTFail("Constructed object is of wrong type")
            return
        }

        XCTAssertEqual(constructedObject.type, .implicit)
        XCTAssertEqual(constructedObject.tagNo, 3)
        XCTAssertEqual(constructedObject.length, 5)
        XCTAssertFalse(constructedObject.constructed)
        XCTAssertEqual(constructedObject.data, Data(bytes: [0x4A, 0x6f, 0x6e, 0x65, 0x73]))
    }

    func testASN1DecodePrimitiveBool() {
        let data = Data(bytes: [0x1, 0x1, 0xff])
        guard let asn1Bool = ASN1Decoder.decode(asn1: data) else {
            XCTFail("Could not decode ASN.1 boolean")
            return
        }
        XCTAssertEqual(asn1Bool.type, .boolean)
        XCTAssertEqual(asn1Bool.length, 1)
        XCTAssertFalse(asn1Bool.constructed)
        XCTAssertEqual(asn1Bool.data, Data(bytes: [0xff]))
        XCTAssertTrue(asn1Bool.value.isEmpty)
    }

    func testASN1DecodePrimitiveIA5String() {
        let data = Data(bytes: [0x16, 0x5, 0x48, 0x65, 0x6c, 0x6c, 0x6f])
        guard let ia5String = ASN1Decoder.decode(asn1: data) else {
            XCTFail("Could not decode ASN.1 IA5 String")
            return
        }
        XCTAssertEqual(ia5String.type, .ia5String)
        XCTAssertFalse(ia5String.constructed)
        XCTAssertEqual(ia5String.length, 5)
        XCTAssertEqual(ia5String.data, Data(bytes: [0x48, 0x65, 0x6c, 0x6c, 0x6f]))
        XCTAssertTrue(ia5String.value.isEmpty)
    }

    func testASN1DecodePrimitiveInteger() {
        let data = Data(bytes: [0x2, 0x3, 0x1, 0xd5, 0x80])
        guard let integer = ASN1Decoder.decode(asn1: data) else {
            XCTFail("Could not decode Integer")
            return
        }
        XCTAssertEqual(integer.type, .integer)
        XCTAssertFalse(integer.constructed)
        XCTAssertEqual(integer.length, 3)
        XCTAssertEqual(integer.data, Data(bytes: [0x1, 0xd5, 0x80]))
        XCTAssertTrue(integer.value.isEmpty)

        // https://www.strozhevsky.com/free_docs/asn1_by_simple_words.pdf
        //0x80 = -128
        //0x0080 = 128
        //0x7FFFFF = 8388607
        //0xff78 = -136
        //0x800001 = -8388607
    }

    func testASN1DecodePrimitiveNull() {
        let data = Data(bytes: [0x5, 0x0])
        guard let integer = ASN1Decoder.decode(asn1: data) else {
            XCTFail("Could not decode Null")
            return
        }
        XCTAssertEqual(integer.type, .null)
        XCTAssertFalse(integer.constructed)
        XCTAssertEqual(integer.length, 0)
        XCTAssertTrue(integer.data.isEmpty)
        XCTAssertTrue(integer.value.isEmpty)
    }

    func testASN1DecodePrimitiveOctetString() {

        let data = Data(bytes: [0x4, 0x2, 0xdf, 0x0])
        guard let octet = ASN1Decoder.decode(asn1: data) else {
            XCTFail("Could not decode Octet String")
            return
        }

        XCTAssertEqual(octet.type, .octetString)
        XCTAssertFalse(octet.constructed)
        XCTAssertEqual(octet.length, 2)
        XCTAssertEqual(octet.data, Data(bytes: [0xdf, 0x0]))
        XCTAssertTrue(octet.value.isEmpty)
    }

    func testASN1DecodeConstructedSet() {
        //SET {name IA5String, ok BOOLEAN}
        let data = Data(bytes: [0x31, 0xa, 0x16, 0x5, 0x53, 0x6d, 0x69, 0x74, 0x68, 0x1, 0x1, 0xff])
        guard let set = ASN1Decoder.decode(asn1: data) as? ASN1Sequence else {
            XCTFail("Could not decode set")
            return
        }

        XCTAssertEqual(set.type, .sequence)
        XCTAssertTrue(set.constructed)
        XCTAssertEqual(set.length, 10)
        XCTAssertTrue(set.data.isEmpty)

        let items = set.items
        let text = items[0]
        XCTAssertEqual(text.type, .ia5String)
        XCTAssertEqual(text.data, Data(bytes: [0x53, 0x6d, 0x69, 0x74, 0x68]))

        let bool = items[1]
        XCTAssertEqual(bool.type, .boolean)
    }

    func testASN1DecodeConstructedSequence() {

        //SEQUENCE {name IA5String, ok BOOLEAN}
        let data = Data(bytes: [0x30, 0xa, 0x16, 0x5, 0x53, 0x6d, 0x69, 0x74, 0x68, 0x1, 0x1, 0xff])
        guard let seq = ASN1Decoder.decode(asn1: data) as? ASN1Sequence else {
            XCTFail("Could not decode sequence")
            return
        }

        XCTAssertEqual(seq.type, .sequence)
        XCTAssertTrue(seq.constructed)
        XCTAssertEqual(seq.length, 10)
        XCTAssertTrue(seq.data.isEmpty)

        let items = seq.items
        let text = items[0]
        XCTAssertEqual(text.type, .ia5String)
        XCTAssertEqual(text.data, Data(bytes: [0x53, 0x6d, 0x69, 0x74, 0x68]))

        let bool = items[1]
        XCTAssertEqual(bool.type, .boolean)
    }

    static var allTests = [
        ("testASN1Decoder", testASN1Decoder),
        ("testASN1DecodeLength_short_notation", testASN1DecodeLength_short_notation),
        ("testASN1DecodeLength_long_notation", testASN1DecodeLength_long_notation),
        ("testASN1DecodeTagNumber_applicationTag_1", testASN1DecodeTagNumber_applicationTag_1),
        ("testASN1DecodeTagNumber_applicationTag_2", testASN1DecodeTagNumber_applicationTag_2),
        ("testASN1DecodeTagNumber_taggedObject_1", testASN1DecodeTagNumber_taggedObject_1),
        ("testASN1DecodeTagNumber_taggedObject_2", testASN1DecodeTagNumber_taggedObject_2),
        ("testASN1DecodeTagNumber_long", testASN1DecodeTagNumber_long),
        ("testASN1DecodeTagNumber_very_long", testASN1DecodeTagNumber_very_long),
        ("testASN1DecodeTagNumber_Bool", testASN1DecodeTagNumber_Bool),
        ("testASN1DecodeTagNumber_Integer", testASN1DecodeTagNumber_Integer),
        ("testASN1DecodeTagNumber_IA5String", testASN1DecodeTagNumber_IA5String),
        ("testASN1DecodeTagNumber_OctetString_constructed", testASN1DecodeTagNumber_OctetString_constructed),
        ("testASN1DecodeTagNumber_OctetString", testASN1DecodeTagNumber_OctetString),
        ("testASN1DecodeTagNumber_Sequence", testASN1DecodeTagNumber_Sequence),
        ("testASN1DecodeTagNumber_Set", testASN1DecodeTagNumber_Set),
        ("testASN1DecodeConstructedObject", testASN1DecodeConstructedObject),
        ("testASN1DecodePrimitiveBool", testASN1DecodePrimitiveBool),
        ("testASN1DecodePrimitiveIA5String", testASN1DecodePrimitiveIA5String),
        ("testASN1DecodePrimitiveInteger", testASN1DecodePrimitiveInteger),
        ("testASN1DecodePrimitiveNull", testASN1DecodePrimitiveNull),
        ("testASN1DecodePrimitiveOctetString", testASN1DecodePrimitiveOctetString),
        ("testASN1DecodeConstructedSet", testASN1DecodeConstructedSet),
        ("testASN1DecodeConstructedSequence", testASN1DecodeConstructedSequence)
    ]
}
