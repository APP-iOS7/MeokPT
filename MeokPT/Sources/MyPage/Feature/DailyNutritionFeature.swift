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
        case loadSavedData(ModelContext)
        case toggleChanged(Bool)
        
        case setSaveNutritionRows([NutritionRowData], ModelContext)
        case saveCurrentManualEntries(ModelContext)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .valueChanged(type, text):
                if let index = state.rows.firstIndex(where: { $0.type == type }) {
                    state.rows[index].value = text
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
                
            case let .setSaveNutritionRows(newRows, context):
                state.rows = newRows
                print("저장 시작 (계산된 데이터) - Nutrition Rows 업데이트됨: \(state.rows.map { "\($0.type.rawValue): \($0.value)"})")
                return performSave(state: state, context: context)
                
            case let .saveCurrentManualEntries(context):
                print("저장 시작 (수동 입력 데이터) - 현재 Rows: \(state.rows.map { "\($0.type.rawValue): \($0.value)"})")
                return performSave(state: state, context: context)
            }
        }
    }
    
    private func performSave(state: DailyNutritionFeature.State, context: ModelContext) -> EffectOf<DailyNutritionFeature> {
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
        
        for rowData in state.rows {
           guard let targetValue = Int(rowData.value) else {
               print("값 변환 실패: \(rowData.type.rawValue) - '\(rowData.value)'")
               continue
           }
           let newItem = NutritionItem(type: rowData.type, value: 0, max: targetValue)
           context.insert(newItem)
           print("저장 (NutritionItem): \(rowData.type.rawValue) - 최대값: \(targetValue)\(rowData.type.unit)")
       }

       do {
           try context.save()
           print("SwiftData 저장 완료 (DailyNutritionFeature)")
       } catch {
           print("SwiftData 저장 실패: \(error)")
       }
       return .none
    }
}
