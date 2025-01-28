//
//  SettingsView.swift
//  Social_Activity
//
//  Created by Andrew Mainella on 2024-11-24.
//

import SwiftUI
import FirebaseAuth

struct DeviceBlock: View {
	let device: Device
	@EnvironmentObject var notificationManager: NotificationManager
	
	func getImage() -> String {
		if (device.type == .iPhone) {
			return "iphone.gen3"
		}
		if (device.type == .iPad) {
			return "ipad"
		}
		if (device.type == .macOSDesktop) {
			return "desktopcomputer"
		}
		if (device.type == .macOSLaptop) {
			return "laptopcomputer"
		}
		return "laptopcomputer"
	}
	
	var body: some View {
		VStack {
			HStack {
				Image(systemName: getImage())
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 35, height: 35)
					.foregroundStyle(.black)
				Text((notificationManager.fcmToken == device.fcmToken) ? "This device":device.name)
					.foregroundStyle(.black)
				Spacer()
				if (notificationManager.fcmToken == device.fcmToken) {
					Button(action: {
						Task {
							Alert(title: Text("Are you sure?"), message: Text("Do you want to stop receiving notifications on this device?"), dismissButton: .cancel())
							
							await notificationManager.request()
						}
					}) {
						Image(systemName: "bell.slash")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 25, height: 25)
							.foregroundStyle(.black)
					}
				}
			}
			HStack {
				Text(getDeviceTimeText(time: device.lastUpdated))
					.foregroundStyle(.black)
				// Last updated today at 8:43 PM
				// Last updated Jan 23 2024 at 8:43 AM
				Spacer()
			}
		}
		.padding()
		.overlay(alignment: .center) {
			RoundedRectangle(cornerRadius: 10)
				.strokeBorder(.black, style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
				.cornerRadius(10)
		}
	}
}

struct DevicesView: View {
	@EnvironmentObject var notificationManager: NotificationManager
	@State var deviceState: LoadingState = LoadingState.loading
	@State var devices: [Device] = []
	
	var body: some View {
		LazyVStack {
			if (notificationManager.hasPermission == false) {
				Button(action: {
					Task {
						await notificationManager.request()
					}
				}) {
					HStack {
						Image(systemName: "bell")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 25, height: 25)
							.foregroundStyle(.black)
						Text("Request Notifications")
							.foregroundStyle(.black)
						Spacer()
					}
					.padding()
					.frame(maxWidth: .infinity)
					.overlay(alignment: .center) {
						RoundedRectangle(cornerRadius: 10)
							.strokeBorder(.black, style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
							.cornerRadius(10)
					}
				}.buttonStyle(.plain)
			}
			if (deviceState == LoadingState.loading) {
				ProgressView()
			} else if (deviceState == LoadingState.failed) {
				Text("Something went wrong!")
			} else {
				ForEach(devices, id: \.fcmToken) { device in
					DeviceBlock(device: device)
				}
			}
		}.onAppear() {
			Task {
				do {
					devices = try await getDevices()
					deviceState = LoadingState.success
				} catch {
					deviceState = LoadingState.failed
				}
			}
		}
	}
}

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
			VStack(spacing: 0) {
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
				HStack {
					Image(systemName: "laptopcomputer.and.iphone")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 50, height: 50)
						.foregroundStyle(.black)
					Text("Devices")
						.font(Font.custom("Nunito-Regular", size: 32))
						.foregroundStyle(.black)
					Spacer()
				}.padding(.top, 5)
				DevicesView()
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
