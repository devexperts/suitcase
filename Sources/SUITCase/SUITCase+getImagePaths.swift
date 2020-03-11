/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest

@available(iOS 12.0, *)
extension SUITCase {
    static var screenshotComparisonImagesFolder = ProcessInfo.processInfo.environment["IMAGES_DIR"]

    /// The enumeration of possible reference screenshots naming strategies.
    public enum ScreenshotComparisonNamingStrategies {
        /// Uses device name (e.g. "iPhone 9") as part of the reference image name.
        case deviceModelName
        /// Uses screenshot size (e.g. "375x667") as part of the reference image name.
        case imageSize
    }

    // swiftlint:disable large_tuple
    func getImagePaths(withLabel customLabel: String?,
                       imageSize: CGSize) throws -> (reference: String, suggested: String, unexpected: String) {
        guard let imagesFolder = SUITCase.screenshotComparisonImagesFolder,
            let testClassName = testClassName,
            var testName = testName,
            let deviceLanguageCode = deviceLanguageCode else {
                throw VerifyScreenshotError.badImagesPath
        }
        if let customLabel = customLabel {
            testName += "/" + customLabel
        }
        let fileName: String
        switch screenshotComparisonNamingStrategy {
        case .imageSize:
            fileName = "\(deviceLanguageCode)_\(Int(imageSize.width))x\(Int(imageSize.height)).png"
        case .deviceModelName:
            fileName = "\(deviceLanguageCode)_\(deviceModelName).png"
        }

        var imagePaths: [String] = []
        for subfolder in ["Reference", "Suggested", "Unexpected"] {
            let filePath = [imagesFolder, subfolder, testClassName, testName, fileName].joined(separator: "/")
            imagePaths.append(filePath)
        }

        return (imagePaths[0], imagePaths[1], imagePaths[2])
    }
}
