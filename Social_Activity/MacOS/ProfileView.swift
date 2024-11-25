//
//  ProfileView.swift
//  Social_Activity
//
//  Created by Andrew Mainella on 2024-11-24.
//

import SwiftUI

struct ProfileView: View {
	@State var geometry: GeometryProxy
	
	init (for metrics: GeometryProxy) {
		self.geometry = metrics
	}
	
	var body: some View {
		ZStack {
			VStack {
				AsyncImage(url: URL(string: "https://avatars.githubusercontent.com/u/82121191?v=4")) { image in
					image.resizable()
				} placeholder: {
					Color.red
				}
				.frame(width: 296, height: 296)
				.clipShape(.rect(cornerRadius: 296))
				.padding()
				HStack {
					Text("Andrew Mainella")
						.font(.system(size: 24))
						.fontWeight(.semibold)
						.padding(.leading)
					Spacer()
				}
				HStack {
					Text("Archimedes4 · he/him")
						.font(.system(size: 24))
						.foregroundStyle(Color("GitHubGray"))
						.fontWeight(.light)
						.padding([.bottom, .leading])
					Spacer()
				}
			}
			.frame(width: geometry.size.width * 0.4)
			.background(.white)
			.cornerRadius(12)
			.overlay(alignment: .center) {
				RoundedRectangle(cornerRadius: 10)
					.strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
					.cornerRadius(10)
					.frame(width: geometry.size.width * 0.4)
			}
		}
	}
}
