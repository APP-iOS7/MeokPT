import SwiftUI

struct NutritionRowView: View {
    let name: String
    let value: String
    let unit: String
    let isEditable: Bool
    let onChange: (String) -> Void

    var focus: FocusState<String?>.Binding
    let rowID: String

    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(Color("App title"))

            Spacer()

            TextField("입력", text: Binding(
                get: { value },
                set: { newValue in onChange(newValue) }
            ))
            .disabled(!isEditable)
            .foregroundStyle(isEditable ? .primary : Color(.systemGray))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .frame(width: 80)
            .focused(focus, equals: rowID)

            Text(unit)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)  
    }
}
