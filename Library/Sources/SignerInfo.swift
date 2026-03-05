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
//  SignerInfo.swift
//

import Foundation

/// A container for signing credentials and configuration.
///
/// `SignerInfo` bundles together all the information needed to create a basic
/// PEM-based signer. This is a convenience structure for simple signing scenarios.
///
/// ## Example
///
/// ```swift
/// let signerInfo = SignerInfo(
///     algorithm: .es256,
///     certificatePEM: certChainPEM,
///     privateKeyPEM: privateKeyPEM,
///     tsa: URL(string: "http://timestamp.digicert.com")
/// )
///
/// let signer = try Signer(info: signerInfo)
/// ```
///
/// - SeeAlso: ``Signer/init(info:)``
public struct SignerInfo {
    /// The signing algorithm to use.
    public let algorithm: SigningAlgorithm

    /// The certificate chain in PEM format.
    public let certificatePEM: String

    /// The private key in PEM format.
    public let privateKeyPEM: String

    /// Optional URL of a timestamp authority for trusted timestamps.
    public let tsa: URL?

    /// Creates a new signer info structure.
    ///
    /// - Parameters:
    ///   - algorithm: The signing algorithm.
    ///   - certificatePEM: The certificate chain in PEM format.
    ///   - privateKeyPEM: The private key in PEM format.
    ///   - tsa: Optional timestamp authority URL.
    public init(
        algorithm: SigningAlgorithm,
        certificatePEM: String,
        privateKeyPEM: String,
        tsa: URL? = nil
    ) {
        self.algorithm = algorithm
        self.certificatePEM = certificatePEM
        self.privateKeyPEM = privateKeyPEM
        self.tsa = tsa
    }
}
