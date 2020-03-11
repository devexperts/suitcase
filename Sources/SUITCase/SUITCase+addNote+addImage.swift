/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest

@available(iOS 12.0, *)
extension SUITCase {
    func addNote(_ message: String) {
        XCTContext.runActivity(named: message) { _ in }
    }

    func addImage(_ image: UIImage, name: String) {
        let attachment = XCTAttachment(image: image)
        attachment.lifetime = .keepAlways
        attachment.name = name

        add(attachment)
    }
}
