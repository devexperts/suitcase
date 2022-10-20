/*
 SUITCase

Copyright ©2020 Devexperts LLC. All rights reserved.
This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

 See https://code.devexperts.com for more open source projects
*/

import XCTest

/// A structure describing image built with RGBA pixels.
public struct RGBAImage: Equatable {
    var pixels: [RGBAPixel]
    var width: Int
    var height: Int

    init(pixels: [RGBAPixel], width: Int, height: Int) {
        self.pixels = pixels
        self.width = width
        self.height = height
    }

    init(pixel: RGBAPixel, width: Int, height: Int) {
        self.pixels = Array(repeating: pixel, count: width * height)
        self.width = width
        self.height = height
    }

    init(uiImage: UIImage) {
        guard
            let cgImage = uiImage.cgImage,
            let colorSpace = cgImage.colorSpace else {
                XCTFail("Unable to unwrap UIImage")
                exit(0)
        }
        width = cgImage.width
        height = cgImage.height
        pixels = []
        pixels.reserveCapacity(width * height)
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard
            let context = CGContext(data: nil,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: bitsPerComponent,
                                    bytesPerRow: bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: bitmapInfo),
            let data = context.data?.assumingMemoryBound(to: UInt8.self) else {
                XCTFail("Unable to create CGContext")
                exit(0)
        }

        let rectangle = CGRect(x: 0, y: 0, width: width, height: height)
        let bitsPerPixel = cgImage.bitsPerPixel

        context.draw(cgImage, in: rectangle)

        for rowNumber in 0..<height {
            for columnNumber in 0..<width {
                let offset = bytesPerRow * rowNumber + (bitsPerPixel * columnNumber) / bitsPerComponent
                let red   = data[offset]
                let green = data[offset + 1]
                let blue  = data[offset + 2]
                let alpha = data[offset + 3]
                pixels.append(RGBAPixel(red: red, green: green, blue: blue, alpha: alpha))
            }
        }
    }

    var uiImage: UIImage {
        var pixelsCopy = pixels
        let bitmapCount = width * height
        let pixelMemoryLayout = MemoryLayout<RGBAPixel>.size
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
        let renderingIntent = CGColorRenderingIntent.defaultIntent

        guard
            let dataProvider = CGDataProvider(data: NSData(bytes: &pixelsCopy,
                                                           length: bitmapCount * pixelMemoryLayout)),
            let cgimage = CGImage(width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bitsPerPixel: 32,
                                  bytesPerRow: width * pixelMemoryLayout,
                                  space: rgbColorSpace,
                                  bitmapInfo: bitmapInfo,
                                  provider: dataProvider,
                                  decode: nil,
                                  shouldInterpolate: true,
                                  intent: renderingIntent) else {
                                    XCTFail("Unable to get CGDataProvider")
                                    exit(0)
        }
        let uiImage = UIImage(cgImage: cgimage)
        return uiImage
    }

    var averageColor: RGBAPixel? {
        var opaquePixelsCount = 0
        var sumOfRed = 0
        var sumOfGreen = 0
        var sumOfBlue = 0

        for pixel in pixels where pixel.isOpaque {
            opaquePixelsCount += 1
            sumOfRed += Int(pixel.red)
            sumOfGreen += Int(pixel.green)
            sumOfBlue += Int(pixel.blue)
        }
        guard opaquePixelsCount > 0 else {

            return nil
        }

        func divideAndRound(_ sum: Int) -> UInt8 {
            let answer = round(Double(sum) / Double(opaquePixelsCount))
            return UInt8(answer)
        }

        return RGBAPixel(red: divideAndRound(sumOfRed),
                         green: divideAndRound(sumOfGreen),
                         blue: divideAndRound(sumOfBlue))
    }
}
