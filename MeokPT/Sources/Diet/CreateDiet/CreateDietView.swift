//
//  FoodAPIView.swift
//  MeokPT
//
//  Created by 김동영 on 5/19/25.
//

import SwiftUI
import ComposableArchitecture
import AlertToast

struct CreateDietView: View {
    @Bindable var store: StoreOf<CreateDietFeature>
    
    @FocusState private var focusedField: Bool

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    VStack {
                        TextField(
                            "",
                            text: $store.foodNameInput.sending(\.foodNameInputChanged),
                            prompt: Text("식품 이름 (예: 고구마, 휠렛 버거)")
                        )
                        .focused($focusedField)
                        .autocapitalization(.none)
                        .onSubmit { store.send(.searchButtonTapped) }
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(.placeholderText))
                    }
                    Spacer()
                    Button(action: {
                        if(focusedField == false) {
                            store.send(.scanBarcodeButtonTapped)
                        } else {
                            store.send(.searchButtonTapped)
                            focusedField = false
                        }
                    }) {
                        if(focusedField == false) {
                            Image(systemName: "barcode.viewfinder")
                                .font(.title)
                        } else {
                            Text("검색")
                        }
                    }
                    .frame(minWidth: 44)
                    .disabled(store.isLoading)
                    .foregroundStyle(Color("TextButton"))
                }
            }
            .padding(.leading, 8)
            .padding(.vertical, 8)
            .padding(.horizontal, 24)

            if store.isLoading {
                VStack (alignment: .center) {
                    Spacer()
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
            } else {
                if !store.fetchedFoodItems.isEmpty {
                    List {
                        ForEach(store.categorizedSections) { sectionData in
                            let isExpanded = store.sectionStates[sectionData.id, default: true]

                            Section {
                                if isExpanded {
                                    ForEach(sectionData.items) { foodInfo in
                                        Button {
                                            store.send(.foodItemRowTapped(foodInfo))
                                        } label: {
                                            FoodItemRowView(foodInfo: foodInfo)
                                        }
                                        .tint(.primary)
                                        .listRowInsets(EdgeInsets())
                                    }
                                }
                            } header: {
                                Button (action: { store.send(.sectionToggled(id: sectionData.id)) }) {
                                    HStack {
                                        Text(sectionData.categoryName)
                                            .font(.subheadline)
                                        Spacer()
                                        Text("영양성분은 100g 기준입니다.")
                                            .font(.subheadline.bold())
                                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                                            .frame(width:14)
                                    }
                                    .foregroundStyle(Color("AppSecondaryColor"))
                                    .padding(.horizontal, -8)
                                    .padding(.bottom, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(Color("AppBackgroundColor"))
                    .padding(.horizontal, 4)
                } else if store.lastSearchType != nil { // 검색결과가 없는 경우
                    VStack(spacing: 24) {
                        Spacer()
                        Text("검색 결과가 없습니다.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Button(action: { store.send(.addCustomFoodTapped) }) {
                            Text("직접 입력 후 음식 추가")
                        }
                        .foregroundStyle(Color("TextButton"))
                        Spacer()
                    }
                } else {
                    Spacer()
                }
            }
            
            if store.totalPages > 1 {
                HStack {
                    Button(action: { store.send(.goToPage(store.currentPage - 1)) }) {
                        Text("이전")
                            .opacity(store.currentPage == 1 ? 0 : 1)
                    }
                    .foregroundStyle(Color("TextButton"))
                    .disabled(store.currentPage == 1)
                    
                    Spacer()
                    Text("\(store.currentPage) / \(store.totalPages)")
                        .font(.footnote)
                        .foregroundStyle(Color("AppSecondaryColor"))
                    Spacer()
                    Button(action: { store.send(.goToPage(store.currentPage + 1)) }) {
                        Text("다음")
                            .opacity(store.currentPage >= store.totalPages ? 0 : 1)
                    }
                    .foregroundStyle(Color("TextButton"))
                    .disabled(store.currentPage >= store.totalPages)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("식단 생성")
        .navigationBarTitleDisplayMode(.inline)
        .contentShape(Rectangle())
        .background(Color("AppBackgroundColor"))
        .sheet(item: $store.scope(state: \.scanner, action: \.scannerSheet)) { _ in
            scannerSheetContent
        }
        .sheet(item: $store.scope(state: \.addFoodSheet, action: \.addFoodSheet)) { store in
            AddFoodView(store: store)
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(0.8)])
        }
        .sheet(item: $store.scope(state: \.addCustomFoodSheet, action: \.addCustomFoodSheet)) { store in
            AddCustomFoodView(store: store)
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(0.8)])
        }
        .toast(isPresenting: Binding(
            get: { store.showAlertToast },
            set: { _ in }
        )) {
            AlertToast(
                displayMode: .banner(.pop),
                type: .complete(Color("AppSecondaryColor")),
                title: "음식 추가 완료",
                subTitle: store.toastMessage
            )
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing,
                        content: { Button(action: {
                store.send(.closeButtonTapped)
            }) { Text("완료").foregroundStyle(Color("TextButton")) }})
        })
    }
    
    private var scannerSheetContent: some View {
        let onFoundCode: (String) -> Void = { code in
            store.send(.barcodeScanned(code))
        }
        let onFailScanning: (ScannerError) -> Void = { error in
            print("Scanner Error: \(error.localizedDescription)")
            store.send(.scannerSheet(.dismiss))
        }
        
        return CameraScannerView(
            didFindCode: onFoundCode,
            didFailScanning: onFailScanning
        )
    }
}

struct FoodItemRowView: View {
    let foodInfo: FoodNutritionItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(foodInfo.foodName).font(.headline).fontWeight(.bold)
                Spacer()
                if foodInfo.DB_CLASS_NM == "상용제품" {
                    Text(foodInfo.makerName)
                        .font(.caption)
                        .foregroundColor(Color("AppSecondaryColor"))
                }
            }
            .padding(.horizontal)
            Text("") // 리스트 Divider 왼쪽 여백 없애기 위한 빈 텍스트
            Text("\(foodInfo.calorie, specifier: "%.0f") kcal").font(.body)
                .padding(.horizontal)
                .padding(.top, -8)
            Spacer().frame(height: 12)
            NutrientView(carbohydrate: foodInfo.carbohydrate, protein: foodInfo.protein, fat: foodInfo.fat)
                .frame(height: 47)
                .padding(.horizontal,24)
        }
        .padding(.vertical, 24)
    }
}

#Preview {
    CreateDietView(
        store: Store(
            initialState: CreateDietFeature.State(foodNameInput: "사과"),
            reducer: { CreateDietFeature()._printChanges() }
        )
    )
}
