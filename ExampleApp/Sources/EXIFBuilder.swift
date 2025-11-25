// This file is licensed to you under the Apache License, Version 2.0 
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license 
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is 
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF 
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE 
// files for the specific language governing permissions and limitations under
// each license.

import CoreLocation
import Foundation
import ImageIO
import UIKit

@MainActor
struct EXIFBuilder {
    private var data: [String: Any] = [
        "@context": ["exif": "http://ns.adobe.com/exif/1.0/"]
    ]

    init() {
        data["exif:Make"] = "Apple"
        data["exif:Model"] = UIDevice.current.model
        data["exif:Software"] = "C2PA Example iOS \(UIDevice.current.systemVersion)"
        let currentDate = ISO8601DateFormatter().string(from: Date())
        data["exif:DateTimeOriginal"] = currentDate
        data["exif:DateTimeDigitized"] = currentDate
    }

    mutating func addImageMetadata(from imageData: Data) {
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
                as? [String: Any]
        else {
            return
        }

        if let exifDict = properties[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            applyEXIFData(exifDict)
        }

        if let gpsDict = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            applyGPSData(gpsDict)
        }

        if let width = properties[kCGImagePropertyPixelWidth as String] as? Int {
            data["exif:PixelXDimension"] = "\(width)"
        }
        if let height = properties[kCGImagePropertyPixelHeight as String] as? Int {
            data["exif:PixelYDimension"] = "\(height)"
        }
    }

    mutating func addLocation(_ location: CLLocation?) {
        guard let location = location else { return }
        data["exif:GPSLatitude"] = "\(location.coordinate.latitude)"
        data["exif:GPSLongitude"] = "\(location.coordinate.longitude)"
        if location.altitude >= 0 {
            data["exif:GPSAltitude"] = "\(location.altitude)"
        }
    }

    private mutating func applyEXIFData(_ exifDict: [String: Any]) {
        let mappings: [(String, String)] = [
            (kCGImagePropertyExifFocalLength as String, "exif:FocalLength"),
            (kCGImagePropertyExifFNumber as String, "exif:FNumber"),
            (kCGImagePropertyExifExposureTime as String, "exif:ExposureTime"),
            (kCGImagePropertyExifWhiteBalance as String, "exif:WhiteBalance"),
            (kCGImagePropertyExifFlash as String, "exif:Flash"),
            (kCGImagePropertyExifLensModel as String, "exif:LensModel"),
            (kCGImagePropertyExifColorSpace as String, "exif:ColorSpace"),
            (kCGImagePropertyExifVersion as String, "exif:ExifVersion"),
            (kCGImagePropertyExifOffsetTime as String, "exif:OffsetTime")
        ]

        for (key, exifKey) in mappings {
            if let value = exifDict[key] {
                data[exifKey] = "\(value)"
            }
        }

        if let iso = exifDict[kCGImagePropertyExifISOSpeedRatings as String] as? [Int],
            let isoValue = iso.first
        {
            data["exif:ISOSpeedRatings"] = "\(isoValue)"
        }
    }

    private mutating func applyGPSData(_ gpsDict: [String: Any]) {
        if let latitude = gpsDict[kCGImagePropertyGPSLatitude as String] as? Double {
            let latRef = gpsDict[kCGImagePropertyGPSLatitudeRef as String] as? String ?? "N"
            data["exif:GPSLatitude"] = "\(latRef == "S" ? -latitude : latitude)"
        }

        if let longitude = gpsDict[kCGImagePropertyGPSLongitude as String] as? Double {
            let lonRef = gpsDict[kCGImagePropertyGPSLongitudeRef as String] as? String ?? "E"
            data["exif:GPSLongitude"] = "\(lonRef == "W" ? -longitude : longitude)"
        }

        if let altitude = gpsDict[kCGImagePropertyGPSAltitude as String] as? Double {
            data["exif:GPSAltitude"] = "\(altitude)"
        }
    }

    func toJSON() throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [.sortedKeys])
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }
}
