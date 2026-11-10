---
name: Brio
description: A precision writing instrument in daylight and obsidian glass.
colors:
  canvas: '#f3f4f6'
  canvas-dark: '#111318'
  canvas-deep-dark: '#0d0f14'
  surface: '#ffffff'
  surface-dark: '#1a1b21'
  surface-raised-dark: '#1e1f25'
  surface-sunken: '#e5e7eb'
  surface-sunken-dark: '#0c0e13'
  surface-hover: '#f9fafb'
  surface-hover-dark: '#282a2f'
  glass: 'rgba(255, 255, 255, 0.85)'
  glass-dark: 'rgba(13, 15, 20, 0.78)'
  text-primary: '#111827'
  text-primary-dark: '#e2e2e9'
  text-secondary: '#4b5563'
  text-secondary-dark: '#c7c4d8'
  text-muted: '#9ca3af'
  text-muted-dark: '#918fa1'
  border: '#e5e7eb'
  border-dark: '#464555'
  hairline: 'rgba(17, 24, 39, 0.08)'
  hairline-dark: 'rgba(255, 255, 255, 0.08)'
  accent: '#0066ff'
  accent-dark: '#4f46e5'
  accent-hover: '#0050cb'
  accent-hover-dark: '#4338ca'
  accent-soft: 'rgba(0, 102, 255, 0.08)'
  accent-soft-dark: 'rgba(79, 70, 229, 0.18)'
  accent-text: '#0050cb'
  accent-text-dark: '#c3c0ff'
  secondary: '#4f46e5'
  secondary-dark: '#38bdf8'
  tertiary: '#10b981'
  tertiary-dark: '#a855f7'
  success: '#10b981'
  success-dark: '#4edea3'
  error: '#ba1a1a'
  error-dark: '#ffb4ab'
  error-soft: '#ffdad6'
  error-soft-dark: 'rgba(239, 68, 68, 0.15)'
  on-accent: '#ffffff'
typography:
  display:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.025em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.015em
  headline-sm:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: -0.005em
  body-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.02em
  kbd:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.01em
  code:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0em
rounded:
  sm: 4px
  keycap: 5px
  row: 6px
  md: 8px
  lg: 12px
  xl: 16px
  hud: 20px
  '2xl': 24px
  full: 9999px
spacing:
  '2xs': 2px
  xs: 4px
  sm: 6px
  md: 10px
  lg: 16px
  xl: 24px
  gutter: 12px
  gutter-compact: 8px
components:
  button-primary:
    backgroundColor: '{colors.accent}'
    textColor: '{colors.on-accent}'
    typography: '{typography.label-md}'
    rounded: '{rounded.md}'
    padding: '0 12px'
    height: 30px
  button-primary-dark:
    backgroundColor: '{colors.accent-dark}'
    textColor: '{colors.on-accent}'
    typography: '{typography.label-md}'
    rounded: '{rounded.md}'
    padding: '0 10px'
    height: 28px
  button-ghost:
    backgroundColor: '{colors.surface}'
    textColor: '{colors.text-primary}'
    typography: '{typography.label-md}'
    rounded: '{rounded.md}'
    padding: '0 12px'
    height: 30px
  button-ghost-dark:
    backgroundColor: 'rgba(255, 255, 255, 0.05)'
    textColor: '{colors.text-primary-dark}'
    typography: '{typography.label-md}'
    rounded: '{rounded.md}'
    padding: '0 10px'
    height: 28px
  command-row:
    textColor: '{colors.text-primary}'
    typography: '{typography.body-md}'
    rounded: '{rounded.row}'
    padding: '0 10px'
    height: 38px
  command-row-dark:
    textColor: '{colors.text-primary-dark}'
    typography: '{typography.body-md}'
    rounded: '{rounded.row}'
    padding: '8px 12px'
    height: 38px
  inspector-card:
    backgroundColor: '{colors.surface}'
    textColor: '{colors.text-primary}'
    typography: '{typography.body-md}'
    rounded: '{rounded.lg}'
    padding: 16px
  inspector-card-dark:
    backgroundColor: 'rgba(255, 255, 255, 0.03)'
    textColor: '{colors.text-primary-dark}'
    typography: '{typography.body-md}'
    rounded: '{rounded.lg}'
    padding: 16px
---

# Design System: Brio

## Overview

**Creative North Star: "The Precision Instrument"**

