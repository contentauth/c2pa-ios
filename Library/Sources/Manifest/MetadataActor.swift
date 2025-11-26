//
//  MetadataActor.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 Identifies a person responsible for an action.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#actor
 */
public struct MetadataActor: Codable, Equatable {

    /**
     List of references to W3C Verifiable Credentials.
     */
    public var credentials: [HashedUri]?

    /**
     An identifier for a human actor, used when the “type” is humanEntry.identified.
     */
    public var identifier: String?


    /**
     - parameter credentials: List of references to W3C Verifiable Credentials.
     - parameter identifier: An identifier for a human actor, used when the “type” is humanEntry.identified.
     */
    public init(credentials: [HashedUri]? = nil, identifier: String? = nil) {
        self.credentials = credentials
        self.identifier = identifier
    }
}
