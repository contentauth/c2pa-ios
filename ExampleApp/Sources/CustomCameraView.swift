// This file is licensed to you under the Apache License, Version 2.0 
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license 
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is 
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE 
// files for the specific language governing permissions and limitations under
// each license.

@preconcurrency import AVFoundation
import CoreLocation
import OSLog
import SwiftUI
import UIKit

struct CustomCameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    let onCapture: (UIImage, CLLocation?) -> Void

    func makeUIViewController(context: Context) -> CustomCameraViewController {
        let controller = CustomCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: CustomCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    @MainActor
    class Coordinator: NSObject, CustomCameraViewControllerDelegate {
        let parent: CustomCameraView

        init(_ parent: CustomCameraView) {
            self.parent = parent
        }

        func didCapturePhoto(_ image: UIImage, location: CLLocation?) {
            parent.capturedImage = image
            parent.onCapture(image, location)
        }

        func didCancel() {
            // Handle cancellation if needed
        }
    }
}

@MainActor
protocol CustomCameraViewControllerDelegate: AnyObject {
    func didCapturePhoto(_ image: UIImage, location: CLLocation?)
    func didCancel()
}

@MainActor
class CustomCameraViewController: UIViewController {
    weak var delegate: CustomCameraViewControllerDelegate?

    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var locationManager: CLLocationManager?
    private var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
        setupLocationManager()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
        startLocationUpdates()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
        stopLocationUpdates()
    }

    private func setupCamera() {
        #if targetEnvironment(simulator)
            os_log("Camera not available on simulator", log: Logger.general, type: .info)
            return
        #else

            captureSession = AVCaptureSession()
            guard let captureSession = captureSession else { return }

            captureSession.beginConfiguration()

            guard
                let camera = AVCaptureDevice.default(
                    .builtInWideAngleCamera, for: .video, position: .back)
            else {
                os_log("Unable to access back camera", log: Logger.error, type: .error)
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch {
                os_log(
                    "Error setting device input: %{public}@", log: Logger.error,
                    type: .error, error.localizedDescription)
                return
            }

            // Setup output
            photoOutput = AVCapturePhotoOutput()
            guard let photoOutput = photoOutput else { return }

            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
                if #available(iOS 16.0, *) {
                    if let maxDimensions = camera.activeFormat.supportedMaxPhotoDimensions.last {
                        photoOutput.maxPhotoDimensions = maxDimensions
                    }
                } else {
                    photoOutput.isHighResolutionCaptureEnabled = true
                }
            }

            captureSession.commitConfiguration()

            // Setup preview layer
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = view.bounds

            if let previewLayer = previewLayer {
                view.layer.insertSublayer(previewLayer, at: 0)
            }
        #endif
    }

    private func setupUI() {
        view.backgroundColor = .black

        #if targetEnvironment(simulator)
            // Add a label for simulator
            let simulatorLabel = UILabel()
            simulatorLabel.text = "Camera Preview\n(Simulator Mode)"
            simulatorLabel.textAlignment = .center
            simulatorLabel.numberOfLines = 2
            simulatorLabel.textColor = .white
            simulatorLabel.font = .systemFont(ofSize: 20)
            simulatorLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(simulatorLabel)
            NSLayoutConstraint.activate([
                simulatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                simulatorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        #endif

        // Add capture button with black background and white icon
        let captureButton = UIButton(type: .custom)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium, scale: .large)
        let cameraImage = UIImage(systemName: "camera.fill", withConfiguration: largeConfig)
        captureButton.setImage(cameraImage, for: .normal)
        captureButton.tintColor = .white
        captureButton.backgroundColor = .black.withAlphaComponent(0.7)
        captureButton.layer.cornerRadius = 50
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)

        // Make the button larger
        captureButton.contentHorizontalAlignment = .center
        captureButton.contentVerticalAlignment = .center
        captureButton.imageView?.contentMode = .scaleAspectFit

        view.addSubview(captureButton)

        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 100),
            captureButton.heightAnchor.constraint(equalToConstant: 100)
        ])

        // Add cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelCapture), for: .touchUpInside)

        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func startSession() {
        // Capture the session before going off main actor
        guard let session = captureSession else { return }
        Task {
            await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    session.startRunning()
                    continuation.resume()
                }
            }
        }
    }

    private func stopSession() {
        captureSession?.stopRunning()
    }

    @objc private func capturePhoto() {
        #if targetEnvironment(simulator)
            // Simulate photo capture on simulator
            simulatePhotoCapture()
        #else
            guard let photoOutput = photoOutput else { return }

            let settings = AVCapturePhotoSettings()
            if #available(iOS 16.0, *) {
                settings.maxPhotoDimensions = photoOutput.maxPhotoDimensions
            } else {
                settings.isHighResolutionPhotoEnabled = true
            }

            photoOutput.capturePhoto(with: settings, delegate: self)
        #endif
    }

    #if targetEnvironment(simulator)
        private func simulatePhotoCapture() {
            // Create a placeholder image for simulator
            let placeholderView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 600))
            placeholderView.backgroundColor = .systemBlue

            let label = UILabel(frame: placeholderView.bounds)
            label.text = "Simulated Photo\n\(Date())"
            label.textAlignment = .center
            label.numberOfLines = 2
            label.textColor = .white
            label.font = .systemFont(ofSize: 24, weight: .bold)
            placeholderView.addSubview(label)

            let renderer = UIGraphicsImageRenderer(size: placeholderView.bounds.size)
            let image = renderer.image { ctx in
                placeholderView.layer.render(in: ctx.cgContext)
            }

            // Call delegate with simulated image
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didCapturePhoto(image, location: self?.currentLocation)
                self?.dismiss(animated: true)
            }
        }
    #endif

    @objc private func cancelCapture() {
        dismiss(animated: true) {
            self.delegate?.didCancel()
        }
    }
}

