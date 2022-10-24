/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/
import UIKit
import XCTest
@testable import SUITCase

@available(iOS 12.0, *)
@available(tvOS 10.0, *)
class CompareImagesTests: XCTestCase {
    func assertComparison(method: SUITCaseMethod,
                          _ image1: RGBAImage,
                          _ image2: RGBAImage,
                          expectedDifference: (image: RGBAImage, value: Double),
                          file: StaticString = #file,
                          line: UInt = #line) {
        do {
            let actualDifference = try method.compareImages(actual: image1.uiImage,
                                                            reference: image2.uiImage)

            XCTAssertTrue(actualDifference.image == expectedDifference.image, file: file, line: line)
            XCTAssertEqual(actualDifference.value,
                           expectedDifference.value,
                           accuracy: 1e-6,
                           file: file,
                           line: line)
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }

    func assertComparisonError(method: SUITCaseMethod,
                               _ image1: RGBAImage,
                               _ image2: RGBAImage,
                               _ expectedError: Error,
                               file: StaticString = #file,
                               line: UInt = #line) {
        XCTAssertThrowsError(try method.compareImages(actual: image1.uiImage,
                                                      reference: image2.uiImage),
                             file: file,
                             line: line) { error in
            do {
                XCTAssertEqual(error.localizedDescription,
                               expectedError.localizedDescription,
                               "Unexpected error description",
                               file: file,
                               line: line)
            }
        }
    }

    let rgbaImage = RGBAImage(pixels: [.black, .blue, .green, .cyan,
                                       .red, .magenta, .yellow, .white,
                                       .darkGray, .gray, .lightGray, .clear],
                              width: 4,
                              height: 3)

    var lighterImage: RGBAImage {
        var template = rgbaImage

        func add16(_ component: inout UInt8) {
            component = component > 239 ? 255 : component + 16
        }

        for counter in 0..<template.pixels.count {
            add16(&template.pixels[counter].red)
            add16(&template.pixels[counter].green)
            add16(&template.pixels[counter].blue)
        }

        return template
    }

    func testStrictComparison() {
        let referenceImage = UIImage(named: "en_iPhone_X_reference_strict", in: .module, compatibleWith: nil)!
        let unexpectedImage = UIImage(named: "en_iPhone_X_unexpected_strict", in: .module, compatibleWith: nil)!
        let differenceImage = UIImage(named: "en_iPhone_X_difference_strict", in: .module, compatibleWith: nil)!

        assertComparison(method: SUITCaseMethodStrict(),
                         RGBAImage(uiImage: referenceImage),
                         RGBAImage(uiImage: unexpectedImage),
                         expectedDifference: (RGBAImage(uiImage: differenceImage),
                                              0.128664))
    }

    func testWithToleranceComparison() {
        let referenceImage = UIImage(named: "en_iPhone_X_reference_strict", in: .module, compatibleWith: nil)!
        let unexpectedImage = UIImage(named: "en_iPhone_X_unexpected_strict", in: .module, compatibleWith: nil)!
        let differenceImage = UIImage(named: "en_iPhone_X_difference_strict", in: .module, compatibleWith: nil)!

        assertComparison(method: SUITCaseMethodWithTolerance(0.05),
                         RGBAImage(uiImage: referenceImage),
                         RGBAImage(uiImage: unexpectedImage),
                         expectedDifference: (RGBAImage(uiImage: differenceImage),
                                              0.128449))
    }
    

    let rgbwImage = RGBAImage(pixels: [.red, .green,
                                       .blue, .white],
                              width: 2,
                              height: 2)

    let cmykImage = RGBAImage(pixels: [.magenta, .cyan,
                                       .black, .yellow],
                              width: 2,
                              height: 2)

    func testGreyscaleComparison() {
        let referenceImage = UIImage(named: "en_iPhone_X_reference_strict", in: .module, compatibleWith: nil)!
        let unexpectedImage = UIImage(named: "en_iPhone_X_unexpected_strict", in: .module, compatibleWith: nil)!
        let differenceImage = UIImage(named: "en_iPhone_X_difference_strict", in: .module, compatibleWith: nil)!

        assertComparison(method: SUITCaseMethodGreyscale(tolerance: 0.1),
                         RGBAImage(uiImage: referenceImage),
                         RGBAImage(uiImage: unexpectedImage),
                         expectedDifference: (RGBAImage(uiImage: differenceImage),
                                              0.067712))
    }

    func testAverageColorComparison() {
        let referenceImage = UIImage(named: "en_iPhone_X_reference_strict", in: .module, compatibleWith: nil)!
        let unexpectedImage = UIImage(named: "en_iPhone_X_unexpected_strict", in: .module, compatibleWith: nil)!
        let differenceImage = UIImage(named: "en_iPhone_X_difference_strict", in: .module, compatibleWith: nil)!

        assertComparison(method: SUITCaseMethodAverageColor(),
                         RGBAImage(uiImage: referenceImage),
                         RGBAImage(uiImage: unexpectedImage),
                         expectedDifference: (RGBAImage(uiImage: differenceImage),
                                              0.046391))

    }

    func testDnaComparison() {
        let referenceImage = UIImage(named: "en_iPhone_X_reference_strict", in: .module, compatibleWith: nil)!
        let unexpectedImage = UIImage(named: "en_iPhone_X_unexpected_strict", in: .module, compatibleWith: nil)!
        let differenceImage = UIImage(named: "en_iPhone_X_difference_strict", in: .module, compatibleWith: nil)!

        assertComparison(method: SUITCaseMethodDNA(tolerance: 0.03),
                         RGBAImage(uiImage: referenceImage),
                         RGBAImage(uiImage: unexpectedImage),
                         expectedDifference: (RGBAImage(uiImage: differenceImage),
                                              0.128522))
    }

    func testThrowingErrors() {
        let leftTransparentImage = RGBAImage(pixels: [.clear, .black,
                                                      .clear, .brown],
                                             width: 2,
                                             height: 2)
        let rightTransparentImage = RGBAImage(pixels: [.green, .clear,
                                                       .magenta, .clear],
                                              width: 2,
                                              height: 2)
        assertComparisonError(method: SUITCaseMethodStrict(),
                              leftTransparentImage,
                              rightTransparentImage,
                              SUITCase.VerifyScreenshotError.nothingCommon)
        assertComparisonError(method: SUITCaseMethodGreyscale(tolerance: 0.01),
                              leftTransparentImage,
                              rgbaImage,
                              SUITCase.VerifyScreenshotError.unexpectedSize)
    }

    static var allTests = [
        ("testStrictComparison", testStrictComparison),
        ("testWithToleranceComparison", testWithToleranceComparison),
        ("testGreyscaleComparison", testGreyscaleComparison),
        ("testAverageColorComparison", testAverageColorComparison),
        ("testDnaComparison", testDnaComparison),
        ("testThrowingErrors", testThrowingErrors)
    ]
}
