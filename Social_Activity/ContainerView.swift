//
//  ContainerView.swift
//  Social_Activity
//
//  Created by Andrew Mainella on 2025-03-10.
//

import SwiftUI

struct ContainerView<Content: View>: View {
	@EnvironmentObject var geometryData: GeometryData
	let content: Content
	init (@ViewBuilder content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		VStack(spacing: 0) {
			content
		}
		.padding(10)
		.frame(width: (geometryData.size.width * (geometryData.state != .small ? 0.4:1)) - (geometryData.state != .small ? 30:0))
		.background(.white)
		.cornerRadius(12)
		.overlay(alignment: .center) {
			RoundedRectangle(cornerRadius: 10)
				.strokeBorder(.black, style: StrokeStyle(lineWidth: 3, dash: [.greatestFiniteMagnitude]))
				.cornerRadius(10)
				.frame(width: (geometryData.size.width * (geometryData.state != .small ? 0.4:1)) - (geometryData.state != .small ? 30:0))
		}
		.padding(.horizontal, 15)
		.padding(.bottom, 15)
	}
}
