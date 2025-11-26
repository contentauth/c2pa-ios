//
//  Time.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 A temporal range representing a starting time to an ending time.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#time
 */
public struct Time: Codable, Equatable {

    /**
     The end time or the end of the asset if not present.
     */
    public var end: String?

    /**
     The start time or the start of the asset if not present.
     */
    public var start: String?

    /**
     The type of time.
     */
    public var type: TimeType?


    /**
     - parameter end: The end time or the end of the asset if not present.
     - parameter start: The start time or the start of the asset if not present.
     - parameter type: The type of time.
     */
    public init(end: String? = nil, start: String? = nil, type: TimeType? = nil) {
        self.end = end
        self.start = start
        self.type = type
    }
}
