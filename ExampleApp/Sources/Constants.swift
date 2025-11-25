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

enum Constants {
    enum Image {
        static let jpegCompressionQuality: Double = 0.9
    }

    enum Keychain {
        static let keychainPrivateKeyTag = "org.contentauth.ExampleApp.keychain.privatekey"
        static let secureEnclaveKeyTag = "org.contentauth.ExampleApp.secureenclave.key"
        static let customCertificateKey = "org.contentauth.ExampleApp.custom.certificate"
        static let customPrivateKeyKey = "org.contentauth.ExampleApp.custom.privatekey"
        static let customPrivateKeyTag = "org.contentauth.ExampleApp.custom.keychain.privatekey"
        static let certChainSuffix = ".certchain"
    }

    enum UserDefaultsKeys {
        static let signingMode = "signingMode"
        static let remoteSigningURL = "remoteSigningURL"
        static let remoteBearerToken = "remoteBearerToken"
    }

    enum C2PA {
        static let claimGenerator = "C2PA Example/1.0.0"
        static let defaultFormat = "image/jpeg"
    }
}
