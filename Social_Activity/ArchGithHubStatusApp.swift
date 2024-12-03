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

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication,
									 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		return true
	}
}
#endif

@main
struct ArchGithHubStatusApp: App {
	
#if os(macOS)
	init() {
		FirebaseApp.configure()
	}
#elseif os(iOS)
	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
	init() {
		FirebaseApp.configure()
	}
	#endif
	
	var body: some Scene {
		#if os(macOS)
			let _ = NSApplication.shared.setActivationPolicy(.regular)
		WindowGroup("Social Activity") {
			Controller()
				.frame(minWidth: 850, maxWidth: .infinity, minHeight: 480, maxHeight: .infinity)
		}
				.windowStyle(HiddenTitleBarWindowStyle())
				MenuBarExtra("Social Activity", systemImage: "waveform.path.ecg") {
					AppMenu()
				}.menuBarExtraStyle(.window)
		#elseif os(iOS)
		WindowGroup {
			Controller()
		}
		#endif
	}
}
