//
//  ArchGithHubStatusApp.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-01-05.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct ArchGithHubStatusApp: App {
	init() {
		FirebaseApp.configure()
	}
	
	var body: some Scene {
		let _ = NSApplication.shared.setActivationPolicy(.regular)
		WindowGroup("Social Activity") {
			MacOSController()
		}
		.windowStyle(HiddenTitleBarWindowStyle())
		MenuBarExtra("Social Activity", systemImage: "waveform.path.ecg") {
			AppMenu()
		}.menuBarExtraStyle(.window)
	}
}
