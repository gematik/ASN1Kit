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

extension ASN1Object {
    /// Search for tag
    /// - Parameter tag: the tag to look for
    /// - Returns: first object that matches tag or nil when not found
    public subscript(tag: ASN1DecodedTag) -> ASN1Object? {
        guard let items = data.items else {
            return nil
        }

        return items.first {
            $0.tag == tag
        }
    }
}
