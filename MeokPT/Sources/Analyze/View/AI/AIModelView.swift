import SwiftUI

struct AIModalView: View {
    @Binding var isPresented: Bool
    @State private var modalHeight: CGFloat = 300
    @State private var dragOffset: CGFloat = 0
    
    let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.8
    let minHeight: CGFloat = 100
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }

            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 100, height: 10)
                    .foregroundStyle(.gray)
                    .padding(.top, 8)

                Text("AI 식단 평가")
                    .foregroundStyle(.black)
                    .font(.title3)

                Text("하나의 식단 평가와 달리, 분석 탭에서 추가한 모든 식단을 고려하여 프롬프트 제작한다.")
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .frame(
                width: UIScreen.main.bounds.width,
                height: max(min(modalHeight + dragOffset, maxHeight), minHeight)
            )
            .background(Color.white)
            .roundedModal(20, corners: [.topLeft, .topRight])
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newHeight = self.modalHeight - value.translation.height
                        if newHeight >= minHeight && newHeight <= maxHeight {
                            self.modalHeight = newHeight
                        }
                    }
                    .onEnded { value in
                        let finalHeight = self.modalHeight - value.translation.height
                        let clampedHeight = min(max(finalHeight, minHeight), maxHeight)
                        withAnimation(.easeOut) {
                            self.modalHeight = clampedHeight
                        }
                        self.dragOffset = 0
                    }
            )
            .transition(.move(edge: .bottom))
        }
        .animation(.easeInOut, value: isPresented)
        .ignoresSafeArea(edges: .bottom)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath (
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func roundedModal(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
