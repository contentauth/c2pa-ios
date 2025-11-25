// This file is licensed to you under the Apache License, Version 2.0 
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license 
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is 
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE 
// files for the specific language governing permissions and limitations under
// each license.

import C2PA
import Crypto
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Signing Mode Enum
public enum SigningMode: String, CaseIterable {
    case defaultMode = "Default"
    case keychain = "Keychain"
    case secureEnclave = "SE"
    case custom = "Custom"
    case remote = "Remote"

    var description: String {
        switch self {
        case .defaultMode:
            return "Uses included test certificate"
        case .keychain:
            return "Generates and stores certificate in Keychain"
        case .secureEnclave:
            return "Uses device hardware security (Secure Enclave)"
        case .custom:
            return "Upload your own certificate/key"
        case .remote:
            return "Use remote signing service"
        }
    }

    var icon: String {
        switch self {
        case .defaultMode:
            return "checkmark.shield.fill"
        case .keychain:
            return "key.icloud.fill"
        case .secureEnclave:
            return "lock.shield.fill"
        case .custom:
            return "person.badge.key.fill"
        case .remote:
            return "network"
        }
    }
}

// MARK: - UTType Extensions
extension UTType {
    static let pemCertificate = UTType(filenameExtension: "pem")!
    static let crtCertificate = UTType(filenameExtension: "crt")!
    static let derCertificate = UTType(filenameExtension: "der")!
    static let keyFile = UTType(filenameExtension: "key")!
}

// MARK: - SettingsView
struct SettingsView: View {
    @Binding var isPresented: Bool

    // Signing mode selection
    @AppStorage("signingMode") private var signingMode: String = SigningMode.defaultMode.rawValue

    // Custom certificate storage
    @AppStorage("customCertificatePath") private var customCertificatePath: String = ""
    @AppStorage("customPrivateKeyPath") private var customPrivateKeyPath: String = ""

    // Remote signing configuration
    @AppStorage("remoteSigningURL") private var remoteSigningURL: String = ""
    @AppStorage("remoteBearerToken") private var remoteBearerToken: String = ""

    // UI State
    @State private var showingCertificatePicker = false
    @State private var showingKeyPicker = false
    @State private var statusMessage = ""
    @State private var isGeneratingKeychain = false
    @State private var isGeneratingSecureEnclave = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var selectedMode: SigningMode {
        SigningMode(rawValue: signingMode) ?? .defaultMode
    }

