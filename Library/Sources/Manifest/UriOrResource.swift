//
//  UriOrResource.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#uriorresource
 */
open class UriOrResource: Codable, Equatable {

    // MARK: Equatable

    public static func == (lhs: UriOrResource, rhs: UriOrResource) -> Bool {
        lhs.alg == rhs.alg
    }


    // MARK: UriOrResource

    /**
     A string identifying the cryptographic hash algorithm used to compute the hash.
     */
    open var alg: String?


    /**
     - parameter alg: A string identifying the cryptographic hash algorithm used to compute the hash.
     */
    public init(alg: String? = nil) {
        self.alg = alg
    }
}
