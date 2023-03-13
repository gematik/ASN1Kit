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
 DataScanner - scan over a Data object as a stream
 */
internal class DataScanner {
    /// The complete data to scan
    private let data: Data

    /// The current position of the scanning head
    private var position = 0
    private var marker: Int?

    required init(data: Data) {
        self.data = data
    }

    /// `true` if there are no more bytes available to scan.
    var isComplete: Bool {
        position >= data.count
    }

    /**
        Roll the scan head back to the position it was at before the last command was run.
        If the last command failed, you should NOT call this method as it would rollback
        the head to even before the last head

        - Parameter distance: number of bytes to rollback the head
     */
    func rollback(distance: Int) {
        position -= distance

        if position < 0 {
            position = 0
        }
    }

    /**
        Scans `distance` bytes, or returns `nil` and restores position if `distance` is
        greater than the number of bytes remaining

        - Parameter distance: number of bytes to scan
        - Returns: the read bytes or nil when no bytes available of requested distance
     */
    func scan(distance: Int) -> Data? {
        pop(bytes: distance)
    }

    /**
        Scans to the end of the data.

        - Returns: the read bytes or nil when no bytes left
     */
    func scanToEnd() -> Data? {
        scan(distance: data.count - position)
    }

    private func pop(bytes: Int = 1) -> Data? {
        guard bytes > 0,
              position <= (data.count - bytes) else {
            return nil
        }

        defer {
            position += bytes
        }

        return data.subdata(in: position ..< position + bytes)
    }

    func mark() {
        marker = position
    }

    func unmark() {
        marker = nil
    }

    var marked: Data? {
        guard let marker = marker else {
            return nil
        }
        return data.subdata(in: marker ..< position)
    }
}
