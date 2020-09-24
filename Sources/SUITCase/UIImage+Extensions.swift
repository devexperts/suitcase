/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest

@available(iOS 12.0, *)
@available(tvOS 10.0, *)
extension UIImage {
    func writePNG(filePath: String) throws {
        try XCTContext.runActivity(named: "Save " + filePath) { _ in
            let fileURL = URL(fileURLWithPath: filePath)
            let folderURL = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: folderURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)

            try pngData()?.write(to: fileURL)
        }
    }

    func resized(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        }

        return image
    }

    func resized(by scaleFactor: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width * scaleFactor,
                             height: size.height * scaleFactor)

        return resized(size: newSize)
    }

    func dna(scaleFactor: CGFloat) -> UIImage {
        let newSize = CGSize(width: (size.width * scaleFactor).rounded() / scale,
                             height: (size.height * scaleFactor).rounded() / scale)
        return resized(size: newSize)
    }

    func clear(rectangle: CGRect) -> UIImage {
        var resultImage = self
        let innerForeground = rectangle.intersection(CGRect(origin: CGPoint.zero, size: size))

        if innerForeground.size != CGSize.zero {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            draw(at: CGPoint.zero)
            let context = UIGraphicsGetCurrentContext()!
            context.clear(innerForeground)
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        }

        return resultImage
    }

    var scaledSize: CGSize {
        size.applying(CGAffineTransform(scaleX: scale, y: scale))
    }
}
