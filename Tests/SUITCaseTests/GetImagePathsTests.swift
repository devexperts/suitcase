/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest
@testable import SUITCase

@available(iOS 12.0, *)
class GetImagePathsTests: XCTestCase {
    func testNameBySizeWithoutLabel() {
        SUITCase.screenshotComparisonImagesFolder = "path/to/folder"
        let suitcase = SUITCase()
        suitcase.testClassName = "TestClassName"
        suitcase.testName = "testName"
        suitcase.deviceLanguageCode = "en"
        suitcase.screenshotComparisonNamingStrategy = .imageSize

        let expectedPaths = (
            reference: "path/to/folder/Reference/TestClassName/testName/en_100x200.png",
            suggested: "path/to/folder/Suggested/TestClassName/testName/en_100x200.png",
            unexpected: "path/to/folder/Unexpected/TestClassName/testName/en_100x200.png")
        do {
            let actualPaths = try suitcase.getImagePaths(withLabel: nil,
                                                         imageSize: CGSize(width: 100, height: 200))
            XCTAssert(actualPaths == expectedPaths, "Actual=\(actualPaths), expected=\(expectedPaths)")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testNameByDeviceNameWithLabel() {
        SUITCase.screenshotComparisonImagesFolder = "path/to/folder"
        let suitcase = SUITCase()
        suitcase.testClassName = "TestClassName"
        suitcase.testName = "testName"
        suitcase.deviceLanguageCode = "ge"
        suitcase.deviceModelName = "iPhone 9"
        suitcase.screenshotComparisonNamingStrategy = .deviceModelName

        let expectedPaths = (
            reference: "path/to/folder/Reference/TestClassName/testName/Views/Collection View/ge_iPhone 9.png",
            suggested: "path/to/folder/Suggested/TestClassName/testName/Views/Collection View/ge_iPhone 9.png",
            unexpected: "path/to/folder/Unexpected/TestClassName/testName/Views/Collection View/ge_iPhone 9.png")

        do {
            let actualPaths = try suitcase.getImagePaths(withLabel: "Views/Collection View",
                                                         imageSize: CGSize(width: 100, height: 200))
            XCTAssert(actualPaths == expectedPaths, "Actual=\(actualPaths), expected=\(expectedPaths)")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testManualName() {
        SUITCase.screenshotComparisonImagesFolder = "path/to/folder"
        let suitcase = SUITCase()
        suitcase.screenshotComparisonNamingStrategy = .manual

        let expectedPaths = (
            reference: "path/to/folder/Reference/imageName.png",
            suggested: "path/to/folder/Suggested/imageName.png",
            unexpected: "path/to/folder/Unexpected/imageName.png")

        do {
            let actualPaths = try suitcase.getImagePaths(withLabel: "imageName",
                                                         imageSize: CGSize(width: 100, height: 200))
            XCTAssert(actualPaths == expectedPaths, "Actual=\(actualPaths), expected=\(expectedPaths)")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testNameBySizeWithoutLabel", testNameBySizeWithoutLabel),
        ("testNameByDeviceNameWithLabel", testNameByDeviceNameWithLabel),
        ("testManualName", testManualName)
    ]
}
