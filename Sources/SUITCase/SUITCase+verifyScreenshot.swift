/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest

@available(iOS 12.0, *)
extension SUITCase {
    /// The enumeration of possible screenshot comparison methods.
    public enum ScreenshotComparisonMethod: Equatable {
        /// The most accurate method, which compares original screenshots pixel by pixel.
        case strict
        /// Downscales screenshots and allows configurable tolerance while comparing pixels.
        case withTolerance(tolerance: Double = 0.1)
        /// Downscales screenshots, removes color saturation, and allows configurable tolerance while comparing pixels.
        case greyscale(tolerance: Double = 0.1)
        /// Extremely dowscales screenshots, and allows configurable tolerance while comparing pixels.
        case dna(tolerance: Double = 0.1, scaleFactor: Double = 0.03)
        /// Compares average colors of screenshots.
        case averageColor
    }

    enum VerifyScreenshotError: LocalizedError {
        case notSimulator
        case offScreenElement(element: XCUIElement)
        case recordMode
        case noReference
        case unexpectedSize
        case nothingCommon
        case noMatch
        case badImagesPath
        case badThreshold(value: Double)

        public var errorDescription: String? {
            switch self {
            case .notSimulator:
                return "SUITCase does not support devices"
            case .offScreenElement(let element):
                return "\(element) is off-screen"
            case .recordMode:
                return "Record mode is enabled. Saved reference screenshot"
            case .noReference:
                return "Reference screenshot is missing. Saved suggested screenshot"
            case .unexpectedSize:
                return "The size of collected screenshot is unexpected"
            case .nothingCommon:
                return "Unable to compare actual and reference screenshots. The opaque areas do not overlap"
            case .noMatch:
                return "Actual and reference screenshots are not similar. Saved unexpected screenshot"
            case .badImagesPath:
                return "Unable to get images path"
            case .badThreshold(let value):
                return "Threshold \(value) is not normalised"
            }
        }
    }

    /// Verifies application screenshot or records new reference image.
    ///
    /// - Parameters:
    ///   - element: An optional XCUIElement that needs to be verified.
    ///   - ignoredElement: An optional XCUIElement that needs to be ignored.
    ///   - ignoredQuery: An optional XCUIElementQuery of elements that need to be ignored.
    ///   - customThreshold: An optional custom threshold.
    ///   - method: An optional method of comparing pixels.
    ///   - label: An optional screenshot label (use if test case have multiple screenshot comparisons).
    ///   - file: The file in which failure occurred.
    ///   Defaults to the file name of the test case in which this function was called.
    ///   - line: The line number on which failure occurred.
    ///   Defaults to the line number on which this function was called.
    public func verifyScreenshot(ofElement element: XCUIElement? = nil,
                                 withoutElement ignoredElement: XCUIElement? = nil,
                                 withoutQuery ignoredQuery: XCUIElementQuery? = nil,
                                 withThreshold customThreshold: Double? = nil,
                                 withMethod method: ScreenshotComparisonMethod = .withTolerance(),
                                 withLabel label: String? = nil,
                                 file: StaticString = #file,
                                 line: UInt = #line) {
        var activityName = screenshotComparisonRecordMode ? "Record screenshot" : "Verify screenshot"
        if let element = element {
            activityName += " of \(element)"
        }
        XCTContext.runActivity(named: activityName) { _ in
            do {
                try verifyScreenshotThrowing(ofElement: element,
                                             withoutElement: ignoredElement,
                                             withoutQuery: ignoredQuery,
                                             withThreshold: customThreshold,
                                             withMethod: method,
                                             withLabel: label)

            } catch {
                XCTFail(error.localizedDescription, file: file, line: line)
            }
        }
    }

    /// Verifies application screenshot or records new reference image.
    ///
    /// - Parameters:
    ///   - element: An optional XCUIElement that needs to be verified.
    ///   - ignoredElement: An optional XCUIElement that needs to be ignored
    ///   - ignoredQuery: An optional XCUIElementQuery of elements that need to be ignored
    ///   - customThreshold: An optional custom threshold.
    ///   - method: An optional method of comparing pixels.
    ///   - label: An optional screenshot label (use if test case have multiple screenshot comparisons).
    func verifyScreenshotThrowing(ofElement element: XCUIElement? = nil,
                                  withoutElement ignoredElement: XCUIElement? = nil,
                                  withoutQuery ignoredQuery: XCUIElementQuery? = nil,
                                  withThreshold customThreshold: Double? = nil,
                                  withMethod method: ScreenshotComparisonMethod = .withTolerance(),
                                  withLabel label: String? = nil) throws {
        guard UIDevice.isSimulator else {
            throw VerifyScreenshotError.notSimulator
        }

        let actualImage = try collectScreenshot(ofElement: element,
                                                withoutElement: ignoredElement,
                                                withoutQuery: ignoredQuery,
                                                withMethod: method)
        let filePaths = try getImagePaths(withLabel: label, imageSize: actualImage.scaledSize)

        guard !screenshotComparisonRecordMode else {
            try actualImage.writePNG(filePath: filePaths.reference)
            throw VerifyScreenshotError.recordMode
        }

        let threshold = customThreshold ?? screenshotComparisonGlobalThreshold
        switch threshold {
        case 0..<0.5:
            break
        case 0.5..<1:
            addNote("Warning: Threshold is dangerously high!")
        default:
            throw VerifyScreenshotError.badThreshold(value: threshold)
        }

        guard let referenceImage = UIImage(contentsOfFile: filePaths.reference) else {
            try actualImage.writePNG(filePath: filePaths.suggested)
            throw VerifyScreenshotError.noReference
        }

        let difference = try compareImages(withMethod: method,
                                           actual: RGBAImage(uiImage: actualImage),
                                           reference: RGBAImage(uiImage: referenceImage))

        addNote("Threshold  = \(String(format: "%.4f", threshold))")
        addNote("Difference = \(String(format: "%.4f", difference.value))")

        if difference.value == 0 {
            addNote("Collected and reference screenshots are similar")
        } else {
            addImage(referenceImage, name: "Reference image")
            addImage(difference.image.uiImage, name: "Difference image")
            if difference.value > threshold {
                try actualImage.writePNG(filePath: filePaths.unexpected)
                throw VerifyScreenshotError.noMatch
            }
        }
    }
}
