/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest

@available(iOS 12.0, *)
public protocol SUITCaseMethod {
    // Resizes the image, dismisses its orientation
    func prepareScreenshot(_ image: UIImage) -> UIImage
    // Compare images and return difference
    func compareImages(actual: RGBAImage, reference: RGBAImage) throws -> (value: Double, image: RGBAImage)
}

@available(iOS 12.0, *)
/// The most accurate method, which compares original screenshots pixel by pixel.
public class SUITCaseMethodStrict: SUITCaseMethod {
    public func prepareScreenshot(_ image: UIImage) -> UIImage {
        return image.resized(by: 1)
    }

    func equalityCondition(_ pixel1: RGBAPixel, _ pixel2: RGBAPixel) -> Bool {
        return pixel1 == pixel2
    }

    public func compareImages(actual: RGBAImage,
                              reference: RGBAImage) throws -> (value: Double, image: RGBAImage) {
        var opaquePixelsCount = 0
        var incorrectPixelsCount = 0
        var pixelsCounter = 0
        var differenceImage = RGBAImage(pixel: DiffImageColors.fillColor,
                                        width: actual.width,
                                        height: actual.height)

        guard (actual.width, actual.height) == (reference.width, reference.height) else {
            throw SUITCase.VerifyScreenshotError.unexpectedSize
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

    public init() { }
}

@available(iOS 12.0, *)
/// Downscales screenshots and allows configurable tolerance while comparing pixels.
public class SUITCaseMethodWithTolerance: SUITCaseMethodStrict {
    var tolerance: Double

    public override func prepareScreenshot(_ image: UIImage) -> UIImage {
        return image.resized(by: 1 / image.scale)
    }

    override func equalityCondition(_ pixel1: RGBAPixel, _ pixel2: RGBAPixel) -> Bool {
        return pixel1.squaredDistance(to: pixel2) <= tolerance * tolerance
    }

    public init(_ tolerance: Double = 0.1) {
        self.tolerance = tolerance
    }
}

@available(iOS 12.0, *)
/// Downscales screenshots, removes color saturation, and allows configurable tolerance while comparing pixels.
public class SUITCaseMethodGreyscale: SUITCaseMethodStrict {
    var tolerance: Double

    public override func prepareScreenshot(_ image: UIImage) -> UIImage {
        return image.resized(by: 1 / image.scale)
    }

    override func equalityCondition(_ pixel1: RGBAPixel, _ pixel2: RGBAPixel) -> Bool {
        return pixel1.intensityDistance(to: pixel2) <= tolerance
    }

    public init(tolerance: Double = 0.1) {
        self.tolerance = tolerance
    }
}

@available(iOS 12.0, *)
/// Extremely dowscales screenshots, and allows configurable tolerance while comparing pixels.
public class SUITCaseMethodDNA: SUITCaseMethodStrict {
    var tolerance: Double
    var scaleFactor: CGFloat

    public override func prepareScreenshot(_ image: UIImage) -> UIImage {
        return image.dna(scaleFactor: CGFloat(scaleFactor))
    }

    override func equalityCondition(_ pixel1: RGBAPixel, _ pixel2: RGBAPixel) -> Bool {
        return pixel1.squaredDistance(to: pixel2) <= tolerance * tolerance
    }

    public init(tolerance: Double = 0.1, scaleFactor: CGFloat = 0.03) {
        self.tolerance = tolerance
        self.scaleFactor = scaleFactor
    }
}

@available(iOS 12.0, *)
/// Compares average colors of screenshots.
public class SUITCaseMethodAverageColor: SUITCaseMethod {
    public func prepareScreenshot(_ image: UIImage) -> UIImage {
        return image.resized(by: 1 / image.scale)
    }

    public func compareImages(actual: RGBAImage, reference: RGBAImage) throws -> (value: Double, image: RGBAImage) {
        guard let actualColor = actual.averageColor,
            let expectedColor = reference.averageColor else {
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
