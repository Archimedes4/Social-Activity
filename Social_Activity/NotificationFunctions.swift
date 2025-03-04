//
//  DeviceFunctions.swift
//  Social_Activity
//
//  Created by Andrew Mainella on 2025-01-26.
//

import Foundation
import UserNotifications
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
#if os(iOS)
import UIKit
#elseif os(macOS)
import IOKit.ps
#endif

// Notificaitons

func addDevice(name: String, type: DeviceTypes, fcmToken: String) async -> LoadingState {
	guard let userID = Auth.auth().currentUser?.uid else { return LoadingState.failed }
	let db = Firestore.firestore()
	do {
		try await db.collection("users").document(userID).collection("devices").document(fcmToken).setData([
			"name": name,
			"type": type.rawValue,
			"fcmToken": fcmToken,
			"lastUpdated": Int(Date.now.timeIntervalSince1970)
		])
		return LoadingState.success
	} catch let error {
		return LoadingState.failed
	}
}

func removeDevice(fcmToken: String) async -> LoadingState {
	guard let userID = Auth.auth().currentUser?.uid else { return LoadingState.failed }
	let db = Firestore.firestore()
	do {
		try await db.collection("users").document(userID).collection("devices").document(fcmToken).delete()
		return LoadingState.success
	} catch let error {
		return LoadingState.failed
	}
}

enum getDeviceErrors: Error {
	case noUser
	case exception
	case invalidDoc
}

func getDevices() async throws-> [Device] {
	guard let userID = Auth.auth().currentUser?.uid else { throw getDeviceErrors.noUser }
	let db = Firestore.firestore()
	do {
		var devices: [Device] = []
		let result = try await db.collection("users").document(userID).collection("devices").getDocuments()
		try result.documents.forEach({ doc in
			let data = doc.data()
			
			guard let name = data["name"] as? String else {
				throw getDeviceErrors.invalidDoc
			}
			
			guard let rawType = data["type"] as? String else {
				throw getDeviceErrors.invalidDoc
			}
			
			guard let type = DeviceTypes(rawValue: rawType) else {
				throw getDeviceErrors.invalidDoc
			}
			
			guard let fcmToken = data["fcmToken"] as? String else {
				throw getDeviceErrors.invalidDoc
			}
			
			guard let lastUpdated = data["lastUpdated"] as? Int else {
				throw getDeviceErrors.invalidDoc
			}
			
			devices.append(Device(name: name, type: type, fcmToken: fcmToken, lastUpdated: lastUpdated))
		})
		return devices
	} catch {
		throw getDeviceErrors.exception
	}
}

#if os(macOS)
func isMacBook() -> Bool {
		let process = Process()
		let pipe = Pipe()
		
		process.launchPath = "/bin/bash"
		process.arguments = ["-c", "pmset -g batt"]
		process.standardOutput = pipe
		
		do {
				try process.run()
				let data = pipe.fileHandleForReading.readDataToEndOfFile()
				let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
				
				return output?.contains("Battery Power") ?? false || output?.contains("AC Power") ?? false
		} catch {
				print("Error checking battery status: \(error.localizedDescription)")
				return false
		}
}
#endif


func getDeviceType() -> DeviceTypes {
	#if os(macOS)
	if (isMacBook()) {
		return DeviceTypes.macOSLaptop
	}
	return DeviceTypes.macOSDesktop
	#elseif os(iOS)
	if (UIDevice.current.localizedModel == "iPhone") {
		return DeviceTypes.iPhone
	}
	// TODO iPad
	return DeviceTypes.unknown
	#endif
}

func getDeviceName() -> String {
	#if os(iOS)
		return UIDevice.current.name
	#elseif os(macOS)
		return Host.current().localizedName ?? ""
	#endif
}

@MainActor
class NotificationManager: ObservableObject{
	@Published private(set) var hasPermission = false
	@Published public var fcmToken: String = ""
		
	init() {
		Task{
			await getAuthStatus()
		}
	}
	
	func request() async{
		do {
			try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
		
			await getAuthStatus()
			
		} catch{
			print(error)
		}
	}
	
	func getAuthStatus() async {
		let status = await UNUserNotificationCenter.current().notificationSettings()
		switch status.authorizationStatus {
		case .authorized, .ephemeral, .provisional:
				hasPermission = true
		default:
				hasPermission = false
		}
		let fcmToken = Messaging.messaging().fcmToken

		if let fcmToken = fcmToken {
			self.fcmToken = fcmToken
		} else {
			self.fcmToken = ""
		}
	}
}

func getDeviceTimeText(time: Int) -> String {
	let lastUpdated = Date(timeIntervalSince1970: TimeInterval(time))
	var date = ""
	if (Calendar.current.isDateInToday(lastUpdated)) {
		date = "today"
	} else {
		let dateComponents = Calendar.current.dateComponents([.month, .day, .year], from: lastUpdated)
		date = "\(dateComponents.month!) \(dateComponents.day!) \(dateComponents.year!)"
	}
	
	let dateFormatter = DateFormatter()
	dateFormatter.dateFormat = "h:mm a"
	let time = dateFormatter.string(from: lastUpdated)
	// TODO pad the minte so it is like 8:01 and 8:11
	return "Last updated \(date) at \(time)"
}

func updateLastLoggedIn() async -> LoadingState {
	guard let userID = Auth.auth().currentUser?.uid else { return LoadingState.failed }
	let db = Firestore.firestore()
	do {
		try await db.collection("users").document(userID).setData([
			"lastLoggedIn": Int(Date.now.timeIntervalSince1970)
		], merge: true)
		return LoadingState.success
	} catch _ {
		return LoadingState.failed
	}
}

func updateGithubId(uid: String) async -> LoadingState {
	guard let userID = Auth.auth().currentUser?.uid else { return LoadingState.failed }
	let db = Firestore.firestore()
	do {
		try await db.collection("users").document(userID).setData([
			"git_uid": uid	
		], merge: true)
		print(uid)
		return LoadingState.success
	} catch _ {
		print("Error")
		return LoadingState.failed
	}
}
