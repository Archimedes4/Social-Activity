//
//  Widgets.swift
//  Widgets
//
//  Created by Andrew Mainella on 2024-11-30.
//

import WidgetKit
import SwiftUI

struct Select_Status_2x1_Provider: TimelineProvider {
		func placeholder(in context: Context) -> Select_Status_2x1_Entry {
			Select_Status_2x1_Entry(date: Date(), status: LoadingState.loading, items: [])
		}

		func getSnapshot(in context: Context, completion: @escaping (Select_Status_2x1_Entry) -> ()) {
			let entry = Select_Status_2x1_Entry(date: Date(), status: LoadingState.failed, items: [])
				completion(entry)
		}

		func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
			var entries: [Select_Status_2x1_Entry] = []
			var emojis: [StatusInformationImage] = []
			emojis.append(StatusInformationImage(id: "1", name: "Coding", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f468-1f4bb.png?v8")!)))
			emojis.append(StatusInformationImage(id: "2", name: "Coding", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f468-1f4bb.png?v8")!)))
			emojis.append(StatusInformationImage(id: "3", name: "Coding", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f468-1f4bb.png?v8")!)))
			
			entries.append(Select_Status_2x1_Entry(date: Date.now, status: LoadingState.success, items: emojis))

				let timeline = Timeline(entries: entries, policy: .atEnd)
				completion(timeline)
		}

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct Select_Status_2x1_Entry: TimelineEntry {
	var date: Date
	var status: LoadingState
	var profile: UserData?
	var statusData: Data?
	var profileData: Data?
	var items: [StatusInformationImage]
}

struct Select_Status_2x1_WidgetsEntryView : View {
	var entry: Select_Status_2x1_Provider.Entry

	var body: some View {
		VStack {
			GeometryReader { geometry in
				if (entry.status == LoadingState.loading) {
					HStack {
						VStack {
							RoundedRectangle(cornerRadius: geometry.size.width/2)
								.frame(width: geometry.size.width/4, height: geometry.size.width/4)
								.blur(radius: 10)
								.foregroundStyle(.gray.opacity(0.8))
							RoundedRectangle(cornerRadius: 15)
								.frame(width: geometry.size.width/3, height: geometry.size.width/10)
								.blur(radius: 10)
								.foregroundStyle(.gray.opacity(0.8))
						}.frame(width: geometry.size.width/2)
						VStack() {
							RoundedRectangle(cornerRadius: 15)
								.frame(width: geometry.size.width/2, height: geometry.size.height/4)
								.blur(radius: 10)
								.foregroundStyle(.gray.opacity(0.8))
							Spacer()
							RoundedRectangle(cornerRadius: 15)
								.frame(width: geometry.size.width/2, height: geometry.size.height/4)
								.blur(radius: 10)
								.foregroundStyle(.gray.opacity(0.8))
							Spacer()
							RoundedRectangle(cornerRadius: 15)
								.frame(width: geometry.size.width/2, height: geometry.size.height/4)
								.blur(radius: 10)
								.foregroundStyle(.gray.opacity(0.8))
						}
					}
				} else if (entry.status == LoadingState.failed) {
					VStack(alignment: .center) {
						Spacer()
						Image(systemName: "exclamationmark.circle")
							.resizable()
							.frame(width: 50, height: 50)
							.foregroundStyle(.white)
						Text("Something went wrong.")
							.foregroundStyle(.white)
						Spacer()
					}.frame(width: geometry.size.width)
				} else {
					HStack {
						VStack {
							if (entry.statusData != nil) {
								Image(uiImage: UIImage(data: entry.statusData!)!)
									.resizable()
									.frame(width: geometry.size.width/4, height: geometry.size.width/4)
							}
							Text("On Vacation")
								.foregroundStyle(.white)
						}.frame(width: geometry.size.width/2)
						VStack {
							ForEach(entry.items) { item in
								Button(action: {
									
								}) {
									HStack {
										Image(uiImage: UIImage(data: item.emojiImage)!)
											.resizable()
											.frame(width: 20, height: 20)
											.padding(.leading)
										Text(item.name)
											.foregroundStyle(.black)
										Spacer()
									}.frame(maxWidth: .infinity, maxHeight: .infinity)
								}.background(.white)
								.cornerRadius(20)
								.overlay(alignment: .center) {
									RoundedRectangle(cornerRadius: 20)
										.strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [.greatestFiniteMagnitude]))
										.cornerRadius(10)
								}
								.buttonStyle(.plain)
							}
						}.frame(width: geometry.size.width/2)
					}
				}
			}
		}
	}
}

struct Select_Status_2x1_Widgets: Widget {
	let kind: String = "Widgets"

	var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: Select_Status_2x1_Provider()) { entry in
			if #available(iOS 17.0, *) {
				Select_Status_2x1_WidgetsEntryView(entry: entry)
					.containerBackground(for: .widget) {
						LinearGradient(stops: [
							Gradient.Stop(color: Color("BlueOne"), location: 0.14),
							Gradient.Stop(color: Color("BlueTwo"), location: 0.53),
							Gradient.Stop(color: Color("GreenOne"), location: 0.87),
						], startPoint: .topTrailing, endPoint: .bottomLeading)
						
					}
			} else {
				Select_Status_2x1_WidgetsEntryView(entry: entry)
					.padding()
					.background(Color.gray.opacity(0.5))
			}
		}
		.configurationDisplayName("Select & Show Status")
		.description("Select from a list of status options. These options fill the bottom of the widget. The current status is displayed at the top.")
		.supportedFamilies([.systemMedium])
	}
}

#Preview(as: .systemMedium) {
	Select_Status_2x1_Widgets()
} timeline: {
	Select_Status_2x1_Entry(date: Date.now, status: LoadingState.success, statusData: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f334.png?v8")!), items: [
		StatusInformationImage(id: "1", name: "Coding", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f468-1f4bb.png?v8")!)),
		StatusInformationImage(id: "2", name: "In Class", emoji: "school_satchel", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f392.png?v8")!)),
		StatusInformationImage(id: "3", name: "Walking", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f6b6.png?v8")!))
	])
	Select_Status_2x1_Entry(date: Date.now, status: LoadingState.loading, items: [])
	Select_Status_2x1_Entry(date: Date.now, status: LoadingState.failed, items: [])
}

