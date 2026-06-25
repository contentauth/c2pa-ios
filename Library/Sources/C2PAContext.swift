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
//  C2PAContext.swift
//

import C2PAC
import Foundation

/// An immutable, shareable configuration context for creating builders.
///
/// A `C2PAContext` captures configuration — settings such as created-assertion
/// labels, trust configuration, and CAWG signer settings — and can be used to
/// create one or more ``Builder`` instances that share it. Once created, a
/// context is immutable.
///
/// ## Topics
///
/// ### Creating a Context
/// - ``init()``
/// - ``init(settings:)``
///
/// ### Controlling Operations
/// - ``cancel()``
///
/// ## Example
///
/// ```swift
/// let settings = try C2PASettings(json: settingsJSON)
/// let context = try C2PAContext(settings: settings)
/// let builder = try Builder(context: context, manifestJSON: manifestJSON)
/// ```
///
/// - SeeAlso: ``C2PASettings``, ``Builder``
public final class C2PAContext {
    let ptr: UnsafeMutablePointer<C2paContext>

    /// Internal initializer that adopts an already-built native context.
    init(ptr: UnsafeMutablePointer<C2paContext>) {
        self.ptr = ptr
    }

    /// Creates a context with default settings.
    ///
    /// - Throws: ``C2PAError`` if the context cannot be created.
    public convenience init() throws {
        self.init(ptr: try guardNotNull(c2pa_context_new()))
    }

    /// Creates a context configured with the given settings.
    ///
    /// The settings are cloned by the C layer, so the caller retains ownership
    /// of `settings`.
    ///
    /// - Parameter settings: The ``C2PASettings`` to configure this context with.
    ///
    /// - Throws: ``C2PAError`` if the context cannot be created.
    public convenience init(settings: C2PASettings) throws {
        let builder = try guardNotNull(c2pa_context_builder_new())
        do {
            _ = try guardNonNegative(
                Int64(c2pa_context_builder_set_settings(builder, settings.rawPtr))
            )
        } catch {
            _ = c2pa_free(builder)
            throw error
        }
        // c2pa_context_builder_build consumes the builder, even on failure.
        self.init(ptr: try guardNotNull(c2pa_context_builder_build(builder)))
    }

    deinit { _ = c2pa_free(ptr) }

    /// Requests cancellation of any in-progress signing or reading operation
    /// running on this context.
    ///
    /// - Throws: ``C2PAError`` if the cancellation request fails.
    public func cancel() throws {
        guard c2pa_context_cancel(ptr) == 0 else {
            throw C2PAError.api(lastC2PAError())
        }
    }
}
