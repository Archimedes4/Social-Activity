//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by Andrew Mainella on 2024-11-30.
//

import WidgetKit
import SwiftUI

struct StatusInformationImage: Identifiable {
	let id: String
	let name: String
	let emoji: String
	let emojiData: Data
}

@main
struct WidgetsBundle: WidgetBundle {
	var body: some Widget {
		Select_Full_Widgets()
		Select_Status_Widgets()
	}
}
