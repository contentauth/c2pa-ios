//
//  UnitType.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 The type of unit for the range.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#unittype
 */
public enum UnitType: String, Codable {

    /**
     Use pixels.
     */
    case pixel

    /**
     Use percentage.
     */
    case percent
}
