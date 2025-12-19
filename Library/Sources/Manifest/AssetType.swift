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
//  AssetType.swift
//

import Foundation

/**
 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def#assettype
 */
public struct AssetType: Codable, Equatable {

    public var type: String

    public var version: String?


    public init(type: String, version: String? = nil) {
        self.type = type
        self.version = version
    }
}
