import SwiftUI

struct HomeList: View {
	@EnvironmentObject var homeData: HomeData
	@EnvironmentObject var geometryData: GeometryData
	@State var minHeight: CGFloat
	
	init (for minHeight: CGFloat) {
		self.minHeight = minHeight
	}
	
	var body: some View {
		ScrollView {
			LazyVStack( spacing: 0) {
				if (homeData.statusItemsState == LoadingState.loading) {
					VStack {
						Spacer()
						ProgressView()
							.scaleEffect(max(minHeight/600, 1))
						Spacer()
					}
					.frame(height: minHeight)
				} else if (homeData.statusItemsState == LoadingState.failed) {
					VStack {
						Spacer()
						Image(systemName: "exclamationmark.icloud.fill")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 30, height: 30)
						Spacer()
					}
					.frame(height: minHeight)
				}
				if (homeData.statusItemsState == LoadingState.success) {
					ForEach(Array(homeData.statusItems.enumerated()), id: \.offset) { index, item in
						Group {
							if let item = item {
								StatusItem(information: item, onSelectEmoji: {
									homeData.selectedIndex = index
									homeData.selectedEmoji = item.emoji
								}, onDelete: {
									var newArr = homeData.statusItems
									newArr.remove(at: index)
									homeData.statusItems = newArr
									homeData.selectedIndex = -1
								}, onCreate: {id, name, emoji, selectedTime, times in})
							} else {
								StatusItem(information: nil, onSelectEmoji: {
									homeData.selectedIndex = homeData.statusItems.count
									homeData.selectedEmoji = homeData.createSelectedEmoji
								}, onDelete: {}, onCreate: { id, name, emoji, selectedTime, times in
									var newArr = homeData.statusItems
									newArr[newArr.count - 1] = StatusInformation(id: id, name: name, emoji: emoji, selectedTime: selectedTime, times: times)
									newArr.append(nil)
									homeData.statusItems = newArr
									homeData.selectedIndex = -1
								})
								.padding(.bottom)
							}
						}.id(item?.id ?? "nil-\(index)")
					}
				}
			}.frame(minHeight: (homeData.statusItemsState != LoadingState.success) ? minHeight:0)
		}
		.scrollDisabled(homeData.statusItemsState != LoadingState.success)
		.frame(width: (geometryData.size.width * (geometryData.state != .small ? 0.6:1)) - (geometryData.state != .small ? 15:20))
		.padding((geometryData.state != .small) ? .trailing:.horizontal, (geometryData.state != .small) ? 15:10)
	}
}

