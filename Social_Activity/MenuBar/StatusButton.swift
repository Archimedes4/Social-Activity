//
//  StatusButton.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-11-21.
//

import SwiftUI

enum buttonState {
	case pressed, hovered, normal, active
}

func getColor(state: buttonState) -> Color {
	if (state == buttonState.active) {
		return Color.yellow
	}
	if (state == buttonState.pressed) {
		return Color.red
	}
	if (state == buttonState.hovered) {
		return Color.blue
	}
	return Color.purple
}

struct StatusButton: View {
	let text: String
	let emoji: String
	@Binding var active: String
	@State var state: buttonState = buttonState.normal
	@State var url: String = ""
	var body: some View {
			Button(action: {
					Task {
						await setStatus(emoji: ":" + emoji + ":", message: text)
					}
			}) {
				HStack {
					if (url != "") {
						AsyncImage(url: URL(string: url)) { image in
							image.resizable()
						} placeholder: {
							Color.red
						}
						.frame(width: 25, height: 25)
					}
					Text(text)
						.fontWeight(.bold)
						.font(Font.system(size: 20))
					Spacer()
				}
				.padding(10)
				.frame(maxWidth: .infinity)
				.background(getColor(state: state))
				.cornerRadius(12)
				.overlay(
					RoundedRectangle(cornerRadius: 12)
						.stroke(.black, lineWidth: 2)
				)
			}
			.buttonStyle(CustomButtonStyle(onPressed: {
				state = buttonState.pressed
							}, onReleased: {
								state = buttonState.hovered
							}))
			.onHover(perform: { e in
				if (e == true) {
					state = buttonState.hovered
				} else {
					state = buttonState.normal
				}
			})
			.focusEffectDisabled()
			.onAppear(perform: {
				Task {
					url = try await GitHubEmoji().getUrl(emoji: emoji)
				}
			})
    }
}

#Preview {
	VStack {
		StatusButton(text: "Helloo", emoji: "", active: .constant("Helloo"))
			.frame(maxWidth: .infinity)
	}.padding()
		.frame(width: 600)
}

//https://stackoverflow.com/questions/57860840/any-swiftui-button-equivalent-to-uikits-touch-down-i-e-activate-button-when
struct CustomButtonStyle: ButtonStyle {
		
		var onPressed: () -> Void
		
		var onReleased: () -> Void
		
		// Wrapper for isPressed where we can run custom logic via didSet (or willSet)
		@State private var isPressedWrapper: Bool = false {
				didSet {
						// new value is pressed, old value is not pressed -> switching to pressed state
						if (isPressedWrapper && !oldValue) {
								onPressed()
						}
						// new value is not pressed, old value is pressed -> switching to unpressed state
						else if (oldValue && !isPressedWrapper) {
								onReleased()
						}
				}
		}
		
		// return the label unaltered, but add a hook to watch changes in configuration.isPressed
		func makeBody(configuration: Self.Configuration) -> some View {
				return configuration.label
						.onChange(of: configuration.isPressed, perform: { newValue in isPressedWrapper = newValue })
		}
}
