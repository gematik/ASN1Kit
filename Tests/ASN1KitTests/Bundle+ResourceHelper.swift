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
extension Bundle {
    /**
        Get the filePath for a resource in a bundle.

        - Parameters:
            - bundle: Name of the bundle packaged with this App/Framework Bundle
            - filename: The filename of the resource in the bundle

        - Returns: Absolute filePath to the Resources in the bundle
     */
    public func resourceFilePath(in bundle: String, for filename: String) -> String {
        let bundlePath = self.bundlePath
        #if os(macOS)
        let resourceFilePath = "file://\(bundlePath)/Resources/\(bundle).bundle/\(filename)"
        #else
        let resourceFilePath = "file://\(bundlePath)/\(bundle).bundle/\(filename)"
        #endif
        return resourceFilePath
    }

    /**
        Get the filePath for a test resource in a bundle.

        - Parameters:
            - bundle: Name of the bundle packaged with this Test Bundle
            - filename: The filename of the resource in the bundle

        - Returns: Absolute filePath to the Resources in the bundle
     */
    public func testResourceFilePath(in bundle: String, for filename: String) -> String {
        let bundlePath = self.bundlePath
        #if os(macOS)
        let resourceFilePath = "file://\(bundlePath)/Contents/Resources/\(bundle).bundle/\(filename)"
        #else
        let resourceFilePath = "file://\(bundlePath)/\(bundle).bundle/\(filename)"
        #endif
        return resourceFilePath
    }
}

extension URL {
    /**
        Convenience function for Data(contentsOf: URL)

        - Throws: An error in the Cocoa domain, if `url` cannot be read.

        - Returns: Data with contents of the (local) File
     */
    public func readFileContents() throws -> Data {
        try Data(contentsOf: self)
    }
}

extension String {
    /// File reading/handling error cases
    public enum FileReaderError: Error {
        /// Indicate the URL was not pointing to a valid Resource
        case invalidURL(String)
        /// Indicate there was no such file at specified path
        case noSuchFileAtPath(String)
    }

    /**
        Read the contents of a local file at path `self`.

        - Throws: FileReaderError when File not exists | An error in the Cocoa domain, if `url` cannot be read.

        - Returns: Data with contents of the File at path `self`
     */
    public func readFileContents() throws -> Data {
        let mUrl: URL = asURL
        guard FileManager.default.fileExists(atPath: mUrl.path) else {
            throw FileReaderError.noSuchFileAtPath(self)
        }
        return try mUrl.readFileContents()
    }

    /// Returns path as URL
    public var asURL: URL {
        if hasPrefix("/") {
            return URL(fileURLWithPath: self)
        }
        if let url = URL(string: self) {
            return url
        } else {
            return URL(fileURLWithPath: self)
        }
    }
}
