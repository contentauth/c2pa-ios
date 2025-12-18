//
//  ValidationStatus.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 A ValidationStatus struct describes the validation status of a specific part of a manifest.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#validationstatus
 */
public struct ValidationStatus: Codable, Equatable {

    public var code: ValidationStatusCode

    public var explanation: String?

    public var success: Bool?

    public var url: String?


    public init(code: ValidationStatusCode, explanation: String? = nil, success: Bool? = nil, url: String? = nil) {
        self.code = code
        self.explanation = explanation
        self.success = success
        self.url = url
    }
}
