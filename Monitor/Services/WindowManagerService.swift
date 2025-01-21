import AppKit

class WindowManagerService {
    static let shared = WindowManagerService()
    private var savedConfigurations: [String: [WindowState]] = [:]
    private var lastSaveTime: Date = Date()
    private let minimumSaveInterval: TimeInterval = 2.0 // Minimum seconds between saves
    
    private init() {
        loadSavedConfigurations()
    }
    
    func saveCurrentWindowStates() {
        // Prevent saving too frequently
        let now = Date()
        guard now.timeIntervalSince(lastSaveTime) >= minimumSaveInterval else { return }
        
        let currentConfig = ScreenConfiguration(screens: NSScreen.screens)
        var windowStates: [WindowState] = []
        
        // Get all windows from running applications
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .forEach { app in
                let appWindows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
                
                appWindows.forEach { windowInfo in
                    guard let windowNumber = windowInfo[kCGWindowNumber as String] as? Int,
                          let window = NSApp.window(withWindowNumber: windowNumber),
                          let screen = window.screen,
                          window.isVisible,
                          !window.isMiniaturized else { return }
                    
                    let state = WindowState(window: window, screen: screen)
                    windowStates.append(state)
                }
            }
        
        savedConfigurations[currentConfig.identifier] = windowStates
        saveConfigurations()
        lastSaveTime = now
    }
    
    func restoreWindowStates() {
        let currentConfig = ScreenConfiguration(screens: NSScreen.screens)
        guard let states = savedConfigurations[currentConfig.identifier] else { return }
        
        states.forEach { state in
            let appWindows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
            
            for windowInfo in appWindows {
                guard let windowNumber = windowInfo[kCGWindowNumber as String] as? Int,
                      let window = NSApp.window(withWindowNumber: windowNumber),
                      let ownerName = windowInfo[kCGWindowOwnerName as String] as? String,
                      ownerName == state.windowTitle else { continue }
                
                window.setFrame(state.frame, display: true, animate: true)
                break
            }
        }
    }
    
    private func loadSavedConfigurations() {
        if let data = UserDefaults.standard.data(forKey: "SavedWindowConfigurations"),
           let decoded = try? JSONDecoder().decode([String: [WindowState]].self, from: data) {
            savedConfigurations = decoded
        }
    }
    
    private func saveConfigurations() {
        if let encoded = try? JSONEncoder().encode(savedConfigurations) {
            UserDefaults.standard.set(encoded, forKey: "SavedWindowConfigurations")
        }
    }
} 