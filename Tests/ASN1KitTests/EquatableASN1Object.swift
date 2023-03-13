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

import ASN1Kit

extension ASN1Object {
    func asEquatable() -> EquatableASN1Object {
        EquatableASN1Object(item: self)
    }

    func equal(to other: ASN1Object) -> Bool {
        tag == other.tag &&
            length == other.length &&
            constructed == other.constructed &&
            data.equal(to: other.data)
    }
}

extension ASN1Data {
    func equal(to other: ASN1Data) -> Bool {
        switch (self, other) {
        case let (.primitive(lhs), .primitive(rhs)):
            return lhs == rhs
        case let (.constructed(lhs), .constructed(rhs)):
            return lhs.map { $0.asEquatable() } == rhs.map { $0.asEquatable() }
        default:
            return false
        }
    }
}

/// Test util to check ASN1 for equality
struct EquatableASN1Object: Equatable {
    let item: ASN1Object

    /// Check equality between ASN1Objects
    static func ==(lhs: EquatableASN1Object, rhs: EquatableASN1Object) -> Bool {
        // swiftlint:disable:previous operator_whitespace
        lhs.item.equal(to: rhs.item)
    }
}
