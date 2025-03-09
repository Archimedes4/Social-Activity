//
//  Types.swift
//  Social_Activity
//
//  Created by Andrew Mainella on 2024-12-01.
//

import Foundation

enum TimeOption {
	case date(Date)
	case duration(Int)
	case never
}

extension TimeOption: Equatable, Identifiable {
	static func == (lhs: TimeOption, rhs: TimeOption) -> Bool {
			switch (lhs, rhs) {
			case (.date(let a), .date(let b)):
					return a == b
			case (.duration(let a), .duration(let b)):
					return a == b
			case (.never, .never):
				return true
			default:
					return false
			}
	}
	
	var id: String {
			switch self {
			case .date(let date):
					return "date-\(date.timeIntervalSince1970)"
			case .duration(let minutes):
					return "duration-\(minutes)"
			case .never:
					return "never"
			}
	}
}

struct StatusInformation: Identifiable {
	let id: String
	let name: String
	let emoji: String
	var selectedTime: TimeOption
	var times: [TimeOption]
	var expiresAt: Date?
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

enum dimensionMode {
	case large // Side by side and the settings page is shown
	case medium // Side by side but the settings page is not shown
	case small // Horizonal
}
