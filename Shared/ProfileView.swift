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
	var body: some View {
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
		}.frame(width: isHover ? nil:38, height: 38)
		.background(.white)
		.clipShape(.rect(cornerRadius: 19))
		.overlay(RoundedRectangle(cornerRadius: 19)
		.stroke(Color.black, lineWidth: 1))
		.position(x: 260, y: 245)
		.zIndex(2)
		.onHover() { hovering in
			isHover = hovering
		}
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
	}
}

struct ProfileView: View {
	@State var geometry: GeometryProxy
	@EnvironmentObject var homeData: HomeData
	
	init (for metrics: GeometryProxy) {
		self.geometry = metrics
	}
	
	var body: some View {
		ZStack {
			VStack {
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
					.overlay(StatusPill())
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
			.frame(width: (geometry.size.width * (geometry.size.width >= 600 ? 0.4:1)) - (geometry.size.width >= 600 ? 0:20))
			.background(.white)
			.cornerRadius(12)
			.overlay(alignment: .center) {
				RoundedRectangle(cornerRadius: 10)
					.strokeBorder(.black, style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
					.cornerRadius(10)
					.frame(width: (geometry.size.width * (geometry.size.width >= 600 ? 0.4:1)) - (geometry.size.width >= 600 ? 0:20))
			}
			.padding(.horizontal)
		}
	}
}
