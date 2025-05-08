import SwiftUI

struct ConditionalProgressView: View {
    var current: Double
    var max: Double
    
    var progressColor: Color {
        current > max ? .red : Color("Green")
    }
    
    var progressValue: Double {
        min(current, max)
    }
    
    var body: some View {
        ProgressView(value: progressValue, total: max)
            .tint(progressColor)
    }
}
