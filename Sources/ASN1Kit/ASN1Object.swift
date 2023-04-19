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
 ASN.1 Object implementation according to the X.690-0207 specification

 For more information see the
 [X.690-0207.pdf](https://www.itu.int/ITU-T/studygroups/com17/languages/X.690-0207.pdf) specification.

 ASN1Object protocol that represents any ASN.1 Tag or Sequence
 */
public protocol ASN1Object {
    /// Type of the object
    var tag: ASN1DecodedTag { get }

    /// The raw bytes of the object
    var data: ASN1Data { get }

    /// The parsed length byte(s)
    /// - Note: this length should not include its own tag and length bytes needed for encoding
    var length: Int { get }

    /// Whether the object is a constructed object.
    var constructed: Bool { get }

    /// The original encoding
    var originalEncoding: Data? { get }
}

extension ASN1Object {
    /// Tag No in case of Context-Specific or Application class
    public var tagNo: UInt? {
        tag.tagNo
    }
}

/// Create an ASN.1 Object from Tag with (constructed/primitive) data
/// - Parameters:
///     - tag: tag for the object
///     - data: constructed/primitive content
/// - Returns: instance of ASN1Object
public func create(tag: ASN1DecodedTag, data: ASN1Data) -> ASN1Object {
    ASN1Primitive(data: data, tag: tag)
}

// MARK: - Primitive

internal struct ASN1Primitive {
    let data: ASN1Data
    let tag: ASN1DecodedTag
    var originalEncoding: Data?
}

extension ASN1Primitive: ASN1Object {
    /// - Note: this length does not include its own tag and length bytes needed for encoding
    var length: Int {
        data.length
    }

    public var constructed: Bool {
        data.constructed
    }
}
