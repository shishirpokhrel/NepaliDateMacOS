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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
