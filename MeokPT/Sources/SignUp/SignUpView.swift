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
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text("이메일")
                        .font(.body)
                        .foregroundStyle(Color("AppSecondaryColor"))
                    Spacer().frame(height: 16)
                    VStack(alignment: .leading) {
                        TextField(
                            "이메일", text: $store.emailText,
                            prompt: Text(verbatim: "example@example.com")
                        )
                        .keyboardType(.emailAddress)
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
                    Spacer().frame(height: 24)
                    HStack {
                        Text("비밀번호")
                            .font(.body)
                            .foregroundStyle(Color("AppSecondaryColor"))
                        Spacer()
                        Text("6자 이상, 영문 또는 숫자")
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
                    Spacer().frame(height: 24)

                    Text("비밀번호 확인")
                        .font(.body)
                        .foregroundStyle(Color("AppSecondaryColor"))
                    Spacer().frame(height: 16)
                    VStack(alignment: .leading) {
                        SecureField("******", text: $store.passWordVerify)
                            .textContentType(.oneTimeCode)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(store.isPasswordVerifyValid ? Color(.placeholderText) : .red)
                        if !store.isPasswordVerifyValid && !store.passWordVerify.isEmpty {
                            Text(store.passwordVerifyErrorMessage)
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
                Spacer()
                Button(action: {}) {
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
