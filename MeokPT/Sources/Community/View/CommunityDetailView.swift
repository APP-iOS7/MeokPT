import SwiftUI
import ComposableArchitecture
import Kingfisher
import AlertToast

struct CommunityDetailView: View {
    @Bindable var store: StoreOf<CommunityDetailFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    KFImage(URL(string: store.communityPost.userProfileImageURL))
                        .placeholder {
                            Image(systemName: "photo")
                                .foregroundStyle(Color.primary.opacity(0.7))
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 55, height: 55)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.communityPost.userNickname)
                        Text(store.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                
                Divider()
                
                Text(store.communityPost.content)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 8) {
                    CommunityDietCell(title: store.communityPost.dietName, kcal: store.kcal, carbohydrate: store.carbohydrate, protein: store.protein, fat: store.fat)
                    if store.communityPost.sharedCount > 0 {
                        HStack(spacing: 0) {
                            Text("이 식단을 ")
                            Text("\(store.communityPost.sharedCount)").bold()
                            Text("명이 추가했어요!")
                        }
                        .font(.caption)
                        .foregroundStyle(Color("AppSecondaryColor"))
                    }
                }
                
                if !store.communityPost.photoURL.isEmpty {
                    KFImage(URL(string: store.communityPost.photoURL))
                        .placeholder {
                            Image(systemName: "photo")
                                .foregroundStyle(Color.primary.opacity(0.7))
                        }
                        .resizable()
                        .scaledToFill()
                        .cornerRadius(20)
                } else {
                    Image("CommunityDetailEmptyImage")
                        .resizable()
                        .scaledToFill()
                        .cornerRadius(20)
                }
            }
            .padding(24)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button(action: {
                    store.send(.getShareButtonTapped)
                }) {
                    Text("내 식단 리스트에 추가")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color("AppTintColor"))
                        .cornerRadius(30)
                }
                .font(.headline.bold())
                .foregroundColor(.black)
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .toast(isPresenting: Binding(
            get: { store.showAlertToast },
            set: { _ in }
        )) {
            AlertToast(
                displayMode: .banner(.pop),
                type: .complete(Color("AppSecondaryColor")),
                title: store.toastMessage,
                subTitle: store.communityPost.dietName
            )
        }
        .navigationTitle(store.communityPost.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("AppBackgroundColor"))
    }
}

struct CommunityDietCell: View {
    var title: String
    var kcal: Double
    var carbohydrate: Double
    var protein: Double
    var fat: Double
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    Text(title)
                        .font(.title3.bold())
                        .lineLimit(1)
                    Spacer()
                }
                Spacer().frame(height: 4)
                Text(String(format: "%.0f kcal", kcal))
                    .font(.body)
            }
            Spacer().frame(height: 8)
            NutrientView(carbohydrate: carbohydrate, protein: protein, fat: fat)
                .padding(.horizontal)
        }
        .padding(24)
        .background(Color("App CardColor"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(uiColor: UIColor.separator), lineWidth: 1)
        )
    }
}

#Preview {
    CommunityDetailView(
        store: Store(initialState: CommunityDetailFeature.State(
            communityPost: dummyCommunityPost
        )) {
            CommunityDetailFeature()
        }
    )
}
