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
//  TextSelectorRange.swift
//

import Foundation

/// One or two TextSelectors identifiying the range to select.
/// - SeeAlso: [TextSelectorRange Reference](https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-definition-schema/#textselectorrange)
public struct TextSelectorRange: Codable, Equatable {

    /// The end of the text range.
    public var end: TextSelector?

    /// The start (or entire) text range.
    public var selector: TextSelector


    /// - Parameters:
    ///   - end: The end of the text range.
    ///   - selector: The start (or entire) text range.
    public init(end: TextSelector? = nil, selector: TextSelector) {
        self.end = end
        self.selector = selector
    }
}
