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
import Nimble

func equalASN1(_ data: ASN1Data) -> Predicate<ASN1Data> {
    let errorMessage = "expected ASN1Data doesn't equal <\(stringify(data))>"
    return Predicate.simple(errorMessage) { actualExpression in
        guard let actual = try actualExpression.evaluate() else {
            return .fail
        }
        return PredicateStatus(bool: actual.equal(to: data))
    }
}
