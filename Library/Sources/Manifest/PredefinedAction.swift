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
//  PredefinedAction.swift
//

import Foundation

/**
 https://spec.c2pa.org/specifications/specifications/2.2/specs/C2PA_Specification.html#_actions
 */
public enum PredefinedAction: String, Codable {

    /**
     (visible) Textual content was inserted into the asset, such as on a text layer or as a caption.
     */
    case addedText = "c2pa.addedText"

    /**
     Changes to tone, saturation, etc.
     */
    case adjustedColor = "c2pa.adjustedColor"

    /**
     Reduced or increased playback speed of a video or audio track
     */
    case changedSpeed = "c2pa.changedSpeed"

    /**
     [DEPRECATED] Changes to tone, saturation, etc.
     */
    @available(*, deprecated)
    case colorAdjustments = "c2pa.color_adjustments"

    /**
     The format of the asset was changed.
     */
    case converted = "c2pa.converted"

    /**
     The asset was first created.
     */
    case created = "c2pa.created"

    /**
     Areas of the asset’s digital content were cropped out.
     */
    case cropped = "c2pa.cropped"

    /**
     Areas of the asset’s digital content were deleted.
     */
    case deleted = "c2pa.deleted"

    /**
     Changes using drawing tools including brushes or eraser.
     */
    case drawing = "c2pa.drawing"

    /**
     Changes were made to audio, usually one or more tracks of a composite asset.
     */
    case dubbed = "c2pa.dubbed"

    /**
     Generalized actions that would be considered editorial transformations of the content.
     */
    case edited = "c2pa.edited"

    /**
     Modifications to asset metadata or a metadata assertion but not the asset’s digital content.
     */
    case editedMetadata = "c2pa.edited.metadata"

    /**
     Applied enhancements such as noise reduction, multi-band compression, or sharpening that represent non-editorial transformations of the content.
     */
    case enhanced = "c2pa.enhanced"

    /**
     Changes to appearance with applied filters, styles, etc.
     */
    case filtered = "c2pa.filtered"

    /**
     An existing asset was opened and is being set as the parentOf ingredient.
     */
    case opened = "c2pa.opened"

    /**
     Changes to the direction and position of content.
     */
    case orientation = "c2pa.orientation"

    /**
     Added/Placed one or more componentOf ingredient(s) into the asset.
     */
    case placed = "c2pa.placed"

    /**
     Asset is released to a wider audience.
     */
    case published = "c2pa.published"

    /**
     One or more assertions were redacted
     */
    case redacted = "c2pa.redacted"

    /**
     A componentOf ingredient was removed.
     */
    case removed = "c2pa.removed"

    /**
     A conversion of one packaging or container format to another. Content is repackaged without transcoding. This action is considered as a non-editorial transformation of the parentOf ingredient.
     */
    case repackaged = "c2pa.repackaged"

    /**
     Changes to either content dimensions, its file size or both
     */
    case resized = "c2pa.resized"

    /**
     A conversion of one encoding to another, including resolution scaling, bitrate adjustment and encoding format change. This action is considered as a non-editorial transformation of the parentOf ingredient.
     */
    case transcoded = "c2pa.transcoded"

    /**
     Changes to the language of the content.
     */
    case translated = "c2pa.translated"

    /**
     Removal of a temporal range of the content.
     */
    case trimmed = "c2pa.trimmed"

    /**
     Something happened, but the claim_generator cannot specify what.
     */
    case unknown = "c2pa.unknown"

    /**
     An invisible watermark was inserted into the digital content for the purpose of creating a soft binding.
     */
    case watermarked = "c2pa.watermarked"
}
