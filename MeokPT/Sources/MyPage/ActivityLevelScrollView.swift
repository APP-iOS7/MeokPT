import SwiftUI

struct ActivityLevelScrollView: View {
    let allLevels: [ActivityLevel] = ActivityLevel.allCases
      @Binding var selectedLevel: ActivityLevel
      let onSelect: (ActivityLevel) -> Void

      var body: some View {
          VStack(alignment: .leading, spacing: 8) {
              Text("평소 활동량")
                  .font(.title3)
                  .foregroundStyle(Color("App title"))

              ScrollView(.horizontal, showsIndicators: false) {
                  HStack(spacing: 12) {
                      ForEach(allLevels) { level in
                          ActivityLevelItemView(
                              level: level,
                              isSelected: selectedLevel == level
                          )
                          .onTapGesture {
                              onSelect(level)
                          }
                      }
                  }
                  .padding(.horizontal) 
                  .padding(.vertical, 8)
              }
          }
      }
}
