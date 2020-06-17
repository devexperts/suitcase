/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest

@available(iOS 12.0, *)
extension XCUIScreenshotProviding {
    /// Determines average color is expected
    /// - Parameters:
    ///   - uiColor: An expected color
    ///   - tolerance: A threshold that allows minor color difference. Default is 0.1
    public func averageColorIs(_ uiColor: UIColor, tolerance: Double = 0.1) -> Bool {
        let expectedPixel = RGBAPixel.init(uiColor: uiColor)

        return XCTContext.runActivity(named: "Check if the average color of \(self) equals to \(expectedPixel)") { _ in
            let pixelImage = screenshot().image.resized(size: CGSize(width: 1, height: 1))
            let rgbaImage = RGBAImage(uiImage: pixelImage)

            if let actualPixel = rgbaImage.pixels.first {
                let distance = sqrt(actualPixel.squaredDistance(to: expectedPixel))
                XCTContext.runActivity(named: "Actual color: \(actualPixel)") { _ in }
                XCTContext.runActivity(named: "Threshold:    \(tolerance)") { _ in }
                XCTContext.runActivity(named: "Distance:     \(distance)") { _ in }
                return distance <= tolerance
            } else {
                XCTContext.runActivity(named: "Unable to get average color") { _ in }
                return false
            }
        }
    }
}
