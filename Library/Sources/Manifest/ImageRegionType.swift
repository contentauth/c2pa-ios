// This file is licensed to you under the Apache License, Version 2.0
// (http://www.apache.org/licenses/LICENSE-2.0) or the MIT license
// (http://opensource.org/licenses/MIT), at your option.
//
// Unless required by applicable law or agreed to in writing, this software is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS OF
// ANY KIND, either express or implied. See the LICENSE-MIT and LICENSE-APACHE
// files for the specific language governing permissions and limitations under
// each license.
//
//  ImageRegionType.swift
//

import Foundation

/**
 Image Region Type controlled vocabulary

 https://cv.iptc.org/newscodes/imageregiontype/
 */
public enum ImageRegionType: String, Codable {

    /**
     A living organism different from humans or flora
     */
    case animal = "http://cv.iptc.org/newscodes/imageregiontype/animal"

    /**
     Artistic work
     */
    case artwork = "http://cv.iptc.org/newscodes/imageregiontype/artwork"

    /**
     A line expressing a visual division of the image, such as a horizon
     */
    case dividingLine = "http://cv.iptc.org/newscodes/imageregiontype/dividingLine"

    /**
     A living organism different from humans and animals
     */
    case plant = "http://cv.iptc.org/newscodes/imageregiontype/plant"

    /**
     A named area on the surface of the planet earth

     Specific details of the area can be expressed by other metadata
     */
    case geoArea = "http://cv.iptc.org/newscodes/imageregiontype/geoArea"

    /**
     A graphic representation of information
     */
    case graphic = "http://cv.iptc.org/newscodes/imageregiontype/graphic"

    /**
     Optical label such as barcode or QR code
     */
    case machineCode = "http://cv.iptc.org/newscodes/imageregiontype/machineCode"

    /**
     A human being
     */
    case human = "http://cv.iptc.org/newscodes/imageregiontype/human"

    /**
     A thing that was produced and can be handed over
     */
    case product = "http://cv.iptc.org/newscodes/imageregiontype/product"

    /**
     Human readable script of any language
     */
    case text = "http://cv.iptc.org/newscodes/imageregiontype/text"

    /**
     A structure with walls and roof in most cases
     */
    case building = "http://cv.iptc.org/newscodes/imageregiontype/building"

    /**
     An object used for transporting something, like car, train, ship, plane or bike
     */
    case vehicle = "http://cv.iptc.org/newscodes/imageregiontype/vehicle"

    /**
     Substances providing nutrition for a living body
     */
    case food = "http://cv.iptc.org/newscodes/imageregiontype/food"

    /**
     Something worn to cover the body
     */
    case clothing = "http://cv.iptc.org/newscodes/imageregiontype/clothing"

    /**
     A special formation of stone mass
     */
    case rockFormation = "http://cv.iptc.org/newscodes/imageregiontype/rockFormation"

    /**
     A significant accumulation of water

     Including a waterfall, a geyser and other phenomena of water
     */
    case bodyOfWater = "http://cv.iptc.org/newscodes/imageregiontype/bodyOfWater"
}
