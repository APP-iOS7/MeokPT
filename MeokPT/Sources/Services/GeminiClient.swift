import Foundation

struct GeminiResponse: Decodable {
    struct Candidate: Decodable {
        struct Content: Decodable {
            struct Part: Decodable {
                let text: String
            }
            let parts: [Part]
        }
        let content: Content
    }
    let candidates: [Candidate]
    
    var generatedText: String? {
        candidates.first?.content.parts.first?.text
    }
}

struct GeminiRequest: Encodable {
    struct Content: Encodable {
        let parts: [Part]
    }
    
    struct Part: Encodable {
        let text: String
    }
    let contents: [Content]
}

struct GeminiClient {
    var generateContent: (String) async throws -> String
    
    static func live(apiKey: String) -> Self {
        return Self (
            generateContent: { prompt in
                guard let url = URL(
                    string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)") else {
                    throw URLError(.badURL)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let requestBody = GeminiRequest(contents: [
                    .init(parts: [.init(text: prompt)])
                ])
                request.httpBody = try JSONEncoder().encode(requestBody)
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    // TODO: - 오류 응답 디코딩
                    throw URLError(.badServerResponse)
                }
                
                let decodeResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                guard let text = decodeResponse.generatedText else {
                    throw URLError(.cannotParseResponse)
                }
                return text
            }
        )
    }
}
