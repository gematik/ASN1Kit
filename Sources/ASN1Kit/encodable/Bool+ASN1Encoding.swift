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

extension Bool: ASN1CodableType {
    public init(from asn1: ASN1Object) throws {
        guard let data = asn1.data.primitive, !data.isEmpty else {
            throw ASN1Error.malformedEncoding("Bool could not be decoded from constructed ASN1Object")
        }

        if data[0] == 0x0 {
            self.init(false)
        } else {
            self.init(true)
        }
    }

    public static func asn1decoded(_ object: ASN1Object) throws -> Bool {
        try Bool(from: object)
    }

    public func asn1encode(tag: ASN1DecodedTag? = nil) throws -> ASN1Object {
        let data = Data([self ? 0xFF : 0x0])
        return ASN1Primitive(data: .primitive(data), tag: tag ?? .universal(.boolean))
    }
}
