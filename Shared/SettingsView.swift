//
//  SettingsView.swift
//  Social_Activity
//
//  Created by Andrew Mainella on 2024-11-24.
//

import SwiftUI
import FirebaseAuth

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
					Spacer()
					Toggle("", isOn: $appPasswordProtected)
						.toggleStyle(.switch)
						.padding(.vertical)
						.labelsHidden()
				}.frame(height: 30)
				HStack {
					Image(systemName: "lock.open.rotation")
						.resizable()
						.frame(width: 25, height: 25)
						.aspectRatio(contentMode: .fit)
					Text("Stay signed into GitHub?")
						.font(Font.custom("Nunito-Regular", size: 20))
					Spacer()
					Toggle("", isOn: $staySignedIn)
						.toggleStyle(.switch)
						.padding(.vertical)
						.labelsHidden()
				}
				Button(action: {
					let firebaseAuth = Auth.auth()
					do {
						try firebaseAuth.signOut()
					} catch let signOutError as NSError {
						print("Error signing out: %@", signOutError)
					}
				}) {
					HStack {
						Image(systemName: "rectangle.portrait.and.arrow.right")
							.resizable()
							.frame(width: 25, height: 25)
							.aspectRatio(contentMode: .fit)
							.foregroundStyle(.black)
						Text("Sign Out")
							.font(Font.custom("Nunito-Regular", size: 20))
							.foregroundStyle(.black)
						Spacer()
					}
				}
				.buttonStyle(.plain)
			}
			.padding(10)
			.frame(width: (geometry.size.width * (geometry.size.width >= 600 ? 0.4:1)) - (geometry.size.width >= 600 ? 0:20))
			.background(.white)
			.cornerRadius(12)
			.overlay(alignment: .center) {
				RoundedRectangle(cornerRadius: 10)
					.strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
					.cornerRadius(10)
					.frame(width: (geometry.size.width * (geometry.size.width >= 600 ? 0.4:1)) - (geometry.size.width >= 600 ? 0:20))
			}
			.onAppear() {
				
			}
		}.padding()
	}
}
