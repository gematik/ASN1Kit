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

public struct ObjectIdentifier: Equatable, Hashable, RawRepresentable {
    public let rawValue: String

    private init(withValidated value: String) {
        rawValue = value
    }

    private init(withUnvalidated value: String) throws {
        // check ASN.1 syntax
        let regex = try! NSRegularExpression( // swiftlint:disable:this force_try
            pattern: "^((urn:oid:)|\\{)?(([0-2]((\\.|\\s)([1-9]([0-9]*)|0))+)|(\\w+\\W?\\w*\\(\\d+\\)\\s*)+)(\\})?$"
        )
        guard !regex.matches(in: value, options: [], range: value.fullRange).isEmpty else {
            throw ASN1Error.malformedEncoding("Invalid OID [\(value)]")
        }
        // Transform OID to internal (simple) representation
        let allowedCharacters = ".0123456789 ".characterSet
        let transformedOID = String(value.filter(allowedCharacters.contains)).replacingOccurrences(of: " ", with: ".")

        guard transformedOID.isOID else {
            throw ASN1Error.malformedEncoding("Invalid (transformed) OID [\(transformedOID)]")
        }

        self.init(withValidated: transformedOID)
    }

    public init?(rawValue: String) {
        do {
            try self.init(withUnvalidated: rawValue)
        } catch {
            return nil
        }
    }

    /// Parse ASN.1 OID from String
    ///
    /// Supports OID formats: ASN.1 notation (http://oid-info.com/faq.htm#17)
    /// and dot notation (http://oid-info.com/faq.htm#14)
    ///
    /// - Note: does not support OID-IRI notation (http://oid-info.com/faq.htm#iri)
    ///
    /// - Parameters:
    ///     - string: OID encoded string e.g. "1.3.6.1.4.1 ", "{1 3 6 1 4 1}", "urn:oid:1.3.6.1.4.1"
    ///               or even "{iso(1) identified-organisation(3) dod(6) internet(1) private(4) enterprise(1)}"
    /// - Throws: ASN1Error when string is malformed
    /// - Returns: The parsed ObjectIdentifier as OID
    public static func from(string value: String) throws -> ObjectIdentifier {
        try ObjectIdentifier(withUnvalidated: value)
    }
}

extension ObjectIdentifier: ASN1CodableType {
    /// ASN.1 Encode the OID
    ///
    /// - Parameter tag: ignored and set to `.universal(.objectIdentifier)`
    /// - Throws: ASN1Error when SIDs are not Int Parsable
    /// - Returns: The ASN1Primitive from ASN1 serializing
    public func asn1encode(tag _: ASN1DecodedTag? = nil) throws -> ASN1Object {
        var sids = rawValue.split(separator: ".").map(String.init).map(UInt.init)
        guard sids.count > 1 else {
            throw ASN1Error.internalInconsistency("Invalid SID encountered [Empty]")
        }
        // Encode first (2) SIDs
        guard let firstSID = sids[0], let secondSID = sids[1] else {
            throw ASN1Error.internalInconsistency("Invalid SID encountered [Too Short]")
        }
        let firstValue = firstSID * UInt(40) + secondSID
        sids.removeFirst()
        sids[0] = firstValue

        // Encode consecutive SID
        let data = try sids.reduce(Data()) { acc, sid in
            var local = Data()
            guard var sidValue = sid else {
                throw ASN1Error.internalInconsistency("Invalid SID encountered [Nil]")
            }
            repeat {
                let current = UInt8(sidValue % 128) | (local.isEmpty ? 0x0 : 0x80)
                local.append(current)
                sidValue /= 128
            } while sidValue > 0

            return acc + local.reversed()
        }

        return ASN1Primitive(data: .primitive(data), tag: .universal(.objectIdentifier))
    }

    /// Initialize an OID from Decoded ASN1 encoding
    /// - Parameter asn1: The (de-serialized) ASN1 Tag
    public init(from asn1: ASN1Object) throws {
        guard asn1.tag == .universal(.objectIdentifier), let oidData = asn1.data.primitive, !oidData.isEmpty else {
            throw ASN1Error.malformedEncoding("OID is not encoded primitive")
        }

        var value = ""
        let scanner = DataScanner(data: oidData)
        while !scanner.isComplete {
            var subId = UInt(0)
            var lastByte: UInt8
            repeat {
                guard let byte = scanner.scan(distance: 1)?[0] else {
                    throw ASN1Error.malformedEncoding("OID is not properly encoded")
                }
                subId *= 128
                subId += UInt(byte) & 0x7F
                lastByte = byte
            } while (lastByte & 0x80) == UInt8(0x80)
            // Treat first two (2) SIDs differently
            if value.isEmpty {
                switch subId {
                case 0 ... 39:
                    value = "0.\(subId)"
                case 40 ... 79:
                    value = "1.\(subId - 40)"
                default:
                    value = "2.\(subId - 80)"
                }
            } else {
                value += ".\(subId)"
            }
        }

        self.init(withValidated: value)
    }
}

extension ObjectIdentifier: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension String {
    // swiftlint:disable force_try line_length
    static let oidRegex =
        try! NSRegularExpression(
            pattern: "^(((0|1)\\.([1-3][0-9]|[0-9])(\\.([1-9]([0-9])*|0))?)|(2\\.([1-9]([0-9]*)|[0-9])))(\\.([1-9]([0-9])*|0))*$"
        )
    // swiftlint:enable force_try line_length

    /// Check if `self` could be a valid ASN.1 OID
    /// - Returns: `true` when matching the oidRegex
    var isOID: Bool {
        !String.oidRegex.matches(in: self, options: [], range: fullRange).isEmpty
    }

    /// Create a Character set of self
    public var characterSet: Set<Character> {
        Set(self)
    }
}

extension ObjectIdentifier: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        try self.init(withUnvalidated: value)
    }
}
