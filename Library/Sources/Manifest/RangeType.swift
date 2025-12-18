//
//  RangeType.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 The type of range for the region of interest.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#rangetype
 */
public enum RangeType: String, Codable {

    /**
     A spatial range. See ``Shape`` for more details.
     */
    case spatial

    /**
     A temporal range. See ``Time`` for more details.
     */
    case temporal

    /**
     A spatial range. See ``Frame`` for more details.
     */
    case frame

    /**
     A textual range. See ``Text`` for more details.
     */
    case textual

    /**
     A range identified by a specific identifier and value. See ``Item`` for more details.
     */
    case identified
}
