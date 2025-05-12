import SwiftUI
import ComposableArchitecture

struct MyPageView: View {
    
    @State private var savedWeight: String = ""
    
    let store: StoreOf<MyPageFeature>
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                
                Text("마이페이지")
                    .font(.system(size: 34, weight: .bold))
                    .padding(.horizontal)
                    .padding(.top, 32)
                
                Spacer().frame(height: 24)
                
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color("AppTertiaryColor"))
                            .frame(width: 64, height: 64)
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .foregroundColor(Color(.white))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
                    
                HStack {
                    Text("회원가입 / 로그인")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    store.send(.loginSignUpButtonTapped)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(Color("AppTertiaryColor"))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.bottom, 32)
                
                HStack(spacing: 16) {
                    NavigationLink(destination: BodyInfoInputView()) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("신체정보 입력")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .semibold))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                            if !savedWeight.isEmpty {
                                Text("현재 몸무게: \(savedWeight)kg")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                                    .padding(.leading)
                            }
                        }
                        .padding()
                        .frame(minHeight: 90)
                        .background(Color("AppTertiaryColor"))
                        .cornerRadius(16)
                    }
                    
                    NavigationLink(destination: DailyCalorieView()) {
                        VStack {
                            HStack {
                                Text("하루 목표 칼로리")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .semibold))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                        .frame(minHeight: 90)
                        .background(Color("AppTertiaryColor"))
                        .cornerRadius(16)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 32)

                VStack(alignment: .leading, spacing: 24) {
                    NavigationLink(destination: MyPostsView()) {
                        Text("내가 쓴 글")
                    }
                    NavigationLink(destination: Text("로그아웃")) {
                        Text("로그아웃")
                    }
                    NavigationLink(destination: Text("회원탈퇴")) {
                        Text("회원탈퇴")
                    }
                }
                .foregroundColor(Color("AppTertiaryColor"))
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                
                Spacer()
            }
            .onAppear {
                if let saved = UserDefaults.standard.dictionary(forKey: "BodyInfo") as? [String: String] {
                    savedWeight = saved["weight"] ?? ""
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("AppBackgroundColor"))
        }
    }
}

#Preview {
    MyPageView(
        store: Store(initialState: MyPageFeature.State()) {
            MyPageFeature()
        }
    )
}
