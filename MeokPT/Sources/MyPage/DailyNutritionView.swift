import SwiftUI
import ComposableArchitecture
import SwiftData

struct DailyNutritionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let store: StoreOf<DailyNutritionFeature>
    var onSaveTapped: (_ store: StoreOf<DailyNutritionFeature>, _ modelContext: ModelContext) -> Void

    @FocusState private var focusedItemID: String?

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        VStack(spacing: 20) {
                            HStack {
                                Text("수치 직접 입력")
                                    .font(.headline)
                                Spacer()
                                Toggle("", isOn: viewStore.binding(
                                    get: \.isEditable,
                                    send: { .toggleChanged($0) }
                                ))
                                .labelsHidden()
                                .tint(Color("AppTintColor", bundle: nil))
                            }
                            .padding(.horizontal)
                            .padding(.top, 30)

                            VStack(spacing: 10) {
                                ForEach(viewStore.rows) { rowData in
                                    let currentRowValue = viewStore.rows.first(where: { $0.id == rowData.id })?.value ?? ""

                                    NutritionRowView(
                                        name: rowData.name,
                                        value: currentRowValue,
                                        unit: rowData.unit,
                                        isEditable: viewStore.isEditable,
                                        onChange: { newValue in
                                            viewStore.send(.valueChanged(type: rowData.type, text: newValue))
                                        },
                                        focus: $focusedItemID,
                                        rowID: rowData.id
                                    )
                                    .id(rowData.id)

                                    if rowData.id != viewStore.rows.last?.id {
                                        Divider().padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                            .background(Color("App CardColor"))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                    }
                    .onChange(of: focusedItemID) { _, newID in
                        if let idToScrollTo = newID {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                scrollViewProxy.scrollTo(idToScrollTo, anchor: .center)
                            }
                        }
                    }
                }
            }
            .background(Color("AppBackgroundColor", bundle: nil))
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button("완료") {
                    focusedItemID = nil
                    onSaveTapped(store, context)
                    dismiss()
                }
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color("AppTintColor", bundle: nil))
                .foregroundColor(.black)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .background(Color("AppBackgroundColor", bundle: nil))
            }
//            .toolbar {
//                ToolbarItemGroup(placement: .keyboard) {
//                    Spacer()
//                    Button("완료") {
//                        focusedItemID = nil
//                    }
//                }
//            }
            .toolbar(.hidden, for: .tabBar)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onAppear {
                viewStore.send(.onAppear)
                viewStore.send(.loadSavedData(context))
            }
            .onTapGesture {
                focusedItemID = nil
            }
        }
    }
}
