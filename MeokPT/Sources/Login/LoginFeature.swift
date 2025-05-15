//
//  LoginFeature.swift
//  MeokPT
//
//  Created by 김동영 on 5/8/25.
//

import Foundation
import ComposableArchitecture
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@Reducer
struct Path {
    @ObservableState
    enum State: Equatable {
        case signUp(SignUpFeature.State)
    }

    enum Action {
        case signUp(SignUpFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.signUp, action: \.signUp) {
            SignUpFeature()
        }
    }
}

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable {
        var emailText: String = ""
        var passWord: String = ""
        var isLoading: Bool = false
        var emailErrorMessage: String = ""
        var passwordErrorMessage: String = ""
        var loginErrorMessage: String = ""
        
        var navigationStack = StackState<Path.State>()
        
        var isCreatingUserDB: Bool = false
        var createUserDBError: String?
        
        var newSignUpUser: User?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case navigationStack(StackAction<Path.State, Path.Action>)
        case navigateToSignUpButtonTapped
        
        case loginButtonTapped
        case loginResponse(Result<AuthDataResult, Error>)
        case appleLoginButtonTapped
        case kakaoLoginButtonTapped
        
        case closeButtonTapped
        case delegate(DelegateAction)
        
        case _createUserDBResponse(Result<Void, Error>)
        case _signUpCompleted
    }
    
    // DelegateAction에 User 객체를 포함하도록 정의 (AppFeature와 일치)
    enum DelegateAction: Equatable {
        static func == (lhs: LoginFeature.DelegateAction, rhs: LoginFeature.DelegateAction) -> Bool {
            switch (lhs, rhs) {
            case (.dismissLoginSheet, .dismissLoginSheet):
                return true
            case (.loginSuccessfully(let lUser), .loginSuccessfully(let rUser)):
                return lUser.uid == rUser.uid
            case (.signUpFlowCompleted(let lUser), .signUpFlowCompleted(let rUser)):
                return lUser.uid == rUser.uid
            default:
                return false
            }
        }
        
        case dismissLoginSheet
        case loginSuccessfully(User)
        case signUpFlowCompleted(User)
    }
    
    enum CancelID {
        case loginRequest
        case createUserDBRequest
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.emailText):
                state.emailErrorMessage = ""
                state.loginErrorMessage = ""
                return .none
                
            case .binding(\.passWord):
                state.passwordErrorMessage = ""
                state.loginErrorMessage = ""
                return .none
                
            case .loginButtonTapped:
                state.isLoading = true
                
                state.emailErrorMessage = ""
                state.passwordErrorMessage = ""
                state.loginErrorMessage = ""
                
                validateEmail(state: &state)
                validatePassword(state: &state)
                
                if !state.emailErrorMessage.isEmpty || !state.passwordErrorMessage.isEmpty {
                    state.isLoading = false
                    return .none
                }
                
                return .run { [email = state.emailText, password = state.passWord] send in
                    let result: Result<AuthDataResult, Error> = await Result {
                        try await Auth.auth().signIn(withEmail: email, password: password)
                    }
                    await send(.loginResponse(result))
                }
                .cancellable(id: CancelID.loginRequest, cancelInFlight: true)
                
            case .loginResponse(.success(let authResult)):
                loginSuccess(&state, authResult)
                return .send(.delegate(.loginSuccessfully(authResult.user)))
                
            case .loginResponse(.failure(let error)):
                loginFailure(&state, error)
                return .none
                
            case .appleLoginButtonTapped:
                return .run { _ in
                    do {
                        try Auth.auth().signOut()
                        print("로그아웃 성공")
                    }
                    catch {
                        print("로그아웃 실패: \(error)")
                    }
                }
                
            case .kakaoLoginButtonTapped:
                return .none
                
            case .closeButtonTapped:
                return .send(.delegate(.dismissLoginSheet))
                
            case .navigateToSignUpButtonTapped:
                state.navigationStack.append(.signUp(SignUpFeature.State()))
                return .none
                
            case ._signUpCompleted:
                guard let user = state.newSignUpUser else {
                    if let currentUser = Auth.auth().currentUser {
                        state.newSignUpUser = nil
                        return .send(.delegate(.signUpFlowCompleted(currentUser)))
                    }
                    state.newSignUpUser = nil
                    return .none
                }
                state.newSignUpUser = nil
                return .send(.delegate(.signUpFlowCompleted(user)))
            
            case .navigationStack(.element(id: _, action: .signUp(.delegate(.signUpCompletedSuccessfully(let userFromSignUp))))):
                state.newSignUpUser = userFromSignUp
                state.isCreatingUserDB = true
                state.createUserDBError = nil
                
                let userId = userFromSignUp.uid
                
                let initialUserData: [String: Any] = [
                    "nickname": NSNull(),
                    "profileImageUrl": NSNull(),
                    "postItems": []
                ]
                
                return .run { send in
                    do {
                        let db = Firestore.firestore()
                        try await db.collection("users").document(userId).setData(initialUserData)
                        print("Firestore에 사용자 초기 데이터 생성 완료. UID: \(userId)")
                        await send(._createUserDBResponse(.success(())))
                    } catch {
                        print("Firestore 사용자 데이터 생성 실패: \(error.localizedDescription)")
                        await send(._createUserDBResponse(.failure(error)))
                    }
                }
                .cancellable(id: CancelID.createUserDBRequest)
                
            case ._createUserDBResponse(.success):
                state.isCreatingUserDB = false
                print("사용자 DB 생성 성공 처리 완료.")
                // DB 생성 성공 후, SignUpView를 스택에서 제거하고 완료 알림
                state.navigationStack.removeAll()
                return .send(._signUpCompleted)

            case ._createUserDBResponse(.failure(let error)):
                state.isCreatingUserDB = false
                state.createUserDBError = "사용자 DB 생성 실패: \(error.localizedDescription)"
                print("사용자 DB 생성 실패 처리: \(error.localizedDescription)")
                state.navigationStack.removeAll()
                return .send(._signUpCompleted)
                
            case .delegate(_):
                return .none
            case .binding(_):
                return .none
            case .navigationStack:
                return .none
            }
        }
        .forEach(\.navigationStack, action: \.navigationStack) {
            Path()
        }
    }

    private func validateEmail(state: inout State) {
        if state.emailText.isEmpty {
            state.emailErrorMessage = "이메일을 입력해주세요."
        } else {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            if !emailPred.evaluate(with: state.emailText) {
                state.emailErrorMessage = "올바른 이메일 주소를 입력해주세요."
            } else {
                state.emailErrorMessage = ""
            }
        }
    }

    private func validatePassword(state: inout State) {
        if state.passWord.isEmpty {
            state.passwordErrorMessage = "비밀번호를 입력해주세요."
        } else if state.passWord.count < 6 {
            state.passwordErrorMessage = "비밀번호는 6자 이상이어야 합니다."
        } else {
            state.passwordErrorMessage = ""
        }
    }

    private func loginSuccess(_ state: inout LoginFeature.State, _ authResult: AuthDataResult) {
        state.isLoading = false
        state.loginErrorMessage = ""
        state.emailErrorMessage = ""
        state.passwordErrorMessage = ""
    }

    private func loginFailure(_ state: inout LoginFeature.State, _ error: any Error) {
        state.isLoading = false
        let nsError = error as NSError
        
        if nsError.domain == AuthErrorDomain {
            if let errorCode = AuthErrorCode(rawValue: nsError.code) {
                switch errorCode {
                case .invalidEmail, .userNotFound, .wrongPassword, .invalidCredential:
                    state.loginErrorMessage = "이메일 또는 비밀번호가 잘못되었거나, 가입되지 않은 사용자입니다."
                case .userDisabled:
                    state.loginErrorMessage = "관리자에 의해 이 사용자 계정이 비활성화되었습니다."
                case .networkError:
                    state.loginErrorMessage = "네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요."
                case .tooManyRequests:
                    state.loginErrorMessage = "로그인 시도 실패가 많아 이 계정에 대한 액세스가 일시적으로 비활성화되었습니다."
                default:
                    state.loginErrorMessage = "로그인 중 예상치 못한 오류가 발생했습니다. (코드: \(nsError.code))"
                }
            } else {
                state.loginErrorMessage = "알 수 없는 Firebase 인증 오류입니다. (코드: \(nsError.code))"
            }
        } else {
            state.loginErrorMessage = "예상치 못한 오류가 발생했습니다."
        }
        print("LoginFeature Error: \(state.loginErrorMessage) | Original: \(error.localizedDescription)")
    }
}
