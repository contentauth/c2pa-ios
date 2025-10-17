//
//  Stream.swift
//

import C2PAC
import Foundation

public struct StreamOptions: OptionSet, Sendable {
    public let rawValue: UInt8
    public static let read = StreamOptions(rawValue: 1 << 0)
    public static let write = StreamOptions(rawValue: 1 << 1)
    public init(rawValue: UInt8) { self.rawValue = rawValue }
}

public final class Stream {
    public typealias Reader = (_ buffer: UnsafeMutableRawPointer, _ count: Int) -> Int
    public typealias Seeker = (_ offset: Int, _ origin: C2paSeekMode) -> Int
    public typealias Writer = (_ buffer: UnsafeRawPointer, _ count: Int) -> Int
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

    // generic constructor for user-provided callbacks
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

    public convenience init(
        read: Reader? = nil,
        seek: Seeker? = nil,
        write: Writer? = nil,
        flush: Flusher? = nil
    ) throws {
        self.init(streamProvider: StreamProvider(r: read, s: seek, w: write, f: flush))
    }

    // Data → read-only stream
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

// MARK: - File-based stream helper ------------------------------------------

extension Stream {

    /**
     Fully-featured *read/write* stream backed by a file on disk.

     The wrapper owns the `FileHandle` and closes it automatically via the StreamProvider's ``FileHandleBox``.

     - attention: This will overwrite existing files!
     */
    public class func write(to url: URL) throws -> Stream {
        try Data().write(to: url, options: .atomic)

        return Self(try .init(forUpdating: url), write: true)
    }

    /**
     Fully-featured *read/write* stream backed by a file on disk.

     The wrapper owns the `FileHandle` and closes it automatically via the StreamProvider's ``FileHandleBox``.

     - throws: when file does not exist.
          */
    public class func update(_ url: URL) throws -> Stream {
        return Self(try .init(forUpdating: url), write: true)
    }

    /**
     Fully-featured *read-only* stream backed by a file on disk.

     The wrapper owns the `FileHandle` and closes it automatically via the StreamProvider's ``FileHandleBox``.

     - throws: when file does not exist.
      */
    public class func read(from url: URL) throws -> Stream {
        return Self(try .init(forReadingFrom: url), write: false)
    }

    private convenience init(_ fh: FileHandle, write: Bool) {
        let fhBox = FileHandleBox(fh)

        let writer: Writer?
        let flusher: Flusher?

        if write {
            writer = { buffer, count in
                try? fhBox.fh.write(contentsOf: Data(bytes: buffer, count: count))

                return count
            }

            flusher = {
                try? fhBox.fh.synchronize()

                return 0
            }
        }
        else {
            writer = nil
            flusher = nil
        }

        self.init(streamProvider: .init(
            r: { buffer, count in
                let data = (try? fhBox.fh.read(upToCount: count)) ?? Data()

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
                        let targetOffset = max(0, currentOffset + off)

                        newPos = UInt64(targetOffset)

                    case End:
                        let end = try fhBox.fh.seekToEnd()
                        let targetOffset = max(0, Int64(end) + off)

                        newPos = UInt64(targetOffset)

                    default:
                        return -1
                    }

                    try fhBox.fh.seek(toOffset: newPos)

                    return Int(newPos)  // Return Int as per Seeker typealias
                }
                catch {
                    return -1
                }
            },
            w: writer,
            f: flusher,
            fileHandleBox: fhBox))
    }
}


/**
 Box to manage FileHandle lifetime, will be stored in the ``StreamProvider``.
  */
final class FileHandleBox {

    let fh: FileHandle

    init(_ fh: FileHandle) {
        self.fh = fh
    }

    deinit {
        try? fh.close()
    }
}
