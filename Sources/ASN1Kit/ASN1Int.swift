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

/// ANS.1 Integer representation
public struct ASN1Int {
    let rawValue: Data

    /// - Returns: Swift.Int when possible (e.g. fits in the range [Int.min-Int.max])
    public var intValue: Int? {
        rawValue.asn1integer
    }

    /// - Returns: The ASN.1 encoded Int value
    public var rawInt: Data {
        rawValue
    }
}

extension ASN1Int: ASN1CodableType {
    public init(from asn1: ASN1Object) throws {
        guard let data = asn1.data.primitive, asn1.tag == .universal(.integer) else {
            throw ASN1Error.malformedEncoding("ASN.1 Object is not properly formatted")
        }
        rawValue = data
    }

    public func asn1encode(tag _: ASN1DecodedTag?) throws -> ASN1Object {
        ASN1Primitive(data: .primitive(rawValue), tag: .universal(.integer))
    }
}
