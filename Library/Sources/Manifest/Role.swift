//
//  Role.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 A role describing the region.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#role
 */
public enum Role: String, Codable {

    /**
     Arbitrary area worth identifying.
     */
    case areaOfInterest = "c2pa.areaOfInterest"

    /**
     This area is all that is left after a crop action.
     */
    case cropped = "c2pa.cropped"

    /**
     This area has had edits applied to it.
     */
    case edited = "c2pa.edited"

    /**
     The area where an ingredient was placed/added.
     */
    case placed = "c2pa.placed"

    /**
     Something in this area was redacted.
     */
    case redacted = "c2pa.redacted"

    /**
     Area specific to a subject (human or not).
     */
    case subjectArea = "c2pa.subjectArea"

    /**
     A range of information was removed/deleted.
     */
    case deleted = "c2pa.deleted"

    /**
     Styling was applied to this area.
     */
    case styled = "c2pa.styled"

    /**
     Invisible watermarking was applied to this area for the purpose of soft binding.
     */
    case watermarked = "c2pa.watermarked"
}
