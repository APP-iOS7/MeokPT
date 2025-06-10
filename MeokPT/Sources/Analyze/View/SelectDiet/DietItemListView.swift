import SwiftUI
import ComposableArchitecture

struct DietItemListView: View {
    @Bindable var store: StoreOf<DietSelectionSheetFeature>

    var body: some View {
            if store.filteredDiets.isEmpty {
                DietEmptyView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(store.filteredDiets) { diet in
                        DietItemCellView(
                            diet: diet,
                            isSelected: store.selectedDiets.contains(diet.id),
                            toggleSelection: {
                                store.send(.toggleDietSelection(diet.id))
                            }
                        )
                    }
                }
                .padding(.top, 5)
            }
    }
}

//#Preview {
//    DietItemListView()
//}
