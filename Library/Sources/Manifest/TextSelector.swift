//
//  TextSelector.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 Selects a range of text via a fragment identifier. This is modeled after the W3C Web Annotation selector model.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#textselector
 */
public struct TextSelector: Codable, Equatable {

    /**
     The end character offset or the end of the fragment if not present.
     */
    public var end: Int32?

    /**
     Fragment identifier as per RFC3023 (XML) or ISO 32000-2 (PDF), Annex O.
     */
    public var fragment: String

    /**
     The start character offset or the start of the fragment if not present.
     */
    public var start: Int32?


    /**
       - parameter end: The end character offset or the end of the fragment if not present.
       - parameter fragment: Fragment identifier as per RFC3023 (XML) or ISO 32000-2 (PDF), Annex O.
       - parameter start: The start character offset or the start of the fragment if not present.
     */
    public init(end: Int32? = nil, fragment: String, start: Int32? = nil) {
        self.end = end
        self.fragment = fragment
        self.start = start
    }
}
