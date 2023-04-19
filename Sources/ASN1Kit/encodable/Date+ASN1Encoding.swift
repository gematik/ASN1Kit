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

import DataKit
import Foundation
import GemCommonsKit

/// Encoding formatter, Decoding formatter
typealias ASN1DateFormatter = ((Date) -> String, (String) -> Date?)

extension Date: ASN1CodableType {
    static let utcTimeFormatter: ASN1DateFormatter = {
        let encodingFormatter = DateFormatter()
        encodingFormatter.calendar = Calendar(identifier: .iso8601)
        encodingFormatter.locale = Locale(identifier: "en_US_POSIX")
        encodingFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        encodingFormatter.dateFormat = "yyMMddHHmmss'Z'"

        let decodingFormatter = DateFormatter()
        decodingFormatter.calendar = Calendar(identifier: .iso8601)
        decodingFormatter.locale = Locale(identifier: "en_US_POSIX")
        decodingFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        decodingFormatter.dateFormat = "yyMMddHHmmssZZZZ"

        return (encodingFormatter.string, decodingFormatter.date)
    }()

    static let generalizedTimeFormatter: ASN1DateFormatter = {
        let encodingFormatter = DateFormatter()
        encodingFormatter.calendar = Calendar(identifier: .iso8601)
        encodingFormatter.locale = Locale(identifier: "en_US_POSIX")
        encodingFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        encodingFormatter.dateFormat = "yyyyMMddHHmmss'Z'"

        return (encodingFormatter.string, GeneralizedTimeDateFormatter.date)
    }()

    public init(from asn1: ASN1Object) throws {
        guard let data = asn1.data.primitive,
              let dateString = String(data: data, encoding: .utf8),
              let dateFormatter = asn1.tag.dateFormatter,
              let date = dateFormatter.1(dateString) else {
            throw ASN1Error.malformedEncoding("Date could not be decoded from constructed ASN1Object")
        }

        self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
    }

    public static func asn1decoded(_ object: ASN1Object) throws -> Date {
        try Date(from: object)
    }

    public func asn1encode(tag: ASN1DecodedTag? = nil) throws -> ASN1Object {
        let dateFormatter = tag?.dateFormatter ?? Date.generalizedTimeFormatter

        let stringDate = dateFormatter.0(self)
        let data = Data(stringDate.utf8)
        return ASN1Primitive(data: .primitive(data), tag: tag ?? .universal(.utcTime))
    }
}

extension ASN1DecodedTag {
    var dateFormatter: ASN1DateFormatter? {
        switch self {
        case let .universal(tag):
            return tag.dateFormatter
        default:
            return nil
        }
    }
}

extension ASN1Tag {
    var dateFormatter: ASN1DateFormatter? {
        switch self {
        case .utcTime:
            return Date.utcTimeFormatter
        case .generalizedTime:
            return Date.generalizedTimeFormatter
        default:
            return nil
        }
    }
}
