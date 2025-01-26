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
		FirebaseApp.configure()
		do {
			try Auth.auth().useUserAccessGroup("SYV2CK2N9N.com.Archimedes4.SocialActivity")
		} catch {}
		return true
	}
}

@main
struct ArchGithHubStatusApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
	
	var body: some Scene {
		WindowGroup {
			Controller()
		}
	}
}
#elseif os(macOS)
@main
struct ArchGithHubStatusApp: App {
	init() {
		FirebaseApp.configure()
	}
	
	var body: some Scene {
		let _ = NSApplication.shared.setActivationPolicy(.regular)
		WindowGroup("Social Activity") {
			Controller()
				.frame(minWidth: 850, maxWidth: .infinity, minHeight: 480, maxHeight: .infinity)
		}
		.windowStyle(HiddenTitleBarWindowStyle())
		MenuBarExtra("Social Activity", systemImage: "waveform.path.ecg") {
			AppMenu()
		}.menuBarExtraStyle(.window)
	}
}

#endif
