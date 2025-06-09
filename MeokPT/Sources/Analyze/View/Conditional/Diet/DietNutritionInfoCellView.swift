import SwiftUI

struct DietNutritionInfoCellView: View {
    let name: String
    let value: String
    
    var body: some View {
        VStack {
            Text(name)
                .font(.caption)
                .foregroundStyle(Color("AppSecondaryColor"))
            Spacer().frame(height: 4)
            Text(value)
                .font(.body)
        }
    }
}
