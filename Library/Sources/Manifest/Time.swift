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
//  Time.swift
//

import Foundation

/**
 A temporal range representing a starting time to an ending time.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#time
 */
public struct Time: Codable, Equatable {

    /**
     The end time or the end of the asset if not present.
     */
    public var end: String?

    /**
     The start time or the start of the asset if not present.
     */
    public var start: String?

    /**
     The type of time.
     */
    public var type: TimeType?


    /**
     - parameter end: The end time or the end of the asset if not present.
     - parameter start: The start time or the start of the asset if not present.
     - parameter type: The type of time.
     */
    public init(end: String? = nil, start: String? = nil, type: TimeType? = nil) {
        self.end = end
        self.start = start
        self.type = type
    }
}
