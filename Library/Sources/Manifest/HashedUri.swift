//
//  HashedUri.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 A HashedUri provides a reference to content available within the same manifest store. This is described in §8.3, URI References of the C2PA Technical Specification.

 https://c2pa.org/specifications/specifications/2.1/specs/C2PA_Specification.html#_uri_references
 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#hasheduri
 */
open class HashedUri: UriOrResource {

    public enum CodingKeys: String, CodingKey {
        case hash
        case url
    }

    /**
     Byte string containing the hash value.
     */
    open var hash: [UInt8]

    /**
     JUMBF URI reference
     */
    open var url: String


    /**
     - parameter alg: A string identifying the cryptographic hash algorithm used to compute the hash.
     - parameter hash: Byte string containing the hash value.
     - parameter url: JUMBF URI reference
     */
    public init(alg: String? = nil, hash: [UInt8], url: String) {
        self.hash = hash
        self.url = url

        super.init(alg: alg)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        hash = try container.decode([UInt8].self, forKey: .hash)
        url = try container.decode(String.self, forKey: .url)

        try super.init(from: decoder)
    }

    override open func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(hash, forKey: .hash)
        try container.encode(url, forKey: .url)
    }
}
