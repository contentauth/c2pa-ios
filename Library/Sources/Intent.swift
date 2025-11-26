//
//  Intent.swift
//

import C2PAC
import Foundation

/// Specifies what kind of manifest to create when building a C2PA claim.
///
/// The builder intent determines how the manifest is structured and what
/// assertions are automatically added.
///
/// ## Topics
///
/// ### Intent Types
/// - ``create(_:)``
/// - ``edit``
/// - ``update``
///
/// - SeeAlso: ``Builder/setIntent(_:)``
public enum BuilderIntent {
    /// A new digital creation with the specified digital source type.
    ///
    /// Use this intent for assets that are being created for the first time,
    /// such as a freshly captured photo or a newly generated image.
    ///
    /// The manifest must not have a parent ingredient. A `c2pa.created` action
    /// will be added if not provided.
    ///
    /// - Parameter digitalSourceType: The type of digital source used to create this asset.
    case create(DigitalSourceType)

    /// An edit of a pre-existing parent asset.
    ///
    /// Use this intent when modifying an existing asset, such as cropping a photo
    /// or applying filters to an image.
    ///
    /// The manifest must have a parent ingredient. A parent ingredient will be
    /// generated from the source stream if not otherwise provided. A `c2pa.opened`
    /// action will be tied to the parent ingredient.
    case edit

    /// A restricted version of edit for non-editorial changes.
    ///
    /// Use this intent for metadata-only updates that don't modify the hashed
    /// content of the asset, such as updating EXIF data or adding descriptions.
    ///
    /// There must be only one ingredient, as a parent. No changes can be made
    /// to the hashed content of the parent.
    case update

    internal func toCIntent() -> (C2paBuilderIntent, C2paDigitalSourceType) {
        switch self {
        case .create(let sourceType):
            return (Create, sourceType.toCType())
        case .edit:
            return (Edit, Empty)
        case .update:
            return (Update, Empty)
        }
    }
}

/// Defines the digital source type for content created by the builder.
///
/// Digital source types classify how the original content was generated,
/// which is important for provenance and authenticity claims.
///
/// ## Topics
///
/// ### Human-Created Content
/// - ``digitalCapture``
/// - ``negativeFilm``
/// - ``positiveFilm``
/// - ``print``
/// - ``humanEdits``
///
/// ### Algorithmically-Created Content
/// - ``trainedAlgorithmicData``
/// - ``trainedAlgorithmicMedia``
/// - ``algorithmicMedia``
/// - ``dataDrivenMedia``
/// - ``algorithmicallyEnhanced``
///
/// ### Composite Content
/// - ``composite``
/// - ``compositeCapture``
/// - ``compositeSynthetic``
/// - ``compositeWithTrainedAlgorithmicMedia``
///
/// ### Other Types
/// - ``empty``
/// - ``computationalCapture``
/// - ``digitalCreation``
/// - ``screenCapture``
/// - ``virtualRecording``
///
/// - SeeAlso: ``BuilderIntent/create(_:)``
public enum DigitalSourceType {
    case empty
    case trainedAlgorithmicData
    case digitalCapture
    case computationalCapture
    case negativeFilm
    case positiveFilm
    case print
    case humanEdits
    case compositeWithTrainedAlgorithmicMedia
    case algorithmicallyEnhanced
    case digitalCreation
    case dataDrivenMedia
    case trainedAlgorithmicMedia
    case algorithmicMedia
    case screenCapture
    case virtualRecording
    case composite
    case compositeCapture
    case compositeSynthetic

    internal func toCType() -> C2paDigitalSourceType {
        switch self {
        case .empty:
            return Empty
        case .trainedAlgorithmicData:
            return TrainedAlgorithmicData
        case .digitalCapture:
            return DigitalCapture
        case .computationalCapture:
            return ComputationalCapture
        case .negativeFilm:
            return NegativeFilm
        case .positiveFilm:
            return PositiveFilm
        case .print:
            return Print
        case .humanEdits:
            return HumanEdits
        case .compositeWithTrainedAlgorithmicMedia:
            return CompositeWithTrainedAlgorithmicMedia
        case .algorithmicallyEnhanced:
            return AlgorithmicallyEnhanced
        case .digitalCreation:
            return DigitalCreation
        case .dataDrivenMedia:
            return DataDrivenMedia
        case .trainedAlgorithmicMedia:
            return TrainedAlgorithmicMedia
        case .algorithmicMedia:
            return AlgorithmicMedia
        case .screenCapture:
            return ScreenCapture
        case .virtualRecording:
            return VirtualRecording
        case .composite:
            return Composite
        case .compositeCapture:
            return CompositeCapture
        case .compositeSynthetic:
            return CompositeSynthetic
        }
    }
}
