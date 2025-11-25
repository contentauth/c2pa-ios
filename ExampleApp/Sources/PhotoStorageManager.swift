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
import OSLog
import UIKit

@MainActor
final class PhotoStorageManager {
    static let shared = PhotoStorageManager()

    private let documentsDirectory: URL
    private let photosDirectory: URL

    private init() {
        documentsDirectory = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        ).first!
        photosDirectory = documentsDirectory.appendingPathComponent("SignedPhotos")

        try? FileManager.default.createDirectory(
            at: photosDirectory, withIntermediateDirectories: true)
    }

    func saveSignedPhoto(_ imageData: Data) throws -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        let fileName = "C2PA_\(timestamp).jpg"

        let fileURL = photosDirectory.appendingPathComponent(fileName)
        try imageData.write(to: fileURL)

        os_log("Saved signed photo to: %{public}@", log: Logger.storage, type: .debug, fileURL.path)
        return fileURL
    }

    func getLatestSignedPhoto() -> URL? {
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: photosDirectory,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )

            let sortedFiles = files.sorted { url1, url2 in
                let date1 =
                    (try? url1.resourceValues(
                        forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                let date2 =
                    (try? url2.resourceValues(
                        forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                return date1 > date2
            }

            return sortedFiles.first
        } catch {
            os_log(
                "Error getting latest photo: %{public}@", log: Logger.error,
                type: .error, error.localizedDescription)
            return nil
        }
    }

    func getAllSignedPhotos() -> [URL] {
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: photosDirectory,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )

            return files.sorted { url1, url2 in
                let date1 =
                    (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate)
                    ?? Date.distantPast
                let date2 =
                    (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate)
                    ?? Date.distantPast
                return date1 > date2
            }
        } catch {
            print("Error listing photos: \(error)")
            return []
        }
    }

    func getPhotosDirectoryURL() -> URL {
        return photosDirectory
    }
}