Brio is a writing tool that should feel machined rather than assembled: one compact surface, one clear action, and no ceremony between the selected text and the improved text. The interface borrows the physical language of professional macOS utilities — hairline framing, dense rows, tactile keycaps, keyboard-first states — so the product feels fast before the user has learned it.

The system has two complete expressions of the same instrument. **Daylight** is the light theme: a cool, luminous work surface made of matte paper, crisp white panels, and an electric blue action color. **Obsidian Glass** is the dark theme: smoked translucent layers, indigo action, cyan signals, and violet for creative expansion. The information architecture, type scale, spacing rhythm, and component anatomy do not change between themes. Only the light, material, and accent spectrum change.

| Theme | Source character | Canvas | Material | Action accent |
|---|---|---|---|---|
| Daylight | Raycast Pro Light | Cool paper | White panels with 1px framing | Brio Blue |
| Obsidian Glass | Obsidian Glass | Pitch obsidian | Frosted glass, tonal wells | Electric Indigo |

**Key Characteristics:**
- **Precision over decoration.** Structural 1px borders, strict alignment, and compact geometry carry the identity.
- **Text is the interface.** Chrome stays quiet; hierarchy, spacing, and focus states direct attention to the writing.
- **Density with air.** A 4px sub-grid supports power-user density without collapsing into visual noise.
- **Physical feedback.** Keycaps, segmented controls, and inset highlights make interaction feel tactile.
- **One motion to value.** The result surface is always closer to the action than a secondary navigation model would be.

**The Two Lamps Rule.** Both themes are the same product under different light. Never change layout, component hierarchy, or interaction order when switching appearance.

## Colors

The palette is cool, technical, and restrained: tinted neutrals do most of the work, one accent carries action, and status colors appear only when they have something to say. The same semantic role maps to a different light and dark value; views should never branch on raw hex values.

### Primary
- **Brio Blue** (`accent`, `accent-hover`, `accent-soft`): the Daylight action color. Use it for primary buttons, selected rows, text caret, focus rings, and active execution indicators.
- **Electric Indigo** (`accent-dark`, `accent-hover-dark`, `accent-soft-dark`): the Obsidian action color. Use it for primary buttons, focused selection, active row indication, and AI activity.
- **Indigo Ink** (`accent-text`): the light theme's high-contrast accent text. Use it when an accent-colored label or glyph must remain readable on white.
- **Lavender Signal** (`accent-text-dark`): the dark theme's accent text and icon tint. This is the source palette's `primary` role. It is a foreground tint, **not** a button fill.

**The Accent Fill Rule.** In dark appearance, `accent-text-dark` is for text and glyphs; `accent-dark` is the only action fill. Reversing them produces lavender buttons with the wrong contrast.

### Secondary
- **Deep Indigo** (`secondary`): optional light-theme auxiliary accent for secondary flows, command icons, and compact badges. It should not compete with Brio Blue inside the same control group.
- **Cyan Flare** (`secondary-dark`): dark-theme signal for streaming generation, variable tokens, diff insertion, and non-blocking hints. Cyan means "changing" or "incoming", not "confirm".

### Tertiary
- **Precision Emerald** (`tertiary`, `success`): light-theme success, healthy daemon, verified result, and live status. Use as a dot, bar, or compact icon; avoid filling large surfaces with green.
- **Violet Glow** (`tertiary-dark`): dark-theme creative expansion, rewrite modes, and macro badges. Violet denotes transformation, not success.
- **Mint Status** (`success-dark`): the dark-theme status green. It is a small-area signal and must never become a primary action color. The dark source palette has no explicit success role; this value carries the light system's mint fixed-dim into dark appearance so status meaning stays stable.

### Neutral
- **Canvas** (`canvas` / `canvas-dark`): the structural backcloth of the workspace. Daylight uses a cool gray rather than pure white on broad surfaces; Obsidian uses a near-black with a blue-violet cast.
- **Surface** (`surface` / `surface-dark`, `surface-raised-dark`): floating panels, cards, inputs, and popover bodies. Daylight reserves pure white for elevated content.
- **Sunken Surface** (`surface-sunken` / `surface-sunken-dark`): segmented tracks, inert search troughs, and recessed wells.
- **Hover Surface** (`surface-hover` / `surface-hover-dark`): rows and controls under pointer hover when accent selection is not appropriate.
- **Text Primary** (`text-primary` / `text-primary-dark`): headings, data values, and active labels.
- **Text Secondary** (`text-secondary` / `text-secondary-dark`): descriptions, metadata, and input labels.
- **Text Muted** (`text-muted` / `text-muted-dark`): placeholders, inactive shortcuts, and disabled states. Never use muted text for content the user must read to complete the task.
- **Hairline** (`hairline` / `hairline-dark`, `border` / `border-dark`): structural dividers and control outlines. Neutral borders are quieter than text; they should be visible at 1px, not dominant.
- **Error** (`error` / `error-dark`, `error-soft` / `error-soft-dark`): destructive actions and inline failures. Dark error uses a salmon foreground on a low-opacity red wash.

