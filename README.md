# SUITCase (ScreenshotUITestCase)
---
SUITCase can verify screenshots in five different ways while testing the User Interface of iOS and iPadOS apps in Simulator. 
It has been designed to be used with XCTest and written in Swift.


## Usage
Built-in XCTest assertions are great for many cases when you automate user interface testing. 
But some cases require testing appearance because `XCUIElement` properties do not fully describe the interface. 
SUITCase verifies screenshots to automate testing formatting texts, displaying images, switching themes, and much more. 
SUITCase currently supports recording and testing apps in Simulator only. 

## Installation
SUITCase is easy to install with the [Swift Package Manager.](https://developer.apple.com/documentation/swift_packages) 
Navigate to project settings and add a package on **Swift Packages** page. 
Copy-Paste a link to this repository in the **Choose Package Repository** window. 
Continue configuring dependency as needed.

![Steps 1, 2 and 3](Docs/InstallationSteps123.png)
![Steps 4 and 5](Docs/InstallationSteps45.png)

Finally, add the Environmental Variable **IMAGES_DIR** to your Scheme. 
If you want to keep your reference Images with your test code, you should probably set it to **$(SOURCE_ROOT)/Images**

![Environment Variable](Docs/EnvironmentVariable.png)


## Your first test with SUITCase
1. Import `XCTest` and `SUITCase`
2. Define your testing class as a subclass of `SUITCase` (or replace `XCTestCase` with `SUITCase` if you change the existing class)
3. Use `verifyScreenshot()` to insert a screenshot assertion in test. 
4. Record the reference screenshot by enabling recording in `setUp()` by adding `screenshotComparisonRecordMode = true` line. 
5. Disable recording by removing this line and run your test. 
```swift
import XCTest
import SUITCase

class AppearanceTests: SUITCase {
    override func setUp() {
        super.setUp()
        // screenshotComparisonRecordMode = true
        XCUIApplication().launch()
    }

    func testMainScreen() {
        verifyScreenshot()
    }
}
```


## Features
### Recording
* Enable **reference screenshots recording** by adding `screenshotComparisonRecordMode = true` line.
* The recording is disabled by default. 
If the reference images are missing, SUITCase will save **the suggested screenshots** into the separate folder.
If the collected screenshots are **unexpected**, SUITCase will save them into another separate folder as well. 
* There are **two screenshots naming strategies** – by the device name and by the screenshot size (default). Change strategy by setting the `screenshotComparisonNamingStrategy` variable. 
* You can also provide **the custom labels** to the screenshots if you want to make multiple assertions in a single test. Just set the `withLabel` argument. 
```swift
screenshotComparisonNamingStrategy = .imageSize
XCUIDevice.shared.orientation = .portrait
verifyScreenshot(withLabel: "Portrait")
// Saves /Images/Reference/AppearanceTests/testMainScreen/Portrait/en_414x896.png

screenshotComparisonNamingStrategy = .deviceModelName
XCUIDevice.shared.orientation = .landscapeLeft
verifyScreenshot(withLabel: "Landscape")
// Saves /Images/Reference/AppearanceTests/testMainScreen/Landscape/en_iPhone 11.png
```


### Thresholds
* Set **the global threshold** by changing `screenshotComparisonDefaultThreshold`.
If unchanged, the default threshold is equal to 0.01, which means SUITCase allows a 1 percent difference between collected and referenced screenshots. 
* You can set the **local threshold** while keeping the global one unchanged. Set the `withThreshold` argument.
```swift
verifyScreenshot() 
// The threshold is default and equals to 0.01

screenshotComparisonGlobalThreshold = 0.02
verifyScreenshot()
// The global threshold is now 0.02

verifyScreenshot(withThreshold: 0.03)
// The global threshold is still 0.02, but for this screenshot comparison threshold equals to 0.03
```


### XCUIElement support
* You can verify **screenshots of specific elements** with `ofElement` argument. 
The reference image will be cropped by this element frame.
* You shoud **erase dynamic element** by using `withoutElement` argument.
* The `withoutQuery` argument allows you to **erase multiple elements** at once. 
* The erased elements are transparent on the reference images, and SUITCase compares only opaque pixels.  
```swift
verifyScreenshot(ofElement: app.buttons["New"])
verifyScreenshot(withoutElement: app.tabBars.element)
verifyScreenshot(withoutQuery: app.images.matching(identifier: "GIF"))
```


### Comparison methods
* SUITCase includes five different comparison methods. 
Each method will attach the collected image, difference value, and current threshold. 
If difference is greater than zero, the reference and difference images will be attached as well. 
* You can pass the method with the  `withMethod` argument:  `verifyScreenshot(method: SUITCaseMethodStrict()])`
* `SUITCaseMethodStrict()` \
The most accurate method, which compares original screenshots pixel by pixel.
![Strict](Docs/strict.png)
* `SUITCaseMethodWithTolerance(_: Double = 0.1)` \
The default method downscales screenshots and allows configurable tolerance while comparing pixels.
![withTolerance](Docs/withTolerance.png)
* `SUITCaseMethodGreyscaleColor(tolerance: Double = 0.1)` \
Downscales screenshots, removes color saturation, and allows configurable tolerance while comparing pixels.
![Greyscale](Docs/greyscale.png)
* `SUITCaseMethodDNA(tolerance: Double = 0.1, scaleFactor: Double = 0.03)` \
Extremely dowscales screenshots, and allows configurable tolerance while comparing pixels. Inspired by [the PhotoDNA.](https://www.microsoft.com/en-us/photodna)
![DNA](Docs/dna.png)
* `SUITCaseMethodAverageColor()` \
Compares the average colors of screenshots.
![Average color](Docs/averageColor.png)
* You can also verify the average color without the reference screenshot by using  `averageColorIs(_ uiColor: UIColor, tolerance: Double = 0.1)` \
`XCTAssert(app.buttons["Red Button"].averageColorIs(.red))`

## License 
SUITCase is the open-source software under [the MPL 2.0 license.](LICENSE)
