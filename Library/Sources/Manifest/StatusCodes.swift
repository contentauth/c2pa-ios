//
//  StatusCodes.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 Contains a set of success, informational, and failure validation status codes.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#statuscodes
 */
public struct StatusCodes: Codable, Equatable {

    public var failure: [ValidationStatus] = []

    public var informational: [ValidationStatus] = []

    public var success: [ValidationStatus] = []


    public init(failure: [ValidationStatus], informational: [ValidationStatus], success: [ValidationStatus]) {
        self.failure = failure
        self.informational = informational
        self.success = success
    }
}