extension CustomCameraViewController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            os_log(
                "Error capturing photo: %{public}@", log: Logger.error,
                type: .error, error.localizedDescription)
            return
        }

        guard let imageData = photo.fileDataRepresentation() else {
            os_log("Unable to create image data from photo", log: Logger.error, type: .error)
            return
        }

        Task { @MainActor in
            // Add GPS metadata if location is available
            var finalImageData = imageData
            if let location = currentLocation {
                finalImageData = addGPSMetadata(to: imageData, location: location) ?? imageData
            }

            guard let image = UIImage(data: finalImageData) else {
                os_log("Unable to create image from photo data", log: Logger.error, type: .error)
                return
            }

            // Do NOT save to photo library here - just pass the image to the delegate
            // The delegate will handle C2PA signing and then save
            os_log(
                "Photo captured, passing to delegate for C2PA signing", log: Logger.general,
                type: .info)
            if let loc = currentLocation {
                os_log(
                    "Current location: %f, %f", log: Logger.metadata,
                    type: .debug, loc.coordinate.latitude, loc.coordinate.longitude)
            }

            delegate?.didCapturePhoto(image, location: currentLocation)
            dismiss(animated: true)
        }
    }

    // MARK: - Location Manager

    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
    }

    private func startLocationUpdates() {
        locationManager?.startUpdatingLocation()
    }

    private func stopLocationUpdates() {
        locationManager?.stopUpdatingLocation()
    }

    private func addGPSMetadata(to imageData: Data, location: CLLocation) -> Data? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
            let uti = CGImageSourceGetType(source)
        else {
            return nil
        }

        let mutableData = NSMutableData()
        guard let mutableDestination = CGImageDestinationCreateWithData(mutableData, uti, 1, nil)
        else {
            return nil
        }

        // Get existing properties
        var properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] ?? [:]

        // Create GPS metadata
        var gpsDict: [String: Any] = [:]

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        gpsDict[kCGImagePropertyGPSLatitude as String] = abs(latitude)
        gpsDict[kCGImagePropertyGPSLatitudeRef as String] = latitude >= 0 ? "N" : "S"
        gpsDict[kCGImagePropertyGPSLongitude as String] = abs(longitude)
        gpsDict[kCGImagePropertyGPSLongitudeRef as String] = longitude >= 0 ? "E" : "W"
        gpsDict[kCGImagePropertyGPSAltitude as String] = location.altitude
        gpsDict[kCGImagePropertyGPSTimeStamp as String] = location.timestamp.timeIntervalSince1970
        gpsDict[kCGImagePropertyGPSDateStamp as String] = ISO8601DateFormatter().string(
            from: location.timestamp)

        if location.horizontalAccuracy >= 0 {
            gpsDict[kCGImagePropertyGPSDOP as String] = location.horizontalAccuracy
        }

        if location.speed >= 0 {
            gpsDict[kCGImagePropertyGPSSpeed as String] = location.speed
            gpsDict[kCGImagePropertyGPSSpeedRef as String] = "K"  // km/h
        }

        if location.course >= 0 {
            gpsDict[kCGImagePropertyGPSTrack as String] = location.course
            gpsDict[kCGImagePropertyGPSTrackRef as String] = "T"  // True direction
        }

        // Add GPS metadata to properties
        properties[kCGImagePropertyGPSDictionary as String] = gpsDict

        // Add the image with metadata
        CGImageDestinationAddImageFromSource(
            mutableDestination, source, 0, properties as CFDictionary)

        guard CGImageDestinationFinalize(mutableDestination) else {
            return nil
        }

        os_log(
            "Added GPS metadata - Lat: %f, Lon: %f, Alt: %fm", log: Logger.metadata,
            type: .debug, latitude, longitude, location.altitude)

        return mutableData as Data
    }
}

// MARK: - CLLocationManagerDelegate

extension CustomCameraViewController: CLLocationManagerDelegate {
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        Task { @MainActor in
            currentLocation = locations.last
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        os_log(
            "Location error: %{public}@", log: Logger.error,
            type: .error, error.localizedDescription)
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
            return
        }

        Task { @MainActor in
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                startLocationUpdates()
            case .denied, .restricted:
                os_log("Location access denied", log: Logger.general, type: .default)
            case .notDetermined:
                break  // Already handled above
            @unknown default:
                break
            }
        }
    }
}
