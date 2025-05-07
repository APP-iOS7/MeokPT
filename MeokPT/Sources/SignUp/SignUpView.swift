//
//  SignUpView.swift
//  MeokPT
//
//  Created by 김동영 on 5/7/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var emailText: String = ""
    @State private var password: String = ""
    @State private var passwordVerify: String = ""
    
    // 유효성 검사 상태 및 오류 메시지
    @State private var isEmailValid: Bool = true
    @State private var emailErrorMessage: String = ""
    @State private var isPasswordValid: Bool = true
    @State private var passwordErrorMessage: String = ""
    @State private var isPasswordVerifyValid: Bool = true
    @State private var passwordVerifyErrorMessage: String = ""
    
    // 모든 필드가 유효한지 확인하는 Computed Property
    var isSignUpButtonDisabled: Bool {
        !isEmailValid || !isPasswordValid || !isPasswordVerifyValid ||
        emailText.isEmpty || password.isEmpty || passwordVerify.isEmpty
    }
    
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
                            "",
                            text: $emailText,
                            prompt: Text(verbatim: "example@example.com")
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .onChange(of: emailText) {
                            validateEmail(email: emailText)
                        }
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(isEmailValid ? Color(.placeholderText) : .red)
                        if !isEmailValid && !emailText.isEmpty {
                            Text(emailErrorMessage)
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
                        SecureField(
                            "",
                            text: $password,
                            prompt: Text(verbatim: "******")
                        )
                        .onChange(of: password) {
                            validatePassword(password: password)
                            if !passwordVerify.isEmpty {
                                validatePasswordVerify(password: self.password, verify: passwordVerify)
                            }
                        }
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(isPasswordValid ? Color(.placeholderText) : .red)
                        if !isPasswordValid && !password.isEmpty {
                            Text(passwordErrorMessage)
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
                        SecureField(
                            "",
                            text: $passwordVerify,
                            prompt: Text(verbatim: "******")
                        )
                        .onChange(of: passwordVerify) {
                            validatePasswordVerify(password: self.password, verify: passwordVerify)
                        }
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(isPasswordVerifyValid ? Color(.placeholderText) : .red)
                        if !isPasswordVerifyValid && !passwordVerify.isEmpty {
                            Text(passwordVerifyErrorMessage)
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
                        .foregroundStyle(isSignUpButtonDisabled ? Color.gray.opacity(0.5) : .black)
                        .frame(maxWidth: .infinity)
                }
                .frame(height: 60)
                .background(isSignUpButtonDisabled ? Color("AppTintColor").opacity(0.5) : Color("AppTintColor"))
                .clipShape(.rect(cornerRadius: 40))
                .buttonStyle(PlainButtonStyle())
                .disabled(isSignUpButtonDisabled)
                
            }
            .padding(.horizontal, 24)
            .navigationTitle("회원가입")
            .navigationBarTitleDisplayMode(.inline)
            .containerRelativeFrame([.horizontal, .vertical])
            .background(Color("AppBackgroundColor"))
        }
    }
    
    func validateEmail(email: String) {
        if email.isEmpty {
            isEmailValid = true
            emailErrorMessage = ""
            return
        }
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        if emailPredicate.evaluate(with: email) {
            isEmailValid = true
            emailErrorMessage = ""
        } else {
            isEmailValid = false
            emailErrorMessage = "올바른 이메일 형식이 아닙니다."
        }
    }
    
    func validatePassword(password: String) {
        if password.isEmpty {
            isPasswordValid = true
            passwordErrorMessage = ""
            return
        }
        if password.count >= 6 {
            isPasswordValid = true
            passwordErrorMessage = ""
        } else {
            isPasswordValid = false
            passwordErrorMessage = "6자 이상 입력해주세요."
        }
    }
    
    func validatePasswordVerify(password: String, verify: String) {
        if verify.isEmpty {
            isPasswordVerifyValid = true
            passwordVerifyErrorMessage = ""
            return
        }
        if password == verify {
            isPasswordVerifyValid = true
            passwordVerifyErrorMessage = ""
        } else {
            isPasswordVerifyValid = false
            passwordVerifyErrorMessage = "비밀번호가 일치하지 않습니다."
        }
    }
}

#Preview {
    SignUpView()
}
