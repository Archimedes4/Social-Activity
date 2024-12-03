//
//  Widgets.swift
//  Widgets
//
//  Created by Andrew Mainella on 2024-11-30.
//

import WidgetKit
import SwiftUI

struct Select_Status_2x2_Provider: TimelineProvider {
		func placeholder(in context: Context) -> Select_Status_2x2_Entry {
			Select_Status_2x2_Entry(date: Date.now, status: LoadingState.loading, entries: [])
		}

		func getSnapshot(in context: Context, completion: @escaping (Select_Status_2x2_Entry) -> ()) {
				let entry = Select_Status_2x2_Entry(date: Date.now, status: LoadingState.loading, entries: [])
				completion(entry)
		}

		func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
				var entries: [Select_Status_2x2_Entry] = []
			do {
				let imgData = try Data(
					contentsOf: URL(string: "https://avatars.githubusercontent.com/u/82121191?v=4")!
				)
				entries.append(Select_Status_2x2_Entry(date: Date.now, status: LoadingState.success, profile: UserData(fullName: "Andrew Mainella", advatar: "https://avatars.githubusercontent.com/u/82121191?v=4", pronouns: "he/him", username: "Archimedes4", status: nil), profileImage: UIImage(data: imgData), entries: []))
			} catch {
				entries.append(Select_Status_2x2_Entry(date: Date.now, status: LoadingState.failed, entries: []))
			}

				let timeline = Timeline(entries: entries, policy: .atEnd)
				completion(timeline)
		}

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct Select_Status_2x2_WidgetsEntryView : View {
	var entry: Select_Status_2x2_Provider.Entry
		var body: some View {
				VStack {
					if (entry.status == LoadingState.loading) {
						HStack {
							Rectangle()
								.frame(width: 100, height: 100)
								.clipShape(.rect(cornerRadius: 50))
								.blur(radius: 10)
								.foregroundStyle(.gray)
							RoundedRectangle(cornerRadius: 25)
								.frame(height: 40)
								.blur(radius: 10)
								.foregroundStyle(.gray)
							Spacer()
						}.frame(maxHeight: .infinity)
						RoundedRectangle(cornerRadius: 25)
							.frame(height: 40)
							.blur(radius: 10)
							.foregroundStyle(.gray)
						RoundedRectangle(cornerRadius: 25)
							.frame(height: 40)
							.blur(radius: 10)
							.foregroundStyle(.gray)
						RoundedRectangle(cornerRadius: 25)
							.frame(height: 40)
							.blur(radius: 10)
							.foregroundStyle(.gray)
						RoundedRectangle(cornerRadius: 25)
							.frame(height: 40)
							.blur(radius: 10)
							.foregroundStyle(.gray)
					} else if (entry.status == LoadingState.failed) {
						Image(systemName: "exclamationmark.circle")
							.resizable()
							.frame(width: 50, height: 50)
						Text("Something went wrong.")
					} else {
						HStack {
							if (entry.profileImage != nil) {
								Image(uiImage: entry.profileImage!)
									.resizable()
									.frame(width: 100, height: 100)
									.clipShape(.rect(cornerRadius: 50))
									.overlay(RoundedRectangle(cornerRadius: 50)
										.stroke(Color.black, lineWidth: 1))
							}
							Text("👋 Hello,\n Andrew Mainella")
								.padding(.leading)
							Spacer()
						}.frame(maxHeight: .infinity)
						Button(action: {}) {
							HStack {
								Text("Coding")
								Spacer()
							}.frame(maxWidth: .infinity)
						}
						Button(action: {}) {
							HStack {
								Text("In Class")
								Spacer()
							}.frame(maxWidth: .infinity)
						}
						Button(action: {}) {
							HStack {
								Text("Sleeping")
								Spacer()
							}.frame(maxWidth: .infinity)
						}
						Button(action: {}) {
							HStack {
								Text("Clear")
								Spacer()
							}.frame(maxWidth: .infinity)
						}
					}
				}
		}
}

struct Select_Status_2x2_Entry: TimelineEntry {
	var date: Date
	var status: LoadingState
	var profile: UserData?
	var profileImage: UIImage?
	var entries: [StatusInformation]
}

struct Select_Status_2x2_Widgets: Widget {
	let kind: String = "Widgets"

	var body: some WidgetConfiguration {
			StaticConfiguration(kind: kind, provider: Select_Status_2x2_Provider()) { entry in
					if #available(iOS 17.0, *) {
						Select_Status_2x2_WidgetsEntryView(entry: entry)
							.containerBackground(for: .widget) {
								LinearGradient(stops: [
									Gradient.Stop(color: Color("BlueOne"), location: 0.14),
									Gradient.Stop(color: Color("BlueTwo"), location: 0.53),
									Gradient.Stop(color: Color("GreenOne"), location: 0.87),
								], startPoint: .topTrailing, endPoint: .bottomLeading)
								
							}
					} else {
						Select_Status_2x2_WidgetsEntryView(entry: entry)
								.padding()
								.background() {
									LinearGradient(stops: [
										Gradient.Stop(color: Color("BlueOne"), location: 0.14),
										Gradient.Stop(color: Color("BlueTwo"), location: 0.53),
										Gradient.Stop(color: Color("GreenOne"), location: 0.87),
									], startPoint: .topTrailing, endPoint: .bottomLeading)
									
								}
					}
			}
			.configurationDisplayName("Select & Show Status")
			.description("Select from a list of status options. These options fill the bottom of the widget. The current status is displayed at the top.")
			.supportedFamilies([.systemLarge])
	}
}

#Preview(as: .systemLarge) {
	Select_Status_2x2_Widgets()
} timeline: {
	Select_Status_2x2_Entry(date: Date.now, status: LoadingState.success, profileImage: UIImage(data: try! Data(
		contentsOf: URL(string: "https://avatars.githubusercontent.com/u/82121191?v=4")!)), entries: [])
	Select_Status_2x2_Entry(date: Date.now, status: LoadingState.loading, entries: [])
	Select_Status_2x2_Entry(date: Date.now, status: LoadingState.failed, entries: [])
}

