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
	@EnvironmentObject var homeData: HomeData

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
						.foregroundStyle(.black)
					Text("Settings")
						.font(Font.custom("Nunito-Regular", size: 32))
						.foregroundStyle(.black)
					Spacer()
				}
				HStack {
					Image(systemName: "lock.app.dashed")
						.resizable()
						.frame(width: 25, height: 25)
						.aspectRatio(contentMode: .fit)
						.foregroundStyle(.black)
					Text("App is password protected?")
						.font(Font.custom("Nunito-Regular", size: 20))
						.foregroundStyle(.black)
						.minimumScaleFactor(0.5)
					Spacer()
					Toggle("", isOn: $appPasswordProtected)
						.toggleStyle(.switch)
						.padding(.vertical)
						.labelsHidden()
				}.frame(height: 30)
				HStack {
					Image(systemName: "lock.open.rotation")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 25, height: 25)
						.foregroundStyle(.black)
					Text("Stay signed into GitHub?")
						.font(Font.custom("Nunito-Regular", size: 20))
						.foregroundStyle(.black)
						.minimumScaleFactor(0.5)
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
							.minimumScaleFactor(0.5)
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
					.strokeBorder(.black, style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
					.cornerRadius(10)
					.frame(width: (geometry.size.width * (geometry.size.width >= 600 ? 0.4:1)) - (geometry.size.width >= 600 ? 0:20))
			}
			.onAppear() {
				// Get the value if the token is being saved.
				let protectedVal = KeychainService().retriveSecret(id: "protected")
				if (protectedVal == "protected") {
					appPasswordProtected = true
				} else {
					appPasswordProtected = false
				}
				let tokenVal = KeychainService().retriveSecret(id: "gitauth")
				if (tokenVal == "no-persistence") {
					staySignedIn = false
				} else {
					staySignedIn = true
				}
			}
			.onChange(of: appPasswordProtected, initial: false) {
				if (appPasswordProtected) {
					KeychainService().save("protected", for: "protected")
				} else {
					KeychainService().save("not-protected", for: "protected")
				}
			}.onChange(of: staySignedIn, initial: false) {
				if (staySignedIn) {
					KeychainService().save(homeData.token, for: "gitauth")
				} else {
					KeychainService().save("no-persistence", for: "gitauth")
				}
			}
		}.padding()
	}
}
