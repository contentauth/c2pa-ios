//
//  DataSource.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 A description of the source for assertion data

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#datasource
 */
public struct DataSource: Codable, Equatable {

    /**
     A list of actors associated with this source.
     */
    public var actors: [MetadataActor]?

    /**
     A human-readable string giving details about the source of the assertion data.
     */
    public var details: String?

    /**
     A value from among the enumerated list indicating the source of the assertion.
     */
    public var type: String


    /**
     - parameter actors: A list of actors associated with this source.
     - parameter details: A human-readable string giving details about the source of the assertion data.
     - parameter type: A value from among the enumerated list indicating the source of the assertion.
     */
    public init(actors: [MetadataActor]? = nil, details: String? = nil, type: String) {
        self.actors = actors
        self.details = details
        self.type = type
    }
}