**The 85/10/5 Rule.** Roughly 85% of the surface is neutral, no more than 10% is accent, and no more than 5% is status color. If an accent feels decorative, remove it.

**The Hairline Rule.** Structural separation uses a 1px line before it uses a shadow, and a shadow before it uses a larger gap. Do not stack all three around the same edge.

### Named Rules
**The Theme Is Not a Tint Rule.** Do not derive dark mode by inverting or dimming light colors. Daylight and Obsidian are separately tuned palettes that share semantic roles.

## Typography

**Display and Body Font:** Inter, with the macOS system sans-serif as fallback.  
**Monospace Font:** JetBrains Mono for paths, code, hashes, and parameter syntax.

**Character:** Inter provides the neutral, compact clarity of a native desktop tool. Tight negative tracking on headings gives the interface its architectural density; the monospace face is a functional marker, never a stylistic costume.

### Hierarchy
| Token | Size / line height | Weight | Tracking | Purpose |
|---|---|---|---|---|
| `display` | 32px / 40px | 600 | -0.025em | Rare top-level identity or empty-state statement. |
| `headline-lg` | 24px / 32px | 600 | -0.02em | Panel or section title. |
| `headline-md` | 20px / 28px | 600 | -0.015em | Command hero and prominent dialog title. |
| `headline-sm` | 16px / 24px | 600 | -0.01em | Card header and grouped settings title. |
| `body-lg` | 15px / 22px | 400 | -0.005em | Primary reading text in the result surface. |
| `body-md` | 13px / 18px | 400 | 0 | Default UI text, list rows, and inputs. |
| `body-sm` | 12px / 16px | 400 | 0 | Supporting copy and compact metadata. |
| `label-md` | 12px / 16px | 500 | 0.01em | Buttons, tabs, and control labels. |
| `label-sm` | 11px / 14px | 500 | 0.02em | Badges, captions, and dense metadata. |
| `kbd` | 11px / 14px | 600 | 0.01em | Shortcut symbols inside keycaps. |
| `code` | 12px / 16px | 400 | 0 | Paths, code, hashes, and terminal references. |

**Theme adjustments.** In Obsidian Glass, the command input may use an 18px / 24px, weight-500 headline treatment to keep the HUD compact. Streamed result text may use a 20px line height for `body-md`. These are compact-density exceptions, not a second type hierarchy.

**The Tight Title Rule.** All headings at `headline-sm` and above use negative tracking. Never add positive tracking to a heading to make it feel "premium".

**The 12px Floor Rule.** Interactive text does not fall below 11px, and sustained reading text does not fall below 12px. If content does not fit, reduce copy or spacing before shrinking type.

**The Tabular Figures Rule.** Numbers that update in place — token counts, timers, progress, model parameters — must use tabular figures (`tnum`) to prevent horizontal jitter.

## Layout

Brio uses a fixed desktop composition rather than a responsive web stack. The floating HUD standardizes at **640px** wide with a dynamic height from **72px** to **480px**. The expanded workspace keeps a fixed navigation rail and lets the detail region absorb the remaining width.

| Region | Size / behavior | Notes |
|---|---|---|
| Floating HUD | 640px; 72–480px high | Primary writing surface; does not stretch edge-to-edge. |
| Navigation rail | 220px fixed | Settings and workspace navigation. Non-fluid. |
| Command / master list | 320–440px | Fixed relationship to the detail region. |
| Detail / result area | Flexible | Absorbs remaining width; yields before the master list. |
| Settings content | 480–640px within the pane | Dual-pane settings keeps a reading-width content column. |
| Panel padding | 16px standard; 24px for panel margins | Keeps the HUD compact without edge crowding. |
| Card gutter | 12px; 8px in dense inspectors | Structural separation without loose canvas. |

**Spatial rhythm.** Every control, row, and inset aligns to a **4px** base grid with a **2px** half-step. Common steps are 2, 4, 6, 8, 10, 12, 16, and 24px. Row padding is 8px vertical and 12px horizontal in the dark HUD; light panels may use 10px horizontal padding in compact lists.

