---
name: frontend
description: Guidance for building consistent, mobile-friendly React interfaces with DaisyUI components and Tailwind CSS layouts. Use when creating or updating frontend components, pages, or app layouts, with attention to content hierarchy, responsive design, accessibility, and existing project conventions.
license: MIT
metadata:
  copyright: Copyright (c) 2026 John Anthony Mariquit <john@mariquit.com>
---

# Frontend

Build mobile-friendly React interfaces with DaisyUI components and constrained Tailwind layouts. Reuse component sizes, page wrappers, and spacing patterns instead of styling each element independently.

## When to Use

- Building or updating UI components, pages, or layout shells.
- Scaffolding feature modules in frontend applications.
- Enforcing DaisyUI component guardrails and responsive design patterns.

## Design Intent

- Before choosing a layout, identify the audience and the primary task the screen supports from the brief and verified product context. Ask only when missing context would materially change the design; do not invent a product or audience.
- Use the product's actual content and existing visual identity. Label necessary placeholders explicitly, and do not fabricate metrics, testimonials, or other claims to fill a layout.
- For existing screens, preserve established patterns unless the requested change requires otherwise. Design intent guides the requested work; it is not permission for an unsolicited redesign.

## Core Rules & Guardrails

### 1. DaisyUI Owns Component Styling

- Check the installed Tailwind CSS and DaisyUI versions and existing shared components before editing. Use classes supported by that version; do not assume older classes such as `input-bordered` or `form-control` are available.
- Confirm unfamiliar classes against installed package sources or documentation matching the installed version. A dependency declaration alone does not verify a class. If confirmation is unavailable, reuse an existing verified component; do not invent class names or claim support without evidence.
- Use DaisyUI semantic classes for controls and component structure:
  - Buttons: `btn`, `btn-primary`, `btn-secondary`, `btn-outline`.
  - Forms: `input`, `select`, `textarea`, `checkbox`, `toggle`, with visible labels.
  - Cards: `card`, `card-body`, `card-title`, `card-actions`.
  - Navigation: `navbar`, `navbar-start`, `navbar-center`, `navbar-end`, `menu`, `drawer`.
  - Dialogs and feedback: `modal`, `modal-box`, `modal-action`, `toast`, `alert`, `badge`.
- Do not rebuild these components with raw utilities such as `px-4 py-2 bg-blue-500 rounded-md`. Do not override their padding, height, radius, or typography independently to make a one-off variant.
- Keep related controls on one supported DaisyUI size variant. Use the default medium size for ordinary controls; use `btn-sm` or `btn-lg` only for a deliberate shared variant that still meets touch-target requirements.
- Reuse existing shared components and extract repeated component recipes within the requested scope. Do not copy long, slightly different class strings across screens.
- Accessibility minimums take precedence over component sizing restrictions. Apply necessary target-size adjustments through a shared component variant, not per-instance overrides.
- When DaisyUI does not cover a required interaction, prefer existing accessible implementations and suitable native HTML controls. Ask before introducing a new component library or materially changing the design system; keep additions consistent with the existing theme.

### 2. Tailwind Owns Layout, Not Control Appearance

- Choose composition from the content and primary task, not a preset template. Use cards for meaningful groups, numbering for actual sequences, and visual emphasis for important information or actions. Do not turn every section into a card or add a hero to an application screen without a task-specific reason.
- Use standard Flexbox and Grid utilities for alignment, wrapping, and responsive structure: `flex`, `grid`, `items-center`, `flex-wrap`, `flex-col md:flex-row`, and `grid-cols-1 md:grid-cols-2`.
- Prefer standard spacing scales, such as `gap-2`, `gap-4`, and `gap-6`, and keep repeated relationships consistent across screens.
- Reuse a consistent page wrapper, such as `container mx-auto p-4 md:p-6 space-y-6`. Avoid duplicated page padding or gaps and margins that account for the same separation.
- Let `card-body`, `navbar`, and other DaisyUI structures provide their internal spacing. Use layout utilities for placement, not to restyle every component's internals.
- Avoid arbitrary pixel values such as `p-[13px]` or `w-[320px]`, inline styling, and negative-margin fixes for ordinary layout. Prefer standard utilities, fluid widths, and responsive columns. When custom styling is justified by a real requirement, keep it narrowly scoped rather than stacking workarounds.

### 3. Theme Colors and Visual Consistency

