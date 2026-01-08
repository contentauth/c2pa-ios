// This file is licensed to you under the Apache License, Version 2.0
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE
// files for the specific language governing permissions and limitations under
// each license.
//
//  Item.swift
//

import Foundation

/// Description of the boundaries of an identified range.
/// - SeeAlso: [Item Reference](https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-definition-schema/#item)
public struct Item: Codable, Equatable {

    /// The container-specific term used to identify items, such as “track_id” for MP4 or “item_ID” for HEIF.
    public var identifier: String

    /// The value of the identifier, e.g. a value of “2” for an identifier of “track_id” would imply track 2 of the asset.
    public var value: String


    /// - Parameters:
    ///   - identifier: The container-specific term used to identify items, such as “track_id” for MP4 or “item_ID” for HEIF.
    ///   - value: The value of the identifier, e.g. a value of “2” for an identifier of “track_id” would imply track 2 of the asset.
    public init(identifier: String, value: String) {
        self.identifier = identifier
        self.value = value
    }
}
