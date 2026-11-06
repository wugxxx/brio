import Foundation

protocol TextProviding: Sendable {
    func stream(prompt: String) -> AsyncThrowingStream<String, Error>
}

enum ProviderError: LocalizedError {
    case invalidConfiguration
    case invalidResponse
    case api(String)

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration: "请先在设置中填写有效的 Base URL、模型和 API Key。"
        case .invalidResponse: "无法解析模型响应，请重试。"
        case .api(let message): message
        }
    }
}

struct OpenAIProvider: TextProviding {
    let baseURL: String
    let model: String
    let apiKey: String

    func stream(prompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    guard var url = URL(string: baseURL.trimmingCharacters(in: .whitespacesAndNewlines)),
                          let scheme = url.scheme, ["http", "https"].contains(scheme),
                          !model.isEmpty, !apiKey.isEmpty else {
                        throw ProviderError.invalidConfiguration
                    }
                    if !url.path.hasSuffix("/chat/completions") {
                        url.append(path: "chat/completions")
                    }
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.timeoutInterval = 90
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    let body = ChatRequest(model: model, messages: [.init(role: "user", content: prompt)], stream: true)
                    request.httpBody = try JSONEncoder().encode(body)
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    guard let httpResponse = response as? HTTPURLResponse else { throw ProviderError.invalidResponse }
                    guard (200..<300).contains(httpResponse.statusCode) else {
                        var message = "AI 服务返回错误（\(httpResponse.statusCode)）。"
                        for try await line in bytes.lines { message += line }
                        throw ProviderError.api(message)
                    }
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let data = String(line.dropFirst(6))
                        if data == "[DONE]" { break }
                        guard let chunk = try? JSONDecoder().decode(ChatChunk.self, from: Data(data.utf8)),
                              let content = chunk.choices.first?.delta.content else { continue }
                        continuation.yield(content)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

private struct ChatRequest: Encodable {
    struct Message: Encodable { let role: String; let content: String }
    let model: String
    let messages: [Message]
    let stream: Bool
}

private struct ChatChunk: Decodable {
    struct Choice: Decodable {
        struct Delta: Decodable { let content: String? }
        let delta: Delta
    }
    let choices: [Choice]
}
