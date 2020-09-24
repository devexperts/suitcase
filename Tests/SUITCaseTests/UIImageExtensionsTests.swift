/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest
@testable import SUITCase

@available(iOS 12.0, *)
@available(tvOS 10.0, *)
class UIImageExtensionsTests: XCTestCase {
    let testImage = RGBAImage(pixels: [.black, .green, .clear, .brown,
                                       .green, .white, .white, .clear,
                                       .clear, .white, .white, .green,
                                       .brown, .clear, .green, .black],
                              width: 4,
                              height: 4).uiImage

    func testClear() {
        let withClearCenter = testImage.clear(rectangle: CGRect(x: 1, y: 1, width: 2, height: 2))
        let expectedImage = RGBAImage(pixels: [.black, .green, .clear, .brown,
                                               .green, .clear, .clear, .clear,
                                               .clear, .clear, .clear, .green,
                                               .brown, .clear, .green, .black],
                                      width: 4,
                                      height: 4)

        XCTAssertEqual(RGBAImage(uiImage: withClearCenter), expectedImage)
    }

    static var allTests = [
        ("testClear", testClear)
    ]
}
