/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest

@available(iOS 12.0, *)
extension SUITCase {
    func collectScreenshot(ofElement element: XCUIElement? = nil,
                           withoutElement ignoredElement: XCUIElement? = nil,
                           withoutQuery ignoredQuery: XCUIElementQuery? = nil,
                           withMethod method: SUITCaseMethod = SUITCaseMethodWithTolerance()) throws -> UIImage {
        var actualImage = UIImage()

        try XCTContext.runActivity(named: "Take a screenshot") { _ in
            var originPoint = CGPoint.zero

            if let element = element {
                guard element.isFullyOnScreen else {
                    throw VerifyScreenshotError.offScreenElement(element: element)
                }
                actualImage = element.screenshot().image
                originPoint = element.frame.origin
            } else {
                actualImage = XCUIScreen.main.screenshot().image
            }

            // Fade the ignored elements
            var ignoredElements: [XCUIElement] = []
            if let ignoredQuery = ignoredQuery {
                ignoredElements += ignoredQuery.allElementsBoundByIndex
            }
            if let ignoredElement = ignoredElement {
                ignoredElements.append(ignoredElement)
            }
            for element in ignoredElements {
                if element.exists {
                    var ignoredElementFrame = element.frame
                    ignoredElementFrame = ignoredElementFrame.offsetBy(dx: -originPoint.x, dy: -originPoint.y)
                    actualImage = actualImage.clear(rectangle: ignoredElementFrame)
                } else {
                    addNote("Warning: \(element) does not exist")
                }
            }

            actualImage = method.prepareScreenshot(actualImage)
        }
        addImage(actualImage, name: "Collected image")

        return actualImage
    }
}

@available(iOS 12.0, *)
extension XCUIElement {
    var isFullyOnScreen: Bool {
        let screenFrame = CGRect(origin: CGPoint.zero, size: XCUIScreen.main.screenshot().image.size)
        return screenFrame.contains(self.frame)
    }
}
