//
//  TimeSelector.swift
//  Social_Activity
//
//  Created by Andrew Mainella on 2025-03-08.
//

import Foundation
import SwiftUI

struct TimeSelector: View {
	@Binding var information: StatusInformation?
	@Binding var state: StatusItemState
	@State var isPickingTime: Bool = false;
	
	func loadUpdateSelectedItem(time: TimeOption) {
		Task {
			let result = await updateSelectedItem(time: time, infoID: information?.id ?? "")
			if (result == LoadingState.success) {
				information?.selectedTime = time
			}
		}
	}
	
	func loadAddItem(time: TimeOption) {
		Task {
			let result = await addItem(time: time, infoID: information?.id ?? "")
			if (result == .success && information?.times.contains(where: {$0 == time}) == false) {
				self.information?.times.append(time)
			}
		}
	}
	
	func loadRemoveItem(time: TimeOption) {
		Task {
			let result = await removeItem(time: time, infoID: information?.id ?? "")
			if (result == .success) {
				self.information?.times = self.information?.times.filter({$0 != time}) ?? []
			}
		}
	}
	
	var body: some View {
		HStack {
			HStack(spacing: 3) {
				if let information = information {
					ForEach(information.times, id: \.id) { time in
						Button(action: {
						//	loadUpdateSelectedItem(time: time)
						}) {
							HStack {
								Image(systemName: "clock")
									.resizable()
									.frame(width: 10, height: 10)
									.foregroundStyle(.black)
								Text(getTimeText(time: time))
									.font(.system(size: 10))
									.foregroundStyle(.black)
								if (state != StatusItemState.viewing && time != information.selectedTime) {
									Button(action: {
							//			loadRemoveItem(time: time)
									}) {
										Image(systemName: "xmark")
											.resizable()
											.frame(width: 10, height: 10)
											.foregroundStyle(.black)
									}.buttonStyle(.plain)
								}
							}
							.padding(5)
							//.background((information.selectedTime == time) ? Color("BlueOne"):.white)
							.clipShape(RoundedRectangle(cornerRadius: 35))
						}
						.buttonStyle(.plain)
					}
				}
			}
			.padding(5)
			.background(.ultraThinMaterial)
			.clipShape(RoundedRectangle(cornerRadius: 35))
			.overlay() {
				RoundedRectangle(cornerRadius: 35)
					.strokeBorder(Color.black, style: StrokeStyle(lineWidth: 1, dash: [.greatestFiniteMagnitude]))
			}
			.padding(.leading, 10)
			Spacer()
		}
		.padding(.bottom, 10)
	}
	
	var neverEnd: some View {
		Button(action: {
			loadUpdateSelectedItem(time: .never)
		}) {
			HStack {
				Image(systemName: "infinity")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 10, height: 10)
					.foregroundStyle(.black)
				Text("Never end")
					.font(.system(size: 10))
					.foregroundStyle(.black)
			}
			.padding(5)
			.background((information?.selectedTime == .never) ? Color("BlueOne"):.white)
			.clipShape(RoundedRectangle(cornerRadius: 35))
		}
		.buttonStyle(.plain)
	}
	
	var addTimeButton: some View {
		Button(action: {
			isPickingTime = true;
		}) {
			Image(systemName: "calendar.badge.plus")
				.resizable()
				.frame(width: 10, height: 10)
				.foregroundStyle(.black)
				.padding(5)
				.background(.white)
				.clipShape(RoundedRectangle(cornerRadius: 35))
				.popover(isPresented: $isPickingTime) {
					DateTimePicker(addItem: { time in
						loadAddItem(time: time)
					})
					.presentationDetents([.height(300)])
				}
		}.buttonStyle(.plain)
	}
	
	func getTimeText(time: TimeOption) -> String {
		if case let .date(date) = time {
			return date.ISO8601Format()
		}
		if case let .duration(int) = time {
			return int.toLongTime()
		}
		return ""
	}
}
