import SwiftUI

struct AnalyzeNutrientView: View {
    let name: String
    let value: String
    
    var body: some View {
        VStack {
            Text(name)
                .font(.caption)
                .foregroundStyle(Color("AppSecondaryColor"))
            Text(value)
        }
    }
}
