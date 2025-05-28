//
//  CreateDietFeature.swift
//  MeokPT
//
//  Created by 김동영 on 5/19/25.
//

import Foundation
import ComposableArchitecture

struct CategorizedFoodSection: Identifiable, Equatable {
    let id = UUID()
    let categoryName: String
    let items: [FoodNutritionItem]
}

@Reducer
struct CreateDietFeature {
    @ObservableState
    struct State: Equatable {
        var foodNameInput: String = "고구마"
        var lastSearchType: FoodNutritionClient.SearchType? = nil

        var currentPage: Int = 1
        var numOfRows: Int = 30
        var totalItemsCount: Int = 0
        
        var fetchedFoodItems: [FoodNutritionItem] = []
        var isLoading: Bool = false
        
        var categorizedSections: [CategorizedFoodSection] {
            let grouped = Dictionary(grouping: fetchedFoodItems, by: { $0.DB_CLASS_NM ?? "기타" })
            let desiredOrder = ["품목대표", "상용제품"]
            var sections: [CategorizedFoodSection] = []

            for categoryName in desiredOrder {
                if let items = grouped[categoryName], !items.isEmpty {
                    sections.append(CategorizedFoodSection(categoryName: categoryName, items: items))
                }
            }
            
            let remainingCategories = grouped.keys.filter { !desiredOrder.contains($0) }.sorted()
            for categoryName in remainingCategories {
                if let items = grouped[categoryName], !items.isEmpty {
                    sections.append(CategorizedFoodSection(categoryName: categoryName, items: items))
                }
            }
            return sections
        }

        var totalPages: Int {
            guard numOfRows > 0 else { return 0 }
            return (totalItemsCount + numOfRows - 1) / numOfRows // 올림 계산
        }
        
        struct ScannerPresentationMarker: Equatable {}
        
        @Presents var scanner: ScannerPresentationMarker?
        @Presents var addFoodSheet: AddFoodFeature.State?
    }
    
    enum Action {
        case foodNameInputChanged(String)
        case searchButtonTapped
        case foodNutritionResponse(Result<FoodNutritionAPIResponse, Error>)
        case goToPage(Int)
        
        case scanBarcodeButtonTapped
        case barcodeScanned(String)
        case barcodeInfoResponse(Result<String?, APIError>)
        case scannerSheet(PresentationAction<Never>)
        case closeButtonTapped
        case foodItemRowTapped(FoodNutritionItem)

        case addFoodSheet(PresentationAction<AddFoodFeature.Action>)
        
        case delegate(DelegateAction)
    }
    
    enum DelegateAction: Equatable {
        case dismissSheet
    }
    
    @Dependency(\.foodNutritionClient) var apiClient
    @Dependency(\.barcodeInfoClient) var barcodeClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .foodNameInputChanged(let name):
                state.foodNameInput = name
                return .none
                
            case .searchButtonTapped:
                let searchText = state.foodNameInput.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !searchText.isEmpty else { return .none }
                
                state.isLoading = true
                state.fetchedFoodItems = []
                state.currentPage = 1
                state.totalItemsCount = 0

                let searchMethod: FoodNutritionClient.SearchType
                
                if let reportNo = foodNameToReportIdMap[searchText] {
                    searchMethod = .byItemReportNo(reportNo)
                } else {
                    searchMethod = .byFoodName(searchText)
                }
                
                state.lastSearchType = searchMethod

                return .run { [searchType = searchMethod, pageNo = state.currentPage, numOfRows = state.numOfRows] send in
                    let result: Result<FoodNutritionAPIResponse, Error> = await Result {
                        try await apiClient.fetch(searchType, pageNo, numOfRows, APIConstants.serviceKey)
                    }
                    await send(.foodNutritionResponse(result))
                }
                
            case .foodNutritionResponse(.success(let response)):
                state.isLoading = false
                if response.header.resultCode == "00" {
                    state.totalItemsCount = response.body?.totalCount ?? 0
                    
                    if let items = response.body?.items, !items.isEmpty {
                        var uniqueItems = [FoodNutritionItem]()
                        var seenReportNumbers = Set<String>()

                        for item in items {
                            if let reportNo = item.ITEM_REPORT_NO, !reportNo.isEmpty {
                                if !seenReportNumbers.contains(reportNo) {
                                    uniqueItems.append(item)
                                    seenReportNumbers.insert(reportNo)
                                }
                            } else {
                                uniqueItems.append(item)
                            }
                        }
                        state.fetchedFoodItems = uniqueItems
                    } else {
                        state.fetchedFoodItems = []
                    }
                } else {
                    state.fetchedFoodItems = []
                    state.totalItemsCount = 0
                }
                return .none
                
