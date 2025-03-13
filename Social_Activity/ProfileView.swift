//
//  ProfileView.swift
//  Social_Activity
//
//  Created by Andrew Mainella on 2024-11-24.
//

import SwiftUI

struct StatusPill: View {
	@State var isHover: Bool = false
	@State var url: String = ""
	@EnvironmentObject var homeData: HomeData
	@EnvironmentObject var geometryData: GeometryData
	@State private var timeRemaining = -1
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	
	var body: some View {
		VStack {
			HStack {
				if (homeData.profile?.status != nil) {
					AsyncImage(url: URL(string: url)) { image in
						image.resizable()
					} placeholder: {
						ProgressView()
							.scaleEffect(0.6)
					}
					.frame(width: 20, height: 20)
					.padding(.leading, isHover ? 15:0)
					if (isHover) {
						Text(homeData.profile?.status?.name ?? "")
							.padding(.trailing)
						if (homeData.profile?.status != nil && timeRemaining < 0) {
							Button(action: {
								Task {
									await clearStatus(token: homeData.token)
									homeData.checkStatus()
								}
							}) {
								Image(systemName: "xmark")
									.resizable()
									.frame(width: 15, height: 15)
									.foregroundStyle(.black)
									.padding(.trailing)
							}.buttonStyle(.plain)
						}
					}
				} else {
					Image(.smiley)
						.resizable()
						.frame(width: 20, height: 20)
						.padding(.leading, isHover ? 15:0)
					if (isHover) {
						Text("No Status Set")
							.padding(.trailing)
					}
				}
			}
			if (isHover && homeData.profile?.status != nil && timeRemaining >= 0) {
				HStack {
					Text(timeString(time: timeRemaining, expiresAt: homeData.profile?.status?.expiresAt))
						.padding(.leading)
					Spacer()
					Button(action: {
						Task {
							await clearStatus(token: homeData.token)
							homeData.checkStatus()
						}
					}) {
						Image(systemName: "xmark")
							.resizable()
							.frame(width: 15, height: 15)
							.foregroundStyle(.black)
							.padding(.trailing)
					}.buttonStyle(.plain)
				}
			}
		}.frame(width: isHover ? 200:38, height: (isHover && homeData.profile?.status != nil) ? 68:38)
		.onHover() { hovering in
			isHover = hovering
		}
		.background(.white)
		.clipShape(.rect(cornerRadius: 19))
		.overlay(RoundedRectangle(cornerRadius: 19)
		.stroke(Color.black, lineWidth: 1))
		.position(x: 115 + geometryData.size.width * 0.2, y: 275)
		.zIndex(2)
		.onAppear() {
			do {
				url = try homeData.getUrl(emoji: homeData.profile?.status?.emoji ?? "")
			} catch {
				
			}
		}
		.onChange(of: homeData.profile?.status?.emoji) {
			do {
				url = try homeData.getUrl(emoji: homeData.profile?.status?.emoji ?? "")
			} catch {
				
			}
		}
		.onReceive(timer) { _ in
			if (homeData.profile != nil && homeData.profile?.status?.expiresAt != nil) {
				timeRemaining = Int(homeData.profile?.status?.expiresAt!.timeIntervalSinceNow ?? 0)
				if (Int(homeData.profile?.status?.expiresAt!.timeIntervalSinceNow ?? 0) == 0) {
					homeData.checkStatus()
				}
			} else {
				timeRemaining = -1
			}
		}
	}
}

struct ProfileView: View {
	@EnvironmentObject var homeData: HomeData
	
	var body: some View {
		ContainerView() {
			if (homeData.profile != nil) {
				AsyncImage(url: URL(string: homeData.profile!.advatar)) { image in
					image.resizable()
				} placeholder: {
					ProgressView()
				}
				.frame(width: 296, height: 296)
				.clipShape(.rect(cornerRadius: 296))
				.overlay(RoundedRectangle(cornerRadius: 148)
				.stroke(Color.black, lineWidth: 1))
				.padding()
				HStack {
					Text(homeData.profile!.fullName)
						.font(.system(size: 24))
						.fontWeight(.semibold)
						.padding(.leading)
						.foregroundStyle(.black)
					Spacer()
				}
				HStack {
					Text("\(homeData.profile!.username) · he/him")
						.font(.system(size: 24))
						.foregroundStyle(Color("GitHubGray"))
						.fontWeight(.light)
						.padding([.bottom, .leading])
					Spacer()
				}
			} else {
				VStack {
					ProgressView()
				}.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
		}
	}
}
