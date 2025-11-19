//
//  SecureEnclaveSigner.swift
//

import C2PAC
import Foundation
import Security

/// Configuration for Secure Enclave-based signing.
///
/// This structure defines the parameters needed to create or access a private key
/// in the iOS Secure Enclave, providing hardware-backed security for signing operations.
public struct SecureEnclaveSignerConfig {
    /// The keychain tag identifying the Secure Enclave key.
    public let keyTag: String

    /// Access control flags determining when and how the key can be used.
    public let accessControl: SecAccessControlCreateFlags

    /// Creates a new Secure Enclave signer configuration.
    ///
    /// - Parameters:
    ///   - keyTag: A unique identifier for the key in the keychain.
    ///   - accessControl: Security flags controlling key usage. Defaults to `.privateKeyUsage`.
    public init(
        keyTag: String,
        accessControl: SecAccessControlCreateFlags = [.privateKeyUsage]
    ) {
        self.keyTag = keyTag
        self.accessControl = accessControl
    }
}

extension Signer {
    /// Creates a signer using a private key stored in the iOS Secure Enclave.
    ///
    /// The Secure Enclave provides hardware-backed security where the private key
    /// never leaves the secure hardware. This is the most secure signing method
    /// available on iOS devices with Secure Enclave support (iPhone 5s and later).
    ///
    /// If the specified key doesn't exist, it will be automatically created in the
    /// Secure Enclave.
    ///
    /// - Parameters:
    ///   - algorithm: Must be `.es256` (the only algorithm supported by Secure Enclave).
    ///   - certificateChainPEM: The certificate chain in PEM format.
    ///   - tsaURL: Optional URL of a timestamp authority.
    ///   - secureEnclaveConfig: Configuration specifying the key tag and access control.
    ///
    /// - Throws: ``C2PAError`` if the algorithm is not ES256, if the Secure Enclave is
    ///   unavailable, or if signing fails.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let config = SecureEnclaveSignerConfig(
    ///     keyTag: "com.example.c2pa.secureenclave",
    ///     accessControl: [.privateKeyUsage, .biometryCurrentSet]
    /// )
    ///
    /// let signer = try Signer(
    ///     algorithm: .es256,
    ///     certificateChainPEM: certChainPEM,
    ///     tsaURL: "http://timestamp.digicert.com",
    ///     secureEnclaveConfig: config
    /// )
    /// ```
    ///
    /// - Important: Only ES256 (P-256) is supported by the Secure Enclave.
    ///   The key is bound to the device and cannot be exported.
    ///
    /// - Note: Secure Enclave is only available on devices with the hardware capability.
    ///   Not available in the iOS Simulator.
    ///
    /// - SeeAlso: ``createSecureEnclaveKey(config:)``, ``deleteSecureEnclaveKey(keyTag:)``
    public convenience init(
        algorithm: SigningAlgorithm,
        certificateChainPEM: String,
        tsaURL: String? = nil,
        secureEnclaveConfig: SecureEnclaveSignerConfig
    ) throws {
        guard algorithm == .es256 else {
            throw C2PAError.api("Secure Enclave only supports ES256 (P-256)")
        }

        try self.init(
            algorithm: algorithm,
            certificateChainPEM: certificateChainPEM,
            tsaURL: tsaURL
        ) { data in
            let query: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: secureEnclaveConfig.keyTag,
                kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
                kSecReturnRef as String: true
            ]

            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)

            let privateKey: SecKey
            if status == errSecItemNotFound {
                privateKey = try Signer.createSecureEnclaveKey(config: secureEnclaveConfig)
            } else if status == errSecSuccess,
                let key = item as! SecKey?
            {
                privateKey = key
            } else {
                throw C2PAError.api("Failed to access Secure Enclave key: \(status)")
            }

            let algorithm = SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256

            guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
                throw C2PAError.api("Secure Enclave key doesn't support required algorithm")
            }

            var error: Unmanaged<CFError>?
            guard
                let signature = SecKeyCreateSignature(
                    privateKey,
                    algorithm,
                    data as CFData,
                    &error)
            else {
                if let error = error?.takeRetainedValue() {
                    throw C2PAError.api("Secure Enclave signing failed: \(error)")
                }
                throw C2PAError.api("Secure Enclave signing failed")
            }

            return signature as Data
        }
    }

    /// Creates a new P-256 private key in the Secure Enclave.
    ///
    /// This method generates a new elliptic curve key pair with the private key stored
    /// in the Secure Enclave hardware. The key is permanently stored and can be accessed
    /// later using the configured key tag.
    ///
    /// - Parameter config: Configuration specifying the key tag and access control.
    ///
    /// - Returns: A `SecKey` reference to the newly created private key.
    ///
    /// - Throws: ``C2PAError`` if key generation fails or if the Secure Enclave is unavailable.
    ///
    /// - Important: Keys created in the Secure Enclave cannot be extracted or exported.
    ///   They can only be used for signing operations within the Secure Enclave.
    ///
    /// - SeeAlso: ``deleteSecureEnclaveKey(keyTag:)``
    public static func createSecureEnclaveKey(config: SecureEnclaveSignerConfig) throws -> SecKey {
        guard
            let access = SecAccessControlCreateWithFlags(
                kCFAllocatorDefault,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                config.accessControl,
                nil
            )
        else {
            throw C2PAError.api("Failed to create access control")
        }

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: config.keyTag,
                kSecAttrAccessControl as String: access
            ]
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            if let error = error?.takeRetainedValue() {
                throw C2PAError.api("Failed to create Secure Enclave key: \(error)")
            }
            throw C2PAError.api("Failed to create Secure Enclave key")
        }

        return privateKey
    }

    /// Deletes a Secure Enclave key from the keychain.
    ///
    /// This method permanently removes a Secure Enclave key identified by its tag.
    /// Once deleted, the key cannot be recovered.
    ///
    /// - Parameter keyTag: The keychain tag identifying the key to delete.
    ///
    /// - Returns: `true` if the key was deleted or didn't exist, `false` if deletion failed.
    ///
    /// - Important: This operation is permanent and cannot be undone.
    ///
    /// - SeeAlso: ``createSecureEnclaveKey(config:)``
    public static func deleteSecureEnclaveKey(keyTag: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
