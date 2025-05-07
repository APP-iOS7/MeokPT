import Foundation
import ComposableArchitecture

@Reducer
struct SignUpFeature {
    @ObservableState
    struct State: Equatable {
        var emailText: String = ""
        var passWord: String = ""
        var passWordVerify: String = ""
        
        var isEmailValid: Bool = true
        var emailErrorMessage: String = ""
        var isPasswordValid: Bool = true
        var passwordErrorMessage: String = ""
        var isPasswordVerifyValid: Bool = true
        var passwordVerifyErrorMessage: String = ""
        
        var isFormValid: Bool {
            isEmailValid && isPasswordValid && isPasswordVerifyValid &&
            !emailText.isEmpty && !passWord.isEmpty && !passWordVerify.isEmpty
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case signUpButtonTapped
    }
    
    enum CancelID { case validation }
    
    var body: some ReducerOf<Self> {
        // $store.emailText 같은 바인딩을 통해 자동으로 state를 업데이트
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            // .binding 액션이 발생했을 때 각 필드에 대한 유효성 검사 수행
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
                // 비밀번호가 변경되면 비밀번호 확인 필드도 다시 검사
                if !state.passWordVerify.isEmpty {
                    if state.passWord == state.passWordVerify {
                        state.isPasswordVerifyValid = true
                        state.passwordVerifyErrorMessage = ""
                    } else {
                        state.isPasswordVerifyValid = false
                        state.passwordVerifyErrorMessage = "비밀번호가 일치하지 않습니다."
                    }
                }
                return .none
                
            case .binding(\.passWordVerify):
                if state.passWordVerify.isEmpty {
                    state.isPasswordVerifyValid = true
                    state.passwordVerifyErrorMessage = ""
                } else if state.passWord == state.passWordVerify {
                    state.isPasswordVerifyValid = true
                    state.passwordVerifyErrorMessage = ""
                } else {
                    state.isPasswordVerifyValid = false
                    state.passwordVerifyErrorMessage = "비밀번호가 일치하지 않습니다."
                }
                return .none
            // 다른 모든 바인딩 변경 (명시적으로 처리하지 않은 경우)
            case .binding:
                return .none

            case .signUpButtonTapped:
                print("회원가입 버튼 탭됨: \(state.emailText), \(state.passWord)")
                return .none
            }
        }
    }
}
