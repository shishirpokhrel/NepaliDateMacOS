//
//  NepaliDateApp.swift
//  NepaliDate
//
//  Created by Shishir Pokhrel on 24/01/2026.
//

import SwiftUI
import Combine

@main
struct NepaliDateApp: App {
    @State private var nepaliDateString: String = "Loading..."
    
    // Timer to update the date every minute
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some Scene {
        MenuBarExtra {
            Button("Check Updates") {
                updateDate()
            }
            Divider()
            
            Menu("About Author") {
                Text("Dev: Shishir Pokhrel")
                Text("Created: Jan 24, 2026")
                Button("LinkedIn Profile") {
                    if let url = URL(string: "https://www.linkedin.com/in/shishirpokhrelqaengineer/") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
            
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            // Explicitly defining the label ensures text is shown next to the icon
            Text(nepaliDateString)
                .foregroundStyle(Color(red: 0.4, green: 0.9, blue: 0.4)) // Light Green
            Image(systemName: "calendar")
        }
        .menuBarExtraStyle(.menu)
    }
    
    init() {
        // Initial update
        _nepaliDateString = State(initialValue: Self.getNepaliDate())
        
        // Hide from Dock
        // Note: For SwiftUI lifecycle, this is best done here or in Info.plist
        // Doing it here covers it for development.
        DispatchQueue.main.async {
            NSApplication.shared.setActivationPolicy(.accessory)
        }
    }
    
    private func updateDate() {
        nepaliDateString = Self.getNepaliDate()
    }
    
    private static func getNepaliDate() -> String {
        let nepaliDate = NepaliDateConverter.toNepaliDate(from: Date())
        return nepaliDate.formatted
    }
}
