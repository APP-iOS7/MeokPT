import SwiftUI
import ComposableArchitecture
import Kingfisher

struct MyPageView: View {
    @Bindable var store: StoreOf<MyPageFeature>

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
                                        .frame(width: 55, height: 55)
                                        .foregroundStyle(Color("AppSecondaryColor"))
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text(store.userProfile?.nickname ?? "회원가입 / 로그인")
                                    .font(.title3)
                                    .foregroundStyle(Color.primary)
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }

                // MARK: - 주요 기능
                Section(header: Text("분석용 정보 입력")) {
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
                
                Section(header: Text("저장한 분석")) {
                    NavigationLink {
                        AIHistoryView(store: Store(initialState: AIHistoryFeature.State()) { AIHistoryFeature() })
                    } label: {
                        Label("저장한 분석 리스트 보기", systemImage: "list.bullet.clipboard.fill")
                    }
                }

                // MARK: - 내 활동
                if store.currentUser != nil {
                    Section(header: Text("내 활동")) {
                        NavigationLink {
                            MyPostsView(store: Store(initialState: MyPostsFeature.State()) { MyPostsFeature() })
                        } label: {
                            Label("내가 쓴 글 보기", systemImage: "pencil")
                        }
                    }

                    // MARK: - 계정 설정
                    Section(header: Text("계정")) {
                        Button {
                            store.showLogoutAlert = true
                        } label: {
                            Label("로그아웃", systemImage: "lock.open")
                                .foregroundStyle(.primary)
                        }
                        .alert("로그아웃", isPresented: $store.showLogoutAlert) {
                            Button("취소", role: .cancel) {}
                            Button("로그아웃", role: .destructive) {
                                store.send(.logoutButtonTapped)
                            }
                        }

                        Button {
                            store.showWithDrawalAlert = true
                        } label: {
                            Label("회원탈퇴", systemImage: "xmark.circle")
                                .foregroundStyle(.red)
                        }
                        .alert("회원탈퇴", isPresented: $store.showWithDrawalAlert) {
                            Button("취소", role: .cancel) {}
                            Button("회원탈퇴", role: .destructive) {
                                store.send(.withDrawalButtonTapped)
                            }
                        } message: {
                            Text("게시한 글이 모두 삭제됩니다. 탈퇴 후에는 계정을 복구할 수 없습니다.")
                        }
                    }
                }
            }
            .padding(.top, 2)
            .navigationTitle("마이페이지")
            .scrollContentBackground(.hidden)
            .background(Color("AppBackgroundColor"))
        }
        .tint(Color("TextButton"))
    }
}

#Preview {
        MyPageView(
            store: Store(initialState: MyPageFeature.State()) {
                MyPageFeature()
            }
        )
}
