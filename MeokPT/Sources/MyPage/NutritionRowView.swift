import SwiftUI

struct NutritionRowView: View {
    let name: String
    let value: String
    let unit: String
    let isEditable: Bool
    let onChange: (String) -> Void
    
    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(Color("AppSecondaryColor"))

            Spacer()
            
            TextField("입력", text: Binding(
                get: { value },
                set: { newValue in onChange(newValue) }
            ))
            .disabled(!isEditable)
            .foregroundStyle(isEditable ? .primary: Color(.gray))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .frame(width: 80)
            Text(unit)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
}

 
