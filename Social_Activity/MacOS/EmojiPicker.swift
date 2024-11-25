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
					Color.red
				}
				.frame(width: 25, height: 25)
				Text(key.replacingOccurrences(of: "_", with: " "))
			}
		}.buttonStyle(.plain)
	}
}

struct EmojiView: View {
	@Binding var emoji: String
	@ObservedObject var gitHubEmojis: GitHubEmoji
	@State var url: String = ""
	
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
		}.onAppear() {
			Task {
				url = try await gitHubEmojis.getUrl(emoji: emoji)
			}
		}
		.onChange(of: emoji, {
			//url = "" TODO wait a few seconds before changing
			Task {
				url = try await gitHubEmojis.getUrl(emoji: emoji)
			}
		})
	}
}

struct EmojiPicker: View {
	@Binding var emoji: String
	@State var emojis: [String: String] = [:]
	@State var filtered: [String: String] = [:]
	@State var search = ""
	var onDismiss: (_ selected: String) -> Void
	@ObservedObject var gitHubEmojis: GitHubEmoji
	
	@State var geometry: GeometryProxy
	
	let columns = [GridItem(.adaptive(minimum: 80))]

	
	init (for metrics: GeometryProxy, emoji: Binding<String>, onDismiss: @escaping (_ selected: String) -> Void, gitHubEmojis: GitHubEmoji) {
		self.geometry = metrics
		self._emoji = emoji
		self.onDismiss = onDismiss
		self.gitHubEmojis = gitHubEmojis
	}
	
	var body: some View {
		VStack {
			HStack {
				TextEditor(text: $search)
					.padding(5)
					.font(Font.custom("Nunito-Regular", size: 20))
					.lineLimit(1)
			}
			.overlay(
				RoundedRectangle(cornerRadius: 12)
					.stroke(.black, lineWidth: 2)
			)
			.padding([.top, .horizontal])
			.frame(height: 50)
			HStack {
				VStack {
					EmojiView(emoji: $emoji, gitHubEmojis: gitHubEmojis)
					Text(emoji)
						.font(Font.custom("Nunito-Regular", size: 20))
					Button(action: {
						onDismiss(emoji)
					}) {
						HStack {
							Image(systemName: "checkmark.circle")
							Text("Select")
						}
						.padding()
						.frame(maxWidth: .infinity)
						.overlay(alignment: .center) {
							RoundedRectangle(cornerRadius: 10)
								.strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
								.cornerRadius(10)
								.frame(maxWidth: .infinity)
						}
					}.buttonStyle(.plain)
					Button(action: {
						onDismiss(emoji)
					}) {
						HStack {
							Image(systemName: "arrow.uturn.backward")
							Text("Go Back")
						}
						.padding()
						.overlay(alignment: .center) {
							RoundedRectangle(cornerRadius: 10)
								.strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
								.cornerRadius(10)
						}
					}.buttonStyle(.plain)
				}.padding(.leading)
					.frame(maxWidth: geometry.size.width * 0.1)
				VStack {
					ScrollView {
						VStack {
							LazyVGrid(columns: columns) {
								ForEach(filtered.sorted(by: <), id: \.key) {item in
									EmojiItem(key: item.key, url: item.value, onSelected: { result in
										emoji = result
									})
								}
							}
						}.frame(maxWidth: .infinity)
					}
				}.frame(maxWidth: .infinity)
			}.frame(width: geometry.size.width * 0.4)
		}.frame(width: geometry.size.width * 0.4)
		.background(.white)
		.cornerRadius(10)
		.overlay(alignment: .center) {
			RoundedRectangle(cornerRadius: 10)
				.strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
				.cornerRadius(10)
				.frame(width: geometry.size.width * 0.4)
		}
		.onAppear() {
			Task {
				do {
					emojis = try await gitHubEmojis.getEmojis()
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
	}
}
