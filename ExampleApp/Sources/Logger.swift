// This file is licensed to you under the Apache License, Version 2.0 
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license 
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is 
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE 
// files for the specific language governing permissions and limitations under
// each license.

import Foundation
import OSLog

enum Logger {
    private static let subsystem = "org.contentauth.ExampleApp"

    static let signing = OSLog(subsystem: subsystem, category: "signing")
    static let verification = OSLog(subsystem: subsystem, category: "verification")
    static let storage = OSLog(subsystem: subsystem, category: "storage")
    static let general = OSLog(subsystem: subsystem, category: "general")
    static let error = OSLog(subsystem: subsystem, category: "error")
    static let certificate = OSLog(subsystem: subsystem, category: "certificate")
    static let metadata = OSLog(subsystem: subsystem, category: "metadata")
}
