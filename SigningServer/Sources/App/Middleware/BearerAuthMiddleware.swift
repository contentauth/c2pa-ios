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

struct BearerAuthMiddleware: AsyncMiddleware {
    let requiredToken: String?

    init() {
        // Get the required token from environment variable
        self.requiredToken = Environment.get("SIGNING_SERVER_TOKEN")
    }

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // If no token is configured, allow all requests (for development)
        guard let requiredToken = requiredToken, !requiredToken.isEmpty else {
            return try await next.respond(to: request)
        }

        // Extract the Authorization header
        guard let authHeader = request.headers[.authorization].first else {
            throw Abort(.unauthorized, reason: "Missing Authorization header")
        }

        // Check if it's a Bearer token
        guard authHeader.hasPrefix("Bearer ") else {
            throw Abort(.unauthorized, reason: "Invalid Authorization header format")
        }

        // Extract and validate the token
        let providedToken = String(authHeader.dropFirst("Bearer ".count))
        guard providedToken == requiredToken else {
            throw Abort(.unauthorized, reason: "Invalid bearer token")
        }

        // Token is valid, continue to the next handler
        return try await next.respond(to: request)
    }
}
