import SwiftUI
import ComposableArchitecture

struct MealSelectionView: View {
    @Bindable var store: StoreOf<MealSelectionFeature>
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.currentDietList) { diet in
                    Button {
                        store.send(.dietCellTapped(id: diet.id))
                    } label: {
                        CommunityDietSelectView(diet: diet)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .navigationTitle("식단 선택")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("AppBackgroundColor"))
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading,
                        content: { Button(action: {
//                store.send(.closeButtonTapped)
            }) { Text("취소").foregroundStyle(Color("TextButton")) }})
        })
    }
}
