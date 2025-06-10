import ComposableArchitecture
import SwiftUI

struct DietSelectionModalView: View {
    @Bindable var store: StoreOf<DietSelectionSheetFeature>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                if store.isLoading {
                    ProgressView()
                    Spacer()
                } else if let errorMessage = store.errorMessage {
                    Text("오류: \(errorMessage)")
                        .foregroundStyle(.red)
                    Spacer()
                } else {
                    ScrollView {
                        HStack {
                            Spacer()
                            Picker("정렬", selection: $store.selectedFilter) {
                                ForEach(DietFilter.allCases) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                            .pickerStyle(.segmented)
                            .fixedSize()
                            Spacer()
                            Button {
                                store.send(.favoriteFilterButtonTapped)
                            } label: {
                                Image(systemName: store.isFavoriteFilterActive ? "heart.fill" : "heart")
                                    .foregroundStyle(Color("AppSecondaryColor"))
                            }
                        }
                        .padding(.trailing, 24)
                        DietItemListView(store: store)
                    }
                }
            }
            .background(Color("AppBackgroundColor"))
            .navigationTitle("식단 선택")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $store.searchText, prompt: "검색")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        store.send(.addDietButtonTapped)
                    } label: {
                        Text("추가")
                    }
                    .disabled(store.selectedDiets.isEmpty || store.filteredDiets.isEmpty)
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("취소")
                    }
                }
            }
            .onAppear {
                store.send(.loadDiets)
            }
        }
    }
}
