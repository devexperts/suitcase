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
                          referenceImageName: String,
                          unexpectedImageName: String,
                          expectedDifference: (imageName: String?, value: Double),
                          file: StaticString = #file,
                          line: UInt = #line) {
        do {
            let referenceImage = UIImage(named: referenceImageName, in: .module, compatibleWith: nil)!
            let unexpectedImage = UIImage(named: unexpectedImageName, in: .module, compatibleWith: nil)!
            let actualDifference = try method.compareImages(actual: referenceImage,
                                                            reference: unexpectedImage)
            
            if let differenceImageName = expectedDifference.imageName,
               let expectedDifferenceImage = UIImage(named: differenceImageName, in: .module, compatibleWith: nil) {
                // FIXME: implement correct differences comparison using real images
//                let expectedDifferenceRGBAImage = RGBAImage(uiImage: expectedDifferenceImage)
//                XCTAssertTrue(actualDifference.image == expectedDifferenceRGBAImage, file: file, line: line)
            }

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

    func testStrictComparison() {
        assertComparison(method: SUITCaseMethodStrict(),
                         referenceImageName: "en_iPhone_X_strict_reference",
                         unexpectedImageName: "en_iPhone_X_strict_unexpected",
                         expectedDifference: ("en_iPhone_X_strict_difference",
                                              0.127299))
    }

    func testWithToleranceComparison() {
        assertComparison(method: SUITCaseMethodWithTolerance(0.3),
                         referenceImageName: "en_iPhone_X_tolerance_reference",
                         unexpectedImageName: "en_iPhone_X_tolerance_unexpected",
                         expectedDifference: ("en_iPhone_X_tolerance_difference",
                                              0.064338))
    }

    func testGreyscaleComparison() {
        assertComparison(method: SUITCaseMethodGreyscale(tolerance: 0.01),
                         referenceImageName: "en_iPhone_X_greyscale_reference",
                         unexpectedImageName: "en_iPhone_X_greyscale_unexpected",
                         expectedDifference: ("en_iPhone_X_greyscale_difference",
                                              0.012003))
    }

    func testAverageColorComparison() {
        assertComparison(method: SUITCaseMethodAverageColor(),
                         referenceImageName: "en_iPhone_X_average_reference",
                         unexpectedImageName: "en_iPhone_X_average_unexpected",
                         expectedDifference: ("en_iPhone_X_average_difference",
                                              0.903053))
    }

    func testDnaComparison() {
        assertComparison(method: SUITCaseMethodDNA(),
                         referenceImageName: "en_iPhone_X_dna_reference",
                         unexpectedImageName: "de_iPhone_X_dna_unexpected",
                         expectedDifference: (nil,
                                              0.034106))
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
