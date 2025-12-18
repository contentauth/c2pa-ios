//
//  TextSelectorRange.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 One or two TextSelectors identifiying the range to select.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#textselectorrange
 */
public struct TextSelectorRange: Codable, Equatable {

    /**
     The end of the text range.
     */
    public var end: TextSelector?

    /**
     The start (or entire) text range.
     */
    public var selector: TextSelector


    /**
     - parameter end: The end of the text range.
     - parameter selector: The start (or entire) text range.
     */
    public init(end: TextSelector? = nil, selector: TextSelector) {
        self.end = end
        self.selector = selector
    }
}
