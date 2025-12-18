//
//  RegionRange.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 A spatial, temporal, frame, or textual range describing the region of interest.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#range
 */
public struct RegionRange: Codable, Equatable {

    /**
     A frame range.
     */
    public var frame: Frame?

    /**
     An item identifier.
     */
    public var item: Item?

    /**
     A spatial range.
     */
    public var shape: Shape?

    /**
     A textual range.
     */
    public var text: Text?

    /**
     A temporal range.
     */
    public var time: Time?

    /**
     The type of range of interest.
     */
    public var type: RangeType


    /**
     - parameter frame: A frame range.
     - parameter item: An item identifier.
     - parameter shape: A spatial range.
     - parameter text: A textual range.
     - parameter time: A temporal range.
     - parameter type: The type of range of interest.
     */
    public init(
        frame: Frame? = nil,
        item: Item? = nil,
        shape: Shape? = nil,
        text: Text? = nil,
        time: Time? = nil,
        type: RangeType
    ) {
        self.frame = frame
        self.item = item
        self.shape = shape
        self.text = text
        self.time = time
        self.type = type
    }
}
