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
				.onAppear {
												for family in UIFont.familyNames.sorted() {
														let names = UIFont.fontNames(forFamilyName: family)
														print("Family: \(family) Font names: \(names)")
												}
										}
		}
	}
}

