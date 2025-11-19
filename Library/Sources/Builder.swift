//
//  Builder.swift
//

import C2PAC
import Foundation

/// A builder for constructing and signing C2PA manifests with advanced options.
///
/// `Builder` provides fine-grained control over the creation of C2PA manifests,
/// including adding ingredients, resources, and configuring embedding options.
/// Use this class when you need more control than the convenience methods
/// in ``C2PA`` provide.
///
/// ## Topics
///
/// ### Creating a Builder
/// - ``init(manifestJSON:)``
/// - ``init(archiveStream:)``
///
/// ### Configuring the Manifest
/// - ``setNoEmbed()``
/// - ``setRemoteURL(_:)``
///
/// ### Adding Content
/// - ``addResource(uri:stream:)``
/// - ``addIngredient(json:format:from:)``
///
/// ### Signing and Output
/// - ``sign(format:source:destination:signer:)``
/// - ``writeArchive(to:)``
///
/// ## Example
///
/// ```swift
/// let builder = try Builder(manifestJSON: manifestJSON)
/// builder.setNoEmbed()
/// try builder.setRemoteURL("https://example.com/manifest.c2pa")
/// try builder.addIngredient(
///     json: ingredientJSON,
///     format: "image/jpeg",
///     from: ingredientStream
/// )
///
/// let signer = try Signer(info: signerInfo)
/// try builder.sign(
///     format: "image/jpeg",
///     source: sourceStream,
///     destination: destStream,
///     signer: signer
/// )
/// ```
public final class Builder {
    private let ptr: UnsafeMutablePointer<C2paBuilder>

    /// Creates a new builder from a manifest JSON definition.
    ///
    /// - Parameter manifestJSON: A JSON string defining the C2PA manifest structure.
    ///
    /// - Throws: ``C2PAError`` if the JSON is invalid or cannot be parsed.
    public init(manifestJSON: String) throws {
        ptr = try guardNotNull(c2pa_builder_from_json(manifestJSON))
    }

    /// Creates a new builder from a previously created C2PA archive stream.
    ///
    /// - Parameter archiveStream: A ``Stream`` containing a C2PA archive.
    ///
    /// - Throws: ``C2PAError`` if the archive is invalid or cannot be read.
    public init(archiveStream: Stream) throws {
        ptr = try guardNotNull(c2pa_builder_from_archive(archiveStream.rawPtr))
    }

    deinit { c2pa_builder_free(ptr) }

    /// Configures the builder to not embed the manifest in the output file.
    ///
    /// When enabled, the manifest will be stored separately and referenced
    /// via a remote URL. You must call ``setRemoteURL(_:)`` to specify
    /// where the manifest will be hosted.
    ///
    /// - SeeAlso: ``setRemoteURL(_:)``
    public func setNoEmbed() { c2pa_builder_set_no_embed(ptr) }

    /// Sets the remote URL where the manifest will be hosted.
    ///
    /// This URL is embedded in the output file when ``setNoEmbed()`` is enabled,
    /// allowing the manifest to be retrieved separately from the media file.
    ///
    /// - Parameter url: The HTTPS URL where the manifest will be accessible.
    ///
    /// - Throws: ``C2PAError`` if the URL is invalid or cannot be set.
    ///
    /// - Note: The URL should be accessible via HTTPS for security.
    ///
    /// - SeeAlso: ``setNoEmbed()``
    public func setRemoteURL(_ url: String) throws {
        _ = try guardNonNegative(
            Int64(c2pa_builder_set_remote_url(ptr, url))
        )
    }

    /// Adds a resource to the manifest.
    ///
    /// Resources are auxiliary files (like thumbnails or metadata) that are
    /// referenced by the manifest and embedded in the signed output.
    ///
    /// - Parameters:
    ///   - uri: The URI identifier for the resource within the manifest.
    ///   - stream: A ``Stream`` containing the resource data.
    ///
    /// - Throws: ``C2PAError`` if the resource cannot be added.
    public func addResource(uri: String, stream: Stream) throws {
        _ = try guardNonNegative(
            Int64(c2pa_builder_add_resource(ptr, uri, stream.rawPtr))
        )
    }

    /// Adds an ingredient (source material) to the manifest.
    ///
    /// Ingredients represent the original or modified content used to create
    /// the new asset. Each ingredient should have its own metadata describing
    /// its provenance.
    ///
    /// - Parameters:
    ///   - json: A JSON string describing the ingredient's assertions and metadata.
    ///   - format: The MIME type of the ingredient (e.g., "image/jpeg").
    ///   - stream: A ``Stream`` containing the ingredient file data.
    ///
    /// - Throws: ``C2PAError`` if the ingredient cannot be added.
    ///
    /// - SeeAlso: ``C2PA/readIngredient(at:dataDir:)``
    public func addIngredient(json: String, format: String, from stream: Stream) throws {
        _ = try guardNonNegative(
            Int64(c2pa_builder_add_ingredient_from_stream(ptr, json, format, stream.rawPtr))
        )
    }

    /// Writes the manifest as a C2PA archive to a stream.
    ///
    /// This creates a standalone archive file containing the manifest and
    /// all associated resources, which can be stored separately or embedded later.
    ///
    /// - Parameter dest: A ``Stream`` where the archive will be written.
    ///
    /// - Throws: ``C2PAError`` if the archive cannot be written.
    public func writeArchive(to dest: Stream) throws {
        _ = try guardNonNegative(
            Int64(c2pa_builder_to_archive(ptr, dest.rawPtr))
        )
    }

    /// Signs the source file and writes the signed result with an embedded manifest.
    ///
    /// This method performs the complete signing operation: it reads the source media,
    /// embeds the configured manifest with all resources and ingredients, signs it
    /// using the provided signer, and writes the result to the destination stream.
    ///
    /// - Parameters:
    ///   - format: The MIME type of the media file (e.g., "image/jpeg", "video/mp4").
    ///   - source: A ``Stream`` containing the source media file.
    ///   - destination: A ``Stream`` where the signed file will be written.
    ///   - signer: A ``Signer`` instance configured with signing credentials.
    ///
    /// - Returns: The raw manifest bytes as `Data`.
    ///
    /// - Throws: ``C2PAError`` if signing fails due to invalid inputs, I/O errors,
    ///   or cryptographic issues.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let builder = try Builder(manifestJSON: manifestJSON)
    /// let signer = try Signer(info: signerInfo)
    /// let sourceStream = try Stream(fileURL: sourceURL)
    /// let destStream = try Stream(fileURL: destURL)
    ///
    /// let manifestData = try builder.sign(
    ///     format: "image/jpeg",
    ///     source: sourceStream,
    ///     destination: destStream,
    ///     signer: signer
    /// )
    /// ```
    ///
    /// - SeeAlso: ``Signer``, ``Stream``
    @discardableResult
    public func sign(
        format: String,
        source: Stream,
        destination: Stream,
        signer: Signer
    ) throws -> Data {
        var manifestPtr: UnsafePointer<UInt8>?
        let size = try guardNonNegative(
            c2pa_builder_sign(
                ptr,
                format,
                source.rawPtr,
                destination.rawPtr,
                signer.ptr,
                &manifestPtr)
        )
        guard let mp = manifestPtr else { return Data() }
        let data = Data(bytes: mp, count: Int(size))
        c2pa_manifest_bytes_free(mp)
        return data
    }
}
