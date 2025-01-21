import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let windowManager = WindowManagerService.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("=== Application did finish launching ===")
        setupStatusBarItem()
        setupScreenChangeObserver()
        setupWindowChangeObserver()
    }
    
    private func setupStatusBarItem() {
        NSLog("=== Setting up status bar item ===")
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            NSLog("=== Status bar button created ===")
            if let image = NSImage(systemSymbolName: "rectangle.split.3x3", accessibilityDescription: "Monitor") {
                NSLog("=== Image created ===")
                image.size = NSSize(width: 18.0, height: 18.0)
                image.isTemplate = true
                button.image = image
                NSLog("=== Image set to button ===")
            } else {
                NSLog("=== Failed to create image ===")
            }
        } else {
            NSLog("=== Failed to create status bar button ===")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        NSLog("=== Menu setup complete ===")
        
        // Force button update
        statusItem.button?.needsDisplay = true
    }
    
    private func setupScreenChangeObserver() {
        NSLog("=== Setting up screen change observer ===")
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(screenConfigurationChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    private func setupWindowChangeObserver() {
        NSLog("=== Setting up window change observer ===")
        // Observe window movements and resizing
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(windowChanged),
            name: NSWindow.didMoveNotification,
            object: nil
        )
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(windowChanged),
            name: NSWindow.didResizeNotification,
            object: nil
        )
    }
    
    @objc private func screenConfigurationChanged() {
        NSLog("=== Screen configuration changed ===")
        // Add a small delay to ensure all screens are properly initialized
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.windowManager.restoreWindowStates()
        }
    }
    
    @objc private func windowChanged() {
        NSLog("=== Window changed ===")
        // Debounce the save operation to prevent excessive saves
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(saveLayoutDebounced), object: nil)
        perform(#selector(saveLayoutDebounced), with: nil, afterDelay: 1.0)
    }
    
    @objc private func saveLayoutDebounced() {
        NSLog("=== Saving window states ===")
        windowManager.saveCurrentWindowStates()
    }
} 