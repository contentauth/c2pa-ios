//
//  ShapeType.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 The type of shape for the range.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#shapetype
 */
public enum ShapeType: String, Codable {

    case rectangle
    case circle
    case polygon
}
