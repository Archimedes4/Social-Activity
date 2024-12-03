//
//  ProfileView.swift
//  Social_Activity
//
//  Created by Andrew Mainella on 2024-11-24.
//

import SwiftUI

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
						Color.red
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
				}
			}
			.frame(width: (geometry.size.width * (geometry.size.width >= 600 ? 0.4:1)) - (geometry.size.width >= 600 ? 0:20))
			.background(.white)
			.cornerRadius(12)
			.overlay(alignment: .center) {
				RoundedRectangle(cornerRadius: 10)
					.strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
					.cornerRadius(10)
					.frame(width: (geometry.size.width * (geometry.size.width >= 600 ? 0.4:1)) - (geometry.size.width >= 600 ? 0:20))
			}
			.padding(.horizontal)
		}
	}
}
