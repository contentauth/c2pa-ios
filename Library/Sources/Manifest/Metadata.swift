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
//  Metadata.swift
//

import Foundation

/**
 The Metadata structure can be used as part of other assertions or on its own to reference others

 NOTE: This object can have any number of additional user-defined properties.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def#metadata
 */
public struct Metadata: Codable, Equatable {

    public var dataSource: DataSource?

    public var dateTime: Date?

    public var reference: HashedUri?

    public var regionOfInterest: RegionOfInterest?

    public var reviewRatings: [ReviewRating]?


    public init(
        dataSource: DataSource? = nil,
        dateTime: Date? = nil,
        reference: HashedUri? = nil,
        regionOfInterest: RegionOfInterest? = nil,
        reviewRatings: [ReviewRating]? = nil
    ) {
        self.dataSource = dataSource
        self.dateTime = dateTime
        self.reference = reference
        self.regionOfInterest = regionOfInterest
        self.reviewRatings = reviewRatings
    }
}
