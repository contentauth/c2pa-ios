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
//  StatusCodes.swift
//

import Foundation

/// Contains a set of success, informational, and failure validation status codes.
/// - SeeAlso: [StatusCodes Reference](https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-definition-schema/#statuscodes)
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
