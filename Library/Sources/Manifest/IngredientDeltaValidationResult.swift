//
//  IngredientDeltaValidationResult.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 Represents any changes or deltas between the current and previous validation results for an ingredient’s manifest.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#ingredientdeltavalidationresult
 */
public struct IngredientDeltaValidationResult: Codable, Equatable {

    public enum CodingKeys: String, CodingKey {
        case ingredientAssertionUri = "ingredientAssertionURI"
        case validationDeltas
    }

    /**
     JUMBF URI reference to the ingredient assertion.
     */
    public var ingredientAssertionUri: String

    /**
     Validation results for the ingredient’s active manifest.
     */
    public var validationDeltas: StatusCodes


    /**
     - parameter ingredientAssertionUri: JUMBF URI reference to the ingredient assertion.
     - parameter validationDeltas: Validation results for the ingredient’s active manifest.
     */
    public init(ingredientAssertionUri: String, validationDeltas: StatusCodes) {
        self.ingredientAssertionUri = ingredientAssertionUri
        self.validationDeltas = validationDeltas
    }
}
