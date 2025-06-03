import ComposableArchitecture
import SwiftData

struct DatabaseClient {
    var fetchSortedNutritionItems: @Sendable () async throws -> [NutritionItem]
}

extension DatabaseClient: DependencyKey {
    static var liveValue: Self {
        Self(
            fetchSortedNutritionItems: {
                @Dependency(\.modelContainer) var modelContainer

               
                let context = await modelContainer.mainContext

                return try await MainActor.run {
                    let descriptor = FetchDescriptor<NutritionItem>()
                    let items = try context.fetch(descriptor)
                    
                   
                    let typeOrder = NutritionType.allCases
                    let sortedItems = items.sorted {
                        guard let first = typeOrder.firstIndex(of: $0.type),
                              let second = typeOrder.firstIndex(of: $1.type) else { return false }
                        return first < second
                    }
                    
                    print("Nutriitem 개수 (DatabaseClient via ModelContainer): \(sortedItems.count)")
                    for item in sortedItems {
                        print("  Fetched (DatabaseClient via ModelContainer): \(item.type.rawValue) - Value: \(item.value)\(item.unit), Max: \(item.max)\(item.unit)")
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
