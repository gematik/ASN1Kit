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

extension String: ASN1CodableType {
    public func asn1encode(tag: ASN1DecodedTag?) throws -> ASN1Object {
        let encoding: String.Encoding
        if let tag = tag {
            encoding = tag.stringEncoding ?? .utf8
        } else {
            encoding = .utf8
        }

        guard let data = data(using: encoding) else {
            throw ASN1Error.malformedEncoding(
                "String: [\(self)] could not be encoded with encoding: [\(String(describing: encoding))]"
            )
        }

        guard let stag = tag ?? encoding.asn1decoded else {
            throw ASN1Error.malformedEncoding(
                "No ASN.1 tag found for tag: [\(String(describing: tag))] " +
                    "and/or encoding: [\(String(describing: encoding))]"
            )
        }

        return ASN1Primitive(data: .primitive(data), tag: stag)
    }

    public init(from asn1: ASN1Object) throws {
        guard let encoding = asn1.tag.stringEncoding,
              let data = asn1.data.primitive,
              let value = String(data: data, encoding: encoding) else {
            throw ASN1Error.malformedEncoding("Could not decode ASN.1 String [\(String(describing: asn1))]")
        }
        self.init(value)
    }
}

extension ASN1DecodedTag {
    var stringEncoding: String.Encoding? {
        switch self {
        case let .universal(tag):
            return tag.stringEncoding
        default:
            return nil
        }
    }
}

extension String.Encoding {
    var asn1tag: ASN1Tag? {
        switch self {
        case .ascii:
            return .ia5String
        case .utf8:
            return .utf8String
        case .utf32BigEndian:
            return .universalString
        case .utf16BigEndian:
            return .bmpString
        default:
            return nil
        }
    }

    var asn1decoded: ASN1DecodedTag? {
        guard let tag = asn1tag else {
            return nil
        }
        return .universal(tag)
    }
}

extension ASN1Tag {
    var stringEncoding: String.Encoding? {
        switch self {
        case .ia5String:
            return .ascii
        case .utf8String:
            return .utf8
        case .universalString:
            return .utf32BigEndian
        case .bmpString:
            return .utf16BigEndian
        case .printableString:
            return .ascii
        case .generalString:
            return .ascii
        default:
            return nil
        }
    }
}
