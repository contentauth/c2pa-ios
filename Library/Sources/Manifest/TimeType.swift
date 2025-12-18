//
//  TimeType.swift
//  C2PA
//
//  Created by Benjamin Erhart on 07.10.25.
//

import Foundation

/**
 The type of time.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#timetype
 */
public enum TimeType: String, Codable {

    /**
     Times are described using Normal Play Time (npt) as described in RFC 2326.
     */
    case npt
}
