import SwiftUI

struct DietEmptyView: View {
//    var onAddDietButtonTap: () -> Void

    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(Color("AppTintColor"))

            VStack(spacing: 10) {
                Text("오늘의 식단을 기록해보세요")
                    .font(.headline)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

//            Button {
//                onAddDietButtonTap()
//            } label: {
//                Text("식단 추가하기")
//                    .fontWeight(.semibold)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .foregroundColor(.white)
//                    .background(Color("AppTintColor"))
//                    .cornerRadius(12)
//            }
//            .padding(.horizontal, 40)
//            .padding(.top, 10)
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack { 
        Spacer()
        DietEmptyView()
        Spacer()
    }
    .background(Color(UIColor.systemGroupedBackground)) // 배경색 추가
    .edgesIgnoringSafeArea(.all)
}
