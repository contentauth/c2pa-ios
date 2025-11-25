// This file is licensed to you under the Apache License, Version 2.0 
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license 
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is 
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE 
// files for the specific language governing permissions and limitations under
// each license.

import Vapor

struct CertificateSigningController {
    func signCSR(req: Request) async throws -> SignedCertificateResponse {
        req.logger.info("=== Certificate Signing Request Headers ===")
        for (name, value) in req.headers {
            req.logger.info("Header: \(name) = \(value)")
        }
        req.logger.info("=== End Headers ===")

        let csrRequest = try req.content.decode(CertificateSigningRequest.self)

        guard csrRequest.csr.contains("BEGIN CERTIFICATE REQUEST") else {
            throw Abort(.badRequest, reason: "Invalid CSR format")
        }

        let response = try await req.application.certificateService.signCSR(csrRequest.csr)
        req.logger.info("Issued certificate: \(response.certificate_id)")

        return response
    }
}
