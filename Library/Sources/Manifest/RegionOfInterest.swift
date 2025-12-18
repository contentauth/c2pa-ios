//
//  RegionOfInterest.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 A region of interest within an asset describing the change.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#regionofinterest
 */
open class RegionOfInterest: Codable, Equatable {

    // MARK: Equatable

    public static func == (lhs: RegionOfInterest, rhs: RegionOfInterest) -> Bool {
        lhs.description == rhs.description
            && lhs.identifier == rhs.identifier
            && lhs.metadata == rhs.metadata
            && lhs.name == rhs.name
            && lhs.region == rhs.region
            && lhs.role == rhs.role
            && lhs.type == rhs.type
    }


    // MARK: RegionOfInterest

    /**
     A free-text string.
     */
    open var description: String?

    /**
     A free-text string representing a machine-readable, unique to this assertion, identifier for the region.
     */
    open var identifier: String?

    /**
     Additional information about the asset.
     */
    open var metadata: Metadata?

    /**
     A free-text string representing a human-readable name for the region which might be used in a user interface.
     */
    open var name: String?

    /**
     A range describing the region of interest for the specific asset.
     */
    open var region: [RegionRange]

    /**
     A value from our controlled vocabulary or an entity-specific value (e.g., com.litware.coolArea) that represents the role of a region among other regions.
     */
    open var role: Role?

    /**
     A value from a controlled vocabulary such as ``ImageRegionType`` or an entity-specific value
     (e.g., com.litware.newType) that represents the type of thing(s) depicted by a region.
     */
    open var type: String?

    /**
     - parameter description: A free-text string.
     - parameter identifier: A free-text string representing a machine-readable, unique to this assertion, identifier for the region.
     - parameter metadata: Additional information about the asset.
     - parameter name: A free-text string representing a human-readable name for the region which might be used in a user interface.
     - parameter region: A range describing the region of interest for the specific asset.
     - parameter role: A value from our controlled vocabulary or an entity-specific value (e.g., com.litware.coolArea) that represents the role of a region among other regions.
     - parameter type: A value from a controlled vocabulary such as ``ImageRegionType`` or an entity-specific value
                        (e.g., com.litware.newType) that represents the type of thing(s) depicted by a region.
     */
    public init(
        description: String? = nil,
        identifier: String? = nil,
        metadata: Metadata? = nil,
        name: String? = nil,
        region: [RegionRange],
        role: Role? = nil,
        type: String? = nil
    ) {
        self.description = description
        self.identifier = identifier
        self.metadata = metadata
        self.name = name
        self.region = region
        self.role = role
        self.type = type
    }

    /**
     - parameter description: A free-text string.
     - parameter identifier: A free-text string representing a machine-readable, unique to this assertion, identifier for the region.
     - parameter metadata: Additional information about the asset.
     - parameter name: A free-text string representing a human-readable name for the region which might be used in a user interface.
     - parameter region: A range describing the region of interest for the specific asset.
     - parameter role: A value from our controlled vocabulary or an entity-specific value (e.g., com.litware.coolArea) that represents the role of a region among other regions.
     - parameter type: A value from the controlled vocabulary ``ImageRegionType`` that represents the type of thing(s) depicted by a region.
     */
    public convenience init(
        description: String? = nil,
        identifier: String? = nil,
        metadata: Metadata? = nil,
        name: String? = nil,
        region: [RegionRange],
        role: Role? = nil,
        type: ImageRegionType
    ) {
        self.init(
            description: description,
            identifier: identifier,
            metadata: metadata,
            name: name,
            region: region,
            role: role,
            type: type.rawValue)
    }
}
