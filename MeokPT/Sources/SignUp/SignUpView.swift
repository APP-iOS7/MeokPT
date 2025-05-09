//
//  SignUpView.swift
//  MeokPT
//
//  Created by 김동영 on 5/7/25.
//

import SwiftUI
import ComposableArchitecture

struct SignUpView: View {
    @Bindable var store: StoreOf<SignUpFeature>
    
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool
    @FocusState private var passwordVerifyFocused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack() {
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("이메일")
                            .font(.body)
                            .foregroundStyle(Color("AppSecondaryColor"))
                            .focused($emailFocused)
                        VStack (alignment: .leading) {
                            TextField(
                                "",
                                text: $store.emailText,
                                prompt: Text(verbatim: "example@example.com")
                            )
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
                                .focused($passwordFocused)
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
                        Spacer().frame(height: 25)
                        Text("비밀번호 확인")
                            .font(.body)
                            .foregroundStyle(Color("AppSecondaryColor"))
                        Spacer().frame(height: 16)
                        VStack(alignment: .leading) {
                            SecureField("******", text: $store.passWordVerify)
                                .textContentType(.oneTimeCode)
                                .focused($passwordVerifyFocused)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.placeholderText))
                            if !store.passwordVerifyErrorMessage.isEmpty {
                                Text(store.passwordVerifyErrorMessage)
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
                    if store.isLoading {
                        ProgressView()
                    }
                    Spacer()
                    Button(action: {store.send(.signUpButtonTapped)}) {
                        Text("회원가입")
                            .font(.subheadline.bold())
                            .foregroundStyle(!store.isFormValid ? Color.gray.opacity(0.5) : .black)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 60)
                    .background(!store.isFormValid ? Color("AppTintColor").opacity(0.5) : Color("AppTintColor"))
                    .clipShape(.rect(cornerRadius: 40))
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!store.isFormValid)
                    
                }
                .padding(.horizontal, 24)
                .navigationTitle("회원가입")
                .navigationBarTitleDisplayMode(.inline)
                .containerRelativeFrame([.horizontal, .vertical])
                .contentShape(Rectangle())
                .onTapGesture {
                    emailFocused = false
                    passwordFocused = false
                    passwordVerifyFocused = false
                }
            }
            .scrollDisabled(true)
            .background(Color("AppBackgroundColor"))
        }
    }
}

#Preview {
    SignUpView(
        store: Store(initialState: SignUpFeature.State()) {
            SignUpFeature()
        }
    )
}
