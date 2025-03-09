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
	let addItem: (_ time: TimeOption) -> Void
	@State private var selectedHours = 0
	@State private var selectedMinutes = 0
	@State private var selectedDate = Date()
	@State private var selectedTime = false
	
	var body: some View {
		VStack {
			VStack {
				Text("Add Time to End the Status")
					.font(.headline)
				Picker("Mode", selection: $selectedTime) {
					Text("Date & Time").tag(false)
					Text("Duration").tag(true)
				}.pickerStyle(.segmented)
				.labelsHidden()
				if (selectedTime) {
					HStack {
							// Hours Picker
							Picker("Hours", selection: $selectedHours) {
									ForEach(0..<25, id: \.self) { hour in
											Text("\(hour) hrs").tag(hour)
									}
							}
							#if os(iOS)
								.pickerStyle(WheelPickerStyle())
							#elseif os(macOS)
								.pickerStyle(.menu)
							#endif
							.frame(width: 150)
							.clipped()
							
							Text(":")
									.font(.largeTitle)
									.padding(.horizontal, 5)
							
							// Minutes Picker
							Picker("Minutes", selection: $selectedMinutes) {
									ForEach(0..<60, id: \.self) { minute in
											Text("\(minute) min").tag(minute)
									}
							}
							#if os(iOS)
								.pickerStyle(WheelPickerStyle())
							#elseif os(macOS)
								.pickerStyle(.menu)
							#endif
							.frame(width: 150)
							.clipped()
					}
					
					// Display selected duration
					Text("Selected Duration: \(selectedHours) hr \(selectedMinutes) min")
							.padding()
				} else {
					Spacer()
					DatePicker("Select Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
							.datePickerStyle(CompactDatePickerStyle()) // Compact style
					Spacer()
				}
		}
		.padding()
			Button(action: {
				if (selectedTime) {
					addItem(.duration((selectedHours * 3600) + (selectedMinutes * 60)))
				} else {
					addItem(.date(selectedDate))
				}
			}) {
				HStack {
					Spacer()
					Image(systemName: "calendar.badge.plus")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.foregroundStyle(.black)
						.frame(width: 25, height: 25)
					Text("Add Time")
						.foregroundStyle(.black)
						.font(.headline)
					Spacer()
				}
				.padding()
				.background(RoundedRectangle(cornerRadius: 20).fill(Color.greenOne))
				.padding(.horizontal)
			}.buttonStyle(.plain)
			#if os(macOS)
				.padding(.bottom)
			#endif
		}
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
	var onCreate: (_ id: String, _ name: String, _ emoji: String, _ selectedTime: TimeOption, _ times: [TimeOption]) -> Void
	@EnvironmentObject var homeData: HomeData
	
	init(information: StatusInformation?, onSelectEmoji: @escaping () -> Void, onDelete: @escaping () -> Void, onCreate: @escaping (_ id: String, _ name: String, _ emoji: String, _ selectedTime: TimeOption, _ times: [TimeOption]) -> Void) {
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
						await setStatus(emoji: ":" + emoji + ":", message: name, expiresAt: getExpiresAt(time: information?.selectedTime ?? .never), token: homeData.token)
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
	var onCreate: (_ id: String, _ name: String, _ emoji: String, _ selectedTime: TimeOption, _ times: [TimeOption]) -> Void
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
				onCreate(itemId, name, emoji, TimeOption.never, [TimeOption.duration(3600)])
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
							TextField("", text: $name)
								.padding(8)
								.overlay(
									RoundedRectangle(cornerRadius: 12)
										.stroke(.black, lineWidth: 2)
								)
								.foregroundStyle(.black)
								.background(.white)
								.scrollContentBackground(.hidden)
								.font(Font.custom("Nunito-Regular", size: 20))
								.padding(.vertical)
								.textFieldStyle(.plain)
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
