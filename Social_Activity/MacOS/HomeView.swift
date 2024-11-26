//
//  HomeView.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-11-21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct StatusInformation: Identifiable {
	let id: String
	let name: String
	let emoji: String
}

protocol StatusItemInformation {}
extension StatusInformation : StatusItemInformation{}
extension Binding<String> : StatusItemInformation {}


struct StatusButtonStyle: ButtonStyle {
		func makeBody(configuration: Configuration) -> some View {
				configuration.label
						.foregroundColor(.white)
		}
}

struct HomeView: View {
	@State var statusItems: [StatusInformation] = []
	@State var createSelectedEmoji: String = "smiley" // The emoji for create
	@State var selectedEmoji: String = "smiley" // The emoji for picker
	@State var selectedIndex: Int = -1 // If -1 not selecting a emoji
	@ObservedObject var gitHubEmojis: GitHubEmoji
	
	func getStatusInformation() async {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		let db = Firestore.firestore()
		let docRef = db.collection("users").document(userID).collection("statuses")

		do {
			let documentsResult = try await docRef.getDocuments()
			var loadingItems: [StatusInformation] = []
			for document in documentsResult.documents {
				let data = document.data()
				if (data.keys.contains("name") && data.keys.contains("emoji")) {
					loadingItems.append(StatusInformation(id: document.documentID, name: data["name"] as! String, emoji: data["emoji"] as! String))
				}
			}
			statusItems = loadingItems
		} catch {
			print("Error getting document: \(error)")
		}

	}
	
	var body: some View {
		GeometryReader { geometry in
			NavigationStack {
				VStack {
					HStack {
						Image("Logo")
							.resizable()
							.frame(width: geometry.size.height * 0.08, height: geometry.size.height * 0.08)
							.cornerRadius(15)
							.padding(.leading)
						Text("Social Activity")
							.font(Font.custom("Nunito-Regular", size: 32))
							.foregroundStyle(.white)
						Spacer()
					}
					.frame(height: geometry.size.height * 0.1)
					HStack {
						VStack {
							if (selectedIndex != -1) {
								EmojiPicker(for: geometry, emoji: $selectedEmoji, onDismiss: {selected in
									selectedIndex = -1
								}, gitHubEmojis: gitHubEmojis)
							} else {
								ProfileView(for: geometry)
							}
							SettingsView(for: geometry)
							Spacer()
						}
						ScrollView {
							LazyVStack {
								ForEach(Array(statusItems.enumerated()), id: \.element.id) { index, item in
									StatusItem(information: item, gitHubEmojis: gitHubEmojis, onSelectEmoji: {
										selectedIndex = index
										selectedEmoji = item.emoji
									}, createEmoji: nil, onDelete: {
										print("On Delete")
										var newArr = statusItems
										newArr.remove(at: index)
										statusItems = newArr
									})
								}
								StatusItem(information: nil, gitHubEmojis: gitHubEmojis, onSelectEmoji: {
									selectedIndex = statusItems.count
									selectedEmoji = createSelectedEmoji
								}, createEmoji: $createSelectedEmoji, onDelete: {
									
								})
								.padding(.bottom)
							}
						}.padding(.horizontal, 10)
					}
				}.frame(width: geometry.size.width, height: geometry.size.height)
				.background(
					LinearGradient(stops: [
						Gradient.Stop(color: Color("BlueOne"), location: 0.14),
						Gradient.Stop(color: Color("BlueTwo"), location: 0.53),
						Gradient.Stop(color: Color("GreenOne"), location: 0.87),
					], startPoint: .topTrailing, endPoint: .bottomLeading)
				)
				.onAppear() {
					Task {
						await getStatusInformation()
					}
				}
				.onChange(of: selectedEmoji) { oldVal, newVal in
					print("Here", newVal)
					if selectedIndex < statusItems.count && selectedIndex >= 0 {
						statusItems[selectedIndex] = StatusInformation(id: statusItems[selectedIndex].id, name: statusItems[selectedIndex].name, emoji: selectedEmoji)
					} else if selectedIndex == statusItems.count {
						print("Count")
						createSelectedEmoji = newVal
					}
				}
			}
		}
	}
}