- Use semantic surfaces and matching content tokens: `bg-base-100 text-base-content`, `bg-base-200 text-base-content`, and `bg-primary text-primary-content`. Let `btn-primary` and other semantic component variants manage their own colors.
- Do not introduce hardcoded palette colors such as `bg-gray-900` or `text-blue-600` unless the user explicitly requires them. Preserve the app's existing theme rather than creating a separate palette per feature.
- Check affected UI for contrast in supported themes. Semantic tokens support theme switching but do not guarantee accessible contrast, especially with opacity modifiers or custom themes. Meet WCAG AA contrast: 4.5:1 for normal text and 3:1 for large text.
- Keep borders, radius, and elevation consistent with the theme. Add shadows or other decoration only when they communicate hierarchy; do not add a large shadow to every card by default.
- Preserve existing fonts and use a small, consistent type hierarchy for headings, body text, and supporting text. Constrain long-form prose with a standard maximum-width utility, without narrowing data views unnecessarily. Do not add decorative fonts or override control typography for novelty.
- Use motion only to explain a state change or provide useful feedback. Respect reduced-motion preferences with supported utilities such as `motion-reduce:transition-none` and `motion-reduce:animate-none`; keep information and controls usable without animation.


### 4. Follow Existing Architecture

Follow the project's existing organization and framework conventions. Do not restructure unrelated files. For a new application, feature-based modules are one possible starting point, not a required layout:

```text
src/
├── core/                  # Shared primitives and app shell
│   ├── components/        # Universal buttons, modals, cards
│   └── layout/            # AppShell, MobileNav, Header
├── features/              # Isolated feature modules
│   ├── dashboard/         # Feature components, hooks, api
│   └── voice-chat/        # Feature components, hooks, api

```

### 5. Mobile-First App Shell and Accessibility

- Reuse the existing shared layout and navigation without duplicating main landmarks, page wrappers, or scrolling regions. Let content grow naturally; use bounded viewport layouts only when the interaction requires them.
- Account for device safe areas and fixed navigation where relevant. Keep focused inputs visible above the on-screen keyboard.
- Stack content on mobile and expand at larger breakpoints. Avoid page-level horizontal scrolling, clipped labels, and fixed widths that prevent reflow at 200% zoom.
- Require interactive targets of at least 44 by 44 CSS pixels. Check the rendered size rather than assuming a DaisyUI size name guarantees it. When needed, use a shared target variant with standard `min-h-12 min-w-12` utilities; keep the visible icon at `size-5` or `size-6` inside the button. Do not pad the icon instead of sizing the interactive element.
- Use semantic HTML, visible form labels, accessible names for icon-only buttons, and visible `focus-visible` indicators. All controls must work with the keyboard; Escape must close dialogs and focus must return to their trigger. DaisyUI classes provide styling, not complete interaction behavior.

### 6. Separation of Hardware/API Logic from UI

- Keep hardware access, network requests, subscriptions, and cleanup separate from presentation using the project's established hooks, services, or framework APIs. Do not introduce a new architecture solely to follow this skill.

### 7. UI Copy

- Name the action in control labels, such as "Save profile" rather than "Submit". Use the same term for the same concept across headings, labels, navigation, and feedback.
- Explain errors in specific, factual language and provide a recovery action when one exists. Do not promise success or a recovery option the implementation cannot provide.
- Make empty states explain what is absent and identify a useful next action when available. Keep instructions close to the relevant control, and remove promotional filler that does not help the user complete the task.

## Composition Example

Use DaisyUI for component internals and Tailwind for layout. This presentational example fits inside the existing page wrapper; it does not prescribe a shared component API.

```tsx
export function NotificationOptions() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold">Notifications</h1>
      <section className="card bg-base-100 text-base-content">
        <div className="card-body">
          <h2 className="card-title">Email preferences</h2>
          <div className="flex flex-col gap-4 md:flex-row md:items-center">
            <h3 className="font-semibold">Weekly activity summary</h3>
            <p>A weekly overview of your account activity.</p>
          </div>
        </div>
      </section>
    </div>
  );
}
```

## Verification Before Completion

Verify affected UI proportionately to the change:

- Check responsive layout, spacing, hierarchy, and theme consistency in the rendered UI when tools are available. Screenshots can support visual review, not prove functional behavior.
- Check relevant accessibility behavior, including keyboard access, focus, contrast, touch targets, and zoom/reflow.
- Exercise changed controls and relevant loading, empty, validation, and error states. Do not ship dead controls, placeholder links, or fabricated data presented as real.
- Run relevant project checks and report what passed, failed, or remains unverified. Do not infer rendered behavior from class names or claim coverage beyond what was tested.
