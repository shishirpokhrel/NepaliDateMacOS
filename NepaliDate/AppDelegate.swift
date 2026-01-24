import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var converterWindowController: NSWindowController?
    
    // Timer to update date string
    var timer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create Status Item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "calendar", accessibilityDescription: "Nepali Date")
            button.title = NepaliDateConverter.toNepaliDate(from: Date()).formatted
            // Use monospaced digit font if possible, or keep standard
            button.action = #selector(statusBarButtonClicked(_:))
            // Listen for both left and right clicks
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Create Popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 350)
        popover.behavior = .transient
        // Initial setup
        resetToToday()
        
        // Start Timer to update button title (every 60s as backup)
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateDateTitle()
        }
        
        // Observe system day change (Midnight)
        NotificationCenter.default.addObserver(self, selector: #selector(dayChanged), name: .NSCalendarDayChanged, object: nil)
    }
    
    @objc func dayChanged(_ notification: Notification) {
        // On midnight, reset everything including the view
        resetToToday()
    }

    
    func updateDateTitle() {
        if let button = statusItem.button {
            let bsDate = NepaliDateConverter.toNepaliDate(from: Date())
            button.title = bsDate.formatted
            // Do NOT reset popover here, as it kills user navigation
        }
    }
    
    func resetToToday() {
        updateDateTitle()
        // Reset popover content to today
        let bsDate = NepaliDateConverter.toNepaliDate(from: Date())
        popover.contentViewController = NSHostingController(rootView: CalendarView(bsDate: bsDate))
    }
    
    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp || (event.type == .leftMouseUp && event.modifierFlags.contains(.control)) {
            // Right Click -> Show Menu
            showContextMenu(sender)
        } else {
            // Left Click -> Toggle Popover
            togglePopover(sender)
        }
    }
    
    func togglePopover(_ sender: Any?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func showContextMenu(_ sender: NSStatusBarButton) {
        let menu = NSMenu()
        
        // Date Converter
        menu.addItem(withTitle: "Date Converter", action: #selector(openConverter), keyEquivalent: "C")
        
        menu.addItem(NSMenuItem.separator())
        
        // About Author (Submenu)
        let aboutItem = NSMenuItem(title: "About Author", action: nil, keyEquivalent: "")
        let aboutMenu = NSMenu()
        aboutMenu.addItem(withTitle: "Dev: Shishir Pokhrel", action: nil, keyEquivalent: "")
        aboutMenu.addItem(withTitle: "Created: Jan 24, 2026", action: nil, keyEquivalent: "")
        let linkedinItem = NSMenuItem(title: "LinkedIn Profile", action: #selector(openLinkedIn), keyEquivalent: "")
        linkedinItem.target = self
        aboutMenu.addItem(linkedinItem)
        menu.setSubmenu(aboutMenu, for: aboutItem)
        menu.addItem(aboutItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        menu.addItem(withTitle: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        
        // Explicitly set target for items handled by AppDelegate
        menu.items.forEach { $0.target = self }
        
        statusItem.menu = menu // Temporarily assign menu to show it? 
        // Better way for instant popup:
        statusItem.button?.performClick(nil) // This might trigger action again if menu is set.
        // Actually best way for one-off menu:
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil // Clear it back so left click works next time?
        // Wait, if I assign menu, left click opens menu.
        // If I want Right Click -> Menu, I should probably use `NSMenu.popUpContextMenu`.
        NSMenu.popUpContextMenu(menu, with: NSApp.currentEvent!, for: sender)
    }
    
    @objc func openConverter() {
        // Close popover if open
        popover.performClose(nil)
        
        // Create window if needed
        if converterWindowController == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered, defer: false)
            window.center()
            window.title = "Date Converter"
            window.contentViewController = NSHostingController(rootView: ConverterView())
            converterWindowController = NSWindowController(window: window)
        }
        
        NSApp.activate(ignoringOtherApps: true)
        converterWindowController?.showWindow(nil)
        converterWindowController?.window?.makeKeyAndOrderFront(nil)
    }
    
    @objc func openLinkedIn() {
        if let url = URL(string: "https://www.linkedin.com/in/shishirpokhrelqaengineer/") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
