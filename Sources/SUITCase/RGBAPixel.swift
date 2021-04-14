/*
 SUITCase
Copyright ©2020 Devexperts LLC. All rights reserved.
This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

See https://code.devexperts.com for more open source projects
*/

#if !os(macOS)
    import UIKit
#endif

/// A primitive structure of RGBA pixel
/// - seealso https://en.wikipedia.org/wiki/RGBA_color_space
struct RGBAPixel: Equatable, Hashable {
    var red: UInt8
    var green: UInt8
    var blue: UInt8
    var alpha: UInt8

    init(red: UInt8 = 0,
         green: UInt8 = 0,
         blue: UInt8 = 0,
         alpha: UInt8 = 255) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(white: UInt8 = 0,
         alpha: UInt8 = 255) {
        self.red = white
        self.green = white
        self.blue = white
        self.alpha = alpha
    }

    init(uiColor: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        self.red = UInt8(cgFloat: red)
        self.green = UInt8(cgFloat: green)
        self.blue = UInt8(cgFloat: blue)
        self.alpha = UInt8(cgFloat: alpha)
    }

    var isOpaque: Bool { alpha == 255 }

    /// The light intensity
    /// - seealso https://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
    var lightIntensity: Double {
        let linearR = red.gammaExpanded
        let linearG = green.gammaExpanded
        let linearB = blue.gammaExpanded

        let linearY = 0.2126 * linearR + 0.7152 * linearG + 0.0722 * linearB

        if linearY <= 0.0031308 {
            return 12.92 * linearY
        } else {
            return 1.055 * pow(linearY, 1 / 2.4) - 0.055
        }
    }

    func intensityDistance(to pixel: RGBAPixel) -> Double {
        if self == pixel {
            return 0
        } else {
            return abs(self.lightIntensity - pixel.lightIntensity)
        }
    }

    // swiftlint:disable identifier_name
    /// The squared euclidean color distance between two pixels
    /// - seealso https://en.wikipedia.org/wiki/Color_difference
    func squaredDistance(to pixel: RGBAPixel) -> Double {
        if self == pixel {

            return 0
        } else {
            let (r1, g1, b1) = (Double(red), Double(green), Double(blue))
            let (r2, g2, b2) = (Double(pixel.red), Double(pixel.green), Double(pixel.blue))

            let (deltaR, deltaG, deltaB) = (r1 - r2, g1 - g2, b1 - b2)

            let meanR = (r1 + r2) / 510

            let weightedR = deltaR * deltaR * (2 + meanR)
            let weightedG = deltaG * deltaG * 4
            let weightedB = deltaB * deltaB * (3 - meanR)

            let weightedSum = weightedR + weightedG + weightedB
            let normalisedSum = weightedSum / 585225 // 9 * 255 * 255

            return normalisedSum
        }
    }

    static var black     = RGBAPixel(white: 0)
    static var darkGray  = RGBAPixel(white: 85)
    static var lightGray = RGBAPixel(white: 170)
    static var white     = RGBAPixel(white: 255)
    static var gray      = RGBAPixel(white: 128)
    static var red       = RGBAPixel(red: 255)
    static var green     = RGBAPixel(green: 255)
    static var blue      = RGBAPixel(blue: 255)
    static var cyan      = RGBAPixel(green: 255, blue: 255)
    static var yellow    = RGBAPixel(red: 255, green: 255)
    static var magenta   = RGBAPixel(red: 255, blue: 255)
    static var orange    = RGBAPixel(red: 255, green: 128)
    static var purple    = RGBAPixel(red: 128, blue: 128)
    static var brown     = RGBAPixel(red: 153, green: 102, blue: 51)
    static var clear     = RGBAPixel(white: 0, alpha: 0)
}

fileprivate extension UInt8 {
    init(cgFloat: CGFloat) {
        self = UInt8(round(Double(cgFloat) * 255))
    }

    var gammaExpanded: Double {
        if self < 11 {
            return Double(self) / 3294.6
        } else {
            return pow((Double(self) + 14.025) / 269.025, 2.4)
        }
    }
}
