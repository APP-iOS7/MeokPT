import SwiftUI
import ComposableArchitecture
import SwiftData

struct DailyNutritionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Bindable var store: StoreOf<DailyNutritionFeature>
    var onSaveTapped: (_ store: StoreOf<DailyNutritionFeature>, _ modelContext: ModelContext) -> Void

    @FocusState private var focusedItemID: String?

    var body: some View {
        ZStack {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    HStack {
                        Text("수치 직접 입력")
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: $store.isEditable.sending(\.toggleChanged))
                            .labelsHidden()
                            .tint(Color("AppTintColor"))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(store.rows) { rowData in
                                NutritionRowView(
                                    name: rowData.name,
                                    value: rowData.value,
                                    unit: rowData.unit,
                                    isEditable: store.isEditable,
                                    onChange: { newValue in
                                        store.send(.valueChanged(type: rowData.type, text: newValue))
                                    },
                                    focus: $focusedItemID,
                                    rowID: rowData.id
                                )
                                .id(rowData.id)
                                
                                if rowData.id != store.rows.last?.id {
                                    Divider().padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(uiColor: UIColor.separator), lineWidth: 1)
                        )
                        
                    }
                    .padding(.horizontal, 24)
                    .onChange(of: focusedItemID) { _, newID in
                        if let idToScrollTo = newID {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                scrollViewProxy.scrollTo(idToScrollTo, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button(action: {
                focusedItemID = nil
                onSaveTapped(store, context)
                dismiss()
            }) {
                Text("저장")
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color("AppTintColor"))
                    .cornerRadius(30)
            }
            .font(.headline.bold())
            .foregroundColor(.black)
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("완료") {
                    focusedItemID = nil
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
            store.send(.loadSavedData)
        }
        .onTapGesture {
            focusedItemID = nil
        }
    }
}
