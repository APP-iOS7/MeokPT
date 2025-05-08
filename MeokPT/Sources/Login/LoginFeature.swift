//
//  LoginFeature.swift
//  MeokPT
//
//  Created by 김동영 on 5/8/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable {
        var emailText: String = ""
        var passWord: String = ""
        
        var isEmailValid: Bool = true
        var emailErrorMessage: String = ""
        var isPasswordValid: Bool = true
        var passwordErrorMessage: String = ""
        
        
        var isFormValid: Bool {
            isEmailValid && isPasswordValid && !emailText.isEmpty && !passWord.isEmpty
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case loginButtonTapped
        case appleLoginButtonTapped
        case kakaoLoginButtonTapped
    }
    
    enum CancelID { case validation }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.emailText):
                if state.emailText.isEmpty {
                    state.isEmailValid = true
                    state.emailErrorMessage = ""
                } else {
                    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
                    if emailPredicate.evaluate(with: state.emailText) {
                        state.isEmailValid = true
                        state.emailErrorMessage = ""
                    } else {
                        state.isEmailValid = false
                        state.emailErrorMessage = "올바른 이메일 형식이 아닙니다."
                    }
                }
                return .none
                
            case .binding(\.passWord):
                if state.passWord.isEmpty {
                    state.isPasswordValid = true
                    state.passwordErrorMessage = ""
                } else if state.passWord.count >= 6 {
                    state.isPasswordValid = true
                    state.passwordErrorMessage = ""
                } else {
                    state.isPasswordValid = false
                    state.passwordErrorMessage = "6자 이상 입력해주세요."
                }
                return .none
                
            case .loginButtonTapped:
                return .none
                
            case .appleLoginButtonTapped:
                return .none
                
            case .kakaoLoginButtonTapped:
                return .none
                
            case .binding(_):
                return .none

            }
        }
    }
}
