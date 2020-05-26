/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest

@available(iOS 12.0, *)
extension SUITCase {
    // Resizes the image, dismisses its orientation
    func downscaleScreenshot(_ image: UIImage,
                             withMethod method: ScreenshotComparisonMethod) -> UIImage {
        switch method {
        case .strict:
            return image.resized(by: 1)
        case .dna(_, let scaleFactor):
            return image.dna(scaleFactor: CGFloat(scaleFactor))
        default:
            return image.resized(by: 1 / image.scale)
        }
    }
}
