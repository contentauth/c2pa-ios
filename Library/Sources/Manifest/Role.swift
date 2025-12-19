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
//  Role.swift
//

import Foundation

/// A role describing the region.
/// - SeeAlso: [Role Reference](https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-definition-schema/#role)
public enum Role: String, Codable {

    /// Arbitrary area worth identifying.
    case areaOfInterest = "c2pa.areaOfInterest"

    /// This area is all that is left after a crop action.
    case cropped = "c2pa.cropped"

    /// This area has had edits applied to it.
    case edited = "c2pa.edited"

    /// The area where an ingredient was placed/added.
    case placed = "c2pa.placed"

    /// Something in this area was redacted.
    case redacted = "c2pa.redacted"

    /// Area specific to a subject (human or not).
    case subjectArea = "c2pa.subjectArea"

    /// A range of information was removed/deleted.
    case deleted = "c2pa.deleted"

    /// Styling was applied to this area.
    case styled = "c2pa.styled"

    /// Invisible watermarking was applied to this area for the purpose of soft binding.
    case watermarked = "c2pa.watermarked"
}
