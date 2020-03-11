/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import Foundation

@available(iOS 12.0, *)
extension SUITCase {
    func compareImages(withMethod method: ScreenshotComparisonMethod = .withTolerance(),
                       actual: RGBAImage,
                       reference: RGBAImage) throws -> (image: RGBAImage, value: Double) {
        let equalityCondition: (RGBAPixel, RGBAPixel) -> Bool
        switch method {
        case .averageColor:
            guard let actualColor = actual.averageColor,
                let expectedColor = reference.averageColor else {
                    throw VerifyScreenshotError.nothingCommon
            }
            let normalizedDifference = sqrt(actualColor.squaredDistance(to: expectedColor))

            let width = 100
            let differenceImagePixels = Array(repeating: actualColor, count: width * width)
                + Array(repeating: expectedColor, count: width * width)
            let differenceImage = RGBAImage(pixels: differenceImagePixels,
                                            width: width,
                                            height: 2 * width)
            addNote("Actual color:   \(actualColor)")
            addNote("Expected color: \(expectedColor)")
            return (differenceImage, normalizedDifference)
        case .strict:
            equalityCondition = { $0 == $1 }
        case .withTolerance(let tolerance), .dna(let tolerance, _):
            let squaredTolerance = tolerance * tolerance
            equalityCondition = { $0.squaredDistance(to: $1) <= squaredTolerance }
        case .greyscale(let tolerance):
            equalityCondition = { $0.intensityDistance(to: $1) <= tolerance }
        }
        var opaquePixelsCount = 0, incorrectPixelsCount = 0, pixelsCounter = 0
        var differenceImage = RGBAImage(pixel: DiffImageColors.fillColor, width: actual.width, height: actual.height)

        guard (actual.width, actual.height) == (reference.width, reference.height) else {
            throw VerifyScreenshotError.unexpectedSize
        }

        for (actualPixel, expectedPixel) in zip(actual.pixels, reference.pixels) {
            if actualPixel.isOpaque, expectedPixel.isOpaque {
                opaquePixelsCount += 1
                if !equalityCondition(actualPixel, expectedPixel) {
                    incorrectPixelsCount += 1
                    differenceImage.pixels[pixelsCounter] = DiffImageColors.tintColor
                }
            } else {
                differenceImage.pixels[pixelsCounter] = DiffImageColors.ignoredColor
            }
            pixelsCounter += 1
        }

        guard opaquePixelsCount > 0 else {
            throw VerifyScreenshotError.nothingCommon
        }

        let normalizedDifference = Double(incorrectPixelsCount) / Double(opaquePixelsCount)

        return (differenceImage, normalizedDifference)
    }

    struct DiffImageColors {
        static var ignoredColor = RGBAPixel.clear
        static var fillColor    = RGBAPixel.white
        static var tintColor    = RGBAPixel.black
    }
}
