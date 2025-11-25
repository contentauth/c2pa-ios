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

struct C2PAConfiguration: Content {
    let algorithm: String
    let timestamp_url: String
    let signing_url: String
    let certificate_chain: String
}

struct C2PAConfigurationController {
    func getConfiguration(req: Request) async throws -> C2PAConfiguration {
        req.logger.info("=== C2PA Configuration Request Headers ===")
        for (name, value) in req.headers {
            req.logger.info("Header: \(name) = \(value)")
        }
        req.logger.info("=== End Headers ===")

        let certPath = FileManager.default.currentDirectoryPath + "/Resources/es256_certs.pem"
        let certificateChain = try String(contentsOfFile: certPath, encoding: .utf8)
        let encodedCertChain = Data(certificateChain.utf8).base64EncodedString()

        guard let serverURL = Environment.get("SIGNING_SERVER_URL"), !serverURL.isEmpty else {
            req.logger.error("SIGNING_SERVER_URL environment variable is not set or is empty")
            throw Abort(.internalServerError, reason: "SIGNING_SERVER_URL environment variable is not set or is empty")
        }

        let signingURL = "\(serverURL)/api/v1/c2pa/sign"
        req.logger.info("Configuration: serverURL=\(serverURL), signingURL=\(signingURL)")

        return C2PAConfiguration(
            algorithm: "es256",
            timestamp_url: "http://timestamp.digicert.com",
            signing_url: signingURL,
            certificate_chain: encodedCertChain
        )
    }
}
