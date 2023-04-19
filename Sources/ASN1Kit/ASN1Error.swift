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
    ASN.1 Error type
 */
public enum ASN1Error: Swift.Error, Equatable {
    /// When the byte-stream encountered unexpected byte(s), insufficient length or
    /// any other invalid encoding options
    case malformedEncoding(String)
    /// When encountered a tag/length that is unsupported (by this decoder)
    case unsupported(String)
    /// When an overflow situation is encountered
    case internalError(String)
    /// When an internal inconsistency was encountered during encoding
    case internalInconsistency(String)
}
