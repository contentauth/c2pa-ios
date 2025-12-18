//
//  Coordinate.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 An x, y coordinate used for specifying vertices in polygons.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#coordinate
 */
public struct Coordinate: Codable, Equatable {

    /**
     The coordinate along the x-axis.
     */
    public var x: Double

    /**
     The coordinate along the y-axis.
     */
    public var y: Double


    /**
     - parameter x: The coordinate along the x-axis.
     - parameter y: The coordinate along the y-axis.
     */
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
