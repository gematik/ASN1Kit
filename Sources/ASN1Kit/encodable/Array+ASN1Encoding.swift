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

extension Array: ASN1DecodableType where Element == ASN1Object {
    public init(from asn1: ASN1Object) throws {
        guard let objects = asn1.data.items else {
            throw ASN1Error.malformedEncoding("Cannot create an Array from a non-constructed ASN1 Tag")
        }
        self.init(objects)
    }
}

extension Sequence where Element == ASN1EncodableType {
    /// ASN.1 encoding of a sequence using the given tag (optional)
    ///
    /// - Parameter tag: the encapsulating tag (default: .universal(.sequence))
    /// - Returns: the ASN.1 encoded object
    /// - Throws: when items in the sequence couldn't be ASN.1 encoded
    public func asn1encode(tag: ASN1DecodedTag? = nil) throws -> ASN1Object {
        try ASN1Primitive(
            data: .constructed(map { try $0.asn1encode(tag: nil) }),
            tag: tag ?? .universal(.sequence)
        )
    }
}
