//
// Copyright (c) 2021 gematik GmbH
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

// MARK: - Encoding

extension ASN1DecodedTag {
    /// Number of bytes needed for encoded tag
    internal var length: Int {
        switch self {
        case .applicationTag(let tag):
            return tag.tagNoLength
        case .taggedTag(let tag):
            return tag.tagNoLength
        case .privateTag(let tag):
            return tag.tagNoLength
        case .universal(let tag):
            return UInt(tag.rawValue).tagNoLength
        }
    }

    internal var tagNo: UInt? {
        switch self {
        case .taggedTag(let tagNo): return tagNo
        case .applicationTag(let tagNo): return tagNo
        case .privateTag(let tagNo): return tagNo
        default: return nil
        }
    }
}
