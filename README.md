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

需要 macOS 15 或更高版本。当前 Command Line Tools 26.6 自带的 Swift 6.3.3 与 SDK 26.5 中的 Swift 6.3.2 模块不匹配，项目脚本默认使用安装在 `~/Library/Developer/Toolchains/swift-6.3.2-RELEASE.xctoolchain` 的工具链；也可以通过 `BRIO_SWIFT_TOOLCHAIN` 指定其他 6.3.2 工具链。

```sh
Scripts/swift run Brio
```

也可以生成可双击启动的应用：

```sh
zsh Scripts/build-app.sh
open .build/Brio.app
```

打包默认使用名为 `Brio Development` 的固定本地开发证书，避免重编译后辅助功能授权失效。可通过 `BRIO_CODESIGN_IDENTITY` 指定其他签名身份。首次使用全局选区读取和替换时，在“系统设置 → 隐私与安全性 → 辅助功能”中允许运行 Brio 的终端或打包后的应用。

点击菜单栏的 Brio 图标可打开工作台或设置。填写 OpenAI 兼容服务的 Base URL、模型 ID 和 API Key 后即可使用。

## 分发 DMG

不需要 Apple 开发者账号。打包脚本默认使用 ad-hoc 签名，不进行公证：

```sh
zsh Scripts/package-dmg.sh
```

输出为 `dist/Brio-<版本>.dmg` 和对应的 `.sha256` 文件。如果希望升级后保留辅助功能授权，可以改用固定的 `Brio Development` 自签证书（首次签名会请求钥匙串授权）：

```sh
BRIO_CODESIGN_IDENTITY='Brio Development' zsh Scripts/package-dmg.sh
```

首次启动未公证应用时，macOS 会拦截：

1. 将 Brio 拖入“应用程序”。
2. 打开“系统设置 → 隐私与安全性”，在“安全性”区域点“仍要打开”。
3. 或在终端执行 `xattr -dr com.apple.quarantine /Applications/Brio.app`。

随后在“系统设置 → 隐私与安全性 → 辅助功能”中允许 Brio。发布新版本时保持同一个 `Brio Development` 证书和 Bundle ID，辅助功能授权通常可以保留；更换证书或 Bundle ID 后需要重新授权。没有该证书时，可用 `BRIO_CODESIGN_IDENTITY=-` 做 ad-hoc 签名，但每次构建都可能需要重新授权。

## 图标

设计稿位于 `Resources/IconDesign/`：

- `Brio-Ink-1024.png`：深墨蓝主图标
- `Brio-Paper-1024.png`：浅色纸感版本
- `Brio-MenuBar-18/36/54/72.png`：菜单栏单色模板

`Resources/AppIcon.icns` 默认由深色主图标生成：

```sh
Scripts/build-iconset.sh
```

切换到浅色版本：

```sh
Scripts/build-iconset.sh Resources/IconDesign/Brio-Paper-1024.png
```

菜单栏图标由 `Sources/Brio/App/MenuBarIcon.swift` 按 18pt 矢量绘制，并作为 template image 自动适配深浅色菜单栏，不依赖位图缩放。

构建 `.app` 时会自动打包 `AppIcon.icns`。

## 验证

```sh
Scripts/swift build --disable-sandbox
```

测试位于 `Tests/BrioTests`。完整 Xcode 环境可运行 XCTest；当前仅有 Command Line Tools 的环境不包含 XCTest 或 Swift Testing，因而无法执行 `swift test`。

## 下一步

- 在常用原生、浏览器和 Electron 应用中验证选区兼容性
- 保留来源应用和 AX 元素引用，改善替换时的焦点恢复
- 增加生成历史和应用级场景推荐
- 补充 App 图标与版本发布流程
