//
//  Metadata.swift
//  C2PA
//
//  Created by Benjamin Erhart on 06.10.25.
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
