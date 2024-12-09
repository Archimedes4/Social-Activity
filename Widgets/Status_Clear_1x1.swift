//
//  Widgets.swift
//  Widgets
//
//  Created by Andrew Mainella on 2024-11-30.
//

import WidgetKit
import SwiftUI

struct Status_Clear_1x1_Provider: TimelineProvider {
		func placeholder(in context: Context) -> Select_Clear_Entry {
			Select_Clear_Entry(date: Date.now, status: LoadingState.loading)
		}

		func getSnapshot(in context: Context, completion: @escaping (Select_Clear_Entry) -> ()) {
			let entry = Select_Clear_Entry(date: Date.now, status: LoadingState.loading)
			completion(entry)
		}

		func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
				var entries: [Select_Clear_Entry] = []

				let timeline = Timeline(entries: entries, policy: .atEnd)
				completion(timeline)
		}

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct Select_Clear_Entry: TimelineEntry {
	var date: Date
	var status: LoadingState
	var profile: UserData?
	var statusData: Data?
	var profileData: Data?
}

struct Status_Clear_1x1_WidgetsEntryView : View {
	var entry: Status_Clear_1x1_Provider.Entry

	var body: some View {
		VStack {
			GeometryReader { geometry in
				if (entry.status == LoadingState.failed) {
					VStack(alignment: .center) {
						Spacer()
						Image(systemName: "exclamationmark.circle")
							.resizable()
							.frame(width: 50, height: 50)
							.foregroundStyle(.white)
						Text("Something went wrong")
							.foregroundStyle(.white)
							.minimumScaleFactor(0.5)
							.lineLimit(1)
						Spacer()
					}.frame(width: geometry.size.width)
				} else if (entry.status == LoadingState.loading) {
					VStack {
						RoundedRectangle(cornerRadius: geometry.size.width/2)
							.blur(radius: 10)
							.foregroundStyle(.gray.opacity(0.8))
							.aspectRatio(contentMode: .fit)
						RoundedRectangle(cornerRadius: 15)
							.blur(radius: 10)
							.foregroundStyle(.gray.opacity(0.8))
							.frame(height: 25)
					}.frame(width: geometry.size.height, height: geometry.size.height)
				} else {
					if (entry.statusData != nil) {
						VStack {
							Image(uiImage: UIImage(data: entry.statusData!)!)
								.resizable()
								.aspectRatio(contentMode: .fit)
							Text("In Class")
						}.frame(width: geometry.size.height, height: geometry.size.height)
						.overlay(alignment: .topLeading) {
							Button(action: {}) {
								HStack {
									Image(systemName: "xmark")
								}.padding(6)
							}
							.background(.white)
							.cornerRadius(20)
							.overlay(alignment: .center) {
								RoundedRectangle(cornerRadius: 20)
									.strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [.greatestFiniteMagnitude]))
									.cornerRadius(10)
							}
							.buttonStyle(.plain)
						}
					} else if (entry.profileData != nil) {
						VStack(alignment: .center) {
							Image(uiImage: UIImage(data: entry.profileData!)!)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.clipShape(.rect(cornerRadius: geometry.size.width/2))
								.overlay(RoundedRectangle(cornerRadius: geometry.size.width/2)
													 .stroke(Color.black, lineWidth: 1))
							Text("Archimedes4")
						}.frame(width: geometry.size.height, height: geometry.size.height)
					}
				}
			}
		}
	}
}

struct Status_Clear_1x1_Widgets: Widget {
	let kind: String = "Widgets"

	var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: Status_Clear_1x1_Provider()) { entry in
			if #available(iOS 17.0, *) {
				Status_Clear_1x1_WidgetsEntryView(entry: entry)
					.containerBackground(for: .widget) {
						LinearGradient(stops: [
							Gradient.Stop(color: Color("BlueOne"), location: 0.14),
							Gradient.Stop(color: Color("BlueTwo"), location: 0.53),
							Gradient.Stop(color: Color("GreenOne"), location: 0.87),
						], startPoint: .topTrailing, endPoint: .bottomLeading)
						
					}
			} else {
				Status_Clear_1x1_WidgetsEntryView(entry: entry)
					.padding()
					.background()
			}
		}
		.configurationDisplayName("Status Clear")
		.description("This is an example widget.")
		.supportedFamilies([.systemSmall])
	}
}

#Preview(as: .systemSmall) {
	Status_Clear_1x1_Widgets()
} timeline: {
	Select_Clear_Entry(date: Date.now, status: LoadingState.success, statusData: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f392.png?v8")!), profileData: try! Data(contentsOf: URL(string: "https://avatars.githubusercontent.com/u/82121191?v=4")!))
	Select_Clear_Entry(date: Date.now, status: LoadingState.success, profileData: try! Data(contentsOf: URL(string: "https://avatars.githubusercontent.com/u/82121191?v=4")!))
	Select_Clear_Entry(date: Date.now, status: LoadingState.loading)
	Select_Clear_Entry(date: Date.now, status: LoadingState.failed)
}

