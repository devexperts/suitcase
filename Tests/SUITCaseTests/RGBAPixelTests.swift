/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest
@testable import SUITCase

@available(iOS 12.0, *)
@available(tvOS 10.0, *)
class RGBAPixelTests: XCTestCase {
    func assertPixel(_ pixel: RGBAPixel,
                     _ red: UInt8,
                     _ green: UInt8,
                     _ blue: UInt8,
                     _ alpha: UInt8,
                     file: StaticString = #file,
                     line: UInt = #line) {
        XCTAssertEqual(pixel.red, red, "Unexpected red component", file: file, line: line)
        XCTAssertEqual(pixel.green, green, "Unexpected green component", file: file, line: line)
        XCTAssertEqual(pixel.blue, blue, "Unexpected blue component", file: file, line: line)
        XCTAssertEqual(pixel.alpha, alpha, "Unexpected alpha component", file: file, line: line)
    }

    // System colors
    let systemGray          = RGBAPixel(white: 134)
    let textBackGroundColor = RGBAPixel(white: 23, alpha: 255)
    let labelColor          = RGBAPixel(red: 255, green: 255, blue: 255, alpha: 173)

    // Apple colors
    let black  = RGBAPixel.black
    let white  = RGBAPixel.white
    let green  = RGBAPixel(red: 0, green: 249, blue: 0, alpha: 255)
    let red    = RGBAPixel(red: 255, green: 38, blue: 0, alpha: 255)
    let orange = RGBAPixel(red: 255, green: 147)
    let yellow = RGBAPixel(red: 255, green: 251)
    let cyan   = RGBAPixel(green: 253, blue: 255)

    // Crayons
    let salmon     = RGBAPixel(red: 255, green: 126, blue: 121)
    let cantaloupe = RGBAPixel(red: 255, green: 212, blue: 121)
    let banana     = RGBAPixel(red: 255, green: 252, blue: 121)
    let honeydew   = RGBAPixel(red: 212, green: 251, blue: 121)
    let flora      = RGBAPixel(red: 115, green: 250, blue: 121)
    let spindrift  = RGBAPixel(red: 115, green: 252, blue: 214)
    let ice        = RGBAPixel(red: 115, green: 253, blue: 255)
    let sky        = RGBAPixel(red: 116, green: 214, blue: 255)
    let orchid     = RGBAPixel(red: 112, green: 129, blue: 255)
    let lavender   = RGBAPixel(red: 215, green: 131, blue: 255)
    let bubblegum  = RGBAPixel(red: 255, green: 133, blue: 255)
    let carnation  = RGBAPixel(red: 255, green: 138, blue: 216)

    func testGreyscaleInitialisation() {
        assertPixel(systemGray, 134, 134, 134, 255)
        assertPixel(textBackGroundColor, 23, 23, 23, 255)
    }

    func testRGBAInitialisation() {
        assertPixel(labelColor, 255, 255, 255, 173)
        assertPixel(green, 0, 249, 0, 255)
        assertPixel(red, 255, 38, 0, 255)
    }

    func testRGBInitialisation() {
        assertPixel(salmon, 255, 126, 121, 255)
        assertPixel(bubblegum, 255, 133, 255, 255)
        assertPixel(banana, 255, 252, 121, 255)
    }

    func testFastInitialisation() {
        assertPixel(orange, 255, 147, 0, 255)
        assertPixel(yellow, 255, 251, 0, 255)
        assertPixel(cyan, 0, 253, 255, 255)
    }

    func testIsOpaque() {
        for pixel in [black, white, red] {
            XCTAssertTrue(pixel.isOpaque, "\(pixel) is not opaque")
        }

        XCTAssertFalse(labelColor.isOpaque, "\(labelColor) is not transparent")
    }

    func testLightIntensity() {
        XCTAssertEqual(textBackGroundColor.lightIntensity, 0.090196, accuracy: 1e-6)
        XCTAssertEqual(green.lightIntensity, 0.842019, accuracy: 1e-6)
        XCTAssertEqual(bubblegum.lightIntensity, 0.703194, accuracy: 1e-6)
        XCTAssertEqual(orange.lightIntensity, 0.680904, accuracy: 1e-6)

        //  Test color cube diagonal
        for white in 0...255 {
            let pixel = RGBAPixel(white: UInt8(white))
            XCTAssertEqual(pixel.lightIntensity, Double(white) / 255.0, accuracy: 1e-6)
        }
    }

    func testSquaredDistance() {
        XCTAssertEqual(white.squaredDistance(to: black), 1)
        XCTAssertEqual(yellow.squaredDistance(to: banana),
                       0.050042,
                       accuracy: 1e-6)
        for pixel in [systemGray, labelColor, carnation, cyan] {
            XCTAssertEqual(pixel.squaredDistance(to: pixel), 0)
        }
    }

    static var allTests = [
        ("testGreyscaleInitialisation", testGreyscaleInitialisation),
        ("testRGBAInitialisation", testRGBAInitialisation),
        ("testRGBInitialisation", testRGBInitialisation),
        ("testFastInitialisation", testFastInitialisation),
        ("testIsOpaque", testIsOpaque),
        ("testLightIntensity", testLightIntensity),
        ("testSquaredDistance", testSquaredDistance)
    ]
}
