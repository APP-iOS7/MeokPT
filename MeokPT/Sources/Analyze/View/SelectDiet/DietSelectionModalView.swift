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
                    Picker("옵션 선택", selection: $selectedOption) {
                        ForEach(Options.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                            
                        }
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                    .padding()
                    
                    Spacer()
                    DietItemListView()
                }
            }
            .navigationTitle("식단 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        
                    } label: {
                        Text("추가")
                    }
                    .foregroundStyle(Color("AppTintColor"))
                    .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("취소")
                    }
                    .foregroundStyle(Color("AppTintColor"))
                }
            }
        }
    }
}
