//
//  GeometryData.swift
//  Social_Activity
//
//  A model for holding geometry data
//
//  Created by Andrew Mainella on 2025-03-10.
//

import SwiftUI

class GeometryData: ObservableObject  {
	@Published public var size: CGSize = CGSize(width: 100, height: 100)
	@Published public var state: dimensionMode = .small
	
	// Function to update state based on width
	func updateSize(newSize: CGSize) {
		DispatchQueue.main.async {
			self.size = newSize
			if (newSize.width >= 600 && newSize.height >= 800) {
				self.state = dimensionMode.large
			} else if (newSize.width >= 600) {
				self.state = dimensionMode.medium
			} else {
				self.state = dimensionMode.small
			}
		}
	}
}
