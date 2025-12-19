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
//  RegionRange.swift
//

import Foundation

/**
 A spatial, temporal, frame, or textual range describing the region of interest.

 https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-def/#range
 */
public struct RegionRange: Codable, Equatable {

    /**
     A frame range.
     */
    public var frame: Frame?

    /**
     An item identifier.
     */
    public var item: Item?

    /**
     A spatial range.
     */
    public var shape: Shape?

    /**
     A textual range.
     */
    public var text: Text?

    /**
     A temporal range.
     */
    public var time: Time?

    /**
     The type of range of interest.
     */
    public var type: RangeType


    /**
     - parameter frame: A frame range.
     - parameter item: An item identifier.
     - parameter shape: A spatial range.
     - parameter text: A textual range.
     - parameter time: A temporal range.
     - parameter type: The type of range of interest.
     */
    public init(
        frame: Frame? = nil,
        item: Item? = nil,
        shape: Shape? = nil,
        text: Text? = nil,
        time: Time? = nil,
        type: RangeType
    ) {
        self.frame = frame
        self.item = item
        self.shape = shape
        self.text = text
        self.time = time
        self.type = type
    }
}
