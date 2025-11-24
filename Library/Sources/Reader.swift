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
//  Reader.swift
//

import C2PAC
import Foundation

/// A reader for extracting C2PA manifest data and resources from media files.
///
/// `Reader` provides low-level access to C2PA manifests and associated resources
/// embedded in media files. Use this class when you need fine-grained control
/// over reading operations or when working with stream-based I/O.
///
/// For simple file-based reading, consider using ``C2PA/readFile(at:dataDir:)`` instead.
///
/// ## Topics
///
/// ### Creating a Reader
/// - ``init(format:stream:)``
/// - ``init(format:stream:manifest:)``
///
/// ### Reading Manifest Data
/// - ``json()``
///
/// ### Extracting Resources
/// - ``resource(uri:to:)``
///
/// ## Example
///
/// ```swift
/// let stream = try Stream(fileURL: imageURL)
/// let reader = try Reader(format: "image/jpeg", stream: stream)
/// let manifestJSON = try reader.json()
/// print("Manifest: \(manifestJSON)")
/// ```
///
/// - SeeAlso: ``Stream``, ``C2PA/readFile(at:dataDir:)``
public final class Reader {
    private let ptr: UnsafeMutablePointer<C2paReader>

    /// Creates a reader for a media file stream.
    ///
    /// This initializer reads the manifest embedded in the media file itself.
    ///
    /// - Parameters:
    ///   - format: The MIME type of the media file (e.g., "image/jpeg", "video/mp4").
    ///   - stream: A ``Stream`` containing the media file data.
    ///
    /// - Throws: ``C2PAError`` if the stream cannot be read or contains no valid manifest.
    public init(format: String, stream: Stream) throws {
        ptr = try guardNotNull(c2pa_reader_from_stream(format, stream.rawPtr))
    }

    /// Creates a reader from separate manifest data and media stream.
    ///
    /// This initializer is used when the manifest is stored separately from the
    /// media file (e.g., when using remote manifests with ``Builder/setNoEmbed()``).
    ///
    /// - Parameters:
    ///   - format: The MIME type of the media file.
    ///   - stream: A ``Stream`` containing the media file data.
    ///   - manifest: The raw manifest bytes.
    ///
    /// - Throws: ``C2PAError`` if the manifest or stream cannot be processed.
    public init(format: String, stream: Stream, manifest: Data) throws {
        ptr = try manifest.withUnsafeBytes { buf in
            try guardNotNull(
                c2pa_reader_from_manifest_data_and_stream(
                    format,
                    stream.rawPtr,
                    buf.bindMemory(to: UInt8.self).baseAddress!,
                    UInt(manifest.count)
                )
            )
        }
    }

    deinit { c2pa_reader_free(ptr) }

    /// Returns the manifest data as a JSON string.
    ///
    /// This method extracts and validates the complete C2PA manifest,
    /// returning it as formatted JSON.
    ///
    /// - Returns: A JSON string containing the manifest data.
    ///
    /// - Throws: ``C2PAError`` if the manifest cannot be read or is invalid.
    public func json() throws -> String {
        try stringFromC(c2pa_reader_json(ptr))
    }

    /// Extracts a resource from the manifest to a stream.
    ///
    /// Resources are auxiliary files embedded in the C2PA manifest, such as
    /// thumbnails or additional metadata files.
    ///
    /// - Parameters:
    ///   - uri: The URI of the resource within the manifest.
    ///   - dest: A ``Stream`` where the resource data will be written.
    ///
    /// - Throws: ``C2PAError`` if the resource cannot be found or extracted.
    public func resource(uri: String, to dest: Stream) throws {
        _ = try guardNonNegative(
            c2pa_reader_resource_to_stream(ptr, uri, dest.rawPtr)
        )
    }
}
