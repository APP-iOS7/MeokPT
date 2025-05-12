import SwiftUI

struct DietItemListView: View {
    // 샘플 데이터
    let items = Array(repeating: "Sample Item", count: 10)
    @State private var selectedStates: [Bool] = Array(repeating: false, count: 10)

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(items.indices, id:\.self) { index in
                    DietItemCellView(isSelected: $selectedStates[index])
                }
            }
        }
    }
}

#Preview {
    DietItemListView()
}
