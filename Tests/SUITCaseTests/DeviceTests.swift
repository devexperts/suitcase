//
//  DeviceTests.swift
//  
//
//  Created by Alexander Kormanovsky on 02.10.2022.
//

import XCTest

class DeviceTests: XCTestCase {
    
    func testSimulatorModelName() {
        if UIDevice.isSimulator {
            let modelName = UIDevice.modelName
            XCTAssertFalse(modelName.lowercased().contains("simulator"))
            
            let allowedCharacters = CharacterSet.alphanumerics
                .union(CharacterSet(charactersIn: "()"))
                .union(CharacterSet.whitespaces)
            let containsAllowedCharactersOnly = (modelName.rangeOfCharacter(from: allowedCharacters.inverted) == nil)
            XCTAssert(containsAllowedCharactersOnly)
        }
    }

}
