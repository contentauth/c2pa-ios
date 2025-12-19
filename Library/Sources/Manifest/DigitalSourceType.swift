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
//  DigitalSourceType.swift
//

import Foundation

/**
 The value of digitalSourceType is one of the URLs specified by the International Press Telecommunications Council (IPTC) NewsCodes Digital Source Type scheme of the form http://cv.iptc.org/newscodes/digitalsourcetype/<CODE>

 https://opensource.contentauthenticity.org/docs/manifest/writing/assertions-actions#digital-source-type
 */
public enum DigitalSourceType: String, Codable {

    /**
     Minor augmentation or correction by algorithm.
     */
    case algorithmicallyEnhanced = "http://cv.iptc.org/newscodes/digitalsourcetype/algorithmicallyEnhanced"

    /**
     Media created purely by an algorithm not based on any sampled training data, e.g. an image created by software using a mathematical formula.
     */
    case algorithmicMedia = "http://cv.iptc.org/newscodes/digitalsourcetype/algorithmicMedia"

    /**
     Mix or composite of several elements, any of which may or may not be generative AI.
     */
    case composite = "http://cv.iptc.org/newscodes/digitalsourcetype/composite"

    /**
     Mix or composite of several elements that are all captures of real life.
     */
    case compositeCapture = "http://cv.iptc.org/newscodes/digitalsourcetype/compositeCapture"

    /**
     Mix or composite of several elements, at least one of which is synthetic.
     */
    case compositeSynthetic = "http://cv.iptc.org/newscodes/digitalsourcetype/compositeSynthetic"

    /**
     The compositing of trained algorithmic media with some other media, such as with inpainting or outpainting operations.
     */
    case compositeWithTrainedAlgorithmicMedia = "http://cv.iptc.org/newscodes/digitalsourcetype/compositeWithTrainedAlgorithmicMedia"

    /**
     Digital media representation of data via human programming or creativity.
     */
    case dataDrivenMedia = "http://cv.iptc.org/newscodes/digitalsourcetype/dataDrivenMedia"

    /**
     Media created by a human using non-generative tools. Use instead of retired digitalArt code.
     */
    case digitalCreation = "http://cv.iptc.org/newscodes/digitalsourcetype/digitalCreation"

    /**
     The digital media is captured from a real-life source using a digital camera or digital recording device.
     */
    case digitalCapture = "http://cv.iptc.org/newscodes/digitalsourcetype/digitalCapture"

    /**
     Augmentation, correction or enhancement by one or more humans using non-generative tools. Use instead of retired minorHumanEdits code.
     */
    case humanEdits = "http://cv.iptc.org/newscodes/digitalsourcetype/humanEdits"

    /**
     The digital image was digitized from a negative on film or any other transparent medium.
     */
    case negativeFilm = "http://cv.iptc.org/newscodes/digitalsourcetype/negativeFilm"

    /**
     The digital image was digitized from a positive on a transparency or any other transparent medium.
     */
    case positiveFilm = "http://cv.iptc.org/newscodes/digitalsourcetype/positiveFilm"

    /**
     The digital image was digitized from an image printed on a non-transparent medium.
     */
    case print = "http://cv.iptc.org/newscodes/digitalsourcetype/print"

    /**
     A capture of the contents of the screen of a computer or mobile device.
     */
    case screenCapture = "http://cv.iptc.org/newscodes/digitalsourcetype/screenCapture"

    /**
     Digital media created algorithmically using a model derived from sampled content.
     */
    case trainedAlgorithmicMedia = "http://cv.iptc.org/newscodes/digitalsourcetype/trainedAlgorithmicMedia"

    /**
     Live recording of virtual event based on synthetic and optionally captured elements.
     */
    case virtualRecording = "http://cv.iptc.org/newscodes/digitalsourcetype/virtualRecording"
}
