import SwiftData

@MainActor
class BodyInfoController {
    static let shared = BodyInfoController()
    let container: ModelContainer
    
    private init() {
        do {
            container = try ModelContainer(for: BodyInfo.self)
        } catch {
            fatalError("BodyInfo ModelContainer 초기화 실패: \(error)")
        }
    }
}
