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
import Vapor

struct CertificateSigningRequest: Content {
    let csr: String  // PEM-encoded CSR
    let metadata: CSRMetadata?
}

struct CSRMetadata: Content {
    let device_id: String?
    let app_version: String?
}

struct SignedCertificateResponse: Content {
    let certificate_id: String
    let certificate_chain: String  // PEM-encoded certificate chain
    let expires_at: Date
    let serial_number: String
}
