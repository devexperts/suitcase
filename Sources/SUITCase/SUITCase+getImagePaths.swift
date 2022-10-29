/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest

@available(iOS 12.0, *)
@available(tvOS 10.0, *)
extension SUITCase {
    static var screenshotComparisonImagesFolder = ProcessInfo.processInfo.environment["IMAGES_DIR"]

    /// The enumeration of possible reference screenshots naming strategies.
    public enum ScreenshotComparisonNamingStrategies {
        /// Uses device name (e.g. "iPhone 9") as part of the reference image name.
        case deviceModelName
        /// Uses screenshot size (e.g. "375x667") as part of the reference image name.
        case imageSize
        /// Only uses a test name or a custom label (if provided) as part of the reference image name.
        case manual
    }

    // swiftlint:disable large_tuple
    func getImagePaths(withLabel customLabel: String?,
                       imageSize: CGSize) throws -> (reference: String, suggested: String, unexpected: String, difference: String) {
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
        let filePath: String
        switch screenshotComparisonNamingStrategy {
        case .imageSize:
            fileName = "\(deviceLanguageCode)_\(Int(imageSize.width))x\(Int(imageSize.height)).png"
            filePath = [testClassName, testName, fileName].joined(separator: "/")
        case .deviceModelName:
            fileName = "\(deviceLanguageCode)_\(deviceModelName).png"
            filePath = [testClassName, testName, fileName].joined(separator: "/")
        case .manual:
            fileName = "\(customLabel ?? testName).png"
            filePath = fileName
        }

        var imagePaths: [String] = []
        for subfolder in ["Reference", "Suggested", "Unexpected", "Difference"] {
            let fullPath = [imagesFolder, subfolder, filePath].joined(separator: "/")
            imagePaths.append(fullPath)
        }

        return (imagePaths[0], imagePaths[1], imagePaths[2], imagePaths[3])
    }
}
