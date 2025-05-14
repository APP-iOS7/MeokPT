import SwiftUI
import ComposableArchitecture

struct MyPageView: View {
    
    @State private var savedWeight: String = ""
    
    let store: StoreOf<MyPageFeature>
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Spacer().frame(height: 24)
                Button(action: {
                    store.send(.loginSignUpButtonTapped)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(Color("AppTertiaryColor"))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.bottom, 32)
                
                HStack(spacing: 16) {
                    NavigationLink(destination: BodyInfoInputView(
                        store: Store(
                            initialState: BodyInfoInputFeature.State(),
                            reducer: {
                                BodyInfoInputFeature()
                            }
                    )
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("회원가입 / 로그인")
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
                    .background(Color("AppTertiaryColor"))
                    .cornerRadius(20)
                    .padding(.horizontal, 24)
                }
                Spacer().frame(height: 16)
                
                HStack {
                    HStack(spacing: 16) {
                        NavigationLink(destination: BodyInfoInputView()) {
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
                                .background(Color("AppTertiaryColor"))
                                .cornerRadius(20)
                            }
                        }
                        
                        NavigationLink(destination: DailyCalorieView()) {
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
                            .background(Color("AppTertiaryColor"))
                            .cornerRadius(20)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 40)
                
                VStack(alignment: .leading, spacing: 24) {
                    NavigationLink(destination: MyPostsView()) {
                        Text("내가 쓴 글")
                            .font(.headline)
                    }
                    NavigationLink(destination: Text("로그아웃")) {
                        Text("로그아웃")
                            .font(.headline)
                    }
                    NavigationLink(destination: Text("회원탈퇴")) {
                        Text("회원탈퇴")
                            .font(.headline)
                    }
                }
                .foregroundColor(Color("AppTertiaryColor"))
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                
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
