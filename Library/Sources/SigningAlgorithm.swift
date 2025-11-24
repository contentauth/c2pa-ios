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
//  SigningAlgorithm.swift
//

import C2PAC
import Foundation

/// Cryptographic algorithms supported for C2PA signing.
///
/// These algorithms are used to cryptographically sign C2PA manifests,
/// providing authenticity and integrity guarantees.
///
/// ## Topics
///
/// ### ECDSA Algorithms
/// - ``es256``
/// - ``es384``
/// - ``es512``
///
/// ### RSA-PSS Algorithms
/// - ``ps256``
/// - ``ps384``
/// - ``ps512``
///
/// ### EdDSA Algorithm
/// - ``ed25519``
public enum SigningAlgorithm {
    /// ECDSA with SHA-256 using the P-256 curve.
    ///
    /// This is the most widely supported algorithm and is recommended for most use cases.
    /// It is the only algorithm supported by the iOS Secure Enclave.
    case es256

    /// ECDSA with SHA-384 using the P-384 curve.
    case es384

    /// ECDSA with SHA-512 using the P-521 curve.
    case es512

    /// RSA-PSS with SHA-256.
    case ps256

    /// RSA-PSS with SHA-384.
    case ps384

    /// RSA-PSS with SHA-512.
    case ps512

    /// EdDSA using Curve25519.
    ///
    /// - Note: Not supported by iOS Keychain or Secure Enclave.
    case ed25519

    var cValue: C2paSigningAlg {
        switch self {
        case .es256: return Es256
        case .es384: return Es384
        case .es512: return Es512
        case .ps256: return Ps256
        case .ps384: return Ps384
        case .ps512: return Ps512
        case .ed25519: return Ed25519
        }
    }

    public var description: String {
        switch self {
        case .es256: return "es256"
        case .es384: return "es384"
        case .es512: return "es512"
        case .ps256: return "ps256"
        case .ps384: return "ps384"
        case .ps512: return "ps512"
        case .ed25519: return "ed25519"
        }
    }
}

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
///     tsaURL: "http://timestamp.digicert.com"
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
    public let tsaURL: String?

    /// Creates a new signer info structure.
    ///
    /// - Parameters:
    ///   - algorithm: The signing algorithm.
    ///   - certificatePEM: The certificate chain in PEM format.
    ///   - privateKeyPEM: The private key in PEM format.
    ///   - tsaURL: Optional timestamp authority URL.
    public init(
        algorithm: SigningAlgorithm,
        certificatePEM: String,
        privateKeyPEM: String,
        tsaURL: String? = nil
    ) {
        self.algorithm = algorithm
        self.certificatePEM = certificatePEM
        self.privateKeyPEM = privateKeyPEM
        self.tsaURL = tsaURL
    }
}
