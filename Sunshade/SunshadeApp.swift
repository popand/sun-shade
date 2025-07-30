//
//  SunshadeApp.swift
//  Sunshade
//
//  Created by Andrei Pop on 2025-06-23.
//

import SwiftUI

@main
struct SunshadeApp: App {
    var body: some Scene {
        WindowGroup {
            // Temporarily use debug view to diagnose Apple Sign-In issues
            // Switch back to MainContentView() once issues are resolved
            AuthenticationDebugView()
        }
    }
}
