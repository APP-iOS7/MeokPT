import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
struct DailyNutritionFeature {
    
    @Dependency(\.modelContainer) private var modelContainer

    private static let isEditableKey = "dailyNutritionIsEditablePreference"
    
    @ObservableState
    struct State: Equatable {
        var rows: [NutritionRowData] = NutritionType.allCases.map {
            NutritionRowData(type: $0, value: "")
        }
        var isEditable: Bool = false
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case valueChanged(type: NutritionType, text: String)
        case loadSavedData
        case toggleChanged(Bool)
        
        case setSaveNutritionRows([NutritionRowData])
        case saveCurrentManualEntries
        
        case onAppear
        case _isEditablePreferenceLoaded(Bool)
        case _loadedRows([NutritionRowData])
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let storedValue: Bool
                    if UserDefaults.standard.object(forKey: Self.isEditableKey) != nil {
                        storedValue = UserDefaults.standard.bool(forKey: Self.isEditableKey)
                    } else {
                        storedValue = false
                        UserDefaults.standard.set(storedValue, forKey: Self.isEditableKey)
                    }
                    await send(._isEditablePreferenceLoaded(storedValue))
                }

            case let ._isEditablePreferenceLoaded(loadedValue):
                state.isEditable = loadedValue
                print("UserDefaults에서 isEditable 로드: \(loadedValue)")
                return .none

            case let .valueChanged(type, text):
                if let index = state.rows.firstIndex(where: { $0.type == type }) {
                    state.rows[index].value = text
                }
                return .none

            case .loadSavedData:
                return .run { [modelContainer] send in
                    print("로딩 시작")

                    let rows: [NutritionRowData] = await MainActor.run {
                        let context = modelContainer.mainContext
                        let fetchDescriptor = FetchDescriptor<NutritionItem>()
                        
                        do {
                            let items = try context.fetch(fetchDescriptor)
                            print("Nutriitem 개수: \(items.count)")
                            
                            for item in items {
                                print("로드 : \(item.type.rawValue) - \(item.max)\(item.unit)")
                            }
                            
                            return NutritionType.allCases.map { type in
                                if let matchedItem = items.first(where: { $0.type == type }) {
                                    return NutritionRowData(type: type, value: String(matchedItem.max))
                                } else {
                                    return NutritionRowData(type: type, value: "")
                                }
                            }
                        } catch {
                            print("로딩 실패")
                            return NutritionType.allCases.map {
                                NutritionRowData(type: $0, value: "")
                            }
                        }
                    }

                    await send(._loadedRows(rows))
                }

            case let ._loadedRows(rows):
                state.rows = rows
                return .none

            case let .toggleChanged(value):
                state.isEditable = value
                return .run { _ in
                    print("UserDefaults에 isEditable 저장: \(value)")
                    UserDefaults.standard.set(value, forKey: Self.isEditableKey)
                }

            case let .setSaveNutritionRows(newRows):
                state.rows = newRows
                return .run { [self, state] _ in
                    await self.performSave(state: state)
                }

            case .saveCurrentManualEntries:
                return .run { [self, state] _ in
                    await self.performSave(state: state)
                }
            case .binding:
                return .none
            }
        }
    }

   @MainActor
   private func performSave(state: State) async {
       let context = self.modelContainer.mainContext
       
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
           print("NutritionItems saved successfully. Posting notification.")
           NotificationCenter.default.post(name: .didUpdateNutritionItems, object: nil)
           print("SwiftData 저장 완료 (DailyNutritionFeature)")
       } catch {
           print("SwiftData 저장 실패: \(error)")
       }
    }
}
