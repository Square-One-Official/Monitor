import Foundation
import AppKit

struct ScreenConfiguration: Codable, Equatable {
    let screens: [ScreenInfo]
    let identifier: String
    
    init(screens: [NSScreen]) {
        self.screens = screens.map(ScreenInfo.init)
        self.identifier = screens.map { screen in
            "\(screen.frame.width)x\(screen.frame.height)@\(screen.frame.origin.x),\(screen.frame.origin.y)"
        }.sorted().joined(separator: "|")
    }
}

struct ScreenInfo: Codable, Equatable {
    let frame: CGRect
    let displayID: UInt32
    
    init(screen: NSScreen) {
        self.frame = screen.frame
        let screenNumberKey = NSDeviceDescriptionKey("NSScreenNumber")
        if let screenNumber = screen.deviceDescription[screenNumberKey] as? NSNumber {
            self.displayID = screenNumber.uint32Value
        } else {
            self.displayID = 0
        }
    }
} 