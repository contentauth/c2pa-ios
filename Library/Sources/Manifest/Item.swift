//
//  Item.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 Description of the boundaries of an identified range.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#item
 */
public struct Item: Codable, Equatable {

    /**
     The container-specific term used to identify items, such as “track_id” for MP4 or “item_ID” for HEIF.
     */
    public var identifier: String

    /**
     The value of the identifier, e.g. a value of “2” for an identifier of “track_id” would imply track 2 of the asset.
     */
    public var value: String


    /**
     - parameter identifier: The container-specific term used to identify items, such as “track_id” for MP4 or “item_ID” for HEIF.
     - parameter value: The value of the identifier, e.g. a value of “2” for an identifier of “track_id” would imply track 2 of the asset.
     */
    public init(identifier: String, value: String) {
        self.identifier = identifier
        self.value = value
    }
}
