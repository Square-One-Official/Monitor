import Foundation
import AppKit

struct WindowState: Codable {
    let appBundleIdentifier: String
    let windowTitle: String?
    let frame: CGRect
    let screenIdentifier: String
    
    init(window: NSWindow, screen: NSScreen) {
        if let app = NSWorkspace.shared.runningApplications.first(where: { app in
            app.activationPolicy == .regular && app.isActive
        }) {
            self.appBundleIdentifier = app.bundleIdentifier ?? ""
        } else {
            self.appBundleIdentifier = ""
        }
        self.windowTitle = window.title
        self.frame = window.frame
        self.screenIdentifier = "\(screen.frame.width)x\(screen.frame.height)@\(screen.frame.origin.x),\(screen.frame.origin.y)"
    }
    
    private enum CodingKeys: String, CodingKey {
        case appBundleIdentifier
        case windowTitle
        case frame
        case screenIdentifier
    }
} 