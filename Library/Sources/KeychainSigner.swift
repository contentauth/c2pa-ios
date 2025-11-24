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
//  KeychainSigner.swift
//

import C2PAC
import Foundation
import Security

extension Signer {
    /// Creates a signer using a private key stored in the iOS/macOS keychain.
    ///
    /// This initializer enables signing with keys stored in the system keychain,
    /// providing a secure way to manage signing credentials without exposing
    /// the private key data directly in your application.
    ///
    /// - Parameters:
    ///   - algorithm: The signing algorithm (ES256, ES384, ES512, PS256, PS384, or PS512).
    ///   - certificateChainPEM: The certificate chain in PEM format.
    ///   - tsaURL: Optional URL of a timestamp authority.
    ///   - keychainKeyTag: The keychain tag identifying the private key.
    ///
    /// - Throws: ``C2PAError`` if the key cannot be found, doesn't support the algorithm,
    ///   or if signing fails. Also throws for Ed25519 which is not supported by iOS keychain.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // First, ensure your key is in the keychain
    /// let signer = try Signer(
    ///     algorithm: .es256,
    ///     certificateChainPEM: certChainPEM,
    ///     tsaURL: "http://timestamp.digicert.com",
    ///     keychainKeyTag: "com.example.c2pa.signing.key"
    /// )
    ///
    /// let builder = try Builder(manifestJSON: manifestJSON)
    /// try builder.sign(
    ///     format: "image/jpeg",
    ///     source: sourceStream,
    ///     destination: destStream,
    ///     signer: signer
    /// )
    /// ```
    ///
    /// - Important: The key must already exist in the keychain before creating the signer.
    ///   Use standard iOS keychain APIs to generate and store the key.
    ///
    /// - Note: Ed25519 is not supported because iOS Keychain doesn't support this algorithm.
    ///
    /// - SeeAlso: ``SecureEnclaveSigner``, ``exportPublicKeyPEM(fromKeychainTag:)``
    public convenience init(
        algorithm: SigningAlgorithm,
        certificateChainPEM: String,
        tsaURL: String? = nil,
        keychainKeyTag: String
    ) throws {
        let secAlgorithm: SecKeyAlgorithm
        switch algorithm {
        case .es256:
            secAlgorithm = .ecdsaSignatureMessageX962SHA256
        case .es384:
            secAlgorithm = .ecdsaSignatureMessageX962SHA384
        case .es512:
            secAlgorithm = .ecdsaSignatureMessageX962SHA512
        case .ps256:
            secAlgorithm = .rsaSignatureMessagePSSSHA256
        case .ps384:
            secAlgorithm = .rsaSignatureMessagePSSSHA384
        case .ps512:
            secAlgorithm = .rsaSignatureMessagePSSSHA512
        case .ed25519:
            throw C2PAError.api("Ed25519 not supported by iOS Keychain")
        }

        try self.init(
            algorithm: algorithm,
            certificateChainPEM: certificateChainPEM,
            tsaURL: tsaURL
        ) { data in
            let query: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: keychainKeyTag,
                kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecReturnRef as String: true
            ]

            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)

            guard status == errSecSuccess,
                let privateKey = item as! SecKey?
            else {
                throw C2PAError.api("Failed to find key '\(keychainKeyTag)' in keychain: \(status)")
            }

            guard SecKeyIsAlgorithmSupported(privateKey, .sign, secAlgorithm) else {
                throw C2PAError.api("Key doesn't support algorithm \(algorithm)")
            }

            var error: Unmanaged<CFError>?
            guard
                let signature = SecKeyCreateSignature(
                    privateKey,
                    secAlgorithm,
                    data as CFData,
                    &error)
            else {
                if let error = error?.takeRetainedValue() {
                    throw C2PAError.api("Signing failed: \(error)")
                }
                throw C2PAError.api("Signing failed")
            }

            return signature as Data
        }
    }
}
