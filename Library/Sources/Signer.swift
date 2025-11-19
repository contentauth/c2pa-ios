//
//  Signer.swift
//

import C2PAC
import Foundation

/// A cryptographic signer for creating C2PA signatures.
///
/// `Signer` encapsulates the signing credentials and algorithm needed to
/// cryptographically sign C2PA manifests. It supports multiple initialization
/// methods for different credential sources:
///
/// - PEM-encoded certificates and private keys
/// - Custom signing closures (for hardware keys or remote signing)
/// - ``SignerInfo`` convenience wrapper
///
/// ## Topics
///
/// ### Creating a Signer
/// - ``init(certsPEM:privateKeyPEM:algorithm:tsaURL:)``
/// - ``init(info:)``
/// - ``init(algorithm:certificateChainPEM:tsaURL:sign:)``
///
/// ### Signing Operations
/// - ``reserveSize()``
///
/// ### Keychain Utilities
/// - ``exportPublicKeyPEM(fromKeychainTag:)``
///
/// ## Example with PEM Credentials
///
/// ```swift
/// let signer = try Signer(
///     certsPEM: certificateChainPEM,
///     privateKeyPEM: privateKeyPEM,
///     algorithm: .es256,
///     tsaURL: "http://timestamp.digicert.com"
/// )
/// ```
///
/// ## Example with Custom Signing Closure
///
/// ```swift
/// let signer = try Signer(
///     algorithm: .es256,
///     certificateChainPEM: certChainPEM,
///     tsaURL: "http://timestamp.digicert.com"
/// ) { dataToSign in
///     // Custom signing logic (e.g., hardware key, remote service)
///     return try signWithHardwareKey(dataToSign)
/// }
/// ```
///
/// - SeeAlso: ``KeychainSigner``, ``SecureEnclaveSigner``, ``WebServiceSigner``
public final class Signer {
    let ptr: UnsafeMutablePointer<C2paSigner>
    private var retainedContext: Unmanaged<AnyObject>?

    private init(ptr: UnsafeMutablePointer<C2paSigner>) {
        self.ptr = ptr
    }

    /// Creates a signer with PEM-encoded certificates and private key.
    ///
    /// This is the most common initialization method for signers using
    /// standard PEM-encoded credentials.
    ///
    /// - Parameters:
    ///   - certsPEM: The certificate chain in PEM format.
    ///   - privateKeyPEM: The private key in PEM format.
    ///   - algorithm: The signing algorithm to use.
    ///   - tsaURL: Optional URL of a timestamp authority for trusted timestamps.
    ///
    /// - Throws: ``C2PAError`` if the credentials are invalid or incompatible.
    ///
    /// - SeeAlso: ``init(info:)``
    public convenience init(
        certsPEM: String,
        privateKeyPEM: String,
        algorithm: SigningAlgorithm,
        tsaURL: String? = nil
    ) throws {
        var raw: UnsafeMutablePointer<C2paSigner>!
        try withSignerInfo(
            alg: algorithm.description,
            cert: certsPEM,
            key: privateKeyPEM,
            tsa: tsaURL
        ) { algPtr, certPtr, keyPtr, tsaPtr in
            var info = C2paSignerInfo(
                alg: algPtr,
                sign_cert: certPtr,
                private_key: keyPtr,
                ta_url: tsaPtr)
            raw = try guardNotNull(c2pa_signer_from_info(&info))
        }
        self.init(ptr: raw)
    }

    /// Creates a signer from a ``SignerInfo`` struct.
    ///
    /// This convenience initializer accepts a ``SignerInfo`` struct containing
    /// all necessary signing credentials.
    ///
    /// - Parameter info: The signing credentials and configuration.
    ///
    /// - Throws: ``C2PAError`` if the credentials are invalid or incompatible.
    ///
    /// - SeeAlso: ``SignerInfo``
    public convenience init(info: SignerInfo) throws {
        try self.init(
            certsPEM: info.certificatePEM,
            privateKeyPEM: info.privateKeyPEM,
            algorithm: info.algorithm,
            tsaURL: info.tsaURL)
    }

