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

/// ASN1 Data/Content type
public enum ASN1Data {
    /// Primitive that holds (encoded) octets/bytes
    case primitive(Data)
    /// Constructed type holding its set/sequence
    case constructed([ASN1Object])

    /// Number of bytes needed for the primitive or nested objects/tags (including their resp. tag and length sizes)
    public var length: Int {
        switch self {
        case let .primitive(data):
            return data.count
        case let .constructed(items):
            return items.reduce(0) { acc, item in
                acc + item.length + item.length.lengthSize + item.tag.length
            }
        }
    }

    internal var constructed: Bool {
        switch self {
        case .constructed:
            return true
        default:
            return false
        }
    }

    /// When case is .constructed the containing ASN1Objects are returned, nil when .primitive
    public var items: [ASN1Object]? {
        // swiftlint:disable:previous discouraged_optional_collection
        if case let .constructed(items) = self {
            return items
        }
        return nil
    }

    /// When case is .primitive the data value is returned, nil when .constructed
    public var primitive: Data? {
        if case let .primitive(data) = self {
            return data
        }
        return nil
    }
}

extension ASN1Data {
    /// Fold over a ASN1 Data object
    /// - Parameters:
    ///     - primitive: Block that gets invoked when self is primitive
    ///     - constructed: Block that gets invoked when self is constructed
    /// - Throws: Rethrows errors from the passed in block parameters
    /// - Returns: The resulting T from given block
    public func fold<T>(
        _ primitive: @escaping (Data) throws -> T,
        _ constructed: ([ASN1Object]) throws -> T
    ) rethrows -> T {
        switch self {
        case let .primitive(data):
            return try primitive(data)
        case let .constructed(items):
            return try constructed(items)
        }
    }
}
