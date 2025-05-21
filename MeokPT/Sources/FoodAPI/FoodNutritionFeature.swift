//
//  FoodNutritionFeature.swift
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
    
    static func == (lhs: CategorizedFoodSection, rhs: CategorizedFoodSection) -> Bool {
        return lhs.id == rhs.id && lhs.categoryName == rhs.categoryName && lhs.items == rhs.items
    }
}

@Reducer
struct FoodNutritionFeature {
    @ObservableState
    struct State: Equatable {
        var foodNameInput: String = "고구마"
        var pageNo: Int = 1
        var numOfRows: Int = 50
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
    }
    
    enum Action {
        case foodNameInputChanged(String)
        case searchButtonTapped
        case foodNutritionResponse(Result<FoodNutritionAPIResponse, Error>)
    }
    
    @Dependency(\.foodNutritionClient) var apiClient
    
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
                
                let searchMethod: FoodNutritionClient.SearchType
                var foundReportNo: String? = nil

                if let reportNoFromExactMatch = foodNameToReportIdMap[searchText] {
                    foundReportNo = reportNoFromExactMatch
                } else {
                    for (keyInMap, reportNoValue) in foodNameToReportIdMap {
                        if keyInMap.contains(searchText) {
                            foundReportNo = reportNoValue
                            break
                        }
                    }
                }
                
                if let reportNo = foundReportNo {
                    searchMethod = .byItemReportNo(reportNo)
                } else {
                    searchMethod = .byFoodName(searchText)
                }
                
                return .run { [searchMethod = searchMethod, pageNo = state.pageNo, numOfRows = state.numOfRows] send in
                    let result: Result<FoodNutritionAPIResponse, Error> = await Result {
                        try await apiClient.fetch(searchMethod, pageNo, numOfRows, APIConstants.serviceKey)
                    }
                    await send(.foodNutritionResponse(result))
                }
                
            case .foodNutritionResponse(.success(let response)):
                state.isLoading = false
                if response.header.resultCode == "00" {
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
                }
                return .none
                
            case .foodNutritionResponse(.failure(_)):
                state.isLoading = false
                state.fetchedFoodItems = []
                return .none
            }
        }
    }
}
