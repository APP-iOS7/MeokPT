import SwiftUI

struct ConditionalProgressView: View {
    var current: Double
    var max: Double
    
    var progressColor: Color {
        current > max ? Color("Red") :  Color(red: 102.0/255.0, green: 204.0/255.0, blue: 102.0/255.0)
    }
    
    var progressValue: Double {
        min(current, max)
    }
    
    var body: some View {
        ProgressView(value: progressValue, total: max)
            .tint(progressColor)
    }
}

#Preview {
    ConditionalProgressView(current: 50, max: 100)
}
