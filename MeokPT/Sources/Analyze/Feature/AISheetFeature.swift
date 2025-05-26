import ComposableArchitecture
import FirebaseAI

struct AISheetFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var generatedResponse: String = "AI 분석 결과를 기다리는 중입니다..."
        var isLoading: Bool = false
    }

    enum Action: Equatable {
        static func == (lhs: AISheetFeature.Action, rhs: AISheetFeature.Action) -> Bool {
            switch (lhs, rhs) {
            case (.onAppear, .onAppear):
                return true
            case (.aiResponse(let lhsResult), .aiResponse(let rhsResult)):
                switch (lhsResult, rhsResult) {
                case (.success(let lhsString), .success(let rhsString)):
                    return lhsString == rhsString
                case (.failure(let lhsError), .failure(let rhsError)):
                    return lhsError.localizedDescription == rhsError.localizedDescription
                default:
                    return false
                }
            default:
                return false
            }
        }
        
        case onAppear
        case aiResponse(Result<String, Error>)
    }
    
    @Dependency(\.firebaseAIService) var firebaseAIService
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            guard !state.isLoading && state.generatedResponse == "AI 분석 결과를 기다리는 중입니다..." else {
                return .none
            }
            state.isLoading = true
            return .run { send in
                let prompt = "분석 탭에서 추가한 모든 식단을 고려하여 프롬프트를 제작해주세요."
                await send(.aiResponse(Result {
                    try await firebaseAIService.generate(prompt)
                }))
            }
        case .aiResponse(.success(let text)):
            state.isLoading = false
            state.generatedResponse = text
            print("success - \(text)")
            return .none
        case .aiResponse(.failure(let error)):
            state.isLoading = false
            state.generatedResponse = "AI 분석 중 오류가 발생했습니다.: \(error.localizedDescription)"
            print("AI Error: \(error.localizedDescription)")
            return .none
        }
    }
}

struct FirebaseAIService {
    var generate: (_ prompt: String) async throws -> String
}

extension FirebaseAIService: DependencyKey {
    static var liveValue: Self = {
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        
        let model = ai.generativeModel(modelName: "gemini-2.0-flash")
        
        return Self(
            generate: { prompt in
                let response = try await model.generateContent(prompt)
                return response.text ?? "NO text in response"
            }
        )
    }()
}

extension DependencyValues {
    var firebaseAIService: FirebaseAIService {
        get { self[FirebaseAIService.self] }
        set { self[FirebaseAIService.self] = newValue }
    }
}

