---
name: Obsidian Glass
colors:
  surface: '#111318'
  surface-dim: '#111318'
  surface-bright: '#37393f'
  surface-container-lowest: '#0c0e13'
  surface-container-low: '#1a1b21'
  surface-container: '#1e1f25'
  surface-container-high: '#282a2f'
  surface-container-highest: '#33353a'
  on-surface: '#e2e2e9'
  on-surface-variant: '#c7c4d8'
  inverse-surface: '#e2e2e9'
  inverse-on-surface: '#2e3036'
  outline: '#918fa1'
  outline-variant: '#464555'
  surface-tint: '#c3c0ff'
  primary: '#c3c0ff'
  on-primary: '#1d00a5'
  primary-container: '#4f46e5'
  on-primary-container: '#dad7ff'
  inverse-primary: '#4d44e3'
  secondary: '#7bd0ff'
  on-secondary: '#00354a'
  secondary-container: '#00a6e0'
  on-secondary-container: '#00374d'
  tertiary: '#ddb7ff'
  on-tertiary: '#490080'
  tertiary-container: '#862dd4'
  on-tertiary-container: '#ebd2ff'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e2dfff'
  primary-fixed-dim: '#c3c0ff'
  on-primary-fixed: '#0f0069'
  on-primary-fixed-variant: '#3323cc'
  secondary-fixed: '#c4e7ff'
  secondary-fixed-dim: '#7bd0ff'
  on-secondary-fixed: '#001e2c'
  on-secondary-fixed-variant: '#004c69'
  tertiary-fixed: '#f0dbff'
  tertiary-fixed-dim: '#ddb7ff'
  on-tertiary-fixed: '#2c0051'
  on-tertiary-fixed-variant: '#6900b3'
  background: '#111318'
  on-background: '#e2e2e9'
  surface-variant: '#33353a'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 2rem
    fontWeight: '600'
    lineHeight: 2.5rem
    letterSpacing: -0.025em
  headline-lg:
    fontFamily: Inter
    fontSize: 1.5rem
    fontWeight: '600'
    lineHeight: 2rem
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 1.125rem
    fontWeight: '500'
    lineHeight: 1.5rem
    letterSpacing: -0.015em
  body-lg:
    fontFamily: Inter
    fontSize: 0.9375rem
    fontWeight: '400'
    lineHeight: 1.45rem
    letterSpacing: -0.01em
  body-md:
    fontFamily: Inter
    fontSize: 0.8125rem
    fontWeight: '400'
    lineHeight: 1.25rem
    letterSpacing: -0.005em
  body-sm:
    fontFamily: Inter
    fontSize: 0.75rem
    fontWeight: '400'
    lineHeight: 1.1rem
    letterSpacing: 0em
  label-code:
    fontFamily: JetBrains Mono
    fontSize: 0.6875rem
    fontWeight: '500'
    lineHeight: 0.875rem
    letterSpacing: 0.02em
  label-kbd:
    fontFamily: Inter
    fontSize: 0.6875rem
    fontWeight: '600'
    lineHeight: 0.875rem
    letterSpacing: 0.01em
  caption:
    fontFamily: Inter
    fontSize: 0.6875rem
    fontWeight: '500'
    lineHeight: 0.9375rem
    letterSpacing: 0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 0.75rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style

This design system channels modern macOS desktop craftsmanship: tactile, instantaneous, and intensely utilitarian. Inspired by tools like Raycast and Linear, the aesthetic fuses macOS native pro ergonomics with refined glassmorphism and technical precision.

### Aesthetic Principles
- **Vibrant Substratum & Frosted Glass:** Translucent surface layers with high-density backdrop blur (`backdrop-filter: blur(20px)`), rendering the desktop environment softly behind floating HUD interfaces.
- **Micro-Borders & Inner Glow:** Crisp 1px hairline borders pairing soft white/light opacity with subtle inner directional highlights to mimic machined chamfered glass edges.
- **Physical Precision:** Tactile keycaps (Kbd pills), precise segmented switches, and snappy micro-interactions that mirror native keyboard-first workflows.
- **High Information Density:** Compact typography, disciplined baseline grids, and razor-sharp data alignments built for power users demanding zero friction.

