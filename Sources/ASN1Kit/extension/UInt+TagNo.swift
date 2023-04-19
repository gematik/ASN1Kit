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

extension UInt {
    /// ASN1 bytes needed to encode Self as Tag class
    internal var tagNoLength: Int {
        if self < 0x1F {
            return 1
        } else {
            var bit = self
            var idx = 1
            repeat {
                idx += 1
                bit >>= 7
            } while bit > 0x0
            return idx
        }
    }
}
