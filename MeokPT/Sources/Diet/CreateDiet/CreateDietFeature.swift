//
//  CreateDietFeature.swift
//  MeokPT
//
//  Created by 김동영 on 5/19/25.
//

import Foundation
import AlertToast
import ComposableArchitecture

struct CategorizedFoodSection: Identifiable, Equatable {
    let id = UUID()
    let categoryName: String
    let items: [FoodNutritionItem]
    var isExpanded: Bool = true
}

@Reducer
struct CreateDietFeature {
    @ObservableState
    struct State: Equatable {
        var foodNameInput: String = ""
        var lastSearchType: FoodNutritionClient.SearchType? = nil
        
        var selectedFilter: String = "모두 검색"
        var dbClassName: String {
            selectedFilter == "품목대표만 검색" ? "품목대표" : ""
        }
        let filters = ["모두 검색", "품목대표만 검색"]

        var currentPage: Int = 1
        var numOfRows: Int = 100
        var totalItemsCount: Int = 0
        
        var fetchedFoodItems: [FoodNutritionItem] = []
        var isLoading: Bool = false
        
        var showAlertToast = false
        var toastMessage = ""
        
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
        var sectionStates: [UUID: Bool] = [:]

        var totalPages: Int {
            guard numOfRows > 0 else { return 0 }
            return (totalItemsCount + numOfRows - 1) / numOfRows // 올림 계산
        }
        
        struct ScannerPresentationMarker: Equatable {}
        
        @Presents var scanner: ScannerPresentationMarker?
        @Presents var addFoodSheet: AddFoodFeature.State?
        @Presents var addCustomFoodSheet: AddCustomFoodFeature.State?
    }
    
    enum Action {
        case foodNameInputChanged(String)
        case searchButtonTapped
        case foodNutritionResponse(Result<FoodNutritionAPIResponse, Error>)
        case goToPage(Int)
        
        case filterChanged(String)
        
        case scanBarcodeButtonTapped
        case barcodeScanned(String)
        case barcodeInfoResponse(Result<String?, APIError>)
        case scannerSheet(PresentationAction<Never>)
        case closeButtonTapped
        case foodItemRowTapped(FoodNutritionItem)
        case addCustomFoodTapped
        case sectionToggled(id: UUID)

        case addFoodSheet(PresentationAction<AddFoodFeature.Action>)
        case addCustomFoodSheet(PresentationAction<AddCustomFoodFeature.Action>)
        case hideToast
        
        case delegate(DelegateAction)
    }
    
    enum DelegateAction: Equatable {
        case dismissSheet
        case addFoodToDiet(foodName: String, amount: Double?, calories: Double, carbohydrates: Double?, protein: Double?, fat: Double?, dietaryFiber: Double?, sugar: Double?, sodium: Double?)
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

                return .run { [searchType = searchMethod, pageNo = state.currentPage, numOfRows = state.numOfRows, dbClassName = state.dbClassName] send in
                    let result: Result<FoodNutritionAPIResponse, Error> = await Result {
                        try await apiClient.fetch(searchType, pageNo, numOfRows, APIConstants.serviceKey, dbClassName)
                    }
                    await send(.foodNutritionResponse(result))
                }
                
