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
//  ReviewRating.swift
//

import Foundation

/**
 A rating on an Assertion. See https://c2pa.org/specifications/specifications/1.0/specs/C2PA_Specification.html#_claim_review.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#reviewrating
 */
public struct ReviewRating: Codable, Equatable {

    public var code: String?

    public var explanation: String

    public var value: UInt8


    public init(code: String? = nil, explanation: String, value: UInt8) {
        self.code = code
        self.explanation = explanation
        self.value = value
    }
}
