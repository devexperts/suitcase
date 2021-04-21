/*
 SUITCase

Copyright (C) 2002 - 2021 Devexperts LLC
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

 See https://code.devexperts.com for more open source projects
*/

import XCTest

@available(iOS 12.0, *)
@available(tvOS 10.0, *)
public protocol SUITCaseMethod {
    // Resizes the image, dismisses its orientation
    func prepareScreenshot(_ image: UIImage) -> UIImage
    // Compare images and return difference
    func compareImages(actual: UIImage, reference: UIImage) throws -> (value: Double, image: RGBAImage)
}

@available(iOS 12.0, *)
@available(tvOS 10.0, *)
/// Downscales screenshots and allows configurable tolerance while comparing pixels.
public class SUITCaseMethodWithTolerance: SUITCaseMethod {
    var tolerance: Double

    public func prepareScreenshot(_ image: UIImage) -> UIImage {
        return image.resized(by: 1 / image.scale)
    }

    func equalityCondition(_ pixel1: RGBAPixel, _ pixel2: RGBAPixel) -> Bool {
        return pixel1.squaredDistance(to: pixel2) <= tolerance * tolerance
    }

    public func compareImages(actual: UIImage,
                              reference: UIImage) throws -> (value: Double, image: RGBAImage) {
        let actualRGBAImage = RGBAImage(uiImage: actual)
        let referenceRGBAImage = RGBAImage(uiImage: reference)

        var opaquePixelsCount = 0
        var incorrectPixelsCount = 0
        var pixelsCounter = 0
        var differenceImage = RGBAImage(pixel: DiffImageColors.fillColor,
                                        width: actualRGBAImage.width,
                                        height: actualRGBAImage.height)

        guard (actualRGBAImage.width, actualRGBAImage.height) == (referenceRGBAImage.width, referenceRGBAImage.height) else {
            throw SUITCase.VerifyScreenshotError.unexpectedSize
        }

        for (actualPixel, expectedPixel) in zip(actualRGBAImage.pixels, referenceRGBAImage.pixels) {
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
            throw SUITCase.VerifyScreenshotError.nothingCommon
        }

        let normalizedDifference = Double(incorrectPixelsCount) / Double(opaquePixelsCount)

        return (normalizedDifference, differenceImage)
    }

    struct DiffImageColors {
        static var ignoredColor = RGBAPixel.clear
        static var fillColor    = RGBAPixel.white
        static var tintColor    = RGBAPixel.black
    }

    public init(_ tolerance: Double = 0.1) {
        self.tolerance = tolerance
    }
}

@available(iOS 12.0, *)
@available(tvOS 10.0, *)
/// The most accurate method, which compares original screenshots pixel by pixel.
public class SUITCaseMethodStrict: SUITCaseMethodWithTolerance {
    public override func prepareScreenshot(_ image: UIImage) -> UIImage {
        return image.resized(by: 1)
    }

    override func equalityCondition(_ pixel1: RGBAPixel, _ pixel2: RGBAPixel) -> Bool {
        return pixel1 == pixel2
    }

    public init() { }
}

@available(iOS 12.0, *)
@available(tvOS 10.0, *)
/// Downscales screenshots, removes color saturation, and allows configurable tolerance while comparing pixels.
public class SUITCaseMethodGreyscale: SUITCaseMethodWithTolerance {
    override func equalityCondition(_ pixel1: RGBAPixel, _ pixel2: RGBAPixel) -> Bool {
        return pixel1.intensityDistance(to: pixel2) <= tolerance
    }

    public init(tolerance: Double = 0.1) {
        super.init(tolerance)
    }
}

@available(iOS 12.0, *)
@available(tvOS 10.0, *)
/// Extremely dowscales screenshots, and allows configurable tolerance while comparing pixels.
public class SUITCaseMethodDNA: SUITCaseMethodWithTolerance {
    var scaleFactor: CGFloat

    public override func prepareScreenshot(_ image: UIImage) -> UIImage {
        return image.dna(scaleFactor: CGFloat(scaleFactor))
    }

    override func equalityCondition(_ pixel1: RGBAPixel, _ pixel2: RGBAPixel) -> Bool {
        return pixel1.squaredDistance(to: pixel2) <= tolerance * tolerance
    }

    public init(tolerance: Double = 0.1, scaleFactor: CGFloat = 0.03) {
        self.scaleFactor = scaleFactor
        super.init(tolerance)
    }
}

@available(iOS 12.0, *)
@available(tvOS 10.0, *)
/// Compares average colors of screenshots.
public class SUITCaseMethodAverageColor: SUITCaseMethod {
    public func prepareScreenshot(_ image: UIImage) -> UIImage {
        return image.resized(by: 1 / image.scale)
    }

    public func compareImages(actual: UIImage, reference: UIImage) throws -> (value: Double, image: RGBAImage) {
        guard let actualColor = RGBAImage(uiImage: actual).averageColor,
            let expectedColor = RGBAImage(uiImage: reference).averageColor else {
                throw SUITCase.VerifyScreenshotError.nothingCommon
        }
        let normalizedDifference = sqrt(actualColor.squaredDistance(to: expectedColor))

        let width = 100
        let differenceImagePixels = Array(repeating: actualColor, count: width * width)
            + Array(repeating: expectedColor, count: width * width)
        let differenceImage = RGBAImage(pixels: differenceImagePixels,
                                        width: width,
                                        height: 2 * width)
        XCTContext.runActivity(named: "Actual color:   \(actualColor)") { _ in }
        XCTContext.runActivity(named: "Expected color: \(expectedColor)") { _ in }
        return (normalizedDifference, differenceImage)
    }

    public init() { }
}
