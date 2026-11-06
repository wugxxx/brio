import Foundation

struct ProviderSettings {
    private let defaults: UserDefaults
    var baseURL: String { defaults.string(forKey: "baseURL") ?? "https://api.openai.com/v1" }
    var model: String { defaults.string(forKey: "model") ?? "gpt-4.1-mini" }
    var apiKey: String { defaults.string(forKey: "apiKey") ?? "" }

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func save(baseURL: String, model: String) {
        defaults.set(baseURL, forKey: "baseURL")
        defaults.set(model, forKey: "model")
    }

    func saveAPIKey(_ apiKey: String) {
        defaults.set(apiKey, forKey: "apiKey")
    }

    func makeProvider() -> any TextProviding {
        return OpenAIProvider(baseURL: baseURL, model: model, apiKey: apiKey)
    }
}
