//
//  EmojiPicker.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-11-22.
//

import SwiftUI

struct EmojiItem: View {
	var key: String
	var url: String
	var onSelected: (_ emoji: String) -> Void
	
	var body: some View {
		Button(action: {onSelected(key)}) {
			VStack {
				AsyncImage(url: URL(string: url)) { image in
					image.resizable()
				} placeholder: {
					ProgressView()
				}
				.frame(width: 25, height: 25)
				Text(key.replacingOccurrences(of: "_", with: " "))
					.minimumScaleFactor(0.2)
					.lineLimit(2)
					.foregroundStyle(.black)
			}
		}.buttonStyle(.plain)
	}
}

struct EmojiView: View {
	@Binding var emoji: String
	@State var url: String = ""
	@EnvironmentObject var homeData: HomeData
	
	var body: some View {
		VStack {
			if (url != "") {
				AsyncImage(url: URL(string: url)) { image in
					image.resizable()
				} placeholder: {
					ProgressView()
				}
				.frame(width: 25, height: 25)
			}
		}
		.onChange(of: emoji, {
			do {
				url = try homeData.getUrl(emoji: emoji)
			} catch {
				
			}
		})
		.onChange(of: homeData.emojis, {
			do {
				url = try homeData.getUrl(emoji: emoji)
			} catch {
				
			}
		})
	}
}

struct EmojiPicker: View {
	@State var emojis: [String: String] = [:]
	@State var filtered: [String: String] = [:]
	@State var search = ""
	@State var initalEmoji: String = "smiley"
	var onDismiss: (_ selected: String) -> Void
	let columns = [GridItem(.adaptive(minimum: 80))]
	@EnvironmentObject var homeData: HomeData
	@EnvironmentObject var geometryData: GeometryData

	
	init (onDismiss: @escaping (_ selected: String) -> Void) {
		self.onDismiss = onDismiss
	}
	
	var body: some View {
		let isAlt = geometryData.state != .small
		VStack {
			TextField("Search", text: $search)
				.textFieldStyle(.plain)
				.padding(5)
				.font(Font.custom("Nunito-Regular", size: 20))
				.onSubmit {
					#if os(iOS)
						UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
					#endif
				}
				.foregroundStyle(.black)
				.padding(2)
				.overlay(
					RoundedRectangle(cornerRadius: 12)
						.stroke(.black, lineWidth: 2)
				)
				.padding([.top, .horizontal])
				VStack (spacing: 0) {
					ScrollView {
						LazyVGrid(columns: columns) {
							ForEach(filtered.sorted(by: <), id: \.key) {item in
								EmojiItem(key: item.key, url: item.value, onSelected: { result in
									homeData.selectedEmoji = result
								})
							}
						}.frame(maxWidth: .infinity)
					}
					Button(action: {
						onDismiss(initalEmoji)
					}) {
						HStack {
							EmojiView(emoji: $initalEmoji)
							Text("Cancel")
								.foregroundStyle(.black)
						}
						.padding()
						.frame(maxWidth: .infinity)
						.overlay(alignment: .center) {
							RoundedRectangle(cornerRadius: 10)
								.strokeBorder(.black, style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
								.cornerRadius(10)
								.frame(maxWidth: .infinity)
						}
					}.buttonStyle(.plain)
					.padding()
					if (homeData.selectedEmoji != initalEmoji) {
						Button(action: {
							onDismiss(homeData.selectedEmoji)
						}) {
							HStack {
								EmojiView(emoji: $homeData.selectedEmoji)
								Text("Select")
									.foregroundStyle(.black)
							}
							.padding()
							.frame(maxWidth: .infinity)
							.overlay(alignment: .center) {
								RoundedRectangle(cornerRadius: 10)
									.strokeBorder(.black, style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
									.cornerRadius(10)
									.frame(maxWidth: .infinity)
							}
						}.buttonStyle(.plain)
						.padding([.horizontal, .bottom])
					}

				}.frame(maxWidth: .infinity)
		}
		.frame(width: (geometryData.size.width * (geometryData.state != .small ? 0.4:1)) - (geometryData.state != .small ? 0:20), height: geometryData.size.height * 0.85)
		.background(.white)
		.cornerRadius(10)
		.overlay(alignment: .center) {
			RoundedRectangle(cornerRadius: 10)
				.strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
				.cornerRadius(10)
				.frame(width: (geometryData.size.width * (geometryData.state != .small ? 0.4:1)) - (geometryData.state != .small ? 0:20))
		}
		.onAppear() {
			initalEmoji = homeData.selectedEmoji
			Task {
				do {
					emojis = try homeData.getEmojis()
					filtered = emojis
				} catch {
					
				}
			}
		}
		.onChange(of: search) { newValue in
			if (newValue == "") {
				filtered = emojis
			} else {
				filtered = emojis.filter({ $0.key.localizedCaseInsensitiveContains(search)})
			}
		}
		.padding(.horizontal)
	}
}
