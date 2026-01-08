// This file is licensed to you under the Apache License, Version 2.0
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE
// files for the specific language governing permissions and limitations under
// each license.
//
//  Action.swift
//

import Foundation

/// - SeeAlso: [Actions Reference](https://opensource.contentauthenticity.org/docs/manifest/writing/assertions-actions#actions)

public struct Action: Codable, Equatable {

    /// The action name. Most probably a ``PredefinedAction``.
    public var action: String

    /// A URL identifying an IPTC term. Most probably a ``DigitalSourceType``.
    public var digitalSourceType: String?

    /// The software or hardware used to perform the action.
    public var softwareAgent: String?

    /// Additional information describing the action.
    public var parameters: [String: String]?


    /// - Parameters:
    ///   - action: The action name. Most probably a ``PredefinedAction``.
    ///   - digitalSourceType: A URL identifying an IPTC term. Most probably a ``DigitalSourceType``.
    ///   - softwareAgent: The software or hardware used to perform the action. Defaults to the app name.
    ///   - parameters: Additional information describing the action.
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

    /// - Parameters:
    ///   - action: The action name as a ``PredefinedAction``.
    ///   - digitalSourceType: A URL identifying an IPTC term as a ``DigitalSourceType``.
    ///   - softwareAgent: The software or hardware used to perform the action. Defaults to the app name.
    ///   - parameters: Additional information describing the action.
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
