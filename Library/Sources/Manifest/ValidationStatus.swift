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
//  ValidationStatus.swift
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
