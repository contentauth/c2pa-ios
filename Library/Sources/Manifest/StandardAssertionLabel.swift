//
//  StandardAssertionLabel.swift
//  C2PA
//
//  Created by Benjamin Erhart on 08.10.25.
//

import Foundation

/**
 The standard C2PA assertions.

 https://spec.c2pa.org/specifications/specifications/2.2/specs/C2PA_Specification.html#_standard_c2pa_assertion_summary
 */
public enum StandardAssertionLabel: String, Codable {

    case actions = "c2pa.actions"

    case assertionMetadata = "c2pa.assertion.metadata"

    case assetRef = "c2pa.asset-ref"

    case assetType = "c2pa.asset-type.v2"

    case bmffBasedHash = "c2pa.hash.bmff.v3"

    case certificateStatus = "c2pa.certificate-status"

    case cloudData = "c2pa.cloud-data"

    case collectionDataHash = "c2pa.hash.collection.data"

    case dataHash = "c2pa.hash.data"

    case depthmap = "c2pa.depthmap.GDepth"

    case embeddedData = "c2pa.embedded-data"

    case fontInfo = "font.info"

    case generalBoxHash = "c2pa.hash.boxes"

    case ingredient = "c2pa.ingredient"

    case metadata = "c2pa.metadata"

    case multiAssetHash = "c2pa.hash.multi-asset"

    case softBinding = "c2pa.soft-binding"

    case thumbnailClaim = "c2pa.thumbnail.claim"

    case thumbnailIngredient = "c2pa.thumbnail.ingredient"

    case timeStamps = "c2pa.time-stamp"
}
