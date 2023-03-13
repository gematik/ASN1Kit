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
import GemCommonsKit

/**
    Date formatting (encoding only) as described in X.680-201508 Chapter 46 Generalized time
 */
public class GeneralizedTimeDateFormatter {
    private init() {}

    /**
        Parse ASN1 Generalized time formatted String to Swift.Date

        - Parameter generalizedTime: ASN1 GeneralizedTime formatted String

        - Returns: The Date when parsing succeeded or nil when input String was malformed
     */
    public static func date(from generalizedTime: String) -> Date? {
        let decodingFormatter = DateFormatter()
        decodingFormatter.calendar = Calendar(identifier: .iso8601)
        decodingFormatter.locale = Locale(identifier: "en_US_POSIX")

        let dateFormat = generalizedTime.dateFormat
        decodingFormatter.dateFormat = dateFormat
        decodingFormatter.timeZone = generalizedTime.timeZone

        guard let date = decodingFormatter.date(from: generalizedTime[0 ..< dateFormat.count]) else {
            return nil
        }

        // Fix the fractions - if needed
        if generalizedTime.hasFraction {
            return date.byAddingFraction(from: generalizedTime)
        }

        return date
    }
}

// swiftlint:disable strict_fileprivate

extension Date {
    fileprivate func byAddingFraction(from date: String) -> Date {
        guard let separatorIndex = date.firstIndex(of: ".") else {
            // huh? Not a fraction?
            return self
        }

        var strFraction = ""
        let index = separatorIndex.utf16Offset(in: date)
        for idx in index ..< date.count {
            let str = String(date[idx])
            if str.isNumerical {
                strFraction += str
            } else {
                break
            }
        }
        guard let fraction = TimeInterval(strFraction) else {
            // meh? Not Double/TimeInterval parse-able
            return self
        }
        if date.hasSeconds {
            return Date(timeIntervalSince1970: timeIntervalSince1970 + fraction)
        }
        if date.hasMinutes {
            return Date(timeIntervalSince1970: timeIntervalSince1970 + (fraction * 60))
        }

        return Date(timeIntervalSince1970: timeIntervalSince1970 + (fraction * 3600))
    }
}

/// ASN1 Generalized time extensions
extension String {
    /// GeneralizedTime date-format for parsing the part before the (possible) fraction
    fileprivate var dateFormat: String {
        var dateFormat = "yyyyMMddHH"
        if hasMinutes {
            dateFormat += "mm"
            if hasSeconds {
                dateFormat += "ss"
            }
        }
        return dateFormat
    }

    /// Get the indicated time zone when available, else assume GMT
    fileprivate var timeZone: TimeZone? {
        if !hasTimeZone || hasSuffix("Z") {
            return TimeZone(secondsFromGMT: 0)
        }
        /// +/- hours (evt. also minutes)
        guard let digits = lastDigits else {
            return nil
        }
        var offset = digits.gmtOffset
        /// Figure out if its + or -
        if self[count - digits.count - 1] == "-" {
            offset = 0 - offset
        }
        return TimeZone(secondsFromGMT: offset)
    }

    /// Minutes should be at index-position 10 and 11
    fileprivate var hasMinutes: Bool {
        if count > 11 {
            guard let index = firstIndex(of: ".") else {
                return true
            }
            return index.utf16Offset(in: self) > 10
        }
        return false
    }

    /// Seconds should be at index-position 12 and 13
    fileprivate var hasSeconds: Bool {
        if count > 13 {
            guard let index = firstIndex(of: ".") else {
                return true
            }
            return index.utf16Offset(in: self) > 12
        }
        return false
    }

    fileprivate var hasFraction: Bool {
        contains(".")
    }

    private var hasTimeZone: Bool {
        hasSuffix("Z") || contains("+") || contains("-")
    }
}

extension String {
    /// Get the all the digits from the end of `self` until a non-digit is encountered
    private var lastDigits: String? {
        var hoursMinutes = ""
        for idx in (0 ..< count).reversed() {
            let digit = String(self[idx])
            if digit.isDigitsOnly {
                hoursMinutes = digit + hoursMinutes
            } else {
                break
            }
        }
        return !hoursMinutes.isEmpty ? hoursMinutes : nil
    }

    /// Seconds from GMT while `self` is interpreted as HHmm
    private var gmtOffset: Int {
        var value = 0
        if count == 4 {
            value = (Int(self[0 ..< 2]) ?? 0) * 3600
            value += (Int(self[2 ..< 4]) ?? 0) * 60
        }
        return value
    }
}
