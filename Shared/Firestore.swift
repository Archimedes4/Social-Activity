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
			guard let selectedTime = data["selectedTime"] as? String else { return nil }
			guard let times = data["times"] as? [String] else { return nil }
			loadingItems.append(StatusInformation(id: document.documentID, name: name, emoji: emoji, selectedTime: selectedTime, times: times))
		}
		return	 loadingItems
	} catch let error {
		print(error)
		return nil
	}
}

/**
 This only updates the value in firestore, please update the information locally
 */
func updateSelectedItem(time: String, infoID: String) async -> LoadingState {
	guard let userID = Auth.auth().currentUser?.uid else { return LoadingState.failed }
	let db = Firestore.firestore()
	do {
		try await db.collection("users").document(userID).collection("statuses").document(infoID).updateData([
			"selectedTime":time,
		])
		return LoadingState.success
	} catch {
		return LoadingState.failed
	}
}

/**
 This only updates the value in firestore, please update the information locally
 */
func addItem(time: String, infoID: String) async -> LoadingState {
	guard let userID = Auth.auth().currentUser?.uid else { return LoadingState.failed }
	let db = Firestore.firestore()
	do {
		try await db.collection("users").document(userID).collection("statuses").document(infoID).updateData([
			"times":FieldValue.arrayUnion([time]),
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
func removeItem(time: String, infoID: String) async -> LoadingState {
	guard let userID = Auth.auth().currentUser?.uid else { return LoadingState.failed }
	let db = Firestore.firestore()
	do {
		try await db.collection("users").document(userID).collection("statuses").document(infoID).updateData([
			"times":FieldValue.arrayRemove([time]),
		])
		return LoadingState.success
	} catch {
		return LoadingState.failed
	}
}