**Control sizing.**
- Compact action: 28px high.
- Standard action: 30px high.
- Command row: 36–40px high.
- Keycap: 20px high, 20px minimum width.

**The Fixed Frame Rule.** The navigation rail and command list do not resize proportionally with the window. The detail area takes the elastic space.

**The 4px Rule.** Spacing resolves to 4px or a 2px half-step, except for 1px hairlines. Values outside that set are not part of the system.

## Elevation & Depth

Depth is a hybrid of tonal layering and material, not a stack of heavy drop shadows. Daylight reads as stacked paper: recessed gray canvas, white raised panels, and a crisp border at every level. Obsidian reads as layered glass: near-black substratum, translucent panels, and a specular top edge that makes the material feel machined.

| Level | Daylight | Obsidian Glass | Use |
|---|---|---|---|
| 0 — canvas | `canvas` with inset 1px dividers | `canvas-dark` / `canvas-deep-dark` | Window backcloth, inactive gutters, recessed areas. |
| 1 — raised surface | `surface` + `hairline` | `surface-dark` + `hairline-dark` | Cards, inspectors, control strips, grouped content. |
| 2 — floating layer | `glass` + 16px blur | `glass-dark` + 28px blur, 190% saturation | HUD shell, command palette, popovers, tooltips. |

### Shadow Vocabulary
- **Daylight panel** (`0 1px 3px rgba(0, 0, 0, 0.04), 0 1px 2px -1px rgba(0, 0, 0, 0.06)`): raised white panels and cards at rest.
- **Daylight floating** (`0 10px 25px -5px rgba(0, 0, 0, 0.08), 0 8px 10px -6px rgba(0, 0, 0, 0.04)`): command palettes, popovers, and menus. Pair with `1px solid rgba(17, 24, 39, 0.10)`.
- **Obsidian HUD** (`0 2px 4px rgba(0, 0, 0, 0.25), 0 12px 28px rgba(0, 0, 0, 0.45), 0 24px 60px rgba(0, 0, 0, 0.55)`): the main floating shell only.
- **Obsidian popover** (`0 4px 14px rgba(0, 0, 0, 0.35)`): menus, tooltips, and context surfaces above the HUD.
- **Keycap lift** (`0 1px 0 rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.10)`): dark keycaps. Daylight keycaps use a 2px solid bottom rim instead.

**Edge lighting.** Daylight raised surfaces use `inset 0 1px 0 rgba(255, 255, 255, 0.8)` as a subtle top highlight. Dark surfaces use `rgba(255, 255, 255, 0.07)` to `0.12`; the edge should catch light, not glow.

**Glass composition.**
- Daylight HUD: `rgba(255, 255, 255, 0.85)` with `backdrop-filter: blur(16px)`.
- Obsidian HUD: `rgba(13, 15, 20, 0.78)` with `backdrop-filter: blur(28px) saturate(190%)`.
- Obsidian popover: `rgba(22, 26, 38, 0.94)` with `blur(16px)`.
- Borders: `1px solid rgba(255, 255, 255, 0.12)` on dark glass.

**Accessibility fallback.** When Reduce Transparency is enabled, replace glass with an opaque surface at the same elevation. When Increase Contrast is enabled, promote hairlines to `border` / `border-dark` and keep focus rings at full accent opacity.

**The Edge Before Shadow Rule.** At rest, a surface proves its elevation first with tone and a 1px edge. Shadows are ambient support, not the primary outline.

**The Functional Glass Rule.** Blur is reserved for floating layers and the HUD. Do not apply glass to cards nested inside a glass panel; use a tonal wash instead.

## Shapes

The form language is rounded but machined: continuous curvature with compact radii, never soft bubbles. SwiftUI surfaces should use `.continuous` corner style so the silhouette matches macOS window geometry.

| Element | Radius | Character |
|---|---|---|
| Keycap / micro chip | 4–5px | Mechanical key silhouette with a flat bottom rim. |
| Input, button | 8px | Comfortable cursor target without a pill shape. |
| Command row, segment thumb | 6px | Tighter internal geometry for dense lists and tracks. |
| Card, inspector, inner panel | 12px | Contained content with a calm edge. |
| Raise panel / popover | 16px | Floating paper or glass. |
| HUD shell | 16px Daylight / 20px Obsidian | macOS window-like frame; the dark HUD is slightly softer. |
| Status pill / avatar | 9999px | Reserved for live status, counters, and identity tokens. |

