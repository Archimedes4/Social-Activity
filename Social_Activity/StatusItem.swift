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

extension Int {
	// new functionality to add to SomeType goes here
	func toLongTime() -> String {
		var hours = 0
		var minutes = 0
		var seconds = 0;
		hours = Int(floor(Double(self)/3600.0))
		var left = 0
		left = self%3600
		minutes = left/60
		seconds = left%60
		var result = ""
		if (hours != 0) {
			result = "\(hours) hour\(hours != 1 ? "s":"")"
		}
		if (minutes != 0) {
			if (hours != 0) {
				result += " "
			}
			result += "\(minutes) minute\(minutes != 1 ? "s":"")"
		}
		if (seconds != 0) {
			if (hours != 0 || minutes != 0) {
				result += " "
			}
			result += "\(seconds) seconds"
		}
		return result
	}
}

struct DateTimePicker: View {
	let addItem: (_ time: Int) -> Void
	@State var hours: Int = 0
	@State var minutes: Int = 0
	@State private var date = Date()
	
	var body: some View {
		VStack {
			HStack {
				Picker("", selection: $hours){
						ForEach(0..<4, id: \.self) { i in
								Text("\(i) hours").tag(i)
						}
				}
				Picker("", selection: $minutes){
						ForEach(0..<60, id: \.self) { i in
								Text("\(i) min").tag(i)
						}
				}
			}
			DatePicker(selection: $date, displayedComponents: .date) {}
				.labelsHidden()
				.contentShape(Rectangle())
				.opacity(0.011)             // <<< here
			Button(action: {
				addItem((hours * 3600) + (minutes * 60))
			}) {
				Text("Add Time")
			}
		}
	}
}

struct TimeSelector: View {
	@Binding var information: StatusInformation?
	@Binding var state: StatusItemState
	@State var isPickingTime: Bool = false;
	
	func loadUpdateSelectedItem(time: Int) {
		Task {
			information?.selectedTime = time
			await updateSelectedItem(time: time, infoID: information?.id ?? "")
		}
	}
	
	func loadAddItem(time: Int) {
		Task {
			if (information?.times.contains(where: {$0 == time}) == false) {
				self.information?.times.append(time)
			}
			await addItem(time: time, infoID: information?.id ?? "")
		}
	}
	
	func loadRemoveItem(time: Int) {
		Task {
			self.information?.times = self.information?.times.filter({$0 != time}) ?? []
			await removeItem(time: time, infoID: information?.id ?? "")
		}
	}
	
	var body: some View {
		HStack {
			HStack(spacing: 3) {
				Button(action: {
					loadUpdateSelectedItem(time: -1)
				}) {
					HStack {
						Image(systemName: "infinity")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 10, height: 10)
							.foregroundStyle(.black)
						Text("Never end")
							.font(.system(size: 10))
							.foregroundStyle(.black)
					}
					.padding(5)
					.background((information?.selectedTime ?? 0 < 0) ? Color("BlueOne"):.white)
					.clipShape(RoundedRectangle(cornerRadius: 35))
				}
				.buttonStyle(.plain)
				if let information = information {
					ForEach(information.times, id: \.hashValue) { time in
						Button(action: {
							loadUpdateSelectedItem(time: time)
						}) {
							HStack {
								Image(systemName: "clock")
									.resizable()
									.frame(width: 10, height: 10)
									.foregroundStyle(.black)
								Text(time.toLongTime())
									.font(.system(size: 10))
									.foregroundStyle(.black)
								if (state != StatusItemState.viewing && time != information.selectedTime) {
									Button(action: {
										loadRemoveItem(time: time)
									}) {
										Image(systemName: "xmark")
											.resizable()
											.frame(width: 10, height: 10)
											.foregroundStyle(.black)
									}.buttonStyle(.plain)
								}
							}
							.padding(5)
							.background((information.selectedTime == time) ? Color("BlueOne"):.white)
							.clipShape(RoundedRectangle(cornerRadius: 35))
						}
						.buttonStyle(.plain)
					}
				}
				Button(action: {
					isPickingTime = true;
				}) {
					Image(systemName: "calendar.badge.plus")
						.resizable()
						.frame(width: 10, height: 10)
						.foregroundStyle(.black)
						.padding(5)
						.background(.white)
						.clipShape(RoundedRectangle(cornerRadius: 35))
						.popover(isPresented: $isPickingTime) {
							DateTimePicker(addItem: { time in
								loadAddItem(time: time)
							})
						}
				}.buttonStyle(.plain)
			}
			.padding(5)
			.background(.ultraThinMaterial)
			.clipShape(RoundedRectangle(cornerRadius: 35))
			.overlay() {
				RoundedRectangle(cornerRadius: 35)
					.strokeBorder(Color.black, style: StrokeStyle(lineWidth: 1, dash: [.greatestFiniteMagnitude]))
			}
			.padding(.leading, 10)
			Spacer()
		}
		.padding(.bottom, 10)
	}
}

