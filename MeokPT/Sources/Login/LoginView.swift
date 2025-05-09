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
    
    @FocusState private var emailFocusedField
    @FocusState private var passwordFocusedField
    
    var body: some View {
            ScrollView{
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
                            .focused($emailFocusedField)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.placeholderText))
                            if !store.emailErrorMessage.isEmpty {
                                Text(store.emailErrorMessage)
                                    .font(.caption2)
                                    .foregroundColor(Color("AppSecondaryColor"))
                                    .padding(.top, 4)
                            }
                            else {
                                Text(" ")
                                    .font(.caption2)
                                    .padding(.top, 4)
                            }
                        }
                        Spacer().frame(height: 25)
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
                                .focused($passwordFocusedField)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.placeholderText))
                            if !store.passwordErrorMessage.isEmpty {
                                Text(store.passwordErrorMessage)
                                    .font(.caption2)
                                    .foregroundColor(Color("AppSecondaryColor"))
                                    .padding(.top, 4)
                            } else {
                                Text(" ")
                                    .font(.caption2)
                                    .padding(.top, 4)
                            }
                        }
                    }
                    .padding()
                    
                    VStack(alignment: .center) {
                        if !store.loginErrorMessage.isEmpty {
                            Text(store.loginErrorMessage)
                                .font(.caption)
                                .foregroundColor(Color.red)
                                .multilineTextAlignment(.center)
                        } else if store.isLoading {
                            ProgressView()
                        } else {
                            Text(" ")
                                .font(.caption)
                        }
                    }.frame(height: 50)
                    
                    Spacer().frame(height: 20)

                    Button(action: {
                        store.send(.loginButtonTapped)
                    }) {
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
                    
                    Divider().frame(width: 320).padding(8)
                    
                    Button(action: {
                        store.send(.appleLoginButtonTapped)
                    }) {
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
                    
                    Button(action: {
                        store.send(.kakaoLoginButtonTapped)
                    }) {
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
                    
                    Button(action: {
                        store.send(.signUpButtonTapped)
                    }) {
                        Text("회원가입")
                            .font(.headline)
                            .foregroundColor(Color("AppTintColor"))
                    }
                    
                }
                .padding(.horizontal, 24)
                .navigationTitle("로그인 / 회원가입")
                .navigationBarTitleDisplayMode(.inline)
                .containerRelativeFrame([.horizontal, .vertical])
                .contentShape(Rectangle())
                .onTapGesture {
                    emailFocusedField = false
                    passwordFocusedField = false
                }
            }
            .scrollDisabled(true)
            .background(Color("AppBackgroundColor"))
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading,
                            content: { Button(action: {
                    store.send(.closeButtonTapped)
                }) { Text("취소")
                        .foregroundColor(Color("AppTintColor"))
                }})
            })
    }
}

#Preview {
    NavigationStack {
        LoginView(
            store: Store(initialState: LoginFeature.State()) {
                LoginFeature()
            }
        )
    }
}
