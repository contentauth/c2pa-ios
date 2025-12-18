//
//  AssetType.swift
//  C2PA
//
//  Created by Benjamin Erhart on 06.10.25.
//

import Foundation

/**
 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def#assettype
 */
public struct AssetType: Codable, Equatable {

    public var type: String

    public var version: String?


    public init(type: String, version: String? = nil) {
        self.type = type
        self.version = version
    }
}
