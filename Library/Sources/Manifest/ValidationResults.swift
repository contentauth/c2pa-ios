//
//  ValidationResults.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 A map of validation results for a manifest store. The map contains the validation results for the active manifest and any ingredient deltas. It is normal for there to be many

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#validationresults
 */
public struct ValidationResults: Codable, Equatable {

    public var activeManifest: StatusCodes?

    public var ingredientDeltas: [IngredientDeltaValidationResult]?


    public init(activeManifest: StatusCodes? = nil, ingredientDeltas: [IngredientDeltaValidationResult]? = nil) {
        self.activeManifest = activeManifest
        self.ingredientDeltas = ingredientDeltas
    }
}
