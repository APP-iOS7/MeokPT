import SwiftUI
import ComposableArchitecture
import Kingfisher

struct MyPageView: View {
    
    @State private var savedWeight: String = ""
    
    let store: StoreOf<MyPageFeature>
    
    @State private var showAlert = false
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Spacer().frame(height: 24)
                Button(action: {
                    if store.userProfile == nil {
                        store.send(.loginSignUpButtonTapped)
                    } else {
                        store.send(.profileEditButtonTapped)
                    }
                }) {
                    HStack {
                        HStack {
                            KFImage(URL(string: store.userProfile?.profileImageUrl ?? ""))
                                .placeholder {
                                    ZStack {
                                        Circle()
                                            .fill(Color("AppBackgroundColor"))
                                            .frame(width: 100, height: 100)
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 108, height: 108)
                                            .foregroundColor(Color("AppTertiaryColor"))
                                    }
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 108, height: 108)
                                .clipShape(Circle())
                            Spacer().frame(width: 26)
                            HStack {
                                Text(store.userProfile?.nickname ?? "회원가입 / 로그인")
                                    .foregroundColor(.white)
                                    .font(.title2.bold())
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("AppTintColor"))
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, minHeight: 157)
                    .background(Color("AppSecondaryColor"))
                    .cornerRadius(20)
                    .padding(.horizontal, 24)
                }
//                .disabled(store.userProfile != nil)
                Spacer().frame(height: 16)
                
                HStack {
                    HStack(spacing: 16) {
                        NavigationLink(destination: BodyNutritionContainerView(
                            initialTab: .bodyinInfoInput,
                            bodyInfoStore: Store(initialState: BodyInfoInputFeature.State()) {
                                BodyInfoInputFeature()
                            },
                            nutritionStore: Store(initialState:
                                DailyNutritionFeature.State()) {
                                    DailyNutritionFeature()
                            }
                        )) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("신체정보 입력")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color("AppTintColor"))
                                }
                                .padding()
                                .frame(maxWidth: 145, minHeight: 145)
                                .background(Color("AppSecondaryColor"))
                                .cornerRadius(20)
                            }
                        }
                        
                        NavigationLink(destination: BodyNutritionContainerView(
                            initialTab: .dailyNutrition,
                            bodyInfoStore: Store(initialState: BodyInfoInputFeature.State()) {
                                BodyInfoInputFeature()
                            },
                            nutritionStore: Store(initialState:
                                DailyNutritionFeature.State()) {
                                    DailyNutritionFeature()
                            }
                        )) {
                            VStack {
                                HStack {
                                    Text("하루 목표 칼로리")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color("AppTintColor"))
                                }
                                .padding()
                            }
                            .frame(maxWidth: 192, minHeight: 145)
                            .background(Color("AppSecondaryColor"))
                            .cornerRadius(20)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 40)
                
                if store.currentUser != nil {
                    VStack(alignment: .leading, spacing: 24) {
                        NavigationLink(destination: MyPostsView()) {
                            Text("내가 쓴 글")
                                .font(.headline)
                        }
                        Button(action: {
                            showAlert = true
                        }) {
                            Text("로그아웃")
                                .font(.headline)
                        }
                        .alert("로그아웃", isPresented: $showAlert) {
                            Button("취소", role: .cancel) {}
                            Button("로그아웃", role: .destructive) {
                                store.send(.logoutButtonTapped)
                            }
                        }
                        Button(action: {
                            store.send(.withDrawalButtonTapped)
                        }) {
                            Text("회원탈퇴")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(Color("AppTertiaryColor"))
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                }
                Spacer()
            }
            .navigationTitle("마이페이지")
            .onAppear {
                if let saved = UserDefaults.standard.dictionary(forKey: "BodyInfo") as? [String: String] {
                    savedWeight = saved["weight"] ?? ""
                }
            }
            .background(Color("AppBackgroundColor"))
        }
        .tint(Color(hex: "FF8F00"))
    }
}


#Preview {
    NavigationStack {
        MyPageView(
            store: Store(initialState: MyPageFeature.State()) {
                MyPageFeature()
            }
        )
    }
}
