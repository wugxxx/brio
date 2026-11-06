import Foundation

struct WritingScene: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var subtitle: String
    var symbol: String
    var instruction: String
    var isBuiltIn: Bool

    init(id: UUID = UUID(), name: String, subtitle: String, symbol: String, instruction: String, isBuiltIn: Bool = false) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.symbol = symbol
        self.instruction = instruction
        self.isBuiltIn = isBuiltIn
    }

    static let builtIns = [
        WritingScene(name: "自然润色", subtitle: "更流畅，保留你的表达", symbol: "wand.and.stars", instruction: "修正语病，让表达自然流畅。保留原意、事实和作者的个人风格，不要过度改写。", isBuiltIn: true),
        WritingScene(name: "正式专业", subtitle: "邮件、汇报与工作沟通", symbol: "briefcase", instruction: "使用清晰、得体、专业的表达。语气自然，不堆砌敬语，不增加原文没有的信息。", isBuiltIn: true),
        WritingScene(name: "精简表达", subtitle: "删除冗余，直击重点", symbol: "text.alignleft", instruction: "删除重复、空泛和冗余内容，用尽可能简洁的语言保留所有关键信息。", isBuiltIn: true),
        WritingScene(name: "技术表达", subtitle: "准确、严谨、易于理解", symbol: "chevron.left.forwardslash.chevron.right", instruction: "优化为准确、严谨的技术表达。保留专业术语、代码和格式，避免含糊措辞和营销语气。", isBuiltIn: true),
        WritingScene(name: "中英互译", subtitle: "自然翻译，不拘泥字句", symbol: "character.book.closed", instruction: "中文翻译为英文，其他语言翻译为中文。译文自然准确，保留原文语气与格式。", isBuiltIn: true)
    ]
}

struct SceneStore {
    private let scenesKey = "scenes"
    private let legacyCustomScenesKey = "customScenes"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [WritingScene] {
        if let data = defaults.data(forKey: scenesKey),
           let scenes = try? JSONDecoder().decode([WritingScene].self, from: data),
           !scenes.isEmpty {
            return scenes
        }
        guard let data = defaults.data(forKey: legacyCustomScenesKey),
              let customScenes = try? JSONDecoder().decode([WritingScene].self, from: data) else {
            return WritingScene.builtIns
        }
        return WritingScene.builtIns + customScenes
    }

    func save(_ scenes: [WritingScene]) {
        guard let data = try? JSONEncoder().encode(scenes) else { return }
        defaults.set(data, forKey: scenesKey)
    }
}

struct PromptBuilder {
    static func make(scene: WritingScene, text: String, followUp: String, previousResult: String) -> String {
        if !followUp.isEmpty, !previousResult.isEmpty {
            return """
            场景要求：\(scene.instruction)
            原始文本：\(text)
            上一版结果：\(previousResult)
            用户调整要求：\(followUp)
            请根据调整要求修改上一版结果。仅返回修改后的正文，不要解释或添加引号。
            """
        }
        return """
        场景要求：\(scene.instruction)
        待处理文本：\(text)
        仅返回处理后的正文。保留事实、数字、人名和代码，不解释修改过程，不添加引号。
        """
    }
}
