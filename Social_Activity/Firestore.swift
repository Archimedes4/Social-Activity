//
//  Firestore.swift
//  Social_Activity
//
//  Created by Andrew Mainella on 2024-11-25.
//

import FirebaseAuth
import FirebaseFirestore

/**
 If the result is nil something went wrong
 */
func getStatusInformation() async -> [StatusInformation]? {
	guard let userID = Auth.auth().currentUser?.uid else { return nil }
	let db = Firestore.firestore()
	let docRef = db.collection("users").document(userID).collection("statuses")
	do {
		let documentsResult = try await docRef.getDocuments()
		var loadingItems: [StatusInformation] = []
		for document in documentsResult.documents {
			let data = document.data()
			guard let name = data["name"] as? String else { return nil }
			guard let emoji = data["emoji"] as? String else { return nil }
			let selectedTime = getTimeOption(data: data["selectedTime"] as Any)
			guard let rawtimes = data["times"] as? [Any] else { return nil }
			let times = rawtimes.map({ getTimeOption(data: $0) })
			loadingItems.append(StatusInformation(id: document.documentID, name: name, emoji: emoji, selectedTime: selectedTime, times: times))
		}
		return	 loadingItems
	} catch let error {
		print(error)
		return nil
	}
}

func getTimeOption(data: Any) -> TimeOption {
	if let time = data as? Timestamp {
		return .date(time.dateValue())
	}
	if let int = data as? Int {
		if (int == -1) {
			return .never
		}
		return .duration(int)
	}
	return .never
}

func getRawVal(option: TimeOption) -> Any {
	if case .date(let date) = option {
		return Timestamp(date: date)
	}
	if case .duration(let int) = option {
		return int
	}
	return -1
}

/**
 This only updates the value in firestore, please update the information locally
 */
func updateSelectedItem(time: TimeOption, infoID: String) async -> LoadingState {
	guard let userID = Auth.auth().currentUser?.uid else { return LoadingState.failed }
	let db = Firestore.firestore()
	do {
		try await db.collection("users").document(userID).collection("statuses").document(infoID).updateData([
			"selectedTime":getRawVal(option: time),
		])
		return LoadingState.success
	} catch {
		return LoadingState.failed
	}
}

/**
 This only updates the value in firestore, please update the information locally
 */
func addItem(time: TimeOption, infoID: String) async -> LoadingState {
	guard let userID = Auth.auth().currentUser?.uid else { return LoadingState.failed }
	let db = Firestore.firestore()
	do {
		try await db.collection("users").document(userID).collection("statuses").document(infoID).updateData([
			"times":FieldValue.arrayUnion([getRawVal(option: time)]),
		])
		return LoadingState.success
	} catch let error {
		print(error)
		return LoadingState.failed
	}
}


/**
 This only updates the value in firestore, please update the information locally
 */
func removeItem(time: TimeOption, infoID: String) async -> LoadingState {
	guard let userID = Auth.auth().currentUser?.uid else { return LoadingState.failed }
	let db = Firestore.firestore()
	do {
		try await db.collection("users").document(userID).collection("statuses").document(infoID).updateData([
			"times":FieldValue.arrayRemove([getRawVal(option: time)]),
		])
		return LoadingState.success
	} catch {
		return LoadingState.failed
	}
}
