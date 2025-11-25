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

struct C2PASigningController {
    func signManifest(req: Request) async throws -> C2PASigningResponse {
        req.logger.info("=== C2PA Signing Request Headers ===")
        for (name, value) in req.headers {
            req.logger.info("Header: \(name) = \(value)")
        }
        req.logger.info("=== End Headers ===")

        let signingRequest = try req.content.decode(C2PASigningRequest.self)

        print("[C2PA Controller] Received signing request")

        let certPath = FileManager.default.currentDirectoryPath + "/Resources/es256_certs.pem"
        let keyPath = FileManager.default.currentDirectoryPath + "/Resources/es256_private.key"

        let certificateChain = try String(contentsOfFile: certPath, encoding: .utf8)
        let privateKeyPEM = try String(contentsOfFile: keyPath, encoding: .utf8)

        guard certificateChain.contains("BEGIN CERTIFICATE") else {
            throw Abort(.internalServerError, reason: "Invalid certificate format")
        }

        guard privateKeyPEM.contains("BEGIN PRIVATE KEY") || privateKeyPEM.contains("BEGIN EC PRIVATE KEY") else {
            throw Abort(.internalServerError, reason: "Invalid private key format")
        }

        // Decode the base64-encoded data to sign
        guard let dataToSign = Data(base64Encoded: signingRequest.claim) else {
            throw Abort(.badRequest, reason: "Invalid base64-encoded data")
        }

        print("[C2PA] Creating signer for data signing")
        print("[C2PA] Data to sign size: \(dataToSign.count) bytes")
        print("[C2PA] Using certificates from: Resources/es256_certs.pem")

        let privateKey = try P256.Signing.PrivateKey(pemRepresentation: privateKeyPEM)
        let signature = try privateKey.signature(for: dataToSign)
        let base64Signature = signature.rawRepresentation.base64EncodedString()

        print("[C2PA] Signature created, size: \(signature.rawRepresentation.count) bytes")
        print("[C2PA Controller] Signature generated successfully")

        return C2PASigningResponse(
            signature: base64Signature
        )
    }
}
