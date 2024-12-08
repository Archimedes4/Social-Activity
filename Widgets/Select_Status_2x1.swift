//
//  Widgets.swift
//  Widgets
//
//  Created by Andrew Mainella on 2024-11-30.
//

import WidgetKit
import SwiftUI

struct Select_Status_2x1_WidgetsEntryView : View {
	var entry: Select_Status_Provider.Entry
	
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
							ForEach(entry.items, id: \.id) { item in
								Button(action: {
									
								}) {
									HStack {
										Image(uiImage: UIImage(data: item.emojiData)!)
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

#Preview(as: .systemMedium) {
	Select_Status_Widgets()
} timeline: {
	Select_Status_Entry(date: Date.now, status: LoadingState.success, statusData: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f334.png?v8")!), items: [
		StatusInformationImage(id: "1", name: "Coding", emoji: "man_technologist", emojiData: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f468-1f4bb.png?v8")!)),
		StatusInformationImage(id: "2", name: "In Class", emoji: "school_satchel", emojiData: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f392.png?v8")!)),
		StatusInformationImage(id: "3", name: "Walking", emoji: "man_technologist", emojiData: try! Data(contentsOf: URL(string: "https://github.githubassets.com/images/icons/emoji/unicode/1f6b6.png?v8")!))
	])
	Select_Status_Entry(date: Date.now, status: LoadingState.loading, items: [])
	Select_Status_Entry(date: Date.now, status: LoadingState.failed, items: [])
}

