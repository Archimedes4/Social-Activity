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
	let selectedTime: String
	let times: [String]
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