**The Capsule Rarity Rule.** Fully rounded shapes mean "live", "count", or "identity". A button, tab, or input must not use a capsule radius.

**Border behavior.** Borders are 1px at every elevation. Dark borders use white at low opacity; light borders use ink at low opacity. Do not thicken a border to communicate focus; add a ring or change the border color.

## Components

Component dimensions are shared across themes unless explicitly noted. Theme differences are material and color, not structure.

### Floating Shell & Command Surface
- **Shape:** 16px Daylight / 20px Obsidian, continuous corners.
- **Daylight:** white-to-frosted surface, 1px `rgba(17, 24, 39, 0.10)` perimeter, ambient panel shadow, 16px blur.
- **Obsidian:** obsidian glass base, 1px white 12% perimeter, triple-tier ambient shadow, 28px blur with 190% saturation.
- **Header:** 44–48px high; brand mark and title on the leading edge, pin and dismiss controls trailing. A 1px divider separates the header from content.
- **Behavior:** the shell stays visually above the source application; it does not fill the screen or adopt a document-window chrome.

### Buttons
- **Shape:** 8px radius; 30px high in Daylight, 28px high in Obsidian.
- **Primary Daylight:** `accent` fill, `on-accent` text, weight 500, `0 12px` padding, 1px `rgba(0, 50, 180, 0.2)` border, and a subtle interior top highlight. Hover shifts to `accent-hover`.
- **Primary Obsidian:** `accent-dark` fill, `on-accent` text, `0 10px` padding, and `inset 0 1px 0 rgba(255, 255, 255, 0.25)`. Hover shifts to `accent-hover-dark`.
- **Focus Daylight:** `0 0 0 2px #FFFFFF, 0 0 0 4px #0066FF`. The white separation ring keeps the focus indicator legible on both canvas and panel.
- **Focus Obsidian:** a 1px accent outline plus a 3px translucent accent halo. The ring must remain visible against the glass surface and the content behind it.
- **Ghost Daylight:** `surface` fill, `border` outline, `text-primary` label, and a 1px ambient shadow. Hover: `surface-hover` fill and a stronger border.
- **Ghost Obsidian:** white 5% fill, white 8% outline, `text-primary-dark` label. Hover: white 9% fill.
- **Disabled:** keep the geometry, reduce text and fill contrast, and remove the shadow. Never rely on opacity alone if the label becomes unreadable.

### Keyboard Shortcut Badges (`<kbd>`)
- **Shape:** 5px radius; 20px high; 20px minimum width; `0 4px` padding.
- **Daylight:** `surface` fill, `#D1D5DB` 1px border, `#9CA3AF` 2px bottom rim, `text-secondary` label. The keycap should read as a physical key resting on the surface.
- **Obsidian:** vertical gradient from white 10% to white 3%, 1px white 12% border, bottom micro-rim shadow, and a 1px inner top highlight. Label uses `kbd` typography at 85% opacity.
- **Content:** use native macOS symbols (`⌘`, `⌥`, `⇧`, `⌃`, `↵`) with no textual substitution when a symbol exists. Literal key labels may use uppercase; symbol-only caps stay as drawn.
- **Placement:** right-align shortcut badges at the end of command rows; keep at least 8px between the label group and the badge.

### Command Inputs & Search Bars
- **Daylight:** `surface` or 80% white with blur, 1px `border`, 8px radius, and `inset 0 1px 2px rgba(0, 0, 0, 0.03)`. A leading search or command glyph uses `text-muted`.
- **Obsidian:** full-bleed, borderless input at the top of the HUD, separated by a 1px bottom divider at white 6%. The input itself has no fill; the floating shell provides the material.
- **Leading signal:** a search or command glyph may lead; the dark command hero may use an AI spark indicator with `0 0 12px rgba(79, 70, 229, 0.4)` ambient glow.
- **Text:** `body-md` for search; 18px / 24px weight-500 is permitted for the HUD command hero. Placeholder uses `text-muted` / `text-muted-dark`.
- **Focus:** immediate accent border plus a 3px soft halo. The input caret uses the theme accent.
- **Trailing accessories:** a compact token chip for the active model or mode, followed by shortcut hints. Accessories are secondary; they must not crowd the typed command.

