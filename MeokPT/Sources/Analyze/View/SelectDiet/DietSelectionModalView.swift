import ComposableArchitecture
import SwiftUI

enum Options: String, CaseIterable {
    case all = "전체"
    case favorite = "즐겨찾기"
}

struct DietSelectionModalView: View {
    @Bindable var store: StoreOf<DietSelectionSheetFeature>

    @State private var selectedOption: Options = .all
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackgroundColor")
                VStack {
                    Picker("옵션 선택", selection: $store.currentFilter.sending(\.setFilter)) {
                        ForEach(Options.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                    .padding()
                    
                    if store.isLoading {
                        ProgressView()
                        Spacer()
                    } else if let errorMessage = store.errorMessage {
                        Text("오류: \(errorMessage)")
                            .foregroundStyle(.red)
                        Spacer()
                    } else {
                        DietItemListView(store: store)
                    }
                }
            }
            .navigationTitle("식단 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        store.send(.addDietButtonTapped)
                    } label: {
                        Text("추가")
                    }
                    .disabled(store.selectedDiets.isEmpty || store.filteredDiets.isEmpty)
                    .foregroundStyle(Color("AppTintColor"))
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
