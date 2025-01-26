//
//  StatusButton.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-11-21.
//

import SwiftUI

struct StatusButton: View {
	let text: String
	let emoji: String
	var active: Bool
	@Binding var token: String
	@Binding var emojis: [String:String]
	@State var hovered: Bool = false
	@State var url: String = ""
	
	var body: some View {
			Button(action: {
				Task {
					await setStatus(emoji: ":" + emoji + ":", message: text, expiresAt: getExpiresAt(time: -1), token: token)
				}
			}) {
				HStack {
					if (url != "") {
						AsyncImage(url: URL(string: url)) { image in
							image.resizable()
						} placeholder: {
							ProgressView()
						}
						.frame(width: 14, height: 14)
					}
					Text(text)
						.font(Font.system(size: 14))
						.foregroundStyle(.black)
					Spacer()
				}
				.padding(5)
				.frame(maxWidth: .infinity)
				.background(hovered ? Color.gray:Color.clear)
				.cornerRadius(4)
			}
			.buttonStyle(.borderless)
			.onHover(perform: { e in
				hovered = e
			})
			.focusEffectDisabled()
			.onAppear(perform: {
				url = emojis[emoji] ?? ""
			})
			.onChange(of: emojis) {
				url = emojis[emoji] ?? ""
			}
    }
}

struct ClearButton: View {
	@Binding var token: String
	@State var hovered: Bool = false
	
	var body: some View {
			Button(action: {
				Task {
					await clearStatus(token: token)
				}
			}) {
				HStack {
					Image(systemName: "xmark")
						.frame(width: 14, height: 14)
					Text("Clear Status")
						.font(Font.system(size: 14))
						.foregroundStyle(.black)
					Spacer()
				}
				.padding(5)
				.frame(maxWidth: .infinity)
				.background(hovered ? Color.gray:Color.clear)
				.cornerRadius(4)
			}
			.buttonStyle(.borderless)
			.onHover(perform: { e in
				hovered = e
			})
			.focusEffectDisabled()
		}
}
