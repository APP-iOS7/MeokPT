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

enum LoginRoute {
    case signUp
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
        
        var path = NavigationPath()
        var signUpState = SignUpFeature.State()
        
        var isCreatingUserDB: Bool = false
        var createUserDBError: String?
        var flowCompletedSuccessfully: Bool = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case loginButtonTapped
        case loginResponse(Result<AuthDataResult, Error>)
        case appleLoginButtonTapped
        case kakaoLoginButtonTapped
        
        case closeButtonTapped
        case delegate(DelegateAction)
        
        case push(LoginRoute)
        case popToRoot
        case signUpAction(SignUpFeature.Action)
        
        case _createUserDBResponse(Result<Void, Error>)
    }
    
    enum DelegateAction {
        case dismissLoginSheet
        case loginSuccessfully
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
                    do {
                        // Firebase 로그인
                        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                        // 성공 액션 전송
                        await send(.loginResponse(.success(authResult)))
                    } catch {
                        // 실패 액션 전송
                        await send(.loginResponse(.failure(error)))
                    }
                }
                .cancellable(id: CancelID.loginRequest, cancelInFlight: true)
                
            case .loginResponse(.success(let authResult)):
                loginSuccess(&state, authResult)
                return .send(.delegate(.dismissLoginSheet))
                
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
                
            case .push(.signUp):
                state.path.append(LoginRoute.signUp)
                return .none
                
            case .popToRoot:
                state.path.removeLast(state.path.count)
                if state.flowCompletedSuccessfully {
                    return .send(.delegate(.dismissLoginSheet))
                }
                return .none
            case .delegate(_):
                return .none
            case .binding(_):
                return .none
                
            case .signUpAction(.delegate(.signUpCompletedSuccessfully)):
                print("회원가입 성공, user DB 생성 시도")
                state.isCreatingUserDB = true
                state.createUserDBError = nil

                // 방금 회원가입한 사용자의 UID 가져오기
                guard let user = Auth.auth().currentUser else {
                    print("오류: 회원가입 후 현재 사용자를 가져올 수 없습니다.")
                    state.isCreatingUserDB = false
                    state.createUserDBError = "사용자 정보를 가져오는데 실패했습니다."
                    return .send(._createUserDBResponse(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Current user not found after sign up."]))))
                }
                let userId = user.uid
                
                // Firestore에 저장할 데이터
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
                
            case .signUpAction(_):
                return .none

            case ._createUserDBResponse(.success):
                state.isCreatingUserDB = false
                state.flowCompletedSuccessfully = true
                print("사용자 DB 생성 성공 처리 완료.")
                return .send(.popToRoot)

            case ._createUserDBResponse(.failure(let error)):
                state.isCreatingUserDB = false
                state.createUserDBError = "사용자 DB 생성 실패: \(error.localizedDescription)"
                state.flowCompletedSuccessfully = false
                print("사용자 DB 생성 실패 처리: \(error.localizedDescription)")
                return .send(.popToRoot)
            }
        }
        Scope(state: \.signUpState, action: \.signUpAction) {
            SignUpFeature()
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
    
    print("로그인 성공. 사용자 UID: \(authResult.user.uid)")
}

private func loginFailure(_ state: inout LoginFeature.State, _ error: any Error) {
    state.isLoading = false
    let nsError = error as NSError
    
    if nsError.domain == AuthErrorDomain {
        if let errorCode = AuthErrorCode(rawValue: nsError.code) {
            switch errorCode {
            case .invalidEmail, .userNotFound, .wrongPassword, .invalidCredential:
                state.loginErrorMessage = "이메일 또는 비밀번호가 잘못되었거나, 가입되지 않은 사용자입니다. 다시 확인 후 시도해주세요."
            case .userDisabled:
                state.loginErrorMessage = "관리자에 의해 이 사용자 계정이 비활성화되었습니다."
            case .networkError:
                state.loginErrorMessage = "네트워크 오류가 발생했습니다. 인터넷 연결을 확인하고 다시 시도해주세요."
            case .tooManyRequests:
                state.loginErrorMessage = "로그인 시도 실패가 많아 이 계정에 대한 액세스가 일시적으로 비활성화되었습니다. 나중에 다시 시도하거나 비밀번호를 재설정할 수 있습니다."
            default:
                state.loginErrorMessage = "로그인 중 예상치 못한 오류가 발생했습니다. 다시 시도해주세요. (오류 코드: \(nsError.code))"
                print("처리되지 않은 Firebase Auth 오류: \(error.localizedDescription), 코드: \(nsError.code)")
            }
        } else {
            state.loginErrorMessage = "알 수 없는 Firebase 인증 오류가 발생했습니다: \(error.localizedDescription) (코드: \(nsError.code))"
        }
    } else {
        state.loginErrorMessage = "예상치 못한 오류가 발생했습니다: \(error.localizedDescription)"
    }
    print(state.loginErrorMessage)
}

}
