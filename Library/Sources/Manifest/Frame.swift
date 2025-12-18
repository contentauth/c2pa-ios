//
//  Frame.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 A frame range representing starting and ending frames or pages. If both ``start`` and ``end`` are missing, the frame will span the entire asset.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#frame
 */
public struct Frame: Codable, Equatable {

    /**
     The end of the frame inclusive or the end of the asset if not present.
     */
    public var end: Int32?

    /**
     The start of the frame or the end of the asset if not present.

     The first frame/page starts at 0.
     */
    public var start: Int32?


    /**
     - parameter end: The end of the frame inclusive or the end of the asset if not present.
     - parameter start: The start of the frame or the end of the asset if not present. The first frame/page starts at 0.
     */
    public init(end: Int32? = nil, start: Int32? = nil) {
        self.end = end
        self.start = start
    }
}