            case .foodNutritionResponse(.success(let response)):
                state.isLoading = false
                if response.header.resultCode == "00" {
                    state.totalItemsCount = response.body?.totalCount ?? 0
                    
                    if let items = response.body?.items, !items.isEmpty {
                        var uniqueItems = [FoodNutritionItem]()
                        
                        // dbClassName이 "품목대표"일 때는 음식이름으로 중복 제거
                        if state.dbClassName == "품목대표" {
                            var seenFoodNames = Set<String>()
                            
                            for item in items {
                                if let foodName = item.FOOD_NM_KR, !foodName.isEmpty {
                                    if !seenFoodNames.contains(foodName) {
                                        uniqueItems.append(item)
                                        seenFoodNames.insert(foodName)
                                    }
                                } else {
                                    uniqueItems.append(item)
                                }
                            }
                        } else {
                            // ITEM_REPORT_NO로 중복 제거
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
                
                return .run { [searchType = lastSearchType, pageNo = state.currentPage, numOfRows = state.numOfRows, dbClassName = state.dbClassName] send in
                    let result: Result<FoodNutritionAPIResponse, Error> = await Result {
                        try await apiClient.fetch(searchType, pageNo, numOfRows, APIConstants.serviceKey, dbClassName)
                    }
                    await send(.foodNutritionResponse(result))
                }
                
            case .filterChanged(let filter):
                state.selectedFilter = filter
                return .none
                
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

                return .run { [pageNo = state.currentPage, numOfRows = state.numOfRows, dbClassName = state.dbClassName] send in
                    let result: Result<FoodNutritionAPIResponse, Error> = await Result {
                        try await apiClient.fetch(searchType, pageNo, numOfRows, APIConstants.serviceKey, dbClassName)
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
                
            case .addCustomFoodTapped:
                state.addCustomFoodSheet = AddCustomFoodFeature.State()
                return .none
                
            case .sectionToggled(let id):
                state.sectionStates[id, default: true].toggle()
                return .none
                
            case .addFoodSheet(.presented(.delegate(let addFoodDelegateAction))):
                switch addFoodDelegateAction {
                case .dismissSheet:
                    state.addFoodSheet = nil
                    return .none
                case .addFoodToDiet(let foodName, let amount, let calories, let carbohydrates, let protein, let fat, let dietFiber, let sugar, let sodium):
                    // 상위로 델리게이트
                    return .send(.delegate(.addFoodToDiet(
                        foodName: foodName,
                        amount: amount,
                        calories: calories,
                        carbohydrates: carbohydrates,
                        protein: protein,
                        fat: fat,
                        dietaryFiber: dietFiber,
                        sugar: sugar,
                        sodium: sodium
                    )))
                    case .createToast(let foodName, let amount):
                    state.showAlertToast = true
                    state.toastMessage = foodName.count > 30
                    ? "\(foodName.prefix(30))…"
                    : "\(foodName) \(Int(amount ?? 0))g"
                    state.addFoodSheet = nil
                    return .run { send in
                        try await Task.sleep(for: .seconds(3))
                        await send(.hideToast)
                    }
                }
                
            case .addCustomFoodSheet(.presented(.delegate(let addFoodDelegateAction))):
                switch addFoodDelegateAction {
                case .dismissSheet:
                    state.addCustomFoodSheet = nil
                    return .none
                case .addFoodToDiet(let foodName, let amount, let calories, let carbohydrates, let protein, let fat, let dietFiber, let sugar, let sodium):
                    // 상위로 델리게이트
                    return .send(.delegate(.addFoodToDiet(
                        foodName: foodName,
                        amount: amount ?? 0,
                        calories: calories ?? 0,
                        carbohydrates: carbohydrates,
                        protein: protein,
                        fat: fat,
                        dietaryFiber: dietFiber,
                        sugar: sugar,
                        sodium: sodium
                    )))
                    case .createToast(let foodName, let amount):
                    state.showAlertToast = true
                    state.toastMessage = foodName.count > 30
                    ? "\(foodName.prefix(30))…"
                    : "\(foodName) \(Int(amount ?? 0))g"
                    state.addCustomFoodSheet = nil
                    return .run { send in
                        try await Task.sleep(for: .seconds(3))
                        await send(.hideToast)
                    }
                }
                
            case .hideToast:
                state.showAlertToast = false
                return .none
            
            case .addFoodSheet(_):
                return .none
                
            case .addCustomFoodSheet(_):
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
        .ifLet(\.$addCustomFoodSheet, action: \.addCustomFoodSheet) {
            AddCustomFoodFeature()
        }
    }
}
