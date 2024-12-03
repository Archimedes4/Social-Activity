//
//  Widgets.swift
//  Widgets
//
//  Created by Andrew Mainella on 2024-11-30.
//

import WidgetKit
import SwiftUI

struct Select_Full_2x1_Provider: TimelineProvider {
		func placeholder(in context: Context) -> Select_Full_2x1_Entry {
			Select_Full_2x1_Entry(date: Date.now, status: LoadingState.loading, items: [])
		}

		func getSnapshot(in context: Context, completion: @escaping (Select_Full_2x1_Entry) -> ()) {
				let entry = Select_Full_2x1_Entry(date: Date.now, status: LoadingState.loading, items: [])
				completion(entry)
		}

		func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
				var entries: [Select_Full_2x1_Entry] = []

			entries.append(Select_Full_2x1_Entry(date: Date.now, status: LoadingState.loading, items: []))

				let timeline = Timeline(entries: entries, policy: .atEnd)
				completion(timeline)
		}

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct Select_Full_2x1_Button: View {
	var item: StatusInformationImage
	@State var geometry: GeometryProxy
	
	init (for metrics: GeometryProxy, item: StatusInformationImage) {
		self.geometry = metrics
		self.item = item
	}
	var body: some View {
		Button(action: {
			
		}) {
			Image(uiImage: UIImage(data: item.emojiImage)!)
				.resizable()
				.frame(width: 20, height: 20)
				.padding()
		}
		.frame(width: geometry.size.height * 0.45, height: geometry.size.height * 0.45)
		.background(.white)
		.cornerRadius(geometry.size.width/3)
		.overlay(alignment: .center) {
			RoundedRectangle(cornerRadius: geometry.size.height * 0.45)
				.strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [.greatestFiniteMagnitude]))
				.cornerRadius(10)
		}
		.buttonStyle(.plain)
	}
}

struct Select_Full_2x1_Entry: TimelineEntry {
	var date: Date
	var status: LoadingState
	var profile: UserData?
	var items: [StatusInformationImage]
}

struct Select_Full_2x1_WidgetsEntryView : View {
	var entry: Select_Full_2x1_Provider.Entry

	var body: some View {
		VStack {
			GeometryReader { geometry in
				if (entry.status == LoadingState.loading) {
					VStack {
						HStack() {
							Spacer()
							RoundedRectangle(cornerRadius: geometry.size.width/2)
								.frame(width: geometry.size.width/6, height: geometry.size.width/6)
								.blur(radius: 10)
								.foregroundStyle(.gray.opacity(0.8))
							Spacer()
							RoundedRectangle(cornerRadius: geometry.size.width/2)
								.frame(width: geometry.size.width/6, height: geometry.size.width/6)
								.blur(radius: 10)
								.foregroundStyle(.gray.opacity(0.8))
							Spacer()
							RoundedRectangle(cornerRadius: geometry.size.width/2)
								.frame(width: geometry.size.width/6, height: geometry.size.width/6)
								.blur(radius: 10)
								.foregroundStyle(.gray.opacity(0.8))
							Spacer()
						}
						Spacer()
						HStack() {
							Spacer()
							RoundedRectangle(cornerRadius: geometry.size.width/2)
								.frame(width: geometry.size.width/6, height: geometry.size.width/6)
								.blur(radius: 10)
								.foregroundStyle(.gray.opacity(0.8))
							Spacer()
							RoundedRectangle(cornerRadius: geometry.size.width/2)
								.frame(width: geometry.size.width/6, height: geometry.size.width/6)
								.blur(radius: 10)
								.foregroundStyle(.gray.opacity(0.8))
							Spacer()
							RoundedRectangle(cornerRadius: geometry.size.width/2)
								.frame(width: geometry.size.width/6, height: geometry.size.width/6)
								.blur(radius: 10)
								.foregroundStyle(.gray.opacity(0.8))
							Spacer()
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
					VStack(alignment: .center, spacing: 0) {
						HStack {
							ForEach(entry.items[0 ..< min(4, entry.items.count)]) { item in
								Select_Full_2x1_Button(for: geometry, item: item)
									.padding(3)
							}
							if (entry.items.count < 4) {
								Spacer()
							}
						}.frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.45)
						Spacer()
						if (entry.items.count > 4) {
							HStack {
								ForEach(entry.items[4 ..< min(entry.items.count, 8)]) { item in
									Select_Full_2x1_Button(for: geometry, item: item)
										.padding(3)
								}
								if (entry.items.count < 8) {
									Spacer()
								}
							}.frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.45)
						}
					}.frame(width: geometry.size.width)
				}
			}
		}
	}
}

struct Select_Full_2x1_Widgets: Widget {
	let kind: String = "Widgets"

	var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: Select_Full_2x1_Provider()) { entry in
			if #available(iOS 17.0, *) {
				Select_Full_2x1_WidgetsEntryView(entry: entry)
					.containerBackground(for: .widget) {
						LinearGradient(stops: [
							Gradient.Stop(color: Color("BlueOne"), location: 0.14),
							Gradient.Stop(color: Color("BlueTwo"), location: 0.53),
							Gradient.Stop(color: Color("GreenOne"), location: 0.87),
						], startPoint: .topTrailing, endPoint: .bottomLeading)
						
					}
			} else {
				Select_Full_2x1_WidgetsEntryView(entry: entry)
					.padding()
					.background()
			}
		}
		.configurationDisplayName("Select Status")
		.description("Select from a list of status options. These options fill the entire screen.")
		.supportedFamilies([.systemMedium])
	}
}

#Preview(as: .systemMedium) {
	Select_Full_2x1_Widgets()
} timeline: {
	Select_Full_2x1_Entry(date: Date.now, status: LoadingState.loading, items: [])
	Select_Full_2x1_Entry(date: Date.now, status: LoadingState.success, items: [
		StatusInformationImage(id: "1", name: "Coding", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f468-1f4bb.png?v8")!)),
		StatusInformationImage(id: "2", name: "In Class", emoji: "school_satchel", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f392.png?v8")!)),
		StatusInformationImage(id: "3", name: "Walking", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f6b6.png?v8")!)),
		StatusInformationImage(id: "4", name: "Sleeping", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f634.png?v8")!)),
		StatusInformationImage(id: "5", name: "Atom", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/atom.png?v8")!)),
		StatusInformationImage(id: "6", name: "Walking", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f334.png?v8")!)),
		StatusInformationImage(id: "7", name: "Walking", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f914.png?v8")!)),
		StatusInformationImage(id: "8", name: "Walking", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f6b6.png?v8")!)),
		StatusInformationImage(id: "9", name: "Walking", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f6b6.png?v8")!)),
		StatusInformationImage(id: "10", name: "Sleeping", emoji: "man_technologist", emojiImage: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f634.png?v8")!))
	])
	Select_Full_2x1_Entry(date: Date.now, status: LoadingState.failed, items: [])
}

