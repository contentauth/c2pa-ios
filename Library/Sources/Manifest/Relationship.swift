//
//  Relationship.swift
//  C2PA
//
//  Created by Benjamin Erhart on 06.10.25.
//

import Foundation

/**
 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def#relationship
 */
public enum Relationship: String, Codable {

    case parentOf
    case componentOf
    case inputTo
}