## Colors

The palette is tuned specifically for focused productivity environments, with deep neutral backing that suppresses eye fatigue while electric spectral accents deliver distinct state signaling.

### Color Architecture
- **Primary (`#4F46E5` - Electric Indigo):** Primary trigger actions, focused caret/selection highlights, active state indicators, and AI enhancement pulses.
- **Secondary (`#38BDF8` - Cyan Flare):** Variable tokens, diff/replacement text highlights, live generation streaming signals, and non-blocking contextual hints.
- **Tertiary (`#A855F7` - Violet Glow):** Creative expansion features, prompt rewriting modes, and macro badge accents.
- **Neutral Core (`#0D0F14` - Pitch Obsidian):** The foundational Canvas base. Extended into layered glass tints (`rgba(17, 20, 29, 0.72)` for panels; `rgba(28, 33, 48, 0.65)` for hovering control wells).
- **Surface Accents & Borders:** Hairline borders leverage `rgba(255, 255, 255, 0.08)` on dark surfaces and `rgba(0, 0, 0, 0.06)` on light mode, paired with top-edge specular highlights (`rgba(255, 255, 255, 0.12)`).

## Typography

Typography balances rapid scanning and optical legibility at dense scales.

- **Primary UI & Text:** `Inter` handles all display titles, list items, prompts, and interface chrome, taking advantage of optical sizing and subtle tabular numbers.
- **Monospace & Metadata:** `JetBrains Mono` handles prompt syntax, diff comparison views, metadata tags, and parameter flags.
- **Keyboard Badges:** `Inter` in semi-bold/medium tracking for clean, authentic rendering of macOS symbols (`⌘`, `⌥`, `⇧`, `⌃`, `↵`).
- **Hierarchy Rules:** Body typography never drops below `0.75rem` for critical interactive elements. Headings retain tight letter-spacing to reinforce architectural density.

## Layout & Spacing

The layout is built for floating HUD overlays (spotlight style) and high-efficiency utility sidebars, adopting a fixed-ratio compact grid rather than loose responsive canvas rules.

### Layout Philosophy
- **HUD Dimensions:** Primary floating modal standardizes on a fixed 640px width with dynamic clamped heights (`min-height: 72px`, `max-height: 480px`).
- **Settings & Extended Panels:** Standard dual-pane split architecture with a fixed 220px navigation rail and fluid 480px–640px content canvas.
- **Internal Density:** Controls, list rows, and command palettes rely on a strict 4px sub-grid rhythm. Padding in interactive rows stays taut at `0.5rem` vertical and `0.75rem` horizontal to maximize vertical information capacity.

## Elevation & Depth

Visual hierarchy uses optical layering, translucent glass composites, and micro-machined edge reflection rather than heavy drop shadows.

### Elevation Hierarchy
1. **Desktop Background Glass (Floating HUD Base):**
   - Background: `rgba(13, 15, 20, 0.78)` with `backdrop-filter: blur(28px) saturate(190%)`.
   - Perimeter Border: 1px continuous border with `rgba(255, 255, 255, 0.12)`.
   - Drop Shadow: Triple-tier ambient drop shadow:
     `0 2px 4px rgba(0, 0, 0, 0.25), 0 12px 28px rgba(0, 0, 0, 0.45), 0 24px 60px rgba(0, 0, 0, 0.55)`.
2. **Elevated Wells & Control Strips:**
   - Background: `rgba(255, 255, 255, 0.04)`.
   - Inset: 1px top highlight `rgba(255, 255, 255, 0.07)` and subtle bottom shadow `inset 0 1px 2px rgba(0, 0, 0, 0.3)`.
