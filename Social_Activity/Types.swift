//
//  Types.swift
//  Social_Activity
//
//  Created by Andrew Mainella on 2024-12-01.
//

struct StatusInformation: Identifiable {
	let id: String
	let name: String
	let emoji: String
	var selectedTime: Int
	var times: [Int]
}

struct UserData {
	let fullName: String
	let advatar: String
	let pronouns: String
	let username: String
	let status: StatusInformation?
}

enum LoadingState {
	case loading, success, failed
}

enum DeviceTypes: String {
	case macOSDesktop = "macOSDesktop"
	case macOSLaptop = "macOSLaptop"
	case iPad = "iPad"
	case iPhone = "iPhone"
	case unknown = "unknown"
}

struct Device {
	let name: String
	let type: DeviceTypes
	let fcmToken: String
	let lastUpdated: Int // This is the epoch time of when the device was last updated.
}