            case .foodNutritionResponse(.failure(_)):
                state.isLoading = false
                state.fetchedFoodItems = []
                state.totalItemsCount = 0
                return .none
                
            case .goToPage(let targetPage):
                guard let lastSearchType = state.lastSearchType,
                      targetPage >= 1 && targetPage <= state.totalPages && targetPage != state.currentPage,
                      !state.isLoading else {
                    return .none
                }
                
                state.isLoading = true
                state.fetchedFoodItems = []
                state.currentPage = targetPage
                
                return .run { [searchType = lastSearchType, pageNo = state.currentPage, numOfRows = state.numOfRows] send in
                    let result: Result<FoodNutritionAPIResponse, Error> = await Result {
                        try await apiClient.fetch(searchType, pageNo, numOfRows, APIConstants.serviceKey)
                    }
                    await send(.foodNutritionResponse(result))
                }
                
            case .scanBarcodeButtonTapped:
                state.scanner = State.ScannerPresentationMarker()
                return .none
                
            case .barcodeScanned(let barcode):
                state.scanner = nil
                state.isLoading = true
                state.fetchedFoodItems = []
                state.totalItemsCount = 0
                state.currentPage = 1
                state.foodNameInput = "바코드: \(barcode)"
                state.lastSearchType = nil

                return .run { send in
                    let result = await Result { try await barcodeClient.fetchItemReportNo(barcode) }
                    
                    let mappedResult: Result<String?, APIError> = result.mapError { error in
                        if let apiError = error as? APIError {
                            return apiError
                        } else {
                            return APIError.requestFailed(error.localizedDescription)
                        }
                    }
                    await send(.barcodeInfoResponse(mappedResult))
                }
                
            case .barcodeInfoResponse(.success(let itemReportNoOrNil)):
                guard let itemReportNo = itemReportNoOrNil, !itemReportNo.isEmpty else {
                    state.isLoading = false
                    state.fetchedFoodItems = []
                    state.totalItemsCount = 0
                    return .none
                }
                
                let searchType = FoodNutritionClient.SearchType.byItemReportNo(itemReportNo)
                state.lastSearchType = searchType
                if !state.isLoading { state.isLoading = true }

                return .run { [pageNo = state.currentPage, numOfRows = state.numOfRows] send in
                    let result: Result<FoodNutritionAPIResponse, Error> = await Result {
                        try await apiClient.fetch(searchType, pageNo, numOfRows, APIConstants.serviceKey)
                    }
                    await send(.foodNutritionResponse(result))
                }

            case .barcodeInfoResponse(.failure):
                state.scanner = nil
                state.isLoading = false
                state.fetchedFoodItems = []
                state.totalItemsCount = 0
                return .none

            case .scannerSheet(.dismiss):
                state.scanner = nil
                return .none
            case .scannerSheet:
                return .none
                
            case .closeButtonTapped:
                return .send(.delegate(.dismissSheet))
                
            case .foodItemRowTapped(let foodItem):
                state.addFoodSheet = AddFoodFeature.State(selectedFoodItem: foodItem)
                return .none

            case .addFoodSheet(.presented(.delegate(let addFoodDelegateAction))):
                switch addFoodDelegateAction {
                case .dismissSheet:
                    state.addFoodSheet = nil // 시트 닫기
                    return .none
                case .addFoodToDiet(let foodName, let amount, let calories, let carbohydrates, let protein, let fat, let dietFiber, let sugar, let sodium):
                    // TODO: 식단에 음식을 추가하는 로직 구현 (예: 부모 Feature로 전달)
                    // state.delegate(.foodAdded(foodItem, amount)) 와 같은 형태로 부모에게 전달 가능
                    state.addFoodSheet = nil // 시트 닫기
                    return .none
                }
                
            case .addFoodSheet(_):
                return .none
                
            case .delegate(_):
                return .none
            }
        }
        .ifLet(\.$scanner, action: \.scannerSheet) {
            EmptyReducer() // 스캐너 자체가 TCA Feature가 아니므로 EmptyReducer
        }
        .ifLet(\.$addFoodSheet, action: \.addFoodSheet) {
            AddFoodFeature()
        }
    }
}
