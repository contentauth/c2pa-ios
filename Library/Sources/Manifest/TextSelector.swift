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
//  TextSelector.swift
//

import Foundation

/**
 Selects a range of text via a fragment identifier. This is modeled after the W3C Web Annotation selector model.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#textselector
 */
public struct TextSelector: Codable, Equatable {

    /**
     The end character offset or the end of the fragment if not present.
     */
    public var end: Int32?

    /**
     Fragment identifier as per RFC3023 (XML) or ISO 32000-2 (PDF), Annex O.
     */
    public var fragment: String

    /**
     The start character offset or the start of the fragment if not present.
     */
    public var start: Int32?


    /**
       - parameter end: The end character offset or the end of the fragment if not present.
       - parameter fragment: Fragment identifier as per RFC3023 (XML) or ISO 32000-2 (PDF), Annex O.
       - parameter start: The start character offset or the start of the fragment if not present.
     */
    public init(end: Int32? = nil, fragment: String, start: Int32? = nil) {
        self.end = end
        self.fragment = fragment
        self.start = start
    }
}
