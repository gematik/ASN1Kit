//
// Copyright (c) 2019 gematik - Gesellschaft für Telematikanwendungen der Gesundheitskarte mbH
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

extension Data: ASN1CodableType {
    public init(from asn1: ASN1Object) throws {
        switch asn1.data {
        case .primitive(let data):
            self.init(data)
        case .constructed(let items):
            self.init(try items.reduce(Data()) { acc, obj in
                let data = try Data(from: obj)
                return acc + data
            })
        }
    }

    public static func asn1decoded(_ object: ASN1Object) throws -> Data {
        return try Data(from: object)
    }

    public func asn1encode(tag: ASN1DecodedTag? = nil) -> ASN1Object {
        return ASN1Primitive(data: .primitive(self), tag: tag ?? .universal(.octetString))
    }
}
