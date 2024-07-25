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

extension DataProtocol {
    var data: Data { .init(self) }
    var hexa: String { map { .init(format: "%02x", $0) }.joined() }
}

struct HexaError: Error {}

extension StringProtocol {
    func hexa() throws -> [UInt8] {
        var startIndex = self.startIndex
        return try (0 ..< count / 2).map { _ in
            let endIndex = index(after: startIndex)
            defer { startIndex = index(after: endIndex) }
            guard let byte = UInt8(self[startIndex ... endIndex], radix: 16)
            else { throw HexaError() }
            return byte
        }
    }
}

extension Data {
    /// Helping function to init Data from `hex` String
    init(hex hexString: String) throws {
        try self.init(hexString.hexa().data)
    }
}

extension Data {
    /// Helping function to output a hexadecimal representation of `self`
    func hexString() -> String {
        hexa
    }
}
