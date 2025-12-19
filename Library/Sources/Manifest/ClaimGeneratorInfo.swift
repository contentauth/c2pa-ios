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
//  ClaimGeneratorInfo.swift
//

import Foundation

#if !os(macOS)
import UIKit
#endif

/// Description of the claim generator, or the software used in generating the claim.
/// - SeeAlso: [ClaimGeneratorInfo Reference](https://opensource.contentauthenticity.org/docs/manifest/json-ref/manifest-definition-schema#claimgeneratorinfo)
public struct ClaimGeneratorInfo: Codable, Equatable {

    public enum CodingKeys: String, CodingKey {
        case icon
        case name
        case operatingSystem = "operating_system"
        case version
    }

    /// Hashed URI to the icon (either embedded or remote).
    public var icon: UriOrResource?

    /// A human readable string naming the claim_generator.
    public var name: String

    /// A human readable string of the OS the claim generator is running on.
    public var operatingSystem: String?

    /// A human readable string of the product’s version
    public var version: String?

    /// - Parameters:
    ///   - icon: Hashed URI to the icon (either embedded or remote).
    ///   - name: A human readable string naming the claim_generator. *(This is automatically evaluated by default. You should not set this yourself!)*
    ///   - operatingSystem: A human readable string of the OS the claim generator is running on. *(You should use ClaimGeneratorInfo.operatingSystem to fill this!)*
    ///   - version: A human readable string of the product’s version. *(This is automatically evaluated by default. You should not set this yourself!)*
    public init(
        icon: UriOrResource? = nil,
        name: String = ClaimGeneratorInfo.appName,
        operatingSystem: String? = nil,
        version: String? = ClaimGeneratorInfo.appVersion
    ) {
        self.icon = icon
        self.name = name
        self.operatingSystem = operatingSystem
        self.version = version
    }

#if os(macOS)
    public static var operatingSystem: String {
        "macOS \(ProcessInfo.processInfo.operatingSystemVersionString)"
    }
#else
    @MainActor
    public static var operatingSystem: String {
        "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }
#endif

    public static var appName: String {
        Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
            ?? ""
    }

    public static var appVersion: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
