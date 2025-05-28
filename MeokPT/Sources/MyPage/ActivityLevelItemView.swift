import SwiftUI

struct ActivityLevelItemView: View {
    let level: ActivityLevel
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(level.title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .black)

            Text(level.description)
                .foregroundColor(isSelected ? .white.opacity(0.9) : .gray)
                .multilineTextAlignment(.center)
                .frame(minHeight: 50)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .frame(width: 200, height: 130)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color("AppTintColor", bundle: nil) : Color("App CardColor"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: isSelected ? Color("AppTintColor", bundle: nil).opacity(0.4) : .gray.opacity(0.2),
                radius: isSelected ? 4 : 2,
                x: 0, y: 2)
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}
