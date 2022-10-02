/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest
import DeviceKit

public extension UIDevice {
    
    static var modelName: String {
        var result = DeviceKit.Device.current.safeDescription
        
        if isSimulator {
            result = result.replacingOccurrences(of: "Simulator (", with: "")
            result.removeLast() // closing brace
        }
        
        return result
    }
    
    static let isSimulator = DeviceKit.Device.current.isSimulator
    
}
