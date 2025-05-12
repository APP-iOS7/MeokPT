import SwiftUI

struct FavoriteToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            Image(systemName: configuration.isOn ? "heart.fill" : "heart")
        }
        .foregroundColor(Color("AppSecondaryColor"))
    }
}

#Preview {
    HStack {
        Toggle("Favorite", isOn: .constant(true))
            .toggleStyle(FavoriteToggleStyle())
            .padding()
        Toggle("Favorite", isOn: .constant(false))
            .toggleStyle(FavoriteToggleStyle())
            .padding()
    }
}
