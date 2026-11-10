import Foundation

protocol TextProviding: Sendable {
    func stream(prompt: String) -> AsyncThrowingStream<String, Error>
}

enum ProviderError: LocalizedError {
    case invalidConfiguration
    case invalidResponse
    case emptyResponse
    case network(String)
    case api(String)

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration: "请先在设置中填写有效的 Base URL、模型和 API Key。"
        case .invalidResponse: "无法解析模型响应，请重试。"
        case .emptyResponse: "模型没有返回内容，请重试。"
        case .network(let message): message
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
                    let model = model.trimmingCharacters(in: .whitespacesAndNewlines)
                    let apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard var url = URL(string: baseURL.trimmingCharacters(in: .whitespacesAndNewlines)),
                          let scheme = url.scheme, ["http", "https"].contains(scheme),
                          !model.isEmpty, !apiKey.isEmpty else {
                        throw ProviderError.invalidConfiguration
                    }
                    let basePath = url.path.hasSuffix("/") ? String(url.path.dropLast()) : url.path
                    if !basePath.hasSuffix("/chat/completions") {
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
                        var detail = ""
                        do {
                            for try await line in bytes.lines {
                                detail += line
                                if detail.count > 240 { break }
                            }
                        } catch {}
                        throw ProviderError.api(Self.errorMessage(status: httpResponse.statusCode, detail: detail))
                    }
                    var receivedContent = false
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data:") else { continue }
                        let payload = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                        if payload.isEmpty { continue }
                        if payload == "[DONE]" { break }
                        guard let chunk = try? JSONDecoder().decode(ChatChunk.self, from: Data(payload.utf8)),
                              let content = chunk.choices.first?.delta.content else { continue }
                        receivedContent = true
                        continuation.yield(content)
                    }
                    guard receivedContent else { throw ProviderError.emptyResponse }
                    continuation.finish()
                } catch let error as URLError {
                    continuation.finish(throwing: ProviderError.network(Self.networkMessage(for: error)))
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private static func errorMessage(status: Int, detail: String) -> String {
        let message: String
        switch status {
        case 400:
            message = "请求被拒绝（400）。"
        case 401, 403:
            message = "API Key 无效或没有访问权限，请在设置中检查。"
        case 404:
            message = "接口地址不正确，请检查 Base URL。"
        case 408:
            message = "请求超时，请稍后重试。"
        case 429:
            message = "请求过于频繁或额度不足，请稍后重试。"
        case 500...599:
            message = "AI 服务暂时不可用（\(status)），请稍后重试。"
        default:
            message = "AI 服务返回错误（\(status)）。"
        }
        let trimmed = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return message }
        return "\(message) \(String(trimmed.prefix(200)))"
    }

    private static func networkMessage(for error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            "网络连接已断开，请检查网络后重试。"
        case .timedOut:
            "请求超时，请重试或检查服务地址。"
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
            "无法连接到 AI 服务，请检查 Base URL。"
        case .secureConnectionFailed, .serverCertificateUntrusted:
            "安全连接失败，请检查服务地址与证书。"
        default:
            "网络请求失败：\(error.localizedDescription)"
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
