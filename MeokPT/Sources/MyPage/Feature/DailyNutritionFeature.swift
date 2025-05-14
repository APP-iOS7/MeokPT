import ComposableArchitecture
import SwiftData

@Reducer
struct DailyNutritionFeature: Reducer {
    struct State: Equatable {
        var rows: [NutritionRowData] = NutritionType.allCases.map {
            NutritionRowData(type: $0, value: "")
        }
        var isEditable: Bool = true
    }

    enum Action: Equatable {
        case valueChanged(type: NutritionType, text: String)
        case saveButtonTapped(ModelContext)
        case loadSavedData(ModelContext)
        case toggleChanged(Bool)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .valueChanged(type, text):
                if let index = state.rows.firstIndex(where: { $0.type == type }) {
                    state.rows[index].value = text
                }
                return .none
            case let .saveButtonTapped(context):
                print("저장 시작")
                
                let fetchDescriptor = FetchDescriptor<NutritionItem>()
                
                do {
                    let existingItems = try context.fetch(fetchDescriptor)
                    for item in existingItems {
                        context.delete(item)
                    }
                    print("기존 데이터 삭제 완료")
                } catch {
                    print("기존 데이터 삭제 실패")
                }
                
                for type in NutritionType.allCases {
                    guard let row = state.rows.first(where: { $0.type == type }) else { continue }
                            
                    guard let value = Int(row.value) else {
                        print("변환 실패")
                        continue
                    }
                    let newItem = NutritionItem(type: row.type, value: value, max: value)
                    context.insert(newItem)
                    print("저장: \(row.type.rawValue) - \(value)\(row.type.unit)")
                }
        
                do {
                    try context.save()
                    print("저장 완료")
                } catch {
                    print("저장 실패: \(error)")
                }
                return .none
            case let .loadSavedData(context):
                print("로딩 시작")
                
                let fetchDescriptor = FetchDescriptor<NutritionItem>()
                
                do {
                    let items = try context.fetch(fetchDescriptor)
                    print("Nutriitem 개수: \(items.count)")
                    
                    for item in items {
                        print("로드 : \(item.type.rawValue) - \(item.value)\(item.unit)")
                    }
                    
                    state.rows = NutritionType.allCases.map { type in
                        if let matchedItem = items.first(where: { $0.type == type} ) {
                            return NutritionRowData(type: type, value: String(matchedItem.value))
                        } else {
                            return NutritionRowData(type: type, value: "")
                        }
                    }
                } catch {
                    print("로딩 실패")
                    state.rows = NutritionType.allCases.map {
                        NutritionRowData(type: $0, value: "")
                    }
                }
                return .none
            case let .toggleChanged(value):
                state.isEditable = value
                return .none
            }
        }
    }
}
