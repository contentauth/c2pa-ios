// This file is licensed to you under the Apache License, Version 2.0 
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license 
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is 
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE 
// files for the specific language governing permissions and limitations under
// each license.

import SwiftUI
import UniformTypeIdentifiers
import WebKit

// Custom WebView that intercepts file uploads
class CustomWebView: WKWebView, WKUIDelegate {
    weak var fileUploadNavigationController: UINavigationController?
    var uploadCompletionHandler: (([URL]) -> Void)?

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.uiDelegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.uiDelegate = self
    }

    // Intercept file upload requests - iOS 18.4+ API
    private func webView(
        _ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters,
        initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void
    ) {
        print("DEBUG: runOpenPanelWith called!")
        print("DEBUG: allowsMultipleSelection: \(parameters.allowsMultipleSelection)")

        uploadCompletionHandler = completionHandler

        // Go straight to C2PA photo picker
        showSignedPhotoPicker()
    }

    private func showSignedPhotoPicker() {
        let photos = PhotoStorageManager.shared.getAllSignedPhotos()

        // Find the topmost view controller to present from
        func findTopViewController(_ viewController: UIViewController?) -> UIViewController? {
            guard let vc = viewController else { return nil }

            if let presented = vc.presentedViewController {
                return findTopViewController(presented)
            }

            if let nav = vc as? UINavigationController {
                return findTopViewController(nav.visibleViewController)
            }

            if let tab = vc as? UITabBarController {
                return findTopViewController(tab.selectedViewController)
            }

            return vc
        }

        guard let rootVC = self.window?.rootViewController,
            let topVC = findTopViewController(rootVC)
        else {
            print("DEBUG: Could not find view controller to present from!")
            self.uploadCompletionHandler?([])
            return
        }

        if photos.isEmpty {
            // No signed photos, show message
            let alert = UIAlertController(
                title: "No Signed Photos",
                message: "Take a photo with C2PA Example first to add credentials.",
                preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "OK", style: .default) { _ in
                    self.uploadCompletionHandler?([])
                })

            topVC.present(alert, animated: true)
            return
        }

        // Create a custom photo picker for signed photos
        let pickerVC = SignedPhotoPickerViewController(photos: photos) { [weak self] selectedURL in
            if let url = selectedURL {
                // Copy to temp directory for upload
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(
                    url.lastPathComponent)
                try? FileManager.default.removeItem(at: tempURL)  // Remove if exists
                try? FileManager.default.copyItem(at: url, to: tempURL)
                self?.uploadCompletionHandler?([tempURL])
            } else {
                self?.uploadCompletionHandler?([])
            }
        }

        let navController = UINavigationController(rootViewController: pickerVC)
        print("DEBUG: Presenting photo picker from: \(type(of: topVC))")
        topVC.present(navController, animated: true)
    }

}

// Custom view controller for picking signed photos
class SignedPhotoPickerViewController: UIViewController {
    private let photos: [URL]
    private let completion: (URL?) -> Void
    private var collectionView: UICollectionView!

    init(photos: [URL], completion: @escaping (URL?) -> Void) {
        self.photos = photos
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "C2PA Photos"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))

        // Setup collection view
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")

        view.addSubview(collectionView)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true) {
            self.completion(nil)
        }
    }
}

extension SignedPhotoPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
        -> Int
    {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
            as! PhotoCell
        let photoURL = photos[indexPath.item]

        if let imageData = try? Data(contentsOf: photoURL),
            let image = UIImage(data: imageData)
        {
            cell.imageView.image = image
        }

        cell.label.text = photoURL.lastPathComponent
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPhoto = photos[indexPath.item]
        dismiss(animated: true) {
            self.completion(selectedPhoto)
        }
    }
}

class PhotoCell: UICollectionViewCell {
    let imageView = UIImageView()
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.75),

            label.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var shouldReload: Bool

    func makeUIView(context: Context) -> CustomWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        let webView = CustomWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        // Ensure the UI delegate is set (it's already set in CustomWebView init, but double-check)
        webView.uiDelegate = webView

        print("DEBUG: WebView created with uiDelegate set")

        return webView
    }

    func updateUIView(_ webView: CustomWebView, context: Context) {
        if shouldReload {
            let request = URLRequest(url: url)
            webView.load(request)
            DispatchQueue.main.async {
                shouldReload = false
            }
        } else if webView.url == nil {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        private func webView(
            _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if let url = navigationAction.request.url {
                // Allow content credentials sites and local files
                if url.host == "contentcredentials.org" || url.host == "www.contentcredentials.org"
                    || url.host == "verify.contentauthenticity.org" || url.scheme == "file"
                {
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.cancel)
                }
            } else {
                decisionHandler(.cancel)
            }
        }
    }
}

struct VerifyWebView: View {
    @Binding var isPresented: Bool
    @State private var shouldReloadWebView = false

    var body: some View {
        NavigationView {
            // Just the webview - no additional UI
            WebView(
                url: URL(string: "https://check.proofmode.org")!,
                shouldReload: $shouldReloadWebView
            )
            .navigationTitle("Verify Content")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            shouldReloadWebView = true
                        },
                        label: {
                            Image(systemName: "arrow.clockwise")
                        })
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// Share sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
