//
//  ReviewRating.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 A rating on an Assertion. See https://c2pa.org/specifications/specifications/1.0/specs/C2PA_Specification.html#_claim_review.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#reviewrating
 */
public struct ReviewRating: Codable, Equatable {

    public var code: String?

    public var explanation: String

    public var value: UInt8


    public init(code: String? = nil, explanation: String, value: UInt8) {
        self.code = code
        self.explanation = explanation
        self.value = value
    }
}
