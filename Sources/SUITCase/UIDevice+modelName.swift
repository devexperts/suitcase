/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import XCTest
import DeviceKit

extension UIDevice {
    
    static let modelName = DeviceKit.Device.current.description
    
    static let isSimulator = DeviceKit.Device.current.isSimulator
    
}