struct StatusItem: View {
	@State var name: String
	@State var emoji: String
	@State var url: String = ""
	@State private var path = NavigationPath()
	@State var state: StatusItemState
	@State var initalName: String = ""
	@State var information: StatusInformation?
	var onSelectEmoji: () -> Void
	var onDelete: () -> Void
	var onCreate: (_ id: String, _ name: String, _ emoji: String, _ selectedTime: Int, _ times: [Int]) -> Void
	@EnvironmentObject var homeData: HomeData
	
	init(information: StatusInformation?, onSelectEmoji: @escaping () -> Void, onDelete: @escaping () -> Void, onCreate: @escaping (_ id: String, _ name: String, _ emoji: String, _ selectedTime: Int, _ times: [Int]) -> Void) {
		self.onSelectEmoji = onSelectEmoji
		self.onDelete = onDelete
		self.onCreate = onCreate
		guard let info = information else {
			self.emoji = "smiley"
			self.name = ""
			self.state = StatusItemState.create
			self.information = nil
			return
		}
		self.information = info
		self.name = info.name
		self.emoji = info.emoji
		self.state = StatusItemState.viewing
	}
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 10)
				.strokeBorder(Color.black, style: StrokeStyle(lineWidth: 3, dash: [(state == StatusItemState.create || state == StatusItemState.creating) ? 10:.greatestFiniteMagnitude]))

				.background(.white)
				.cornerRadius(10)
			if (state == StatusItemState.viewing) {
				Button(action: {
					Task {
						await setStatus(emoji: ":" + emoji + ":", message: name, expiresAt: getExpiresAt(time: information?.selectedTime ?? -1), token: homeData.token)
						homeData.checkStatus()
					}
				}) {
					MainStatusItem(information: $information, onDelete: onDelete, onSelectEmoji: onSelectEmoji, onCreate: onCreate, emoji: $emoji, name: $name, state: $state, url: $url, initalName: $initalName)
				}.buttonStyle(.plain)
			} else if (state != StatusItemState.create && state != StatusItemState.viewing && state != StatusItemState.editing) {
				LoadingItem(state: $state)
			} else if (state != StatusItemState.failed) {
				MainStatusItem(information: $information, onDelete: onDelete, onSelectEmoji: onSelectEmoji, onCreate: onCreate, emoji: $emoji, name: $name, state: $state, url: $url, initalName: $initalName)
			} else {
				
			}
		}
		.onAppear() {
			do {
				url = try homeData.getUrl(emoji: emoji)
			} catch {
				
			}
		}
		.onChange(of: emoji) {
			do {
				url = try homeData.getUrl(emoji: emoji)
			} catch {
				
			}
		}
		.onChange(of: homeData.emojis) {
			do {
				url = try homeData.getUrl(emoji: emoji)
			} catch {
				
			}
		}
		.onChange(of: homeData.createSelectedEmoji) {
			if (state == StatusItemState.create) {
				emoji = homeData.createSelectedEmoji
			}
		}
		.padding(.vertical, 2)
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
	@Binding var information: StatusInformation?
	var onDelete: () -> Void
	var onSelectEmoji: () -> Void
	var onCreate: (_ id: String, _ name: String, _ emoji: String, _ selectedTime: Int, _ times: [Int]) -> Void
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
			let itemId = UUID().uuidString
			guard let userID = Auth.auth().currentUser?.uid else {
				state = StatusItemState.failed
				return
			}
			let res: Void = try await db.collection("users").document(userID).collection("statuses").document(itemId).setData([
				"name": name,
				"emoji": emoji,
				"id":itemId,
				"selectedTime":-1,
				"times":[60]
			])
			withAnimation(.easeIn(duration: 0.3)){
				state = StatusItemState.create
				onCreate(itemId, name, emoji, -1, [3600])
				name = ""
			}
		} catch {
			state = StatusItemState.failed
		}
	}

	func deleteItem() async {
		withAnimation(.easeIn(duration: 0.3)){
			state = StatusItemState.deleting
		}
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
			withAnimation(.easeIn(duration: 0.3)){
				onDelete()
			}
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
							ProgressView()
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
							.foregroundStyle(.black)
						Spacer()
					}
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
								.foregroundStyle(.black)
								.background(.white)
								.scrollContentBackground(.hidden)
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
							.foregroundStyle(.black)
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
							.foregroundStyle(.black)
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
								.foregroundStyle(.black)
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
							.foregroundStyle(.black)
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
							.foregroundStyle(.black)
					}.buttonStyle(.plain)
				}
			}
			if (state != StatusItemState.viewing) {
				HStack{
					Text("\(90 - name.count) characters remaining")
						.offset(y: -9)
						.padding(.leading, 65)
						.foregroundStyle(.black)
					Spacer()
				}
			}
			if (state == StatusItemState.viewing || state == StatusItemState.editing) {
				TimeSelector(information: $information, state: $state)
			}
		}
	}
}

struct FailedItem: View {
	var body: some View {
		HStack {
			Image(systemName: "exclamationmark.circle")
				.resizable()
				.frame(width: 25, height: 25)
			Text("Failed")
				.font(Font.custom("Nunito-Regular", size: 20))
		}
	}
}
