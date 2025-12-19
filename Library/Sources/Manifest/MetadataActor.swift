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
//  MetadataActor.swift
//

import Foundation

/// Identifies a person responsible for an action.
/// - SeeAlso: [Actor Reference](https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-definition-schema/#actor)
public struct MetadataActor: Codable, Equatable {

    /// List of references to W3C Verifiable Credentials.
    public var credentials: [HashedUri]?

    /// An identifier for a human actor, used when the “type” is humanEntry.identified.
    public var identifier: String?


    /// - Parameters:
    ///   - credentials: List of references to W3C Verifiable Credentials.
    ///   - identifier: An identifier for a human actor, used when the “type” is humanEntry.identified.
    public init(credentials: [HashedUri]? = nil, identifier: String? = nil) {
        self.credentials = credentials
        self.identifier = identifier
    }
}
