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
import FirebaseMessaging

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
	let gcmMessageIDKey = "gcm.message_id"
	func application(_ application: UIApplication,
									didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		FirebaseApp.configure()
		do {
			try Auth.auth().useUserAccessGroup("SYV2CK2N9N.com.Archimedes4.SocialActivity")
		} catch {}
		
		Messaging.messaging().delegate = self
		Task {
			await NotificationManager().request()
		}
		print(Messaging.messaging().fcmToken)
		
		application.registerForRemoteNotifications()
		
		return true
	}
	func application(_ application: UIApplication,
										didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		 print("APNs token retrieved: \(deviceToken)")

		 // With swizzling disabled you must set the APNs token here.
		 Messaging.messaging().apnsToken = deviceToken
	 }
}
extension AppDelegate: MessagingDelegate {
		func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
			let dataDict: [String: String] = ["token": fcmToken ?? ""]
			 NotificationCenter.default.post(
				 name: Notification.Name("FCMToken"),
				 object: nil,
				 userInfo: dataDict
			 )
			if let fcmToken = fcmToken {
				Task {
					await addDevice(name: getDeviceName(), type: getDeviceType(), fcmToken: fcmToken)
				}
			}
		}
}

extension AppDelegate : UNUserNotificationCenterDelegate {
		
		// Receive displayed notifications for iOS 10 devices.
		func userNotificationCenter(_ center: UNUserNotificationCenter,
																willPresent notification: UNNotification,
																withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
				let userInfo = notification.request.content.userInfo
				
				if let messageID = userInfo[gcmMessageIDKey] {
						print("Message ID: \(messageID)")
				}
				
				print(userInfo)
				
				// Change this to your preferred presentation option
				completionHandler([[.banner, .badge, .sound]])
		}
	
		func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
				print("something went wronf")
		}
		
		func userNotificationCenter(_ center: UNUserNotificationCenter,
																didReceive response: UNNotificationResponse,
																withCompletionHandler completionHandler: @escaping () -> Void) {
				let userInfo = response.notification.request.content.userInfo
				
				if let messageID = userInfo[gcmMessageIDKey] {
						print("Message ID from userNotificationCenter didReceive: \(messageID)")
				}
				
				print(userInfo)
				
				completionHandler()
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
class AppDelegate: NSObject, NSApplicationDelegate {
	let gcmMessageIDKey = "gcm.message_id"
	func applicationWillFinishLaunching(_ notification: Notification) {
		FirebaseApp.configure()
		do {
			try Auth.auth().useUserAccessGroup("SYV2CK2N9N.com.Archimedes4.SocialActivity")
		} catch {}
		
		Messaging.messaging().delegate = self
		Task {
			await NotificationManager().request()
		}
		print(Messaging.messaging().fcmToken)
		
		(notification.object as! NSApplication).registerForRemoteNotifications()
		
	}
	func application(_ application: NSApplication,
										didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		 print("APNs token retrieved: \(deviceToken)")

		 // With swizzling disabled you must set the APNs token here.
		 Messaging.messaging().apnsToken = deviceToken
	 }
}
extension AppDelegate: MessagingDelegate {
		func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
			let dataDict: [String: String] = ["token": fcmToken ?? ""]
			 NotificationCenter.default.post(
				 name: Notification.Name("FCMToken"),
				 object: nil,
				 userInfo: dataDict
			 )
			if let fcmToken = fcmToken {
				Task {
					await addDevice(name: getDeviceName(), type: getDeviceType(), fcmToken: fcmToken)
				}
			}
		}
}

extension AppDelegate : NSUserNotificationCenterDelegate {
		
		// Receive displayed notifications for iOS 10 devices.
		func userNotificationCenter(_ center: UNUserNotificationCenter,
																willPresent notification: UNNotification,
																withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
				let userInfo = notification.request.content.userInfo
				
				if let messageID = userInfo[gcmMessageIDKey] {
						print("Message ID: \(messageID)")
				}
				
				print(userInfo)
				
				// Change this to your preferred presentation option
				completionHandler([[.banner, .badge, .sound]])
		}
	
		func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
				print("something went wronf")
		}
		
		func userNotificationCenter(_ center: UNUserNotificationCenter,
																didReceive response: UNNotificationResponse,
																withCompletionHandler completionHandler: @escaping () -> Void) {
				let userInfo = response.notification.request.content.userInfo
				
				if let messageID = userInfo[gcmMessageIDKey] {
						print("Message ID from userNotificationCenter didReceive: \(messageID)")
				}
				
				print(userInfo)
				
				completionHandler()
		}
}


@main
struct ArchGithHubStatusApp: App {
	@NSApplicationDelegateAdaptor private var delegate: AppDelegate
	
	var body: some Scene {
		let _ = NSApplication.shared.setActivationPolicy(.regular)
		WindowGroup("Social Activity") {
			Controller()
				.frame(minWidth: 850, maxWidth: .infinity, minHeight: 490, maxHeight: .infinity)
		}
		.windowStyle(HiddenTitleBarWindowStyle())
		MenuBarExtra("Social Activity", systemImage: "waveform.path.ecg") {
			AppMenu()
		}.menuBarExtraStyle(.window)
	}
}

#endif
