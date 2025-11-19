//
//  C2PA.swift
//

import C2PAC
import Foundation

/// The main entry point for C2PA operations.
///
/// `C2PA` provides static methods for reading and signing content credentials in media files.
/// It wraps the underlying C2PA Rust library with a type-safe Swift API.
///
/// ## Topics
///
/// ### Reading Manifests
/// - ``readFile(at:dataDir:)``
/// - ``readIngredient(at:dataDir:)``
///
/// ### Signing Files
/// - ``signFile(source:destination:manifestJSON:signerInfo:dataDir:)``
public enum C2PA {
    /// Reads the C2PA manifest from a file and returns it as JSON.
    ///
    /// This method extracts and validates the C2PA manifest embedded in a media file,
    /// returning the manifest data as a JSON string.
    ///
    /// - Parameters:
    ///   - url: The URL of the file to read the manifest from.
    ///   - dataDir: Optional directory for storing temporary or cached data during processing.
    ///
    /// - Returns: A JSON string containing the C2PA manifest data.
    ///
    /// - Throws: ``C2PAError`` if the file cannot be read, has no manifest, or contains invalid data.
    ///
    /// ## Example
    ///
    /// ```swift
    /// do {
    ///     let manifestJSON = try C2PA.readFile(at: imageURL)
    ///     print("Manifest: \(manifestJSON)")
    /// } catch {
    ///     print("Failed to read manifest: \(error)")
    /// }
    /// ```
    ///
    /// - SeeAlso: ``readIngredient(at:dataDir:)``
    public static func readFile(
        at url: URL,
        dataDir: URL? = nil
    ) throws -> String {
        try stringFromC(
            c2pa_read_file(url.path, dataDir?.path)
        )
    }

    /// Reads ingredient information from a file that will be used in a C2PA manifest.
    ///
    /// This method extracts information about a media file that will be referenced as an
    /// ingredient (source material) in a new C2PA manifest. Ingredients represent the
    /// original or modified content used to create a new asset.
    ///
    /// - Parameters:
    ///   - url: The URL of the ingredient file to read.
    ///   - dataDir: Optional directory for storing temporary or cached data during processing.
    ///
    /// - Returns: A JSON string containing the ingredient information.
    ///
    /// - Throws: ``C2PAError`` if the file cannot be read or processed as an ingredient.
    ///
    /// ## Example
    ///
    /// ```swift
    /// do {
    ///     let ingredientJSON = try C2PA.readIngredient(at: originalImageURL)
    ///     // Use ingredientJSON when building a new manifest
    /// } catch {
    ///     print("Failed to read ingredient: \(error)")
    /// }
    /// ```
    ///
    /// - SeeAlso: ``readFile(at:dataDir:)``
    public static func readIngredient(
        at url: URL,
        dataDir: URL? = nil
    ) throws -> String {
        let result = c2pa_read_ingredient_file(url.path, dataDir?.path)
        guard let result = result else {
            let errorMsg = lastC2PAError()
            // TODO: This special case handling may be removable if the underlying C API
            // is updated to handle NULL data_dir consistently with c2pa_read_file
            if errorMsg.contains("null parameter data_dir") || errorMsg.contains("data_dir") {
                throw C2PAError.api("No ingredient data found")
            }
            throw C2PAError.api(errorMsg)
        }
        return try stringFromC(result)
    }

    /// Signs a media file with a C2PA manifest using PEM-encoded certificates and keys.
    ///
    /// This convenience method creates a signed copy of the source file with an embedded
    /// C2PA manifest. The manifest contains assertions about the content, its provenance,
    /// and is cryptographically signed using the provided credentials.
    ///
    /// - Parameters:
    ///   - source: The URL of the source file to sign.
    ///   - destination: The URL where the signed file will be written.
    ///   - manifestJSON: A JSON string defining the C2PA manifest structure and assertions.
    ///   - signerInfo: The signing credentials including certificate chain and private key.
    ///   - dataDir: Optional directory for storing temporary or cached data during processing.
    ///
    /// - Throws: ``C2PAError`` if signing fails due to invalid inputs, I/O errors, or cryptographic issues.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let signerInfo = SignerInfo(
    ///     certificatePEM: certPEM,
    ///     privateKeyPEM: keyPEM,
    ///     algorithm: .es256,
    ///     tsaURL: "http://timestamp.digicert.com"
    /// )
    ///
    /// try C2PA.signFile(
    ///     source: sourceURL,
    ///     destination: destURL,
    ///     manifestJSON: manifestJSON,
    ///     signerInfo: signerInfo
    /// )
    /// ```
    ///
    /// - Note: For more advanced signing scenarios, including hardware-backed keys
    ///   and streaming operations, use ``Builder`` with a ``Signer`` instance.
    ///
    /// - SeeAlso: ``Builder``, ``Signer``, ``SignerInfo``
    public static func signFile(
        source: URL,
        destination: URL,
        manifestJSON: String,
        signerInfo: SignerInfo,
        dataDir: URL? = nil
    ) throws {
        var maybeErr: UnsafeMutablePointer<CChar>?
        withSignerInfo(
            alg: signerInfo.algorithm.description,
            cert: signerInfo.certificatePEM,
            key: signerInfo.privateKeyPEM,
            tsa: signerInfo.tsaURL
        ) { algPtr, certPtr, keyPtr, tsaPtr in
            var sInfo = C2paSignerInfo(
                alg: algPtr,
                sign_cert: certPtr,
                private_key: keyPtr,
                ta_url: tsaPtr)
            maybeErr = c2pa_sign_file(
                source.path,
                destination.path,
                manifestJSON,
                &sInfo,
                dataDir?.path)
        }

        if let e = maybeErr {
            let msg = try stringFromC(e)
            throw C2PAError.api(msg)
        }
    }
}

/// Errors that can occur during C2PA operations.
///
/// `C2PAError` represents various error conditions that may arise when working
/// with the C2PA library, from low-level C API errors to data validation failures.
public enum C2PAError: Error, CustomStringConvertible {
    /// An error reported by the underlying C2PA library.
    ///
    /// - Parameter message: The error message from the Rust/C layer.
    case api(String)

    /// An unexpected NULL pointer was encountered in the C API.
    case nilPointer

    /// Invalid UTF-8 data was returned from the C2PA library.
    case utf8

    /// A negative status code was returned from the C API.
    ///
    /// - Parameter value: The negative status value.
    case negative(Int64)

    /// A human-readable description of the error.
    public var description: String {
        switch self {
        case .api(let m): return "C2PA-API error: \(m)"
        case .nilPointer: return "Unexpected NULL pointer"
        case .utf8: return "Invalid UTF-8 from C2PA"
        case .negative(let v): return "C2PA negative status \(v)"
        }
    }
}
