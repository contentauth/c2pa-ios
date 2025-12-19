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
//  Coordinate.swift
//

import Foundation

/// An x, y coordinate used for specifying vertices in polygons.
/// - SeeAlso: [Coordinate Reference](https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-definition-schema/#coordinate)
public struct Coordinate: Codable, Equatable {

    /// The coordinate along the x-axis.
    public var x: Double

    /// The coordinate along the y-axis.
    public var y: Double


    /// - Parameters:
    ///   - x: The coordinate along the x-axis.
    ///   - y: The coordinate along the y-axis.
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
