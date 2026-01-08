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

func routes(_ app: Application) throws {
    app.get { _ async in
        return [
            "status": "C2PA Signing Server is running",
            "version": "1.0.0",
            "mode": "testing"
        ]
    }

    // Health check endpoint
    app.get("health") { _ async in
        return HTTPStatus.ok
    }

    let api = app.grouped("api", "v1")

    // Certificate signing endpoint
    let certificates = api.grouped("certificates")

    let certificateSigningController = CertificateSigningController()
    certificates.post("sign", use: certificateSigningController.signCSR)

    // C2PA endpoints with bearer auth protection
    let c2pa = api.grouped("c2pa")
        .grouped(BearerAuthMiddleware())

    let c2paConfigurationController = C2PAConfigurationController()
    c2pa.get("configuration", use: c2paConfigurationController.getConfiguration)

    let c2paSigningController = C2PASigningController()
    c2pa.post("sign", use: c2paSigningController.signManifest)
}
