//
//  Action.swift
//  C2PA
//
//  Created by Benjamin Erhart on 08.10.25.
//

import Foundation

/**
 https://opensource.contentauthenticity.org/docs/manifest/writing/assertions-actions#actions
 */

public struct Action: Codable, Equatable {

    /**
     The action name. Most probably a ``PredefinedAction``.
     */
    public var action: String

    /**
     A URL identifying an IPTC term. Most probably a ``DigitalSourceType``.
     */
    public var digitalSourceType: String?

    /**
     The software or hardware used to perform the action.
     */
    public var softwareAgent: String?

    /**
     Additional information describing the action.
     */
    public var parameters: [String: String]?


    /**
     - parameter action: The action name. Most probably a ``PredefinedAction``.
     - parameter digitalSourceType: A URL identifying an IPTC term. Most probably a ``DigitalSourceType``.
     - parameter softwareAgent: The software or hardware used to perform the action. Defaults to the app name.
     - parameter parameters: Additional information describing the action.
     */
    public init(
        action: String,
        digitalSourceType: String? = nil,
        softwareAgent: String? = ClaimGeneratorInfo.appName,
        parameters: [String: String]? = nil
    ) {
        self.action = action
        self.digitalSourceType = digitalSourceType
        self.softwareAgent = softwareAgent
        self.parameters = parameters
    }

    /**
     - parameter action: The action name as a ``PredefinedAction``.
     - parameter digitalSourceType: A URL identifying an IPTC term as a ``DigitalSourceType``.
     - parameter softwareAgent: The software or hardware used to perform the action. Defaults to the app name.
     - parameter parameters: Additional information describing the action.
     */
    public init(
        action: PredefinedAction,
        digitalSourceType: DigitalSourceType,
        softwareAgent: String? = ClaimGeneratorInfo.appName,
        parameters: [String: String]? = nil
    ) {
        self.init(
            action: action.rawValue,
            digitalSourceType: digitalSourceType.rawValue,
            softwareAgent: softwareAgent,
            parameters: parameters)
    }
}
