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

/// ASN1 Encodable type that allows converting Swift types to ASN1 encoding
public protocol ASN1EncodableType {
    /// DER encode an `ASN1EncodableType`
    /// - Parameter tag: the ASN1 tag class
    /// - Returns: new ASN1Object to be used for serializing
    func asn1encode(tag: ASN1DecodedTag?) throws -> ASN1Object
}

/// ASN1 Decodable type allows for initializing Swift type(s) from ASN1 encoding
public protocol ASN1DecodableType {
    /// Initialize a type from Decoded ASN1 encoding
    /// - Parameter asn1: The (de-serialized) ASN1 Tag
    init(from asn1: ASN1Object) throws
}

/// ASN1Codable types are ASN1 Encodable and Decodable
public typealias ASN1CodableType = ASN1EncodableType & ASN1DecodableType
