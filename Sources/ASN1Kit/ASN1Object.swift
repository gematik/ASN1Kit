//
// Created by Arjan Duijzer on 18/04/2017.
// Copyright (c) 2017 Gematik. All rights reserved.
//

import Foundation

/**
    ASN.1 Object/Tag implementation according to the X.690-0207 specification

    For more information see the
    [X.690-0207.pdf](https://www.itu.int/ITU-T/studygroups/com17/languages/X.690-0207.pdf) specification.
*/
public enum ASN1Tag: UInt8 {
    /// 'Placeholder' type for Tagged objects
    case implicit = 0x0

    /// Tag is boolean
    case boolean = 0x1

    /// Tag is Integer
    case integer = 0x02

    /// Tag is bit string
    /// - Warning: unsupported
    case bitString = 0x03

    /// Tag is Octet String (Byte octets as String)
    /// - SeeAlso: `Data.hexValue`
    case octetString = 0x04

    /// Tag is null object
    case null = 0x05

    /// Tag is Object Identifier
    /// - Warning: unsupported
    case objectIdentifier = 0x06

    /// Tag is External
    /// - Warning: unsupported
    case external = 0x08

    /// Tag is Enumeration/enumerated
    /// - Warning: unsupported
    case enumerated = 0x0a

    /// Tag is a Sequence of sub-asn1-objects
    case sequence = 0x10

    /// Tag is a Set of sub-asn1-objects (Un-ordered sequence)
    case set = 0x11

    /// Tag is Numeric String (1, 2, 3, 4, 5, 6, 7, 8, 9, 0, and SPACE)
    /// - Warning: unsupported
    case numericString = 0x12

    /// Tag is a printable string (a-z, A-Z, ' () +,-.?:/= and SPACE)
    /// - Warning: unsupported
    case printableString = 0x13

    //// Tag is a T61 String
    /// - Warning: unsupported
    case t61String = 0x14

    /// Tag is Videotex String (CCITT's T.100 and T.101 character sets)
    /// - Warning: unsupported
    case videotexString = 0x15

    /// Tag is a ia5 String (International ASCII characters (International Alphabet 5))
    /// - Warning: unsupported
    case ia5String = 0x16

    /// Tag is UTC Time
    /// - Warning: unsupported
    case utcTime = 0x17

    /// Tag is Generalized Time
    /// - Warning: unsupported
    case generalizedTime = 0x18

    /// Tag is Graphic String (all registered G sets and SPACE)
    /// - Warning: unsupported
    case graphicString = 0x19

    /// Tag is Visible String (International ASCII printing character sets)
    /// - Warning: unsupported
    case visibleString = 0x1a

    /// Tag is General String (all registered graphic and character sets plus SPACE and DELETE)
    /// - Warning: unsupported
    case generalString = 0x1b

    /// Tag is Universal String (ISO10646 character set)
    /// - Warning: unsupported
    case universalString = 0x1c

    /// Tag is BMP String (Basic Multilingual Plane of ISO/IEC/ITU 10646-1)
    /// - Warning: unsupported
    case bmpString = 0x1e

    /// Tag is UTF8 String (any character from a recognized alphabet (including ASCII control characters)
    /// - Warning: unsupported
    case utf8String = 0x0c

    /// Tag is Relative OID
    /// - Warning: unsupported
    case relativeOID = 0x0d

    /// Raw value
    public var unsignedIntValue: UInt {
        return UInt(self.rawValue)
    }

    public static let universal: UInt8 = 0x0
    public static let constructed: UInt8 = 0x20
    public static let application: UInt8 = 0x40
    public static let tagged: UInt8 = 0x80
}

/**
    ASN1Object protocol that resembles any ASN.1 Tag or Sequence
*/
public protocol ASN1Object {
    /// Type of the object
    var type: ASN1Tag { get }

    /// The raw bytes of the object
    var data: Data { get }

    /// The parsed length bytes
    var length: Int { get }

    /// Whether the object is a constructed object.
    var constructed: Bool { get }

