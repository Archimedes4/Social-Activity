//
//  StatusItem.swift
//  Social_Activity
//
//  Created by Andrew Mainella on 2024-11-25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

enum StatusItemState {
	case create, editing, viewing, creating, deleting, updating, failed
}

struct StatusItem: View {
	@State var name: String
	@State var emoji: String
	@Binding var createEmoji: String
	@State var url: String = ""
	@ObservedObject var gitHubEmojis: GitHubEmoji
	@State private var path = NavigationPath()
	@State var state: StatusItemState
	@State var initalName: String = ""
	var information: StatusInformation?
	var onSelectEmoji: () -> Void
	var onDelete: () -> Void
	
	init(information: StatusInformation?, gitHubEmojis: GitHubEmoji, onSelectEmoji: @escaping () -> Void, createEmoji: Binding<String>?, onDelete: @escaping () -> Void) {
		self.gitHubEmojis = gitHubEmojis
		self.onSelectEmoji = onSelectEmoji
		self.onDelete = onDelete
		guard let info = information else {
			if (createEmoji != nil) {
				self._createEmoji = createEmoji!
			} else {
				self._createEmoji = Binding.constant("")
			}
			self.emoji = "smiley"
			self.name = ""
			self.state = StatusItemState.create
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
				.strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [(state == StatusItemState.create) ? 10:.greatestFiniteMagnitude]))
				.background(.white)
				.cornerRadius(10)
			if (state != StatusItemState.create && state != StatusItemState.viewing && state != StatusItemState.editing) {
				LoadingItem(state: $state)
			} else {
				MainStatusItem(information: information, onDelete: onDelete, onSelectEmoji: onSelectEmoji, emoji: $emoji, name: $name, state: $state, url: $url, initalName: $initalName)
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

struct LoadingItem: View {
	@Binding var state: StatusItemState
	
	func getText(s: StatusItemState) -> String {
		if (s == StatusItemState.creating) {
			return "Creating..."
		}
		if (s == StatusItemState.deleting) {
			return "Deleting..."
		}
		return "Updating..."
	}
	
	var body: some View {
		HStack {
			ProgressView()
			Text(getText(s: state))
				.font(Font.custom("Nunito-Regular", size: 20))
				.padding(.leading, 8)
		}.frame(height: 65)
	}
}

struct MainStatusItem: View {
	var information: StatusInformation?
	var onDelete: () -> Void
	var onSelectEmoji: () -> Void
	@Binding var emoji: String
	@Binding var name: String
	@Binding var state: StatusItemState
	@Binding var url: String
	@Binding var initalName: String
	
	func updateItem() async {
		state = StatusItemState.updating
		let db = Firestore.firestore()
		do {
			guard let userID = Auth.auth().currentUser?.uid else {
				state = StatusItemState.failed
				return
			}
			guard let infoID = information?.id else {
				state = StatusItemState.failed
				return
			}
			try await db.collection("users").document(userID).collection("statuses").document(infoID).updateData([
				"name": name,
				"emoji": emoji
			])
			withAnimation(.easeIn(duration: 0.3)){
				state = StatusItemState.viewing
			}
		} catch {
			state = StatusItemState.failed
		}
	}
	
	func addItem() async {
		state = StatusItemState.creating
		let db = Firestore.firestore()
		do {
			guard let userID = Auth.auth().currentUser?.uid else {
				state = StatusItemState.failed
				return
			}
			try await db.collection("users").document(userID).collection("statuses").addDocument(data: [
				"name": name,
				"emoji": emoji
			])
			state = StatusItemState.editing
		} catch {
			state = StatusItemState.failed
		}
	}

	func deleteItem() async {
		state = StatusItemState.deleting
		let db = Firestore.firestore()
		do {
			guard let userID = Auth.auth().currentUser?.uid else {
				state = StatusItemState.failed
				return
			}
			guard let infoID = information?.id else {
				state = StatusItemState.failed
				return
			}
			try await db.collection("users").document(userID).collection("statuses").document(infoID).delete()
			onDelete()
		} catch {
			state = StatusItemState.failed
		}
	}
	
	var body: some View {
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
					.buttonStyle(StatusButtonStyle())
					.disabled(state == StatusItemState.viewing)
					.focusEffectDisabled()
					
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
				if (state == StatusItemState.create) {
					Button(action: {
						Task {
							await addItem()
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
							Task {
								await updateItem()
							}
						}) {
							Image(systemName: "checkmark.square")
								.resizable()
								.frame(width: 25, height: 25)
						}.buttonStyle(.plain)
					}
					Button(action: {
						Task {
							await deleteItem()
						}
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
	}
}
