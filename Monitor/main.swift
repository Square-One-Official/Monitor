import Cocoa

NSLog("=== MONITOR APP STARTING ===")
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

NSLog("=== MONITOR APP RUNNING ===")
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv) 