/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest

/// SUITCase inherits from XCTestCase and allows comparing screenshots while testing UI.
@available(iOS 12.0, *)
@available(tvOS 10.0, *)
open class SUITCase: XCTestCase {
    private lazy var testNameComponents = name
        .trimmingCharacters(in: .punctuationCharacters)
        .components(separatedBy: .whitespaces)
    lazy var testClassName = testNameComponents.first
    lazy var testName = testNameComponents.last

    var deviceModelName = UIDevice.modelName
    var deviceLanguageCode = Locale(identifier: Locale.preferredLanguages.first!).languageCode

    /// Enables Record Mode, which saves reference images.
    public var screenshotComparisonRecordMode = false
    /// The global threshold variable, which allows the difference between collected and reference screenshots.
    public var screenshotComparisonGlobalThreshold = 0.01
    /// Changes current reference images naming strategy.
    public var screenshotComparisonNamingStrategy = ScreenshotComparisonNamingStrategies.imageSize
}
