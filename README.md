# Brio

Brio 是一款 macOS 原生 AI 写作助手：在任意应用中选中文本，通过预设场景润色、精简或翻译，再复制或替换回原文。

## 当前原型

- 菜单栏常驻与工作台全局快捷键（默认 `⇧⌘B`）
- 最多 5 个自定义场景快捷键，读取选区后直接生成
- 打开工作台时可选择保留或清空上次内容
- 场景新增、编辑、删除与持久化
- OpenAI 兼容接口的 SSE 流式生成
- 原文编辑、多轮微调、复制和选区替换
- API Key 保存在本机应用偏好设置

## 运行

需要 macOS 15 或更高版本、Swift 6.3 工具链。

```sh
swift run Brio
```

也可以生成可双击启动的应用：

```sh
zsh Scripts/build-app.sh
open .build/Brio.app
```

打包默认使用名为 `Brio Development` 的固定本地开发证书，避免重编译后辅助功能授权失效。可通过 `BRIO_CODESIGN_IDENTITY` 指定其他签名身份。首次使用全局选区读取和替换时，在“系统设置 → 隐私与安全性 → 辅助功能”中允许运行 Brio 的终端或打包后的应用。

点击菜单栏的 Brio 图标可打开工作台或设置。填写 OpenAI 兼容服务的 Base URL、模型 ID 和 API Key 后即可使用。

## 验证

```sh
swift build
```

测试位于 `Tests/BrioTests`。完整 Xcode 环境可运行 XCTest；当前仅有 Command Line Tools 的环境不包含 XCTest 或 Swift Testing，因而无法执行 `swift test`。

## 下一步

- 在常用原生、浏览器和 Electron 应用中验证选区兼容性
- 保留来源应用和 AX 元素引用，改善替换时的焦点恢复
- 增加生成历史和应用级场景推荐
- 添加签名、Info.plist 与可双击启动的 `.app` 打包流程
