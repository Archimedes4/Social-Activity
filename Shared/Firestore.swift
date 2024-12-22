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
			loadingItems.append(StatusInformation(id: document.documentID, name: name, emoji: emoji))
		}
		return	 loadingItems
	} catch let error {
		print(error)
		return nil
	}
}
