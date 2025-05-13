import ComposableArchitecture
import FirebaseAuth

@Reducer
struct SignUpFeature {
    @ObservableState
    struct State: Equatable {
        var emailText: String = ""
        var passWord: String = ""
        var passWordVerify: String = ""
        
        var isLoading: Bool = false
        var emailErrorMessage: String = ""
        var passwordErrorMessage: String = ""
        var passwordVerifyErrorMessage: String = ""
        
        var signUpErrorMessage: String = "" // 전체 회원가입 폼 에러
        var isFormValid: Bool {
            !emailText.isEmpty && !passWord.isEmpty && !passWordVerify.isEmpty &&
            emailErrorMessage.isEmpty && passwordErrorMessage.isEmpty && passwordVerifyErrorMessage.isEmpty && passWord == passWordVerify
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case signUpButtonTapped
        case signUpResponse(Result<AuthDataResult, Error>)
        case delegate(DelegateAction)
    }

    enum DelegateAction {
        case signUpCompletedSuccessfully(User)
    }

    enum CancelID { case signUpRequest }
    
    var body: some ReducerOf<Self> {
        // $store.emailText 같은 바인딩을 통해 자동으로 state를 업데이트
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            // .binding 액션이 발생했을 때 각 필드에 대한 유효성 검사 수행
            case .binding(\.emailText):
                validateEmail(&state)
                return .none
                
            case .binding(\.passWord):
                validatePassword(&state)
                if !state.passWordVerify.isEmpty {
                    validatePasswordVerify(&state)
                }
                return .none
                
            case .binding(\.passWordVerify):
                validatePasswordVerify(&state)
                return .none
                
            case .signUpButtonTapped:
                if !state.isFormValid { return .none }
                state.isLoading = true
                state.signUpErrorMessage = ""
                return .run { [email = state.emailText, password = state.passWord] send in
                    do {
                        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                        await send(.signUpResponse(.success(authResult)))
                    } catch {
                        await send(.signUpResponse(.failure(error)))
                    }
                }
                .cancellable(id: CancelID.signUpRequest, cancelInFlight: true)

            case .signUpResponse(.success(let authResult)):
                state.isLoading = false
                print("SignUpFeature: 회원가입 성공 - UID: \(authResult.user.uid)")
                return .send(.delegate(.signUpCompletedSuccessfully(authResult.user)))

            case .signUpResponse(.failure(let error)):
                SignUpFailure(&state, error)
                return .none
                
            case .delegate(_):
                return .none
                
            // 다른 모든 바인딩 변경 (명시적으로 처리하지 않은 경우)
            case .binding(_):
                return .none
            }
        }
    }
    private func validateEmail(_ state: inout SignUpFeature.State) {
        state.emailErrorMessage = ""
        state.signUpErrorMessage = ""
        
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
    
    private func validatePassword(_ state: inout SignUpFeature.State) {
        state.passwordErrorMessage = ""
        state.signUpErrorMessage = ""
        
        if state.passWord.isEmpty {
            state.passwordErrorMessage = "비밀번호를 입력해주세요."
        } else if state.passWord.count < 6 {
            state.passwordErrorMessage = "비밀번호는 6자 이상이어야 합니다."
        } else {
            state.passwordErrorMessage = ""
        }
    }
    
    private func validatePasswordVerify(_ state: inout SignUpFeature.State) {
        state.passwordVerifyErrorMessage = ""
        state.signUpErrorMessage = ""
        
        if state.passWordVerify.isEmpty {
            state.passwordVerifyErrorMessage = "비밀번호 확인을 입력해주세요."
        } else if state.passWord != state.passWordVerify {
            state.passwordVerifyErrorMessage = "비밀번호가 일치하지 않습니다."
        } else {
            state.passwordVerifyErrorMessage = ""
        }
    }
    
    private func SignUpFailure(_ state: inout SignUpFeature.State, _ error: any Error) {
        state.isLoading = false
        let nsError = error as NSError
        if nsError.domain == AuthErrorDomain, let errorCode = AuthErrorCode(rawValue: nsError.code) {
            switch errorCode {
            case .emailAlreadyInUse:
                state.emailErrorMessage = "이미 사용 중인 이메일입니다."
            case .invalidEmail:
                state.emailErrorMessage = "유효하지 않은 이메일 형식입니다."
            case .weakPassword:
                state.passwordErrorMessage = "비밀번호가 너무 약합니다. (6자 이상)"
            default:
                state.signUpErrorMessage = "회원가입 중 오류가 발생했습니다. (\(errorCode.rawValue))"
            }
        } else {
            state.signUpErrorMessage = "알 수 없는 오류가 발생했습니다."
        }
        print("SignUp Error: \(error.localizedDescription)")
    }
}
