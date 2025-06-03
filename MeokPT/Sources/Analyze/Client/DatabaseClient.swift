import ComposableArchitecture
import SwiftData
import Foundation

@DependencyClient
struct DatabaseClient {
    var fetchSortedNutritionItems: @Sendable (_ modelContext: ModelContext) async throws -> [NutritionItem]
}

extension DatabaseClient: DependencyKey {
    static var liveValue: Self {
        return Self(
            fetchSortedNutritionItems: { modelContext in
                try await MainActor.run {
                    let descriptor = FetchDescriptor<NutritionItem>()
                    let items = try modelContext.fetch(descriptor)
                    
                    // 기존 정렬 로직
                    let typeOrder = NutritionType.allCases // NutritionType이 이 범위에서 접근 가능해야 함
                    let sortedItems = items.sorted {
                        guard let first = typeOrder.firstIndex(of: $0.type),
                              let second = typeOrder.firstIndex(of: $1.type) else { return false }
                        return first < second
                    }
                    
                    print("Nutriitem 개수 (DatabaseClient): \(sortedItems.count)")
                    for item in sortedItems {
                        print("  Fetched (DatabaseClient): \(item.type.rawValue) - Value: \(item.value)\(item.unit), Max: \(item.max)\(item.unit)")
                    }
                    return sortedItems
                }
            }
        )
    }
}

extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
