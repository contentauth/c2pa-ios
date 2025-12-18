//
//  Shape.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 A spatial range representing rectangle, circle, or a polygon.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#shape
 */
public struct Shape: Codable, Equatable {

    /**
     The type of shape.
     */
    public var type: ShapeType

    /**
     The origin of the coordinate in the shape.
     */
    public var origin: Coordinate

    /**
     The width for rectangles or diameter for circles.

     This field can be ignored for polygons.
     */
    public var width: Double?

    /**
     The height of a rectnagle.

     This field can be ignored for circles and polygons.
     */
    public var height: Double?

    /**
     The vertices of the polygon.

     This field can be ignored for rectangles and circles.
     */
    public var vertices: [Coordinate]?

    /**
     If the range is inside the shape.

     The default value is true.
     */
    public var inside: Bool

    /**
     The type of unit for the shape range.
     */
    public var unit: UnitType


    /**
     - parameter type: The type of shape.
     - parameter origin: The origin of the coordinate in the shape.
     - parameter width: The width for rectangles or diameter for circles. This field can be ignored for polygons.
     - parameter height: The height of a rectnagle. This field can be ignored for circles and polygons.
     - parameter vertices: The vertices of the polygon. This field can be ignored for rectangles and circles.
     - parameter inside: If the range is inside the shape. The default value is true.
     - parameter unit: The type of unit for the shape range.
     */
    public init(
        type: ShapeType,
        origin: Coordinate,
        width: Double? = nil,
        height: Double? = nil,
        vertices: [Coordinate]? = nil,
        inside: Bool = true,
        unit: UnitType
    ) {
        self.type = type
        self.origin = origin
        self.width = width
        self.height = height
        self.vertices = vertices
        self.inside = inside
        self.unit = unit
    }
}
