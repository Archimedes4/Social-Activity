//
//  Widgets.swift
//  Widgets
//
//  Created by Andrew Mainella on 2024-11-30.
//

import WidgetKit
import SwiftUI
import FirebaseAuth

struct Select_Full_Provider: TimelineProvider {
		func placeholder(in context: Context) -> Select_Full_Entry {
			Select_Full_Entry(date: Date(), status: LoadingState.loading, items: [])
		}

		func getSnapshot(in context: Context, completion: @escaping (Select_Full_Entry) -> ()) {
			let entry = Select_Full_Entry(date: Date(), status: LoadingState.loading, items: [])
			completion(entry)
		}

		func getTimeline(in context: Context, completion: @escaping (Timeline<Select_Full_Entry>) -> ()) {
			var entries: [Select_Full_Entry] = []
			print(Auth.auth().currentUser)
			
			let timeline = Timeline(entries: entries, policy: .atEnd)
			completion(timeline)
		}

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct Select_Full_Entry: TimelineEntry {
	var date: Date
	var status: LoadingState
	var profile: UserData? //Needed to hide the current status from the options
	var items: [StatusInformationImage]
}

struct Select_Full_WidgetsEntryView : View {
	var entry: Select_Full_Provider.Entry
	@Environment(\.widgetFamily) var widgetFamily

	var body: some View {
		switch widgetFamily {
		case .systemSmall:
			Select_Full_1x1_WidgetsEntryView(entry: entry)
		case .systemMedium:
			Select_Full_2x1_WidgetsEntryView(entry: entry)
		default:
			Select_Full_1x1_WidgetsEntryView(entry: entry)
		}
	}
}

struct Select_Full_Widgets: Widget {
	let kind: String = "Widgets"

	var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: Select_Full_Provider()) { entry in
			if #available(iOS 17.0, *) {
				Select_Full_WidgetsEntryView(entry: entry)
					.containerBackground(for: .widget) {
						LinearGradient(stops: [
							Gradient.Stop(color: Color("BlueOne"), location: 0.14),
							Gradient.Stop(color: Color("BlueTwo"), location: 0.53),
							Gradient.Stop(color: Color("GreenOne"), location: 0.87),
						], startPoint: .topTrailing, endPoint: .bottomLeading)
					}
			} else {
				Select_Full_WidgetsEntryView(entry: entry)
					.padding()
					.background()
			}
		}
		.configurationDisplayName("Select Status")
		.description("Select from a list of status options. These options fill the entire screen.")
		.supportedFamilies([.systemSmall, .systemMedium])
	}
}

#Preview(as: .systemSmall) {
	Select_Full_Widgets()
} timeline: {
	Select_Full_Entry(date: Date.now, status: LoadingState.success, items: [
		StatusInformationImage(id: "1", name: "Coding", emoji: "man_technologist", emojiData: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f468-1f4bb.png?v8")!)),
	StatusInformationImage(id: "2", name: "In Class", emoji: "school_satchel", emojiData: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f392.png?v8")!)),
	StatusInformationImage(id: "3", name: "Walking", emoji: "man_technologist", emojiData: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f6b6.png?v8")!))
	])
	Select_Full_Entry(date: Date.now, status: LoadingState.loading, items: [])
	Select_Full_Entry(date: Date.now, status: LoadingState.failed, items: [])
}


