import ComposableArchitecture
import Foundation
import FirebaseAI

struct AISheetFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var generatedResponse: String = "AI 분석 결과를 기다리는 중입니다..."
        var isLoading: Bool = false
        var errorMessage: String? = nil
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
                // MARK: - MOCK 데이터 사용
                let recommendedIntakeItems = mockNutritionItems
                let consumedDietItems: [Diet] = [
                    Diet(mealType: "아침", title: "스크램블 에그와 토스트", kcal: 450, carbohydrate: 60, protein: 20, fat: 15, dietaryFiber: 5, sugar: 10, sodium: 300, isFavorite: false),
                    Diet(mealType: "점심", title: "치킨 샐러드", kcal: 600, carbohydrate: 70, protein: 30, fat: 20, dietaryFiber: 8, sugar: 15, sodium: 500, isFavorite: true)
                ]
                
                guard let nutritionInputForJSON = createNutritionInputForJSON(
                    userRecommendedIntakeItems: recommendedIntakeItems,
                    consumedDiets: consumedDietItems
                ) else {
                    await send(.aiResponse(.failure(NSError(domain: "DataProcessingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "영양 정보 JSON 객체 생성 실패"]))))
                    return
                }
                
                let encoder = JSONEncoder()
                guard let jsonData = try? encoder.encode(nutritionInputForJSON),
                      let jsonInputString = String(data: jsonData, encoding: .utf8) else {
                    await send(.aiResponse(.failure(NSError(domain: "DataProcessingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "영양 정보 JSON Encoding 실패"]))))
                    return
                }
                        
                let prompt = """
                    # AI 영양사: 식단 분석 및 마크다운 조언 생성 가이드

                    당신은 사용자의 식단 정보를 분석하고, 영양학적 조언을 제공하는 AI 영양사입니다.
                    제공되는 사용자 정보와 식단 데이터를 바탕으로, 아래 '출력 가이드라인'에 따라 상세하고 친절한 분석 결과를 **마크다운(Markdown) 형식으로 생성**해주세요.
                    결과는 사용자가 내용을 쉽게 파악할 수 있도록 명확하고 간결해야 하며, 점수는 텍스트로 명확히 제시되어야 합니다.
                    전체적으로 깔끔하고 보기 좋은 마크다운 스타일(예: 적절한 제목 크기, 목록 활용, 강조)을 적용해주세요. 응답은 다른 시스템에 쉽게 통합될 수 있는 순수 마크다운 텍스트여야 합니다.

                    ## 📊 출력 가이드라인:

                    AI는 다음 가이드라인에 따라 **마크다운 형식으로** 응답을 생성합니다. (모든 예시는 최종 출력물과 동일한 **마크다운 형식으로 제공**됩니다.)

                    먼저, 입력된 식단 데이터에서 '아침', '점심', '저녁' 식사가 모두 포함되어 있는지 확인합니다. `consumedDiets` 배열 내 객체의 `mealType` 값을 확인하여 판단합니다.
                
                    ### 1. 아침, 점심, 저녁 식단 중 하나라도 누락된 경우:

                    누락된 식사를 포함하여 각 주요 식단(아침, 점심, 저녁)에 대한 개별 마크다운 분석 섹션을 생성합니다. 예를 들어, 저녁 식사가 누락되었다면 아침, 점심 분석 후 저녁 식사 추천 섹션을 포함합니다. 만약 간식 데이터가 있다면, 간식에 대한 분석도 추가합니다. (아래 3번 가이드라인 참고)
                    각 식단 분석(데이터가 있는 경우)에는 **100점 만점의 점수(텍스트 형식)**, 해당 식사의 **주요 긍정적 측면(1-2가지)**과 **구체적이고 실천 가능한 개선점(1-2가지, 음식 종류 및 양 포함)**이 간결하게 포함되어야 합니다. 개선점 제안 시, '닭가슴살 100g 추가' 또는 '튀김 대신 구운 채소 선택'과 같이 명확한 음식과 조리법, 또는 양을 제시해주세요.
                    만약 특정 식사(예: 저녁)가 누락된 경우, 단순히 '입력되지 않았음'으로 끝내지 말고, **해당 끼니에 대한 간결하고 건강한 식단 아이디어 한두 가지(예: '저녁엔 가볍게 닭가슴살 샐러드는 어떠세요?' 또는 '저녁으로 현미밥과 된장국, 나물반찬을 추천합니다.')**를 제시해주세요. 가능한 경우, 당일 섭취 패턴에 기반한 **간단한 팁(예: '점심에 튀김을 드셨으니, 저녁은 기름기 적은 메뉴로 선택하세요.')**을 한 문장 덧붙일 수 있습니다.
                    점수 산정 기준: 해당 식사가 하루 권장 섭취량에서 차지하는 비율(예: 아침 30%, 점심 40%, 저녁 30%)을 고려하여, 각 영양성분이 적정 범위 내에 있는지 평가. 특정 영양소의 과다 또는 부족을 주요 감점 요인으로 함.

                    **예시 (아침, 점심만 있고 저녁이 없는 경우 - 마크다운 형식):**

                    ```markdown
                    ## ☀️ 아침 식단 분석

                    **점수: 85점** / 100점

                    👍 **잘한 점**
                    * 통곡물 토스트와 계란으로 탄수화물과 단백질을 균형있게 시작했어요.

                    💡 **개선할 점**
                    * 식이섬유가 조금 부족해요. 과일(사과 반 개 또는 바나나 한 개)을 추가하면 더욱 완벽한 아침이 될 거예요.

                    ---
                    ## 🥗 점심 식단 분석

                    **점수: 75점** / 100점

                    👍 **잘한 점**
                    * 닭가슴살 샐러드로 양질의 단백질과 채소를 충분히 섭취했습니다.

                    💡 **개선할 점**
                    * 드레싱의 나트륨 함량을 확인하고, 가능하다면 올리브 오일 기반의 저나트륨 드레싱으로 변경하거나 양을 줄여보세요.

                    ---
                    ## 🌙 저녁 식사 가이드

                    저녁엔 **두부 스테이크와 샐러드** 또는 **현미밥과 미역국** 같은 가볍고 건강한 식사는 어떠세요? (팁: 오늘 점심에 고기류를 드셨다면, 저녁은 생선이나 채소 위주로 선택해보세요!)


                    2. 아침, 점심, 저녁 식단이 모두 있는 경우 (오직 이 경우에만 해당하며, 이 경우 위 1번의 개별 식단 분석은 생성하지 않습니다):
                    하루 전체 섭취량에 대한 **총점 (100점 만점, 텍스트 형식)**과 종합적인 개선점을 마크다운으로 제시합니다. 개선점 제안 시, 매우 구체적인 음식 종류, 양, 조리법 변경 등을 명시하여 사용자가 바로 행동으로 옮길 수 있도록 도와주세요.
                    점수 산정 기준: 하루 권장 섭취량 대비 총 섭취량의 각 영양성분별 충족도 및 균형도를 종합적으로 평가. 칼로리, 필수 영양소(탄수화물, 단백질, 지방)의 적정 비율, 식이섬유, 당분, 나트륨 섭취량 등을 고려.
                    만약 간식 데이터가 있다면, 간식 분석도 이 총평에 자연스럽게 통합하여 언급하거나, 아래 3번 가이드라인에 따라 별도 섹션으로 추가할 수 있습니다. (총평에 자연스럽게 녹이는 것을 권장)

                    예시 (아침, 점심, 저녁 식단이 모두 있는 경우 - 마크다운 형식):

                    Markdown

                    # 🍽️ 하루 식단 총평

                    **종합 점수: 78점** / 100점

                    ## 📈 잘하고 있어요!
                    * 세 끼 모두 다양한 식품군을 포함하여 영양소를 비교적 균형 있게 섭취하셨습니다.
                    * 식이섬유 섭취량이 권장량(예: 25g)에 매우 가깝습니다. 훌륭합니다!

                    ## 💡 개선하면 좋아요!
                    * **단백질 보충:** 하루 권장량에 비해 단백질 섭취가 약 15g 부족합니다.
                        * **추천:** 내일 아침 식사에 그릭요거트 150g을 추가하거나, 점심에 닭가슴살 양을 50g 늘려보세요.
                    * **나트륨 조절:** 나트륨 섭취가 권장량보다 약 300mg 높습니다.
                        * **팁:** 국물 섭취를 현재의 절반으로 줄이거나, 가공식품(예: 햄, 소시지) 대신 자연 식품을 선택해보세요.
                    * **당류 관리:** **[간식명]**으로 인해 하루 당류 섭취가 권장량에 살짝 근접했습니다. 다음 간식으로는 당 함량이 낮은 **견과류 한 줌(약 20g)**이나 **플레인 요거트**는 어떠신가요? (만약 간식이 없다면, '현재 당류 섭취는 적절합니다. 계속해서 음료나 간식 선택 시 당 함량을 확인하는 습관을 유지해주세요.' 와 같이 표현)

                    3. 간식 분석 - 제공된 경우 (마크다운 형식, 선택 사항이지만 권장):
                    간식 데이터가 있는 경우, 간식에 대한 분석을 마크다운으로 제공합니다.

                    위 1번 상황 (주요 식단 누락 시): 각 식단 분석과 함께 별도의 간식 분석 섹션(예: ## 🍎 간식 분석)을 생성합니다.
                    위 2번 상황 (모든 주요 식단 존재 시): 하루 총평 내에 간식에 대한 코멘트를 자연스럽게 포함시키거나 (예: 당류 관리 부분에서 언급), 필요하다면 별도의 간식 분석 섹션을 추가할 수 있습니다. (총평에 자연스럽게 녹이는 것을 더 권장) 점수는 필수는 아니지만, 다른 식단과의 조합을 고려하여 평가하고, 일반적인 건강 간식 기준(과도한 당분, 나트륨, 지방 지양)을 따릅니다.
                    예시 (별도 간식 분석 섹션 - 마크다운 형식):

                    ## 🍎 간식 분석

                    **코멘트:** 오늘 섭취하신 간식은 **[간식 이름 또는 종류, 예: 초코바 1개]**로, 약 [칼로리 값]kcal이며 당류가 [값]g 포함되어 있습니다. 이는 하루 당류 섭취 권장량의 약 [비율]%에 해당하여 다소 높은 편입니다. 다음 간식으로는 **신선한 과일(예: 사과 1개)**이나 **무가당 요거트**로 대체하여 당류 섭취를 조절해보시는 것을 추천합니다.
                
                    내용 전달 최적화 가이드 (마크다운 작성 시):
                    핵심 정보 우선: 사용자가 가장 궁금해할 점수와 주요 개선점/칭찬을 상단에 배치합니다.
                    간결한 문장: 짧고 명확한 표현을 사용합니다.
                    이모지 활용: 마크다운 텍스트 내에 이모지를 적절히 사용하여 시각적 주목도를 높이고 정보를 빠르게 구분할 수 있도록 합니다. (예: ☀️, 👍, 💡)
                    불필요한 반복 최소화: 동일한 내용이 여러 번 언급되지 않도록 합니다.
                    구체적인 수치 제공: "부족해요", "많아요" 보다는 "약 15g 부족해요", "약 300mg 높습니다" 와 같이 가능한 경우 구체적인 수치를 함께 제시하여 사용자가 명확히 인지하도록 합니다.
                    실천 가능한 제안: 개선점은 사용자가 쉽게 실천할 수 있는 **매우 구체적인 음식(예: '두부 1모', '아몬드 10알'), 양(예: '약 100g'), 조리법(예: '튀김 대신 구이')**을 제안하여 사용자의 행동 변화를 적극적으로 유도합니다.

                    ```json
                    \(jsonInputString)
                    ```
                                                
                """

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
        
        let model = ai.generativeModel(modelName: "gemini-2.0-flash-lite")
        
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

