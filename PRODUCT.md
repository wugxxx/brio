# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

macOS 15+ native app. The `ios` value selects Apple's HIG-oriented design guidance; this product ships only on macOS.

## Users

People who write in other macOS apps — email, reports, documents, chat — and want to improve selected text without leaving the app they are in. Chinese-first, with bilingual Chinese/English work as a first-class case.

The specific primary segment (knowledge workers, developers, customer-support staff, or a broader audience) is not yet confirmed. Treat the paragraph above as the repository-supported hypothesis.

## Product Purpose

Brio is a native macOS AI writing assistant. Select text anywhere, trigger a saved scene with a shortcut, and receive a streamed rewrite in a floating panel that can copy the result or replace the original selection in place.

Success means the distance from selection to usable text is one keystroke and one short review, without opening a chat app or losing the current application.

## Positioning

Selection-first, in-place writing assistance: menu-bar resident, scene shortcuts, no separate chat surface. The mechanism a neighboring chat product could not copy truthfully is that Brio starts from text the user already selected in another app and can put the result back where it came from.

The exact positioning language is inferred from the implementation and has not been confirmed by the user.

## Operating Context

- Users work inside Mail, browsers, document editors, and chat apps, then return to that work.
- Reading and replacing another app's selection requires macOS Accessibility permission.
- The app is configured with an OpenAI-compatible Base URL, model ID, and API key.
- Up to five scene shortcuts read a selection and generate immediately.
- Results stream into a floating panel that can be pinned or dismissed, copied, or used to replace the source selection.
- The menu-bar icon opens either the selected-text flow or a blank workspace.

## Capabilities and Constraints

- Native SwiftUI/AppKit app, macOS 15+, Swift 6.3; runs as a menu-bar accessory (`LSUIElement`).
- Selection capture and replacement use the Accessibility API, with clipboard paste as a fallback.
- Generation uses an OpenAI-compatible `POST {base}/chat/completions` endpoint with SSE streaming.
- API credentials live in local app preferences; there is no account, cloud sync, or server-side history.
- The interface is Chinese; built-in scenes cover natural polish, professional tone, concision, technical writing, and Chinese/English translation.
- Users can add, edit, and delete scenes; shortcut bindings are limited to five.
- Distribution currently uses an ad-hoc-signed DMG. Pricing, licensing, notarization, analytics, and additional localizations are undecided.

## Brand Commitments

- Name: **Brio**.
- Tagline: **让表达恰如其分**.
- Voice: calm, precise, restrained, and specific. Avoid hype and generic productivity language.
- Existing visual assets are the app icon and the custom menu-bar glyph in `Resources/` and `Sources/Brio/App/MenuBarIcon.swift`.

## Evidence on Hand

- `README.md` documents the prototype, build flow, Accessibility requirement, and distribution path.
- No testimonials, customer logos, benchmarks, press coverage, or production usage data exist. Future work must not fabricate them.
- No committed screenshots or design-system record exist yet.

## Product Principles

1. Stay inside the user's app: every flow begins and ends with the selection.
2. One motion to value: selection, scene, result, with minimum ceremony.
3. Restraint over spectacle: the writing is the interface.
4. Local by default: credentials and content stay on the Mac except for the chosen API call.
5. Preserve the author's voice: improve the text without impersonating or over-rewriting it.

## Accessibility & Inclusion

- Accessibility permission is a core product dependency, not an optional integration.
- The interface must support VoiceOver labels, complete keyboard paths, larger text, and Reduce Motion where motion is decorative.
- Copy is Chinese-first; generated output must handle Chinese and English naturally.

## Open Decisions

- Primary user segment and the concrete usage scene that should lead future design decisions.
- Final positioning wording.
- Pricing, licensing, signing/notarization, analytics, and localization beyond Chinese.
- Whether a public landing page or marketing surface will exist. If it does, its build path is still unset.