3. **Popovers, Tooltips & Context Menus:**
   - Background: `rgba(22, 26, 38, 0.94)` with `backdrop-filter: blur(16px)`.
   - Border: 1px `rgba(255, 255, 255, 0.14)`.
   - Shadow: `0 4px 14px rgba(0, 0, 0, 0.35)`.

## Shapes

The geometry adheres to contemporary macOS continuous curvature (squircle-aligned tolerances), balancing soft approachability with machined structure.

### Corner Radii Guidelines
- **HUD Main Window:** `rounded-xl` (1.25rem / 20px) to mirror macOS window frames and spotlight launchers.
- **Card Containers & Inner Panels:** `rounded-lg` (0.75rem / 12px).
- **Interactive Inputs & List Selections:** `rounded` (0.5rem / 8px).
- **Kbd Shortcut Badges & Micro Chips:** `rounded-sm` (0.3125rem / 5px) for authentic keycap silhouette.
- **Action Icons & Status Pills:** Full circular capsule (`9999px`) reserved purely for counter pills and avatar tokens.

## Components

### 1. Interactive Command Input (Floating HUD Top)
- **Structure:** Transparent full-bleed input container, borderless base with a subtle bottom divider `1px solid rgba(255, 255, 255, 0.06)`.
- **Text:** `headline-md`, zero native outline, zero background. Leading AI spark indicator with subtle ambient glow (`0 0 12px rgba(79, 70, 229, 0.4)`).
- **Trailing Accessories:** Inline token chip representing the active text prompt model (e.g., "Enhance Pro 4.0") and shortcut key prompts.

### 2. Keyboard Shortcut Badges (`<kbd>`)
- **Appearance:** Inset-molded 3D keycaps. Background `linear-gradient(180deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.03) 100%)`.
- **Borders & Shadow:** 1px border `rgba(255, 255, 255, 0.12)`, bottom edge micro-rim `box-shadow: 0 1px 0 rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.1)`.
- **Typography:** `label-kbd`, uppercase, opacity 85%.

### 3. List Rows & Command Items
- **Inactive:** Transparent background, primary text `rgba(255, 255, 255, 0.85)`, secondary text `rgba(255, 255, 255, 0.45)`.
- **Active / Keyboard-Selected:** Background `rgba(79, 70, 229, 0.18)` or neutral hover `rgba(255, 255, 255, 0.08)`. Left indicator bar 2px solid `#4F46E5`.
- **Padding:** 8px vertical, 12px horizontal. Rounded radius 6px.

### 4. Segmented Controls
- **Track:** Recessed container, background `rgba(0, 0, 0, 0.25)`, border `1px solid rgba(255, 255, 255, 0.05)`, padding 2px.
- **Thumb:** Active segment slides on an elevated card `rgba(255, 255, 255, 0.12)` with `box-shadow: 0 1px 3px rgba(0,0,0,0.3)`.
- **Text:** `caption` font weight medium; active tab transitions text to pure white (`#FFFFFF`).

### 5. Buttons & Action Triggers
- **Primary:** Background `#4F46E5` with top edge specular line `inset 0 1px 0 rgba(255, 255, 255, 0.25)`. Hover: `#4338CA`.
- **Ghost / Neutral:** Background `rgba(255, 255, 255, 0.05)`, border `1px solid rgba(255, 255, 255, 0.08)`. Hover: `rgba(255, 255, 255, 0.09)`.
- **Height:** Compact `28px` for pro-tier density, with `0.625rem` horizontal padding.

### 6. Polish Diff & Prompt Enhancement Cards
- **Container:** Grounded card with `rgba(255, 255, 255, 0.03)` surface and 1px hairline border.
- **Diff Highlighting:** Removed text marked with soft red-tinted strike `rgba(239, 68, 68, 0.15)`; injected prompt polish highlighted with bright electric blue `rgba(56, 189, 248, 0.15)` and cyan underline.