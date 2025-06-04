import SwiftUI
import ComposableArchitecture
import Kingfisher

struct MyPageView: View {
    
    @State private var showAlert = false
    let store: StoreOf<MyPageFeature>

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Profile Section
                Section {
                    Button {
                        store.send(store.userProfile == nil ? .loginSignUpButtonTapped : .profileEditButtonTapped)
                    } label: {
                        HStack(spacing: 16) {
                            KFImage(URL(string: store.userProfile?.profileImageUrl ?? ""))
                                .placeholder {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .foregroundStyle(.gray.opacity(0.5))
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text(store.userProfile?.nickname ?? "회원가입 / 로그인")
                                    .font(.headline)
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }

                // MARK: - 주요 기능
                Section {
                    NavigationLink {
                        BodyNutritionContainerView(
                            initialTab: .bodyinInfoInput,
                            bodyInfoStore: Store(initialState: BodyInfoInputFeature.State()) { BodyInfoInputFeature() },
                            nutritionStore: Store(initialState: DailyNutritionFeature.State()) { DailyNutritionFeature() }
                        )
                    } label: {
                        Label("신체정보 입력", systemImage: "person.fill")
                    }

                    NavigationLink {
                        BodyNutritionContainerView(
                            initialTab: .dailyNutrition,
                            bodyInfoStore: Store(initialState: BodyInfoInputFeature.State()) { BodyInfoInputFeature() },
                            nutritionStore: Store(initialState: DailyNutritionFeature.State()) { DailyNutritionFeature() }
                        )
                    } label: {
                        Label("하루 섭취량 입력", systemImage: "fork.knife")
                    }
                }

                // MARK: - 내 활동
                if store.currentUser != nil {
                    Section(header: Text("내 활동")) {
                        NavigationLink(destination: MyPostsView()) {
                            Label("내가 쓴 글", systemImage: "pencil")
                        }
                    }

                    // MARK: - 계정 설정
                    Section(header: Text("계정")) {
                        Button {
                            showAlert = true
                        } label: {
                            Label("로그아웃", systemImage: "lock.open")
                                .foregroundStyle(.primary)
                        }
                        .alert("로그아웃", isPresented: $showAlert) {
                            Button("취소", role: .cancel) {}
                            Button("로그아웃", role: .destructive) {
                                store.send(.logoutButtonTapped)
                            }
                        }

                        Button {
                            store.send(.withDrawalButtonTapped)
                        } label: {
                            Label("회원탈퇴", systemImage: "xmark.circle")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("마이페이지")
            .scrollContentBackground(.hidden)
            .background(Color("AppBackgroundColor"))
        }
        .tint(Color("AppTintColor"))
    }
}

#Preview {
        MyPageView(
            store: Store(initialState: MyPageFeature.State()) {
                MyPageFeature()
            }
        )
}
