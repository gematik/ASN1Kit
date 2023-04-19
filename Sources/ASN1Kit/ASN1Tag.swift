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

/**
 ASN.1 Tag implementation according to the X.690-0207 specification

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
    case bitString = 0x03

    /// Tag is Octet String (Byte octets as String)
    /// - SeeAlso: `Data.hexValue`
    case octetString = 0x04

    /// Tag is null object
    case null = 0x05

    /// Tag is Object Identifier
    case objectIdentifier = 0x06

    /// Tag is External
    /// - Warning: unsupported
    case external = 0x08

    /// Tag is Enumeration/enumerated
    /// - Warning: unsupported
    case enumerated = 0x0A

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
    case ia5String = 0x16

    /// Tag is UTC Time
    case utcTime = 0x17

    /// Tag is Generalized Time
    case generalizedTime = 0x18

    /// Tag is Graphic String (all registered G sets and SPACE)
    /// - Warning: unsupported
    case graphicString = 0x19

    /// Tag is Visible String (International ASCII printing character sets)
    /// - Warning: unsupported
    case visibleString = 0x1A

    /// Tag is General String (all registered graphic and character sets plus SPACE and DELETE)
    /// - Warning: unsupported
    case generalString = 0x1B

    /// Tag is Universal String (ISO10646 character set)
    case universalString = 0x1C

    /// Tag is BMP String (Basic Multilingual Plane of ISO/IEC/ITU 10646-1)
    case bmpString = 0x1E

    /// Tag is UTF8 String (any character from a recognized alphabet (including ASCII control characters)
    case utf8String = 0x0C

    /// Tag is Relative OID
    /// - Warning: unsupported
    case relativeOID = 0x0D

    /// Tag is TIME
    /// - Note: Added in X.680 in 08/2015
    /// - Warning: unsupported
    case time = 0x0E

    public static let universal: UInt8 = 0x0
    public static let constructed: UInt8 = 0x20
    public static let application: UInt8 = 0x40
    public static let `private`: UInt8 = 0xC0
    public static let tagged: UInt8 = 0x80
}
