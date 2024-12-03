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

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication,
									 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		return true
	}
}

@main
struct ArchGithHubStatusApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
	init() {
		FirebaseApp.configure()
	}
	
	var body: some Scene {
		WindowGroup {
			Controller()
		}
	}
}

