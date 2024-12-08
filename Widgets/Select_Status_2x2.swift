//
//  Widgets.swift
//  Widgets
//
//  Created by Andrew Mainella on 2024-11-30.
//

import WidgetKit
import SwiftUI

struct Select_Status_2x2_WidgetsEntryView : View {
	var entry: Select_Status_Provider.Entry
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
					if (entry.profileData != nil) {
						Image(uiImage: UIImage(data: entry.profileData!)!)
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

#Preview(as: .systemLarge) {
	Select_Status_Widgets()
} timeline: {
	Select_Status_Entry(date: Date.now, status: LoadingState.success, profileData: try! Data(
		contentsOf: URL(string: "https://avatars.githubusercontent.com/u/82121191?v=4")!), items: [])
	Select_Status_Entry(date: Date.now, status: LoadingState.loading, items: [])
	Select_Status_Entry(date: Date.now, status: LoadingState.failed, items: [])
}

