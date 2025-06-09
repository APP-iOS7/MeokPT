import SwiftUI

struct ActivityLevelItemView: View {
    let level: ActivityLevel
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(level.title)
                .font(.headline)
                .foregroundColor(isSelected ? .black : .gray)

            Text(level.description)
                .foregroundColor(isSelected ? .black : .gray)
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
                .stroke(Color(UIColor.separator), lineWidth: 1)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}
