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
//  Stream.swift
//

import C2PAC
import Foundation

/// Options for configuring stream read/write capabilities.
public struct StreamOptions: OptionSet, Sendable {
    public let rawValue: UInt8

    /// The stream supports read operations.
    public static let read = StreamOptions(rawValue: 1 << 0)

    /// The stream supports write operations.
    public static let write = StreamOptions(rawValue: 1 << 1)

    public init(rawValue: UInt8) { self.rawValue = rawValue }
}

/// A generic stream abstraction for reading and writing C2PA data.
///
/// `Stream` provides a flexible interface for I/O operations with C2PA libraries,
/// supporting both file-based and in-memory streaming. It bridges Swift's native
/// I/O mechanisms with the underlying C API.
///
/// ## Topics
///
/// ### Creating Streams
/// - ``init(read:seek:write:flush:)``
/// - ``init(data:)``
/// - ``init(fileURL:truncate:createIfNeeded:)``
///
/// ### Stream Callbacks
/// - ``Reader``
/// - ``Seeker``
/// - ``Writer``
/// - ``Flusher``
///
/// ## Examples
///
/// ### File-based Stream
///
/// ```swift
/// let stream = try Stream(fileURL: fileURL)
/// ```
///
/// ### In-memory Stream
///
/// ```swift
/// let data = Data(/* ... */)
/// let stream = try Stream(data: data)
/// ```
///
/// ### Custom Stream
///
/// ```swift
/// var buffer = Data()
/// let stream = try Stream(
///     write: { pointer, count in
///         let data = Data(bytes: pointer, count: count)
///         buffer.append(data)
///         return count
///     }
/// )
/// ```
///
/// - SeeAlso: ``Reader``, ``Builder``
public final class Stream {
    /// A closure that reads data from the stream into a buffer.
    ///
    /// - Parameters:
    ///   - buffer: The buffer to read data into.
    ///   - count: The number of bytes to read.
    /// - Returns: The number of bytes actually read, or -1 on error.
    public typealias Reader = (_ buffer: UnsafeMutableRawPointer, _ count: Int) -> Int

    /// A closure that seeks to a position in the stream.
    ///
    /// - Parameters:
    ///   - offset: The offset to seek to.
    ///   - origin: The origin for the seek operation (start, current, or end).
    /// - Returns: The new position in the stream, or -1 on error.
    public typealias Seeker = (_ offset: Int, _ origin: C2paSeekMode) -> Int

    /// A closure that writes data from a buffer to the stream.
    ///
    /// - Parameters:
    ///   - buffer: The buffer containing data to write.
    ///   - count: The number of bytes to write.
    /// - Returns: The number of bytes actually written, or -1 on error.
    public typealias Writer = (_ buffer: UnsafeRawPointer, _ count: Int) -> Int

    /// A closure that flushes any buffered data to the stream.
    ///
    /// - Returns: 0 on success, or -1 on error.
    public typealias Flusher = () -> Int

    private final class StreamProvider {
        let r: Reader?
        let s: Seeker?
        let w: Writer?
        let f: Flusher?
        // Also store the FileHandle Box if created by Stream(fileURL:)
        // to ensure its lifetime is tied to the Stream object itself.
        var fileHandleBox: AnyObject?

        init(r: Reader?, s: Seeker?, w: Writer?, f: Flusher?, fileHandleBox: AnyObject? = nil) {
            self.r = r
            self.s = s
            self.w = w
            self.f = f
            self.fileHandleBox = fileHandleBox
        }
    }

    private static let cRead: ReadCallback = { ctx, data, len in
        guard let ctx, let data else { return -1 }
        let b = Unmanaged<StreamProvider>.fromOpaque(ctx).takeUnretainedValue()
        guard let r = b.r else { return -1 }
        return r(data, Int(len))
    }

    private static let cSeek: SeekCallback = { ctx, off, mode in
        guard let ctx else { return -1 }
        let b = Unmanaged<StreamProvider>.fromOpaque(ctx).takeUnretainedValue()
        guard let s = b.s else { return -1 }
        return s(Int(off), mode)
    }

    private static let cWrite: WriteCallback = { ctx, data, len in
        guard let ctx, let data else { return -1 }
        let b = Unmanaged<StreamProvider>.fromOpaque(ctx).takeUnretainedValue()
        guard let w = b.w else { return -1 }
        return w(data, Int(len))
    }

    private static let cFlush: FlushCallback = { ctx in
        guard let ctx else { return -1 }
        let b = Unmanaged<StreamProvider>.fromOpaque(ctx).takeUnretainedValue()
        return b.f?() ?? 0
    }

    private let streamProviderRef: Unmanaged<StreamProvider>
    private let contextPtr: UnsafeMutablePointer<StreamContext>
    private let streamPtr: UnsafeMutablePointer<C2paStream>

    private init(streamProvider: StreamProvider) {
        streamProviderRef = .passRetained(streamProvider)
        contextPtr = asStreamCtx(streamProviderRef.toOpaque())

        streamPtr = c2pa_create_stream(
            contextPtr,
            streamProvider.r != nil ? Stream.cRead : nil,
            streamProvider.s != nil ? Stream.cSeek : nil,
            streamProvider.w != nil ? Stream.cWrite : nil,
            streamProvider.f != nil ? Stream.cFlush : nil
        )
    }

