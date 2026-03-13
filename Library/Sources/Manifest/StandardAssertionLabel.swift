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
//  StandardAssertionLabel.swift
//

import Foundation

/// The standard C2PA assertions.
/// - SeeAlso: [C2PA Specification: Standard C2PA Assertion Summary](https://spec.c2pa.org/specifications/specifications/2.3/specs/C2PA_Specification.html#_standard_c2pa_assertion_summary)
public enum StandardAssertionLabel: String, Codable {

    /// Describes actions performed on the asset.
    case actions = "c2pa.actions"

    /// Version 2 of the actions assertion schema.
    case actionsV2 = "c2pa.actions.v2"

    /// Metadata about another assertion.
    case assertionMetadata = "c2pa.assertion.metadata"

    /// Provides an alternate representation of the content (for example an EXIF preservation image).
    case alternativeContentRepresentation = "c2pa.alternative-content-representation"

    /// Reference to a location where the asset may be obtained.
    case assetRef = "c2pa.asset-ref"

    /// Describes the media type and classification of the asset.
    case assetType = "c2pa.asset-type.v2"

    /// Hash of a BMFF-based asset structure.
    case bmffBasedHash = "c2pa.hash.bmff.v3"

    /// Information about the certificate used for signing.
    case certificateStatus = "c2pa.certificate-status"

    /// Reference to externally stored assertion data.
    case cloudData = "c2pa.cloud-data"

    /// Hash of a collection of assets.
    case collectionDataHash = "c2pa.hash.collection.data"

    /// Hash of byte ranges of the asset.
    case dataHash = "c2pa.hash.data"

    /// Google depth map metadata assertion.
    case depthmap = "c2pa.depthmap.GDepth"

    /// Embedded binary data such as images, prompts, or other files.
    case embeddedData = "c2pa.embedded-data"

    /// Reference to an externally stored assertion.
    case externalReference = "c2pa.external-reference"

    /// Font metadata describing fonts used in the asset.
    case fontInfo = "font.info"

    /// Hash of specific boxes in a container format.
    case generalBoxHash = "c2pa.hash.boxes"

    /// Ingredient describing an input asset used to create the current asset.
    case ingredient = "c2pa.ingredient"

    /// Version 3 of the ingredient assertion.
    case ingredientV3 = "c2pa.ingredient.v3"

    /// Structured metadata about the asset (for example EXIF or IPTC).
    case metadata = "c2pa.metadata"

    /// Hash referencing multiple assets.
    case multiAssetHash = "c2pa.hash.multi-asset"

    /// Soft binding information between content and manifest.
    case softBinding = "c2pa.soft-binding"

    /// Thumbnail representing the asset at claim creation.
    case thumbnailClaim = "c2pa.thumbnail.claim"

    /// Thumbnail representing an imported ingredient.
    case thumbnailIngredient = "c2pa.thumbnail.ingredient"

    /// Signed timestamp token associated with the claim.
    case timeStamps = "c2pa.time-stamp"
}
