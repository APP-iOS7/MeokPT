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
import AuthenticationServices
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

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
    struct State {
        var emailText: String = ""
        var passWord: String = ""
        var isLoading: Bool = false
        var emailErrorMessage: String = ""
        var passwordErrorMessage: String = ""
        var loginErrorMessage: String = ""
        
        var navigationStack = StackState<Path.State>()
        
        var isCreatingUserDB: Bool = false
        var createUserDBError: String?
        
        var newSignUpUser: FirebaseAuth.User?
        
        var currentNonce: String?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case navigationStack(StackAction<Path.State, Path.Action>)
        case navigateToSignUpButtonTapped
        
        case loginButtonTapped
        case loginResponse(Result<AuthDataResult, Error>)
        case appleLoginButtonTapped
        case appleSignInResultReceived(Result<ASAuthorizationAppleIDCredential, Error>)
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
        case loginSuccessfully(FirebaseAuth.User)
        case signUpFlowCompleted(FirebaseAuth.User)
    }
    
    enum CancelID {
        case loginRequest
        case createUserDBRequest
        case appleSignInRequest
        case kakaoSignInRequest
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
                state.isLoading = false
                if authResult.additionalUserInfo?.isNewUser == true {
                    state.newSignUpUser = authResult.user
                    state.isCreatingUserDB = true
                    state.createUserDBError = nil
                    
                    let userId = authResult.user.uid
                    let initialUserData: [String: Any] = [
                        "nickname": NSNull(),
                        "profileImageUrl": NSNull(),
                        "postItems": []
                    ]
                    
                    return .run { send in
                        do {
                            let db = Firestore.firestore()
                            try await db.collection("users").document(userId).setData(initialUserData)
                            print("Firestore에 신규 사용자 초기 데이터 생성 완료. UID: \(userId)")
                            await send(._createUserDBResponse(.success(())))
                        } catch {
                            print("Firestore 신규 사용자 데이터 생성 실패: \(error.localizedDescription)")
                            await send(._createUserDBResponse(.failure(error)))
                        }
                    }
                    .cancellable(id: CancelID.createUserDBRequest)
                } else {
                    loginSuccess(&state, authResult)
                    return .send(.delegate(.loginSuccessfully(authResult.user)))
                }
                
            case .loginResponse(.failure(let error)):
                loginFailure(&state, error)
                return .none
                
            case .appleLoginButtonTapped:
                state.isLoading = true
                state.loginErrorMessage = ""
                state.currentNonce = randomNonceString()
                print("Apple 로그인 버튼 선택됨. Nonce 생성: \(state.currentNonce ?? "알 수 없음")")
                return .none
                
            case .appleSignInResultReceived(.success(let appleIDCredential)):
                guard let nonce = state.currentNonce else {
                    state.isLoading = false
                    state.loginErrorMessage = "Apple 로그인 실패: 보안 정보(Nonce)가 누락되었습니다."
                    print("오류: Apple 로그인 콜백 중 Nonce가 nil입니다.")
                    return .none
                }
                
                guard let appleIDToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    state.isLoading = false
                    state.loginErrorMessage = "Apple 로그인 실패: ID 토큰을 가져올 수 없습니다."
                    print("오류: Apple 인증 정보에서 ID 토큰 문자열을 가져올 수 없습니다.")
                    return .none
                }
                
                let credential = OAuthProvider.credential(providerID: .apple,
                                                          idToken: idTokenString,
                                                          rawNonce: nonce,
                                                          accessToken: appleIDCredential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) })
                state.currentNonce = nil
                
                return .run { send in
                    let result: Result<AuthDataResult, Error> = await Result {
                        try await Auth.auth().signIn(with: credential)
                    }
                    await send(.loginResponse(result))
                }
                .cancellable(id: CancelID.appleSignInRequest, cancelInFlight: true)
                
            case .appleSignInResultReceived(.failure(let error)):
                state.isLoading = false
                state.currentNonce = nil
                if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                    state.loginErrorMessage = "애플 로그인이 취소되었습니다."
                    print("Apple 로그인이 사용자에 의해 취소되었습니다.")
                } else {
                    state.loginErrorMessage = "애플 로그인에 실패했습니다.: \(error.localizedDescription)"
                    print("Apple 로그인 실패. 오류: \(error.localizedDescription)")
                }
                return .none
                
            case .kakaoLoginButtonTapped:
                state.isLoading = true
                state.loginErrorMessage = ""
                state.currentNonce = randomNonceString()
                print("Kakao 로그인 버튼 선택됨. Nonce 생성: \(state.currentNonce ?? "알 수 없음")")

                return .run { [nonce = state.currentNonce!] send in
                    let kakaoLoginResult: Result<OAuthToken, Error> = await Task { @MainActor in
                        await withCheckedContinuation { continuation in
                            if UserApi.isKakaoTalkLoginAvailable() {
                                UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                                    if let error = error {
                                        continuation.resume(returning: .failure(error))
                                    } else if let oauthToken = oauthToken {
                                        continuation.resume(returning: .success(oauthToken))
                                    } else {
                                        let unknownError = NSError(domain: "com.kakao.sdk", code: -999, userInfo: [NSLocalizedDescriptionKey: "알 수 없는 카카오 로그인 오류입니다."])
                                        continuation.resume(returning: .failure(unknownError))
                                    }
                                }
                            } else {
                                UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                                    if let error = error {
                                        continuation.resume(returning: .failure(error))
                                    } else if let oauthToken = oauthToken {
                                        continuation.resume(returning: .success(oauthToken))
                                    } else {
                                        let unknownError = NSError(domain: "com.kakao.sdk", code: -999, userInfo: [NSLocalizedDescriptionKey: "알 수 없는 카카오 계정 로그인 오류입니다."])
                                        continuation.resume(returning: .failure(unknownError))
                                    }
                                }
                            }
                        }
                    }.value

                    switch kakaoLoginResult {
                    case .success(let oauthToken):
                        guard let idTokenString = oauthToken.idToken else {
                            let errorMessage = "카카오 로그인에 성공했으나 ID 토큰을 받지 못했습니다. (Kakao Developers에서 OIDC 설정 및 동의항목 확인 필요)"
                            print("Kakao login error: \(errorMessage)")
                            let error = NSError(domain: "KakaoSDKError", code: -2, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                            await send(.loginResponse(.failure(error)))
                            return
                        }
                        
                        let providerID = "oidc.kakao_login"
                        
                        let credential = OAuthProvider.credential(
                            providerID: .custom(providerID),
                            idToken: idTokenString,
                            rawNonce: nonce,
                            accessToken: oauthToken.accessToken
                        )
                        
                        let firebaseResult: Result<AuthDataResult, Error> = await Result {
                            try await Auth.auth().signIn(with: credential)
                        }
                        await send(.loginResponse(firebaseResult))
                        
                    case .failure(let error):
                        print("Kakao 로그인 오류: \(error.localizedDescription)")
                        await send(.loginResponse(.failure(error)))
                    }
                }
                .cancellable(id: CancelID.kakaoSignInRequest, cancelInFlight: true)

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
                    state.isLoading = false
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
                if !state.navigationStack.isEmpty {
                    state.navigationStack.removeAll()
                }
                return .send(._signUpCompleted)

            case ._createUserDBResponse(.failure(let error)):
                state.isCreatingUserDB = false
                state.createUserDBError = "사용자 DB 생성 실패: \(error.localizedDescription)"
                print("사용자 DB 생성 실패 처리: \(error.localizedDescription)")
                if !state.navigationStack.isEmpty {
                    state.navigationStack.removeAll()
                }
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
        state.currentNonce = nil
        state.loginErrorMessage = ""
        state.emailErrorMessage = ""
        state.passwordErrorMessage = ""
    }

    private func loginFailure(_ state: inout LoginFeature.State, _ error: any Error) {
        state.isLoading = false
        state.currentNonce = nil
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
                case .credentialAlreadyInUse:
                    state.loginErrorMessage = "이 소셜 계정은 이미 다른 사용자와 연결되어 있습니다."
                default:
                    state.loginErrorMessage = "로그인 중 예상치 못한 오류가 발생했습니다. (코드: \(nsError.code))"
                }
            } else {
                state.loginErrorMessage = "알 수 없는 Firebase 인증 오류입니다. (코드: \(nsError.code))"
            }
        }
        else if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            state.loginErrorMessage = "Apple Sign In이 사용자에 의해 취소되었습니다."
        }
        else if nsError.domain == "KakaoSDK.ClientError" && nsError.code == KakaoSDKCommon.ClientFailureReason.Cancelled.hashValue {
             state.loginErrorMessage = nsError.localizedDescription
        }
        else {
            state.loginErrorMessage = "로그인을 다시 시도해주세요."
        }
        print("LoginFeature 오류: \(state.loginErrorMessage) | 원본 오류: \(error.localizedDescription)")
    }
}

private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("임의의 바이트를 생성할 수 없습니다. SecRandomCopyBytes가 OSStatus \(errorCode)로 실패했습니다.")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    return result
}