    /// Creates a signer with a custom signing closure.
    ///
    /// This initializer enables advanced signing scenarios where the private key
    /// is not directly accessible as PEM data. Common use cases include:
    ///
    /// - Hardware security modules (HSM)
    /// - Secure Enclave on iOS devices
    /// - Remote signing services
    /// - Keychain-stored keys
    ///
    /// The signing closure receives the data to be signed and must return the
    /// signature bytes. The closure is called during the signing operation.
    ///
    /// - Parameters:
    ///   - algorithm: The signing algorithm that matches your closure's implementation.
    ///   - certificateChainPEM: The certificate chain in PEM format.
    ///   - tsaURL: Optional URL of a timestamp authority for trusted timestamps.
    ///   - sign: A closure that accepts data to sign and returns the signature.
    ///
    /// - Throws: ``C2PAError`` if the signer cannot be created.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let signer = try Signer(
    ///     algorithm: .es256,
    ///     certificateChainPEM: certChain,
    ///     tsaURL: "http://timestamp.digicert.com"
    /// ) { dataToSign in
    ///     let signature = try SecKeyCreateSignature(
    ///         privateKeyRef,
    ///         .ecdsaSignatureMessageX962SHA256,
    ///         dataToSign as CFData,
    ///         nil
    ///     )
    ///     return signature as Data
    /// }
    /// ```
    ///
    /// - SeeAlso: ``SecureEnclaveSigner``, ``KeychainSigner``
    public convenience init(
        algorithm: SigningAlgorithm,
        certificateChainPEM: String,
        tsaURL: String? = nil,
        sign: @escaping (Data) throws -> Data
    ) throws {
        // keep closure alive
        final class Box {
            let fn: (Data) throws -> Data
            init(_ fn: @escaping (Data) throws -> Data) { self.fn = fn }
        }
        let box = Box(sign)
        let ref = Unmanaged.passRetained(box as AnyObject)  // Retain Box as AnyObject

        let tramp: SignerCallback = { ctx, bytes, len, dst, dstCap in
            // ctx is the opaque pointer to our Box instance
            guard let ctx, let bytes, let dst else { return -1 }
            let b = Unmanaged<Box>.fromOpaque(ctx).takeUnretainedValue()
            let msg = Data(bytes: bytes, count: Int(len))  // len is uintptr_t (UInt)

            do {
                let sig = try b.fn(msg)
                // dstCap is uintptr_t (UInt)
                guard UInt(sig.count) <= dstCap else { return -1 }  // Compare UInts
                sig.copyBytes(to: dst, count: sig.count)
                return sig.count
            } catch {
                return -1
            }
        }

        var raw: UnsafeMutablePointer<C2paSigner>!
        try certificateChainPEM.withCString { certPtr in
            try withOptionalCString(tsaURL) { tsaPtr in
                raw = try guardNotNull(
                    c2pa_signer_create(
                        ref.toOpaque(),  // Pass opaque pointer to Box instance
                        tramp,
                        algorithm.cValue,
                        certPtr,
                        tsaPtr
                    )
                )
            }
        }

        self.init(ptr: raw)
        retainedContext = ref  // Store the Unmanaged<AnyObject>
    }

    deinit {
        c2pa_signer_free(ptr)
        retainedContext?.release()
    }

    /// Returns the expected signature size in bytes for this signer.
    ///
    /// This method is used internally to allocate buffer space for the signature.
    /// The size depends on the signing algorithm configured for this signer.
    ///
    /// - Returns: The signature size in bytes.
    ///
    /// - Throws: ``C2PAError`` if the size cannot be determined.
    public func reserveSize() throws -> Int {
        try Int(guardNonNegative(c2pa_signer_reserve_size(ptr)))
    }
}

extension Signer {
    /// Exports the public key from a keychain-stored key as PEM format.
    ///
    /// This utility method retrieves a private key from the iOS/macOS keychain
    /// and exports its corresponding public key in PEM format. This is useful
    /// when working with keychain-stored keys that need to be shared or
    /// included in certificate signing requests.
    ///
    /// - Parameter keyTag: The keychain tag identifying the private key.
    ///
    /// - Returns: The public key in PEM format.
    ///
    /// - Throws: ``C2PAError`` if the key cannot be found or exported.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let publicKeyPEM = try Signer.exportPublicKeyPEM(
    ///     fromKeychainTag: "com.example.signing.key"
    /// )
    /// ```
    ///
    /// - SeeAlso: ``KeychainSigner``, ``SecureEnclaveSigner``
    public static func exportPublicKeyPEM(fromKeychainTag keyTag: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
            let privateKey = item as! SecKey?
        else {
            throw C2PAError.api("Failed to find key '\(keyTag)' in keychain: \(status)")
        }

        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw C2PAError.api("Failed to extract public key")
        }

        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data?
        else {
            if let error = error?.takeRetainedValue() {
                throw C2PAError.api("Failed to export public key: \(error)")
            }
            throw C2PAError.api("Failed to export public key")
        }

        let base64 = publicKeyData.base64EncodedString(options: [
            .lineLength64Characters, .endLineWithLineFeed
        ])
        return "-----BEGIN PUBLIC KEY-----\n\(base64)\n-----END PUBLIC KEY-----"
    }
}
