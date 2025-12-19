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
//  Frame.swift
//

import Foundation

/**
 A frame range representing starting and ending frames or pages. If both ``start`` and ``end`` are missing, the frame will span the entire asset.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#frame
 */
public struct Frame: Codable, Equatable {

    /**
     The end of the frame inclusive or the end of the asset if not present.
     */
    public var end: Int32?

    /**
     The start of the frame or the end of the asset if not present.

     The first frame/page starts at 0.
     */
    public var start: Int32?


    /**
     - parameter end: The end of the frame inclusive or the end of the asset if not present.
     - parameter start: The start of the frame or the end of the asset if not present. The first frame/page starts at 0.
     */
    public init(end: Int32? = nil, start: Int32? = nil) {
        self.end = end
        self.start = start
    }
}
