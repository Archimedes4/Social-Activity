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
	let emojiImage: Data
}

@main
struct WidgetsBundle: WidgetBundle {
	var body: some Widget {
		Select_Full_1x1_Widgets()
		Select_Full_2x1_Widgets()
		Select_Status_1x1_Widgets()
		Select_Status_2x1_Widgets()
		Select_Status_2x2_Widgets()
	}
}
