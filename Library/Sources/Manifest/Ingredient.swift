//
//  Ingredient.swift
//  C2PA
//
//  Created by Benjamin Erhart on 06.10.25.
//

import Foundation

/**
 An Ingredient is any external asset that has been used in the creation of an asset.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def#ingredient
 */
public struct Ingredient: Codable, Equatable {

    public enum CodingKeys: String, CodingKey {
        case activeManifest = "active_manifest"
        case data
        case dataTypes = "data_types"
        case description
        case documentId = "document_id"
        case format
        case hash
        case informationalUri = "informational_URI"
        case instanceId = "instance_id"
        case label
        case manifestData = "manifest_data"
        case metadata
        case provenance
        case relationship
        case thumbnail
        case title
        case validationResults = "validation_results"
        case validationStatus = "validation_status"
    }

    /**
     The active manifest label (if one exists).

     If this ingredient has a manifest store, this is the label of the active manifest.
     */
    public var activeManifest: String?

    /**
     A reference to the actual data of the ingredient.
     */
    public var data: ResourceRef?

    /**
     Additional information about the data’s type to the ingredient V2 structure.
     */
    public var dataTypes: [AssetType]?

    /**
     Additional description of the ingredient.
     */
    public var description: String?

    /**
     Document ID from xmpMM:DocumentID in XMP metadata.
     */
    public var documentId: String?

    /**
     The format of the source file as a MIME type.
     */
    public var format: String?

    /**
     An optional hash of the asset to prevent duplicates.
     */
    public var hash: String?

    /**
     URI to an informational page about the ingredient or its data.
     */
    public var informationalUri: String?

    /**
     Instance ID from xmpMM:InstanceID in XMP metadata.
     */
    public var instanceId: String?

    /**
     The ingredient’s label as assigned in the manifest.
     */
    public var label: String?

    /**
     A manifest store from the source asset extracted as a binary C2PA blob.
     */
    public var manifestData: ResourceRef?

    /**
     Any additional ``Metadata`` as defined in the C2PA spec.
     */
    public var metadata: Metadata?

    /**
     URI from dcterms:provenance in XMP metadata.
     */
    public var provenance: String?

    /**
     Set to ``Relationship#parentOf`` if this is the parent ingredient.

     There can only be one parent ingredient in the ingredients.
     */
    public var relationship: Relationship?

    /**
     A thumbnail image capturing the visual state at the time of import.

     A tuple of thumbnail MIME format (for example image/jpeg) and binary bits of the image.
     */
    public var thumbnail: ResourceRef?

    /**
     A human-readable title, generally source filename.
     */
    public var title: String?

    /**
     Validation results (Ingredient.V3)
     */
    public var validationResults: ValidationResults?

    /**
     Validation status (Ingredient v1 & v2)
     */
    public var validationStatus: [ValidationStatus]?


    /**
     - parameter activeManifest: The active manifest label (if one exists). If this ingredient has a manifest store, this is the label of the active manifest.
     - parameter data: A reference to the actual data of the ingredient.
     - parameter dataTypes: Additional information about the data’s type to the ingredient V2 structure.
     - parameter description: Additional description of the ingredient.
     - parameter documentId: Document ID from xmpMM:DocumentID in XMP metadata.
     - parameter format: The format of the source file as a MIME type.
     - parameter hash: An optional hash of the asset to prevent duplicates.
     - parameter informationalUri: URI to an informational page about the ingredient or its data.
     - parameter instanceId: Instance ID from xmpMM:InstanceID in XMP metadata.
     - parameter label: The ingredient’s label as assigned in the manifest.
     - parameter manifestData: A manifest store from the source asset extracted as a binary C2PA blob.
     - parameter metadata: Any additional ``Metadata`` as defined in the C2PA spec.
     - parameter provenance: URI from dcterms:provenance in XMP metadata.
     - parameter relationship: Set to ``Relationship#parentOf`` if this is the parent ingredient. There can only be one parent ingredient in the ingredients.
     - parameter thumbnail: A thumbnail image capturing the visual state at the time of import. A tuple of thumbnail MIME format (for example image/jpeg) and binary bits of the image.
     - parameter title: A human-readable title, generally source filename.
     - parameter validationResults: Validation results (Ingredient.V3)
     - parameter validationStatus: Validation status (Ingredient v1 & v2)
     */
    public init(
        activeManifest: String? = nil,
        data: ResourceRef? = nil,
        dataTypes: [AssetType]? = nil,
        description: String? = nil,
        documentId: String? = nil,
        format: String? = nil,
        hash: String? = nil,
        informationalUri: String? = nil,
        instanceId: String? = nil,
        label: String? = nil,
        manifestData: ResourceRef? = nil,
        metadata: Metadata? = nil,
        provenance: String? = nil,
        relationship: Relationship? = nil,
        thumbnail: ResourceRef? = nil,
        title: String? = nil,
        validationResults: ValidationResults? = nil,
        validationStatus: [ValidationStatus]? = nil
    ) {
        self.activeManifest = activeManifest
        self.data = data
        self.dataTypes = dataTypes
        self.description = description
        self.documentId = documentId
        self.format = format
        self.hash = hash
        self.informationalUri = informationalUri
        self.instanceId = instanceId
        self.label = label
        self.manifestData = manifestData
        self.metadata = metadata
        self.provenance = provenance
        self.relationship = relationship
        self.thumbnail = thumbnail
        self.title = title
        self.validationResults = validationResults
        self.validationStatus = validationStatus
    }
}
