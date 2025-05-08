//
//  LoginView.swift
//  MeokPT
//
//  Created by 김동영 on 5/7/25.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    @Bindable var store: StoreOf<LoginFeature>
    
    var body: some View {
        NavigationStack{
            VStack {
                VStack(alignment: .leading) {
                    Text("이메일")
                        .font(.body)
                        .foregroundStyle(Color("AppSecondaryColor"))
                    Spacer().frame(height: 16)
                    VStack (alignment: .leading) {
                        TextField(
                            "",
                            text: $store.emailText,
                            prompt: Text(verbatim: "example@example.com")
                        )
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(store.isEmailValid ? Color(.placeholderText) : .red)
                        if !store.isEmailValid && !store.emailText.isEmpty {
                            Text(store.emailErrorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                        }
                        else {
                            Text(" ")
                                .font(.caption)
                                .padding(.top, 4)
                        }
                    }
                    Spacer().frame(height: 40)
                    HStack {
                        Text("비밀번호")
                            .font(.body)
                            .foregroundStyle(Color("AppSecondaryColor"))
                        Spacer()
                        Text("6자 이상, 영문, 숫자")
                            .font(.caption2)
                            .foregroundStyle(Color(.placeholderText))
                    }
                    Spacer().frame(height: 16)
                    VStack(alignment: .leading) {
                        SecureField("******", text: $store.passWord)
                            .textContentType(.oneTimeCode)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(store.isPasswordValid ? Color(.placeholderText) : .red)
                        if !store.isPasswordValid && !store.passWord.isEmpty {
                            Text(store.passwordErrorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                        } else {
                            Text(" ")
                                .font(.caption)
                                .padding(.top, 4)
                        }
                    }
                }
                .padding()
                
                Spacer().frame(height: 70)
                
                Button(action: {}) {
                    ZStack {
                        HStack {
                            Spacer().frame(width: 36)
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                            Spacer()
                            
                        }
                        HStack {
                            Spacer().frame(width: 36)
                            Text("이메일/비밀번호로 로그인")
                                .font(.body)
                                .foregroundStyle(.black)
                        }
                    }
                }
                .frame(width: 320, height: 60)
                .background(Color("AppTintColor"))
                .clipShape(.rect(cornerRadius: 40))
                .buttonStyle(PlainButtonStyle())
                
                Spacer().frame(height: 16)
                
                Button(action: {}) {
                    ZStack {
                        HStack {
                            Spacer().frame(width: 36)
                            Image(systemName: "apple.logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 28)
                                .foregroundStyle(.background)
                            Spacer()
                        }
                        HStack {
                            Spacer().frame(width: 36)
                            Text("Apple로 로그인")
                                .font(.body)
                                .foregroundStyle(.background)
                        }
                    }
                }
                .frame(width: 320, height: 60)
                .background(.primary)
                .clipShape(.rect(cornerRadius: 40))
                .buttonStyle(PlainButtonStyle())
                
                Spacer().frame(height: 16)
                
                Button(action: {}) {
                    ZStack {
                        HStack {
                            Spacer().frame(width: 36)
                            Image("kakaoLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 28)
                            Spacer()
                        }
                        HStack {
                            Spacer().frame(width: 36)
                            Text("카카오톡으로 로그인")
                                .font(.body)
                                .foregroundStyle(.black)
                        }
                    }
                }
                .frame(width: 320, height: 60)
                .background(.yellow)
                .clipShape(.rect(cornerRadius: 40))
                .buttonStyle(PlainButtonStyle())
                
                Spacer().frame(height: 40)
                Divider().frame(width: 160).padding()
                Button(action: {}) {
                    Text("회원가입")
                        .font(.headline)
                        .foregroundStyle(Color("AppTintColor"))
                }
                
            }
            .padding(.horizontal, 24)
            .navigationTitle("로그인 / 회원가입")
            .navigationBarTitleDisplayMode(.inline)
            .containerRelativeFrame([.horizontal, .vertical])
            .background(Color("AppBackgroundColor"))
        }
    }
}

#Preview {
    LoginView(
        store: Store(initialState: LoginFeature.State()) {
            LoginFeature()
        }
    )
}
