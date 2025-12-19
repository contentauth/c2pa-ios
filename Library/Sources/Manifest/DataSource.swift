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
//  DataSource.swift
//

import Foundation

/// A description of the source for assertion data
/// - SeeAlso: [DataSource Reference](https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-definition-schema/#datasource)
public struct DataSource: Codable, Equatable {

    /// A list of actors associated with this source.
    public var actors: [MetadataActor]?

    /// A human-readable string giving details about the source of the assertion data.
    public var details: String?

    /// A value from among the enumerated list indicating the source of the assertion.
    public var type: String


    /// - Parameters:
    ///   - actors: A list of actors associated with this source.
    ///   - details: A human-readable string giving details about the source of the assertion data.
    ///   - type: A value from among the enumerated list indicating the source of the assertion.
    public init(actors: [MetadataActor]? = nil, details: String? = nil, type: String) {
        self.actors = actors
        self.details = details
        self.type = type
    }
}