    var body: some View {
        NavigationView {
            Form {
                // Signing Mode Selection
                Section(header: Text("Signing Mode")) {
                    Picker("Select Mode", selection: $signingMode) {
                        ForEach(SigningMode.allCases, id: \.self) { mode in
                            Label {
                                VStack(alignment: .leading) {
                                    Text(mode.rawValue)
                                    Text(mode.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } icon: {
                                Image(systemName: mode.icon)
                            }
                            .tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 5)

                    // Mode description
                    VStack(alignment: .leading, spacing: 5) {
                        Label(selectedMode.rawValue, systemImage: selectedMode.icon)
                            .font(.headline)
                        Text(selectedMode.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }

                // Mode-specific configuration
                switch selectedMode {
                case .defaultMode:
                    defaultModeSection
                case .keychain:
                    keychainModeSection
                case .secureEnclave:
                    secureEnclaveSection
                case .custom:
                    customModeSection
                case .remote:
                    remoteModeSection
                }

                // Status Section
                Section(header: Text("Status")) {
                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    } else {
                        statusView
                    }
                }

                // Actions Section
                if selectedMode != .defaultMode {
                    Section {
                        Button("Reset to Default", role: .destructive) {
                            resetToDefault()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSettings()
                        isPresented = false
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingCertificatePicker,
            allowedContentTypes: [
                .pemCertificate, .crtCertificate, .derCertificate, .x509Certificate, .item
            ],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result: result, isCertificate: true)
        }
        .fileImporter(
            isPresented: $showingKeyPicker,
            allowedContentTypes: [.pemCertificate, .keyFile, .item],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result: result, isCertificate: false)
        }
        .alert("Certificate Operation", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Mode Sections

    private var defaultModeSection: some View {
        Section(header: Text("Default Certificate")) {
            VStack(alignment: .leading, spacing: 10) {
                Label("Test Certificate Active", systemImage: "checkmark.seal.fill")
                    .foregroundColor(.green)
                Text("Using C2PA Example ES256 demo certificate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("For testing purposes only")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            .padding(.vertical, 5)
        }
    }

    private var keychainModeSection: some View {
        Section(header: Text("Keychain Certificate")) {
            VStack(alignment: .leading, spacing: 10) {
                if isKeychainCertificateAvailable() {
                    Label("Keychain Certificate Active", systemImage: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("Certificate stored in device Keychain")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Regenerate Certificate", role: .destructive) {
                        generateKeychainCertificate()
                    }
                    .disabled(isGeneratingKeychain)
                } else {
                    Text("No Keychain certificate found")
                        .foregroundColor(.secondary)

                    Button("Generate Certificate") {
                        generateKeychainCertificate()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isGeneratingKeychain)

                    if isGeneratingKeychain {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            }
            .padding(.vertical, 5)
        }
    }

    private var secureEnclaveSection: some View {
        Section(header: Text("Secure Enclave")) {
            VStack(alignment: .leading, spacing: 10) {
                // Server Configuration
                VStack(alignment: .leading, spacing: 5) {
                    Text("Signing Server URL")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("https://signing-server.example.com", text: $remoteSigningURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Bearer Token")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SecureField("Enter bearer token", text: $remoteBearerToken)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                if !remoteSigningURL.isEmpty && !remoteBearerToken.isEmpty {
                    Label("Server configured", systemImage: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }

                Divider()

                if isSecureEnclaveSupported() {
                    if isSecureEnclaveKeyAvailable() {
                        Label("Secure Enclave Active", systemImage: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("Hardware-backed signing key active")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button("Regenerate Key", role: .destructive) {
                            generateSecureEnclaveKey()
                        }
                        .disabled(isGeneratingSecureEnclave)
                    } else {
                        Text("No Secure Enclave key found")
                            .foregroundColor(.secondary)

                        Button("Generate Secure Key") {
                            generateSecureEnclaveKey()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isGeneratingSecureEnclave)

                        if isGeneratingSecureEnclave {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                } else {
                    Label("Not Available", systemImage: "xmark.shield.fill")
                        .foregroundColor(.red)
                    Text("Secure Enclave requires a physical device")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 5)
        }
    }

    private var customModeSection: some View {
        Group {
            Section(header: Text("Certificate")) {
                VStack(alignment: .leading, spacing: 10) {
                    Button("Select Certificate (.pem/.crt)") {
                        showingCertificatePicker = true
                    }
                    .buttonStyle(.borderedProminent)

                    if !customCertificatePath.isEmpty {
                        Label(
                            customCertificatePath.components(separatedBy: "/").last
                                ?? "Certificate selected",
                            systemImage: "checkmark.seal.fill"
                        )
                        .foregroundColor(.green)
                        .font(.caption)
                    }
                }
                .padding(.vertical, 5)
            }

            Section(header: Text("Private Key")) {
                VStack(alignment: .leading, spacing: 10) {
                    Button("Select Private Key (.pem/.key)") {
                        showingKeyPicker = true
                    }
                    .buttonStyle(.borderedProminent)

                    if !customPrivateKeyPath.isEmpty {
                        Label(
                            customPrivateKeyPath.components(separatedBy: "/").last
                                ?? "Key selected",
                            systemImage: "key.fill"
                        )
                        .foregroundColor(.green)
                        .font(.caption)
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }

    private var remoteModeSection: some View {
        Group {
            Section(header: Text("Remote Signing Service")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Service URL")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("https://signing-server.example.com/sign", text: $remoteSigningURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Text("Bearer Token")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SecureField("Enter bearer token", text: $remoteBearerToken)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    if !remoteSigningURL.isEmpty && !remoteBearerToken.isEmpty {
                        Label("Credentials configured", systemImage: "checkmark.seal.fill")
                            .foregroundColor(.green)
                                .font(.caption)
                        } else {
                            Text("Both URL and token are required")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                }
                .padding(.vertical, 5)
            }
        }
    }

    private var statusView: some View {
        VStack(alignment: .leading, spacing: 5) {
            switch selectedMode {
            case .defaultMode:
                Label("Ready to sign", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .keychain:
                if isKeychainCertificateAvailable() {
                    Label("Ready to sign", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Label("Certificate needed", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                }
            case .secureEnclave:
                if !remoteSigningURL.isEmpty && !remoteBearerToken.isEmpty && isSecureEnclaveKeyAvailable() {
                    Label("Ready to sign", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if !remoteSigningURL.isEmpty && !remoteBearerToken.isEmpty {
                    Label("Key generation needed", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                } else {
                    Label("Server configuration needed", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                }
            case .custom:
                if !customCertificatePath.isEmpty && !customPrivateKeyPath.isEmpty {
                    Label("Ready to sign", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Label(
                        "Certificate and key needed", systemImage: "exclamationmark.triangle.fill"
                    )
                    .foregroundColor(.orange)
                }
            case .remote:
                if !remoteSigningURL.isEmpty && !remoteBearerToken.isEmpty {
                    Label("Ready to sign", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Label("URL and token needed", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func isKeychainCertificateAvailable() -> Bool {
        // Check if a certificate exists in keychain
        return UserDefaults.standard.bool(forKey: "hasKeychainCertificate")
    }

    private func isSecureEnclaveSupported() -> Bool {
        #if targetEnvironment(simulator)
            return false
        #else
            // Check if device supports Secure Enclave
            var error: Unmanaged<CFError>?
            let access = SecAccessControlCreateWithFlags(
                kCFAllocatorDefault,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                .privateKeyUsage,
                &error
            )
            return access != nil
        #endif
    }

    private func isSecureEnclaveKeyAvailable() -> Bool {
        // Check if a Secure Enclave key exists
        return UserDefaults.standard.bool(forKey: "hasSecureEnclaveKey")
    }

    private func generateKeychainCertificate() {
        isGeneratingKeychain = true
        statusMessage = "Generating certificate..."

        Task {
            do {
                // Generate P256 key pair
                let privateKey = P256.Signing.PrivateKey()

                // Store in Keychain
                let keyData = privateKey.rawRepresentation
                let keychainKey = Constants.Keychain.keychainPrivateKeyTag

                // Save to keychain
                let query: [String: Any] = [
                    kSecClass as String: kSecClassKey,
                    kSecAttrApplicationTag as String: keychainKey.data(using: .utf8)!,
                    kSecValueData as String: keyData,
                    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
                ]

                // Delete existing if any
                    SecItemDelete(query as CFDictionary)
    
                    // Also delete any existing certificate chain
                    let certChainKey = Constants.Keychain.keychainPrivateKeyTag + Constants.Keychain.certChainSuffix
                    let deleteCertQuery: [String: Any] = [
                        kSecClass as String: kSecClassGenericPassword,
                        kSecAttrAccount as String: certChainKey
                    ]
                    SecItemDelete(deleteCertQuery as CFDictionary)
    
                    // Add new key
                    let status = SecItemAdd(query as CFDictionary, nil)
    
                if status == errSecSuccess {
                    await MainActor.run {
                        UserDefaults.standard.set(true, forKey: "hasKeychainCertificate")
                        statusMessage = "Certificate generated successfully"
                        isGeneratingKeychain = false
                    }
                } else {
                    throw NSError(domain: "Keychain", code: Int(status), userInfo: nil)
                }
            } catch {
                await MainActor.run {
                    statusMessage = "Failed to generate certificate: \(error.localizedDescription)"
                    isGeneratingKeychain = false
                }
            }
        }
    }

    private func generateSecureEnclaveKey() {
        isGeneratingSecureEnclave = true
        statusMessage = "Generating Secure Enclave key..."

        Task {
            do {
                // Create Secure Enclave key
                let tag = Data(Constants.Keychain.secureEnclaveKeyTag.utf8)

                // Delete existing key if any
                let deleteQuery: [String: Any] = [
                    kSecClass as String: kSecClassKey,
                    kSecAttrApplicationTag as String: tag
                ]
                    SecItemDelete(deleteQuery as CFDictionary)
    
                    // Also delete the associated certificate chain
                    let certChainKey = Constants.Keychain.secureEnclaveKeyTag + Constants.Keychain.certChainSuffix
                    let deleteCertQuery: [String: Any] = [
                        kSecClass as String: kSecClassGenericPassword,
                        kSecAttrAccount as String: certChainKey
                    ]
                    SecItemDelete(deleteCertQuery as CFDictionary)
    
                    // Generate new key
                    var error: Unmanaged<CFError>?
                    guard
                    let access = SecAccessControlCreateWithFlags(
                        kCFAllocatorDefault,
                        kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                        [.privateKeyUsage, .biometryAny],
                        &error
                    )
                else {
                    throw error!.takeRetainedValue() as Error
                }

                let attributes: [String: Any] = [
                    kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                    kSecAttrKeySizeInBits as String: 256,
                    kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
                    kSecPrivateKeyAttrs as String: [
                        kSecAttrIsPermanent as String: true,
                        kSecAttrApplicationTag as String: tag,
                        kSecAttrAccessControl as String: access
                    ]
                ]

                guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error)
                else {
                    throw error!.takeRetainedValue() as Error
                }

                // Get public key and create certificate
                guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
                    throw NSError(
                        domain: "SecureEnclave", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to get public key"])
                }

                // Create certificate using CertificateManager
                let config = CertificateManager.CertificateConfig(
                    commonName: "Device Certificate",
                    organization: "C2PA Example",
                    organizationalUnit: "Mobile",
                    country: "US",
                    state: "CA",
                    locality: "San Francisco",
                    emailAddress: nil,
                    validityDays: 365
                )

                let certificateChain = try CertificateManager.createSelfSignedCertificateChain(
                    for: publicKey,
                    config: config
                    )
    
                    // Mark that we have a Secure Enclave key (certificate chain is not stored here anymore)
                    UserDefaults.standard.set(true, forKey: "hasSecureEnclaveKey")
    
                    await MainActor.run {
                    statusMessage = "Secure Enclave key generated successfully"
                    isGeneratingSecureEnclave = false
                }
            } catch {
                await MainActor.run {
                    statusMessage = "Failed to generate key: \(error.localizedDescription)"
                    isGeneratingSecureEnclave = false
                    alertMessage = "Secure Enclave error: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }

    private func handleFileSelection(result: Result<[URL], Error>, isCertificate: Bool) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            do {
                let accessing = url.startAccessingSecurityScopedResource()
                defer {
                    if accessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                }

                let data = try Data(contentsOf: url)

                // Store in Keychain
                let keychainKey =
                    isCertificate
                    ? Constants.Keychain.customCertificateKey
                    : Constants.Keychain.customPrivateKeyKey

                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: keychainKey,
                    kSecValueData as String: data,
                    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
                ]

                // Delete existing
                SecItemDelete(query as CFDictionary)

                // Add new
                let status = SecItemAdd(query as CFDictionary, nil)

                if status == errSecSuccess {
                    if isCertificate {
                        customCertificatePath = url.lastPathComponent
                    } else {
                        customPrivateKeyPath = url.lastPathComponent
                    }
                    statusMessage = "\(isCertificate ? "Certificate" : "Key") stored in Keychain"
                } else {
                    statusMessage = "Failed to store in Keychain: \(status)"
                }

            } catch {
                statusMessage = "Error loading file: \(error.localizedDescription)"
            }

        case .failure(let error):
            statusMessage = "Selection failed: \(error.localizedDescription)"
        }
    }

    private func resetToDefault() {
        signingMode = SigningMode.defaultMode.rawValue
        customCertificatePath = ""
        customPrivateKeyPath = ""
        UserDefaults.standard.set(false, forKey: "hasKeychainCertificate")
        UserDefaults.standard.set(false, forKey: "hasSecureEnclaveKey")
        statusMessage = "Reset to default certificate"

        // Clean up keychain items
        let keysToDelete = [
            Constants.Keychain.keychainPrivateKeyTag,
            Constants.Keychain.secureEnclaveKeyTag,
            Constants.Keychain.customCertificateKey,
            Constants.Keychain.customPrivateKeyKey
        ]

        for key in keysToDelete {
            let query: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: key.data(using: .utf8)!
            ]
            SecItemDelete(query as CFDictionary)

            let passwordQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
                ]
                SecItemDelete(passwordQuery as CFDictionary)
    
                // Also delete certificate chains for keys that have them
                if key == Constants.Keychain.secureEnclaveKeyTag || key == Constants.Keychain.keychainPrivateKeyTag {
                    let certChainKey = key + Constants.Keychain.certChainSuffix
                    let certChainQuery: [String: Any] = [
                        kSecClass as String: kSecClassGenericPassword,
                        kSecAttrAccount as String: certChainKey
                    ]
                    SecItemDelete(certChainQuery as CFDictionary)
                }
            }
        }

    private func saveSettings() {
        // Settings are automatically saved via @AppStorage
        // Notify C2PAManager about the change
        NotificationCenter.default.post(name: Notification.Name("SigningModeChanged"), object: nil)
    }
}