### Command List Items & Navigation Rows
- **Geometry:** 36–40px high, 6px radius, `0 10px` horizontal padding in Daylight; 8px vertical and 12px horizontal in Obsidian.
- **Resting Daylight:** transparent fill, `text-primary` label, `text-secondary` metadata. Hover or keyboard selection: `accent-soft` fill and accent text.
- **Resting Obsidian:** transparent fill, `text-primary-dark` label at 85% opacity, secondary text at 45% opacity.
- **Selected Obsidian:** `accent-soft-dark` fill or white 8% neutral hover, with a 2px `accent-dark` left indicator bar. Keyboard selection is always stronger than pointer hover.
- **Trailing metadata:** secondary label first, then keycap badges. Do not right-align a second unrelated action inside the row.

### Segmented Controls
- **Track Daylight:** `surface-sunken`, 8px radius, 2px padding, 1px low-opacity ink border.
- **Thumb Daylight:** `surface` fill, 6px radius, `text-primary` label, `0 1px 3px rgba(0, 0, 0, 0.1)` shadow.
- **Track Obsidian:** black 25% recessed fill, 1px white 5% border, 2px padding.
- **Thumb Obsidian:** white 12% elevated fill with `0 1px 3px rgba(0, 0, 0, 0.3)` shadow. Active text is pure white.
- **Inactive label:** `text-secondary` / `text-secondary-dark`; hover raises label contrast, not fill opacity.
- **Behavior:** the thumb moves; the track does not resize. Use one segmented row for mutually exclusive modes, never for navigation.

### Cards, Inspectors & Diffs
- **Daylight card:** `surface` fill, 1px `border`, 12px radius, 16px padding. Section headers use a 1px `canvas` separator.
- **Obsidian card:** white 3% wash, 1px `hairline-dark`, 12px radius, 16px padding. Do not add a shadow; the wash and hairline provide separation.
- **Key-value metadata:** two-column alignment, `text-secondary` keys, `text-primary` values, tabular numbers for numeric values. Keep row heights consistent across the inspector.
- **Diff removed:** dark theme uses a soft red-tinted strike wash at about 15% opacity; light theme uses `error-soft` with `error` text. Strikethrough is supplemental, never the only signal.
- **Diff added:** dark theme uses a cyan-tinted wash at about 15% opacity with a cyan underline; light theme uses a blue-tinted wash tied to `accent-soft`. Keep the text readable at `body-md`.
- **Streaming:** show a caret or compact activity indicator in the accent color. Do not animate the whole card or pulse entire blocks of text.

### Status & Feedback
- **Live / success:** a small `success` dot, bar, or icon; 8px dot size in dense rows. Pair with text or an accessible label.
- **Error:** inline `error-soft` container with 1px error border, 8px radius, and a compact icon. Use full-width error banners only for failures that block the current task.
- **Loading:** skeleton or caret in neutral tones; accent is reserved for the active action, not every loading surface.
- **Keyboard:** every pointer action has a keyboard path. Hover-only affordances are not acceptable for copy, replace, pin, dismiss, or scene execution.

## Do's and Don'ts

### Do:
- **Do** define every visual value as a semantic token and resolve it by appearance. Views should ask for `accent`, `surface`, or `text-secondary`, not for blue or indigo.
- **Do** keep the same component order, dimensions, and keyboard behavior across Daylight and Obsidian Glass.
- **Do** use 1px hairlines and tonal steps before adding shadow or extra spacing.
- **Do** use blur only on the floating shell and popovers, with an opaque fallback for Reduce Transparency.
- **Do** provide a visible focus ring, a keyboard path, and a text label for every state that color alone might communicate.
- **Do** use tabular figures for live numbers and JetBrains Mono only for code-like content.

### Don't:
- **Don't** use `accent-text-dark` (`#C3C0FF`) as a button fill; the dark action fill is `accent-dark`.
- **Don't** mix the Daylight blue action and Obsidian indigo action inside one appearance.
- **Don't** apply glassmorphism to nested cards, list rows, or every panel. It is a floating-layer material.
- **Don't** use pure white as the broad daylight canvas, or pure black as the dark canvas; both themes use tinted neutrals.
- **Don't** use capsule radii for buttons, tabs, or inputs. Reserve them for status, counters, and identity tokens.
- **Don't** use shadows as the primary boundary between regions. Structure comes from tone and 1px edges.
- **Don't** use muted text for primary content, placeholders as labels, or color as the only error signal.
- **Don't** add motion to the result surface for decoration. Streaming feedback is the only continuous motion the writing flow needs.
