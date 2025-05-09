import SwiftUI

struct AIModalView: View {
    @Binding var isPresented: Bool

    @State private var backgroundOpacity: Double = 0
    @State private var modalHeight: CGFloat = UIScreen.main.bounds.height * 0.8
    @GestureState private var dragOffset: CGSize = .zero

    let minHeight: CGFloat = 100
    let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.8
    let dismissThreshold: CGFloat = 150

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    closeModal()
                }

            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 40)
                    .frame(width: 50, height: 5)
                    .foregroundStyle(.gray)
                    .padding(.top, 8)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                let newHeight = modalHeight - value.translation.height
                                if value.translation.height > dismissThreshold {
                                    closeModal()
                                } else {
                                    withAnimation(.easeOut) {
                                        modalHeight = min(max(newHeight, minHeight), maxHeight)
                                    }
                                }
                            }
                    )

                Text("AI 식단 평가")
                    .foregroundStyle(.black)
                    .font(.title3)

                Text("하나의 식단 평가와 달리, 분석 탭에서 추가한 모든 식단을 고려하여 프롬프트 제작한다.")
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .frame(height: modalHeight - dragOffset.height)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .roundedModal(20, corners: [.topLeft, .topRight])
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                backgroundOpacity = 0.4
            }
        }
    }

    private func closeModal() {
        withAnimation(.easeInOut(duration: 0.3)) {
            backgroundOpacity = 0
            isPresented = false
        }
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
