//
//  FoodAPIView.swift
//  MeokPT
//
//  Created by 김동영 on 5/19/25.
//

import SwiftUI
import ComposableArchitecture

struct FoodNutritionView: View {
    @Bindable var store: StoreOf<FoodNutritionFeature>
    
    @FocusState private var focusedField: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        VStack {
                            TextField(
                                "",
                                text: $store.foodNameInput.sending(\.foodNameInputChanged),
                                prompt: Text("식품 이름 (예: 고구마)")
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
                            focusedField = false
                            store.send(.scanBarcodeButtonTapped)
                        }) {
                            if store.isLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.title)
                            }
                        }
                        .disabled(store.isLoading)
                    }
                    Spacer().frame(height:8)
                    
                    if store.isLoading {
                        VStack (alignment: .center){
                            Spacer()
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer()
                            
                        }
                    } else {
                        if !store.fetchedFoodItems.isEmpty {
                            ScrollView {
                                ForEach(store.categorizedSections) { sectionData in
                                    HStack {
                                        Text(sectionData.categoryName)
                                            .font(.subheadline)
                                        Spacer()
                                        Text("영양성분은 100g 기준입니다.")
                                            .font(.subheadline.bold())
                                    }
                                    .foregroundStyle(Color("AppSecondaryColor"))
                                    .padding([.top])
                                    VStack(alignment: .leading) {
                                        VStack(alignment: .leading) {
                                            ForEach(sectionData.items) { foodInfo in
                                                FoodItemRowView(foodInfo: foodInfo)
                                                    .padding(.horizontal)
                                                
                                                if foodInfo.id != sectionData.items.last?.id {
                                                    Divider()
                                                }
                                            }
                                        }
                                    }
                                    .padding(.vertical)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(UIColor.separator), lineWidth: 1)
                                    )
                                }
                            }
                        } else if store.lastSearchType != nil { // 검색결과가 없는 경우
                            VStack {
                                Spacer()
                                Text("검색 결과가 없습니다.")
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                Spacer()
                            }
                        } else {
                            Spacer()
                        }
                    }
                    // 페이지네이션
                    if store.totalPages > 1 {
                        HStack {
                            Button(action: { store.send(.goToPage(store.currentPage - 1)) }) {
                                Text("이전")
                            }
                            .foregroundStyle(Color("TextButtonColor"))
                            
                            Spacer()
                            Text("\(store.currentPage) / \(store.totalPages)")
                                .font(.footnote)
                                .foregroundStyle(Color("AppSecondaryColor"))
                            Spacer()
                            Button(action: { store.send(.goToPage(store.currentPage + 1)) }) {
                                Text("다음")
                            }
                            .foregroundStyle(Color("TextButtonColor"))
                            .disabled(store.currentPage >= store.totalPages)
                        }
                        .padding(.top, 8)
                    }
                    Spacer()
                }
                .padding(24)
                .containerRelativeFrame([.horizontal, .vertical])
            }
            .scrollDisabled(true)
            .navigationTitle("식단 생성")
            .navigationBarTitleDisplayMode(.inline)
            .contentShape(Rectangle())
            .background(Color("AppBackgroundColor"))
            .onTapGesture {
                focusedField = false
            }
            .sheet(item: $store.scope(state: \.scanner, action: \.scannerSheet)) { _ in
                scannerSheetContent
            }
        }
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
            Spacer().frame(height:4)
            Text("\(foodInfo.calorie, specifier: "%.0f") kcal").font(.body)
            Spacer().frame(height: 20)
            NutrientView(carbohydrate: foodInfo.carbohydrate, protein: foodInfo.protein, fat: foodInfo.fat)
                .frame(height: 47)
                .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    FoodNutritionView(
        store: Store(
            initialState: FoodNutritionFeature.State(foodNameInput: "사과"),
            reducer: { FoodNutritionFeature()._printChanges() }
        )
    )
}
