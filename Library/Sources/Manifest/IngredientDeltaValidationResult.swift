// This file is licensed to you under the Apache License, Version 2.0
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE
// files for the specific language governing permissions and limitations under
// each license.
//
//  IngredientDeltaValidationResult.swift
//

import Foundation

/// Represents any changes or deltas between the current and previous validation results for an ingredient’s manifest.
/// - SeeAlso: [IngredientDeltaValidationResult Reference](https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-definition-schema/#ingredientdeltavalidationresult)
public struct IngredientDeltaValidationResult: Codable, Equatable {

    public enum CodingKeys: String, CodingKey {
        case ingredientAssertionUri = "ingredientAssertionURI"
        case validationDeltas
    }

    /// JUMBF URI reference to the ingredient assertion.
    public var ingredientAssertionUri: String

    /// Validation results for the ingredient’s active manifest.
    public var validationDeltas: StatusCodes


    /// - Parameters:
    ///   - ingredientAssertionUri: JUMBF URI reference to the ingredient assertion.
    ///   - validationDeltas: Validation results for the ingredient’s active manifest.
    public init(ingredientAssertionUri: String, validationDeltas: StatusCodes) {
        self.ingredientAssertionUri = ingredientAssertionUri
        self.validationDeltas = validationDeltas
    }
}
