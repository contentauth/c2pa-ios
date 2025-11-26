//
//  ValidationStatusCode.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 https://spec.c2pa.org/specifications/specifications/1.0/specs/C2PA_Specification.html#_existing_manifests
 */
public enum ValidationStatusCode: String, Codable {

    /**
     The claim signature referenced in the ingredient’s claim validated.
     */
    case claimSignatureValidated = "claimSignature.validated"

    /**
     The signing credential is listed on the validator’s trust list.
     */
    case signingCredentialTrusted = "signingCredential.trusted"

    /**
     The time-stamp credential is listed on the validator’s trust list.
     */
    case timeStampTrusted = "timeStamp.trusted"

    /**
     The hash of the the referenced assertion in the ingredient’s manifest matches the corresponding hash in the assertion’s hashed URI in the claim.
     */
    case assertionHashedUriMatch = "assertion.hashedURI.match"

    /**
     Hash of a byte range of the asset matches the hash declared in the data hash assertion.
     */
    case assertionDataHashMatch = "assertion.dataHash.match"

    /**
     Hash of a box-based asset matches the hash declared in the BMFF hash assertion.
     */
    case assertionBmffHashMatch = "assertion.bmffHash.match"

    /**
     A non-embedded (remote) assertion was accessible at the time of validation.
     */
    case assertionAccessible = "assertion.accessible"

    /**
     The referenced claim in the ingredient’s manifest cannot be found.
     */
    case claimMissing = "claim.missing"

    /**
     More than one claim box is present in the manifest.
     */
    case claimMultiple = "claim.multiple"

    /**
     No hard bindings are present in the claim.
     */
    case claimHardBindingsMissing = "claim.hardBindings.missing"

    /**
     The hash of the the referenced ingredient claim in the manifest does not match the corresponding hash in the ingredient’s hashed URI in the claim.
     */
    case ingredientHashedUriMismatch = "ingredient.hashedURI.mismatch"

    /**
     The claim signature referenced in the ingredient’s claim cannot be found in its manifest.
     */
    case claimSignatureMissing = "claimSignature.missing"

    /**
     The claim signature referenced in the ingredient’s claim failed to validate.
     */
    case claimSignatureMismatch = "claimSignature.mismatch"

    /**
     The manifest has more than one ingredient whose relationship is parentOf.
     */
    case manifestMultipleParents = "manifest.multipleParents"

    /**
     The manifest is an update manifest, but it contains hard binding or actions assertions.
     */
    case manifestUpdateInvalid = "manifest.update.invalid"

    /**
     The manifest is an update manifest, but it contains either zero or multiple parentOf ingredients.
     */
    case manifestUpdateWrongParents = "manifest.update.wrongParents"

    /**
     The signing credential is not listed on the validator’s trust list.
     */
    case signingCredentialUntrusted = "signingCredential.untrusted"

    /**
     The signing credential is not valid for signing.
     */
    case signingCredentialInvalid = "signingCredential.invalid"

    /**
     The signing credential has been revoked by the issuer.
     */
    case signingCredentialRevoked = "signingCredential.revoked"

    /**
     The signing credential has expired.
     */
    case signingCredentialExpired = "signingCredential.expired"

    /**
     The time-stamp does not correspond to the contents of the claim.
     */
    case timeStampMismatch = "timeStamp.mismatch"

    /**
     The time-stamp credential is not listed on the validator’s trust list.
     */
    case timeStampUntrusted = "timeStamp.untrusted"

    /**
     The signed time-stamp attribute in the signature falls outside the validity window of the signing certificate or the TSA’s certificate.
     */
    case timeStampOutsideValidity = "timeStamp.outsideValidity"

    /**
     The hash of the the referenced assertion in the manifest does not match the corresponding hash in the assertion’s hashed URI in the claim.
     */
    case assertionHashedUriMismatch = "assertion.hashedURI.mismatch"

    /**
     An assertion listed in the ingredient’s claim is missing from the ingredient’s manifest.
     */
    case assertionMissing = "assertion.missing"

    /**
     An assertion was found in the ingredient’s manifest that was not explicitly declared in the ingredient’s claim.
     */
    case assertionUndeclared = "assertion.undeclared"

    /**
     A non-embedded (remote) assertion was inaccessible at the time of validation.
     */
    case assertionInaccessible = "assertion.inaccessible"

    /**
     An assertion was declared as redacted in the ingredient’s claim but is still present in the ingredient’s manifest.
     */
    case assertionNotRedacted = "assertion.notRedacted"

    /**
     An assertion was declared as redacted by its own claim.
     */
    case assertionSelfRedacted = "assertion.selfRedacted"

    /**
     An action assertion was redacted when the ingredient’s claim was created.
     */
    case assertionActionRedacted = "assertion.action.redacted"

    /**
     The hash of a byte range of the asset does not match the hash declared in the data hash assertion.
     */
    case assertionDataHashMismatch = "assertion.dataHash.mismatch"

    /**
     The hash of a box-based asset does not match the hash declared in the BMFF hash assertion.
     */
    case assertionBmffHashMismatch = "assertion.bmffHash.mismatch"

    /**
     A hard binding assertion is in a cloud data assertion.
     */
    case assertionCloudDataHardBinding = "assertion.cloud-data.hardBinding"

    /**
     An update manifest contains a cloud data assertion referencing an actions assertion.
     */
    case assertionCloudDataActions = "assertion.cloud-data.actions"

    /**
     The value of an alg header, or other header that specifies an algorithm used to compute the value of another field, is unknown or unsupported.
     */
    case algorithmUnsupported = "algorithm.unsupported"
}
