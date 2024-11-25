//
//  SettingsView.swift
//  Social_Activity
//
//  Created by Andrew Mainella on 2024-11-24.
//

import SwiftUI

struct SettingsView: View {
	@State var geometry: GeometryProxy
	@State var appPasswordProtected: Bool = false
	@State var staySignedIn: Bool = true
		
	init (for metrics: GeometryProxy) {
		self.geometry = metrics
	}
	var body: some View {
		ZStack {
			VStack (spacing: 0) {
				HStack {
					Image(systemName: "gearshape.fill")
						.resizable()
						.frame(width: 30, height: 30)
					Text("Settings")
						.font(Font.custom("Nunito-Regular", size: 32))
					Spacer()
				}
				HStack {
					Image(systemName: "lock.app.dashed")
						.resizable()
						.frame(width: 25, height: 25)
						.aspectRatio(contentMode: .fit)
					Text("App is password protected?")
						.font(Font.custom("Nunito-Regular", size: 20))
					Toggle("", isOn: $appPasswordProtected)
						.toggleStyle(.switch)
						.padding(.vertical)
					Spacer()
				}.frame(height: 30)
				HStack {
					Image(systemName: "lock.open.rotation")
						.resizable()
						.frame(width: 25, height: 25)
						.aspectRatio(contentMode: .fit)
					Text("Stay signed into GitHub?")
						.font(Font.custom("Nunito-Regular", size: 20))
					Toggle("", isOn: $staySignedIn)
						.toggleStyle(.switch)
						.padding(.vertical)
					Spacer()
				}
				HStack {
					Image(systemName: "rectangle.portrait.and.arrow.right")
						.resizable()
						.frame(width: 25, height: 25)
						.aspectRatio(contentMode: .fit)
					Text("Sign Out")
						.font(Font.custom("Nunito-Regular", size: 20))
					Spacer()
				}
			}
			.padding(10)
			.frame(width: geometry.size.width * 0.4)
			.background(.white)
			.cornerRadius(12)
			.overlay(alignment: .center) {
				RoundedRectangle(cornerRadius: 10)
					.strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
					.cornerRadius(10)
					.frame(width: geometry.size.width * 0.4)
			}
		}.padding()
	}
}