    /// Creates a custom stream with user-provided callbacks.
    ///
    /// This initializer allows complete control over stream behavior by providing
    /// custom closures for read, seek, write, and flush operations.
    ///
    /// - Parameters:
    ///   - read: Optional closure for reading data.
    ///   - seek: Optional closure for seeking within the stream.
    ///   - write: Optional closure for writing data.
    ///   - flush: Optional closure for flushing buffered data.
    ///
    /// - Throws: ``C2PAError`` if the stream cannot be created.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer = Data()
    /// let stream = try Stream(
    ///     write: { pointer, count in
    ///         let data = Data(bytes: pointer, count: count)
    ///         buffer.append(data)
    ///         return count
    ///     },
    ///     flush: {
    ///         // Perform any necessary flush operations
    ///         return 0
    ///     }
    /// )
    /// ```
    public convenience init(
        read: Reader? = nil,
        seek: Seeker? = nil,
        write: Writer? = nil,
        flush: Flusher? = nil
    ) throws {
        self.init(streamProvider: StreamProvider(r: read, s: seek, w: write, f: flush))
    }

    /// Creates a read-only stream from in-memory data.
    ///
    /// This convenience initializer creates a stream that reads from a `Data` object.
    /// The stream supports both reading and seeking, but not writing.
    ///
    /// - Parameter data: The data to read from.
    ///
    /// - Throws: ``C2PAError`` if the stream cannot be created.
    ///
    /// - Note: The data is copied internally, so modifications to the original
    ///   `Data` object after creating the stream will not affect the stream.
    public convenience init(data: Data) throws {
        var cursor = 0
        let streamProvider = StreamProvider(
            r: { buffer, count in
                let remain = data.count - cursor
                guard remain > 0 else { return 0 }
                let n = Swift.min(remain, count)
                _ = data.withUnsafeBytes {  // Silence "unused result" warning
                    memcpy(buffer, $0.baseAddress!.advanced(by: cursor), n)
                }
                cursor += n
                return n
            },
            s: { offset, mode in
                switch mode {
                case Start: cursor = max(0, offset)
                case Current: cursor = max(0, cursor + offset)
                case End: cursor = max(0, data.count + offset)
                default: return -1
                }
                return cursor
            },
            w: nil, f: nil, fileHandleBox: nil
        )
        self.init(streamProvider: streamProvider)
    }

    deinit {
        c2pa_release_stream(streamPtr)
        streamProviderRef.release()
    }

    // raw C pointer (internal)
    var rawPtr: UnsafeMutablePointer<C2paStream> { streamPtr }
}

extension Stream {
    /// Creates a file-based stream for reading and writing.
    ///
    /// This convenience initializer creates a fully-featured stream backed by a file
    /// on disk, supporting read, write, seek, and flush operations. The file handle
    /// is managed automatically and will be closed when the stream is deallocated.
    ///
    /// - Parameters:
    ///   - url: The file URL to open.
    ///   - truncate: If `true`, truncates the file to zero length. Defaults to `true`.
    ///   - createIfNeeded: If `true`, creates the file if it doesn't exist. Defaults to `true`.
    ///
    /// - Throws: ``C2PAError`` if the file cannot be opened or created.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a stream for writing
    /// let outputStream = try Stream(fileURL: outputURL)
    ///
    /// // Create a stream for reading (don't truncate)
    /// let inputStream = try Stream(fileURL: inputURL, truncate: false)
    /// ```
    ///
    /// - Note: The file is opened for both reading and writing. The stream manages
    ///   the file handle lifecycle automatically.
    public convenience init(
        fileURL url: URL,
        truncate: Bool = true,
        createIfNeeded: Bool = true
    ) throws {
        if createIfNeeded, !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }

        let fh = try FileHandle(forUpdating: url)
        if truncate { try fh.truncate(atOffset: 0) }

        // Box to manage FileHandle lifetime, will be stored in the StreamProvider
        final class FileHandleBox {
            let fh: FileHandle
            init(_ fh: FileHandle) { self.fh = fh }
            deinit { try? fh.close() }
        }
        let fhBox = FileHandleBox(fh)

        let streamProvider = StreamProvider(
            r: { buffer, count in
                let data: Data
                data = (try? fhBox.fh.read(upToCount: count)) ?? Data()
                data.copyBytes(
                    to: buffer.assumingMemoryBound(to: UInt8.self),
                    count: data.count)
                return data.count
            },
            s: { offset, mode in
                do {
                    let off = Int64(offset)
                    let newPos: UInt64

                    switch mode {
                    case Start:
                        newPos = UInt64(max(0, off))
                    case Current:
                        let currentOffset = Int64(fhBox.fh.offsetInFile)
                        var targetOffset = currentOffset + off
                        if targetOffset < 0 { targetOffset = 0 }
                        newPos = UInt64(targetOffset)
                    case End:
                        let end = try fhBox.fh.seekToEnd()
                        var targetOffset = Int64(end) + off
                        if targetOffset < 0 { targetOffset = 0 }
                        newPos = UInt64(targetOffset)
                    default:
                        return -1
                    }
                    try fhBox.fh.seek(toOffset: newPos)
                    return Int(newPos)  // Return Int as per Seeker typealias
                } catch { return -1 }
            },
            w: { buffer, count in
                try? fhBox.fh.write(contentsOf: Data(bytes: buffer, count: count))

                return count
            },
            f: {
                try? fhBox.fh.synchronize()

                return 0
            },
            fileHandleBox: fhBox
        )
        self.init(streamProvider: streamProvider)
    }
}
