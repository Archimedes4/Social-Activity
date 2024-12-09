//
//  Select_Status.swift
//  WidgetsExtension
//
//  Created by Andrew Mainella on 2024-12-05.
//

import WidgetKit
import SwiftUI
import FirebaseAuth
import FirebaseCore

struct Select_Status_Provider: TimelineProvider {
		func placeholder(in context: Context) -> Select_Status_Entry {
			Select_Status_Entry(date: Date(), status: LoadingState.loading, items: [])
		}

		func getSnapshot(in context: Context, completion: @escaping (Select_Status_Entry) -> ()) {
			let entry = Select_Status_Entry(date: Date(), status: LoadingState.loading, items: [])
			completion(entry)
		}

	func getTimeline(in context: Context, completion: @escaping (Timeline<Select_Status_Entry>) -> ()) {
			var entries: [Select_Status_Entry] = []
			entries.append(Select_Status_Entry(date: .now, status: LoadingState.failed, items: []))
		
			let timeline = Timeline(entries: entries, policy: .atEnd)
			completion(timeline)
		}

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct Select_Status_Entry: TimelineEntry {
	var date: Date
	var status: LoadingState
	var profile: UserData?
	var statusData: Data?
	var profileData: Data?
	var items: [StatusInformationImage]
}

struct Select_Status_WidgetsEntryView: View {
	var entry: Select_Status_Provider.Entry
	@Environment(\.widgetFamily) var widgetFamily

	var body: some View {
		switch widgetFamily {
		case .systemSmall:
			Select_Status_1x1_WidgetsEntryView(entry: entry)
		case .systemMedium:
			Select_Status_2x1_WidgetsEntryView(entry: entry)
		case .systemLarge:
			Select_Status_2x2_WidgetsEntryView(entry: entry)
		default:
			Select_Status_1x1_WidgetsEntryView(entry: entry)
		}
	}
}

struct Select_Status_Widgets: Widget {
	let kind: String = "Widgets"

	var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: Select_Status_Provider()) { entry in
			if #available(iOS 17.0, *) {
				Select_Status_WidgetsEntryView(entry: entry)
					.containerBackground(for: .widget) {
						LinearGradient(stops: [
							Gradient.Stop(color: Color("BlueOne"), location: 0.14),
							Gradient.Stop(color: Color("BlueTwo"), location: 0.53),
							Gradient.Stop(color: Color("GreenOne"), location: 0.87),
						], startPoint: .topTrailing, endPoint: .bottomLeading)
						
					}
			} else {
				Select_Status_WidgetsEntryView(entry: entry)
					.padding()
					.background()
			}
		}
		.configurationDisplayName("Select & Show Status")
		.description("Select from a list of status options. These options fill the bottom of the widget. The current status is displayed at the top.")
		.supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
	}
}
