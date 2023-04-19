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
import Commandant
import DataKit
import Foundation

struct ParseCommand: CommandProtocol {
    enum Error: Swift.Error {
        case unsupportedMode(_: String)
        case asn1Error(Swift.Error)
    }

    let verb: String = "parse"
    let function: String = "Parse ASN.1 encoded file or from cmd-line input"

    func run(_ options: Options) -> Result<Void, Error> {
        let file = URL(fileURLWithPath: (options.file as NSString).expandingTildeInPath)
        let fileContents = try? file.readFileContents()
        guard !options.string.isEmpty || fileContents != nil else {
            return .failure(.unsupportedMode("No string or valid file path passed"))
        }

        do {
            let data: Data
            if let fileContents = fileContents {
                data = fileContents
            } else {
                let sanitized = options.string.sanitize()
                data = try Data(hex: sanitized)
            }
            let asn1 = try ASN1Decoder.decode(asn1: data)

            print("ASN1: [\(asn1)]")

            return .success(())
        } catch {
            return .failure(.asn1Error(error))
        }
    }

    struct Options: OptionsProtocol {
        let file: String
        let string: String
        let verbose: Bool

        static func create(_ file: String) -> (String) -> (Bool) -> Options {
            { (string: String) in { (verbose: Bool) in
                Options(
                    file: file,
                    string: string,
                    verbose: verbose
                )
            }
            }
        }

        static func evaluate(_ m: CommandMode) -> Result<Options, CommandantError<Error>> {
            // swiftlint:disable:previous identifier_name
            create
                <*> m <| Option(key: "f", defaultValue: "", usage: "path to ANS.1 encoded file")
                <*> m <| Option(key: "s", defaultValue: "", usage: "String passed as ASN.1 encoded hex")
                <*> m <| Option(key: "v", defaultValue: false, usage: "Show verbose logging")
        }
    }
}

extension String {
    /// Remove all non hex-characters from String so it can be interpreted by Data(hex:)
    func sanitize() -> String {
        let allowedCharacters = "0123456789abcdefABCDEF".characterSet
        return filter(allowedCharacters.contains)
    }
}
