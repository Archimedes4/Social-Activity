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

enum StatusItemState {
	case creating, editing, viewing
}

protocol StatusItemInformation {}
extension StatusInformation : StatusItemInformation{}
extension Binding<String> : StatusItemInformation {}


struct StatusItem: View {
	var information: StatusInformation?
	@State var name: String
	@State var emoji: String
	@Binding var createEmoji: String
	@State var url: String = ""
	@ObservedObject var gitHubEmojis: GitHubEmoji
	@State private var path = NavigationPath()
	@State var state: StatusItemState
	@State var initalName: String = ""
	var onSelectEmoji: () -> Void
	
	func addEntry() async {
		let db = Firestore.firestore()
		do {
			guard let userID = Auth.auth().currentUser?.uid else { return }
			let ref = try await db.collection("users").document(userID).collection("statuses").addDocument(data: [
				"name": name,
				"emoji": emoji
			])
			print("Document added with ID: \(ref.documentID)")
			state = StatusItemState.editing
		} catch {
			print("Error adding document: \(error)")
		}
	}
	
	init(information: StatusInformation?, gitHubEmojis: GitHubEmoji, onSelectEmoji: @escaping () -> Void, createEmoji: Binding<String>?) {
		self.gitHubEmojis = gitHubEmojis
		self.onSelectEmoji = onSelectEmoji
		guard let info = information else {
			if (createEmoji != nil) {
				self._createEmoji = createEmoji!
			} else {
				self._createEmoji = Binding.constant("")
			}
			self.emoji = "smiley"
			self.name = ""
			self.state = StatusItemState.creating
			self.information = nil
			return
		}
		if (createEmoji != nil) {
			self._createEmoji = createEmoji!
		} else {
			self._createEmoji = Binding.constant(info.emoji)
		}
		self.information = info
		self.name = info.name
		self.emoji = info.emoji
		self.state = StatusItemState.viewing
	}
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 10)
				.strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [(state == StatusItemState.creating) ? 10:.greatestFiniteMagnitude]))
				.background(.white)
				.cornerRadius(10)
			VStack (spacing: 0){
				HStack {
					if (url != "") {
						Button(action: {
							onSelectEmoji()
						}) {
							AsyncImage(url: URL(string: url)) { image in
								image.resizable()
							} placeholder: {
								Color.red
							}
							.frame(width: 25, height: 25)
							.padding(.leading)
						}
						.buttonStyle(PlainButtonStyle())
						.disabled(state == StatusItemState.viewing)
					}
					if (state == StatusItemState.viewing) {
						VStack() {
							Spacer()
							Text(name)
								.font(Font.custom("Nunito-Regular", size: 20))
								.padding(.leading, 8)
							Spacer()
						}.frame(height: 65)
					} else {
						VStack {
							VStack {
								TextEditor(text: $name)
									.lineLimit(1)
									.padding(3)
									.overlay(
										RoundedRectangle(cornerRadius: 12)
											.stroke(.black, lineWidth: 2)
									)
									.font(Font.custom("Nunito-Regular", size: 20))
									.padding(.vertical)
							}.frame(height: 65)
						}
					}
					Spacer()
					if (state == StatusItemState.creating) {
						Button(action: {
							Task {
								await addEntry()
							}
						}) {
							Image(systemName: "plus.app")
								.resizable()
								.frame(width: 25, height: 25)
								.padding(.trailing)
						}.buttonStyle(.plain)
					} else if (state == StatusItemState.viewing) {
						Button(action: {
							initalName = name
							withAnimation(.easeIn(duration: 0.3)){
								state = StatusItemState.editing
							}
						}) {
							Image(systemName: "pencil")
								.resizable()
								.frame(width: 25, height: 25)
								.padding(.trailing)
						}.buttonStyle(.plain)
					} else {
						// Editing
						if (initalName != name) {
							Button(action: {
								withAnimation(.easeIn(duration: 0.3)){
									state = StatusItemState.viewing
								}
							}) {
								Image(systemName: "checkmark.square")
									.resizable()
									.frame(width: 25, height: 25)
							}.buttonStyle(.plain)
						}
						Button(action: {
							state = StatusItemState.viewing
						}) {
							Image(systemName: "trash.square")
								.resizable()
								.frame(width: 25, height: 25)
						}.buttonStyle(.plain)
						Button(action: {
							withAnimation(.easeIn(duration: 0.3)){
								state = StatusItemState.viewing
							}
						}) {
							Image(systemName: "x.square")
								.resizable()
								.frame(width: 25, height: 25)
								.padding(.trailing)
						}.buttonStyle(.plain)
					}
				}.frame(height: 65)
				if (state != StatusItemState.viewing) {
					HStack{
						Text("\(90 - name.count) characters remaining")
						.offset(y: -9)
						.padding(.leading, 65)
						Spacer()
					}
				}
			}
			.onAppear() {
				Task {
					url = try await GitHubEmoji().getUrl(emoji: emoji)
				}
			}
			.onChange(of: emoji) {
				Task {
					url = try await GitHubEmoji().getUrl(emoji: emoji)
				}
			}
			.onChange(of: createEmoji) {
				emoji = createEmoji
			}
		}
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
									}, createEmoji: nil)
								}
								StatusItem(information: nil, gitHubEmojis: gitHubEmojis, onSelectEmoji: {
									selectedIndex = statusItems.count
									selectedEmoji = createSelectedEmoji
								}, createEmoji: $createSelectedEmoji)
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
