//
//  AIHistoryFeature.swift
//  MeokPT
//
//  Created by 김동영 on 6/10/25.
//

import ComposableArchitecture
import SwiftData
import Foundation

// Sendable한 데이터 전송을 위한 구조체
struct AnalyzeHistoryData: Sendable, Equatable {
    let id: UUID
    let timestamp: Date
    let encodedData: String
    let cleanedResponse: String
    let persistentModelID: PersistentIdentifier
    
    init(from analyzeHistory: AnalyzeHistory) {
        self.id = analyzeHistory.id
        self.timestamp = analyzeHistory.timestamp
        self.encodedData = analyzeHistory.encodedData
        self.cleanedResponse = analyzeHistory.cleanedResponse
        self.persistentModelID = analyzeHistory.persistentModelID
    }
}

@Reducer
struct AIHistoryFeature {
    
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
        var historyItems: [AnalyzeHistoryData] = []
        var selectedItem: AnalyzeHistoryData? = nil
        var showingDetail: Bool = false
        var errorMessage: String? = nil
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case loadHistory
        case historyLoaded([AnalyzeHistoryData])
        case loadingFailed(String)
        case selectItem(AnalyzeHistoryData)
        case dismissDetail
        case deleteItem(PersistentIdentifier)
        case itemDeleted(PersistentIdentifier)
        case deleteFailed(String)
    }
    
    @Dependency(\.modelContainer) var modelContainer
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                
            case .binding(_):
                return .none
                
            case .onAppear:
                return Effect.send(.loadHistory)
                
            case .loadHistory:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    let result = await MainActor.run {
                        do {
                            let context = modelContainer.mainContext
                            let descriptor = FetchDescriptor<AnalyzeHistory>(
                                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
                            )
                            let items = try context.fetch(descriptor)
                            let historyData = items.map { AnalyzeHistoryData(from: $0) }
                            return Result<[AnalyzeHistoryData], Error>.success(historyData)
                        } catch {
                            return Result<[AnalyzeHistoryData], Error>.failure(error)
                        }
                    }
                    
                    switch result {
                    case .success(let items):
                        await send(.historyLoaded(items))
                    case .failure(let error):
                        await send(.loadingFailed(error.localizedDescription))
                    }
                }
                
            case .historyLoaded(let items):
                state.isLoading = false
                state.historyItems = items
                return .none
                
            case .loadingFailed(let errorMessage):
                state.isLoading = false
                state.errorMessage = errorMessage
                return .none
                
            case .selectItem(let item):
                state.selectedItem = item
                state.showingDetail = true
                return .none
                
            case .dismissDetail:
                state.selectedItem = nil
                state.showingDetail = false
                return .none
                
            case .deleteItem(let persistentID):
                return .run { send in
                    let result = await MainActor.run {
                        do {
                            let context = modelContainer.mainContext
                            if let item = context.model(for: persistentID) as? AnalyzeHistory {
                                context.delete(item)
                                try context.save()
                                return Result<PersistentIdentifier, Error>.success(persistentID)
                            } else {
                                throw NSError(domain: "AIHistoryError", code: 404, userInfo: [NSLocalizedDescriptionKey: "아이템을 찾을 수 없습니다."])
                            }
                        } catch {
                            return Result<PersistentIdentifier, Error>.failure(error)
                        }
                    }
                    
                    switch result {
                    case .success(let deletedID):
                        await send(.itemDeleted(deletedID))
                    case .failure(let error):
                        await send(.deleteFailed(error.localizedDescription))
                    }
                }
                
            case .itemDeleted(let deletedID):
                state.historyItems.removeAll { $0.persistentModelID == deletedID }
                return .none
                
            case .deleteFailed(let errorMessage):
                state.errorMessage = errorMessage
                return .none
            }
        }
    }
}
