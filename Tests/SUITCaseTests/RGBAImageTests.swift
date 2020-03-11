/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest
@testable import SUITCase

@available(iOS 12.0, *)
class RGBAImageTests: XCTestCase {
    func testPixelInitialisation() {
        let orangePixel = RGBAPixel.orange
        let orangeImage = RGBAImage(pixel: orangePixel, width: 4, height: 4)

        XCTAssertEqual(orangeImage.pixels.count, 16, "Unexpected count of pixels")
        for pixel in orangeImage.pixels {
            XCTAssertEqual(pixel, orangePixel, "Unexpected pixel")
        }
    }

    func testUIImageConversions() {
        let rgbaImage = RGBAImage(pixels: [.black, .blue, .green, .cyan,
                                           .red, .magenta, .yellow, .white,
                                           .darkGray, .gray, .lightGray, .clear],
                                  width: 4,
                                  height: 3)
        let uiImage = rgbaImage.uiImage
        let convertedRgbaImage = RGBAImage(uiImage: uiImage)

        XCTAssertEqual(convertedRgbaImage, rgbaImage, "Unexpected results of conversion")
    }

    func testAveragePixel() {
        let whiteImage = RGBAImage(pixel: .white, width: 3, height: 3)
        XCTAssertEqual(whiteImage.averageColor, RGBAPixel.white)

        let cyanImage = RGBAImage(pixel: .cyan, width: 2, height: 2)
        XCTAssertEqual(cyanImage.averageColor, RGBAPixel.cyan)

        let bwImage = RGBAImage(pixels: [.black, .white,
                                         .white, .black],
                                width: 2,
                                height: 2)
        XCTAssertEqual(bwImage.averageColor, RGBAPixel.gray)

        let clearImage = RGBAImage(pixel: .clear, width: 4, height: 4)
        XCTAssertNil(clearImage.averageColor)
    }

    static var allTests = [
        ("testPixelInitialisation", testPixelInitialisation),
        ("testUIImageConversions", testUIImageConversions),
        ("testAveragePixel", testAveragePixel)
    ]
}