    /// When the ASN1 object is constructed out of one or more sub encoded objects.
    var value: [ASN1Object] { get }
}

/**
    ASN1TaggedObject protocol to distinguish between 'normal' objects and tagged objects.
*/
public protocol ASN1TaggedObject: ASN1Object {
    /// The tagged number
    var tagNo: UInt { get }
}

/**
    ASN1Sequence protocol to distinguish between Objects vs Sequences.
*/
public protocol ASN1Sequence: ASN1Object {
    /// List with ASN1Object objects in this sequence
    var items: [ASN1Object] { get }
}

/**
    ASN1ApplicationSpecific protocol to distinguish between tagged objects vs application specific tagged objects.
*/
public protocol ASN1ApplicationSpecific: ASN1TaggedObject {
}

// MARK: - Encoding

extension UInt {
    internal var tagNoLength: Int {
        if self < 0x1f {
            return 1
        } else {
            var bit = self
            var idx = 1
            repeat {
                idx += 1
                bit >>= 7
            } while (bit > 0x0)
            return idx
        }
    }
}

extension Int {
    internal var lengthSize: Int {
        if self > 0x7f {
            // long notation
            var bit = self
            var idx = 1
            repeat {
                idx += 1
                bit >>= 8
            } while (bit > 0x0)
            return idx
        } else {
            // short notation
            return 1
        }
    }
}

// MARK: - Primitive

internal struct ASN1Primitive {
    let data: Data
    let type: ASN1Tag
    let constructed: Bool
}

extension ASN1Primitive: ASN1Object {
    var length: Int {
        return data.count
    }

    var value: [ASN1Object] {
        return []
    }
}

// MARK: - Sequence

internal struct ASN1SequenceStruct {
    let primitive: ASN1Object
    let items: [ASN1Object]
}

extension ASN1SequenceStruct: ASN1Sequence {
    var type: ASN1Tag {
        return primitive.type
    }
    var data: Data {
        return primitive.data
    }
    var length: Int {
        return items.reduce(0) { length, element in
            let size = element.length
            let tagSize: Int
            if let tagged = element as? ASN1TaggedObject {
                tagSize = tagged.tagNo.tagNoLength
            } else {
                tagSize = 1
            }

            return length + size + size.lengthSize + tagSize
        }
    }
    var constructed: Bool {
        return primitive.constructed
    }
    var value: [ASN1Object] {
        if self.constructed {
            return items
        }
        return []
    }

}

// MARK: - Application Specific

internal struct ASN1ApplicationSpecificObject {
    let primitive: ASN1TaggedObject
}

extension ASN1ApplicationSpecificObject: ASN1ApplicationSpecific {
    var type: ASN1Tag {
        return primitive.type
    }
    var data: Data {
        return primitive.data
    }
    var length: Int {
        return primitive.length
    }
    var constructed: Bool {
        return primitive.constructed
    }
    var tagNo: UInt {
        return primitive.tagNo
    }
    var value: [ASN1Object] {
        return primitive.value
    }
}

// MARK: - Tagged Object

internal struct ASN1TaggedStructure {
    let primitive: ASN1Object
    let tagNo: UInt
    let objects: [ASN1Object]
}

extension ASN1TaggedStructure: ASN1TaggedObject {
    var type: ASN1Tag {
        return primitive.type
    }
    var data: Data {
        if self.constructed {
            return Data.empty
        } else {
            return primitive.data
        }
    }
    var length: Int {
        guard !objects.isEmpty, self.constructed else {
            return primitive.length
        }
        return objects.reduce(0) { length, element in
            let size = element.length
            let tagSize: Int
            if let tagged = element as? ASN1TaggedObject {
                tagSize = tagged.tagNo.tagNoLength
            } else {
                tagSize = 1
            }

            return length + size + size.lengthSize + tagSize
        }
    }
    var constructed: Bool {
        return primitive.constructed
    }
    var value: [ASN1Object] {
        if self.constructed {
            return self.objects
        }
        return []
    }
}
