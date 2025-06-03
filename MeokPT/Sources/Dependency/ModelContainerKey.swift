import ComposableArchitecture
import SwiftData
import Foundation

private enum ModelContainerKey: DependencyKey {
    static var liveValue: ModelContainer {
        do {
            return try ModelContainer(for: BodyInfo.self, NutritionItem.self, DietItem.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    static var testValue: ModelContainer {
        do {
            return try ModelContainer(
                for: BodyInfo.self, NutritionItem.self, DietItem.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            fatalError("Failed to create test ModelContainer: \(error.localizedDescription)")
        }
    }
}

extension DependencyValues {
    var modelContainer: ModelContainer {
        get { self[ModelContainerKey.self] }
        set { self[ModelContainerKey.self] = newValue }
    }
}
