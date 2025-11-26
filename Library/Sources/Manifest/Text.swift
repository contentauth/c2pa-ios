//
//  Text.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 A textual range representing multiple (possibly discontinuous) ranges of text.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#text
 */
public struct Text: Codable, Equatable {

    /**
     The ranges of text to select.
     */
    public var selectors: [TextSelectorRange]


    /**
     - parameter selectors: The ranges of text to select.
     */
    public init(selectors: [TextSelectorRange]) {
        self.selectors = selectors
    }
}
