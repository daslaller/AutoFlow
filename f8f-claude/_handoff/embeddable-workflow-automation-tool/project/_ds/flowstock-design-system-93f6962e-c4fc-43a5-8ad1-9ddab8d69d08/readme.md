# FlowStock Design System

FlowStock is a repair-shop management SaaS: repair job intake & tracking (with AI-assisted parsing), a Kanban repair pipeline, and parts/inventory management for independent phone/laptop/electronics repair shops. It's built on [Base44](https://base44.com) (a hosted app builder) with a React + Tailwind + shadcn/ui ("new-york" style, neutral base) frontend.

Note: the in-app UI literally titles itself **"RepairX"** (see the sidebar logo/wordmark in `src/Layout.jsx` and the onboarding screen), while the repository and product are named **FlowStock**. This design system uses **FlowStock** as the brand name throughout (matching the repo you gave us) and documents the RepairX in-product wordmark as a historical/internal name — flag if you'd like it fully renamed one way or the other.

## Sources
- GitHub repo: [daslaller/b44-flowstock](https://github.com/daslaller/b44-flowstock) (branch `main`) — the sole input for this system. Explore it directly for anything this system simplified or omitted: full Radix-based component implementations, the `entities/` JSON schemas (Asset, Company, Customer, InventoryItem, PurchaseOrder, RepairJob, SerialNumber, UserCompany), and page-level data logic.
- The repo's own README notes it's a **manual extraction of a Base44 project** — a handful of files referenced by the pages (`Skeleton`, `Textarea`, `Tabs`, `Switch`, `Toast`/`Toaster`, `Tooltip`, `Table`, `Slider`, `Toggle`, `Sonner`) are imported in the source pages but were not present in the exported `src/components/ui/` folder. This system rebuilt those (documented per-component below) matching their on-screen usage; if you have the missing source files, re-attach the repo and we'll swap in the exact originals.

## Index — what's in this project
- `styles.css` + `tokens/` — CSS custom properties (colors, type, spacing, shadows) and their specimen cards
- `components/core/` — Button, Badge, Card
- `components/forms/` — Input, Label, Textarea, Select, Checkbox, RadioGroup
- `components/feedback/` — Progress, Skeleton, Alert
- `components/navigation/` — Tabs
- `components/overlays/` — Dialog, Sheet, Popover, Tooltip
- `components/data-display/` — Avatar, Separator, Accordion
- `components/domain/` — StatusBadge, PriorityIcon, MetricCard, KanbanCard, KanbanColumn, InventoryItemCard (FlowStock-specific composites built from the primitives above)
- `ui_kits/flowstock/` — interactive click-through recreation of Dashboard, Kanban, Inventory, and Repair Intake
- `assets/` — see Iconography below (no logo file was found in the source — see note)
- `SKILL.md` — Claude Code-compatible skill wrapper for this system

## Components
Core: Button, Badge, Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter.
Forms: Input, Label, Textarea, Select, Checkbox, RadioGroup.
Feedback: Progress, Skeleton, Alert.
Navigation: Tabs.
Overlays: Dialog, Sheet, Popover, Tooltip.
Data display: Avatar, Separator, Accordion.
Domain (FlowStock-specific): StatusBadge, PriorityIcon, MetricCard, KanbanCard, KanbanColumn, InventoryItemCard.

### Intentional additions / gaps
- **Rebuilt without source** (imported in pages, file missing from the manual export): Skeleton, Textarea, Tabs, Select. Built to match on-screen usage exactly; re-attach the repo if you find the originals.
- **Not yet ported** — the source's `components/ui/` folder defines 35 shadcn primitives total; this pass covered the ~20 exercised by an actual product screen. Not built: a richer Radix Accordion variant, AlertDialog, Breadcrumb, Calendar, Carousel, Chart, Collapsible, Command, ContextMenu, Drawer, DropdownMenu, Form, HoverCard, InputOTP, Menubar, NavigationMenu, Pagination, Resizable, ScrollArea. None of these appear in the six product pages we read (Dashboard, Inventory, Kanban, Onboarding, RepairIntake, RepairDetail) — ask if you want any of them built out.
- **StatusBadge / PriorityIcon / KanbanCard / KanbanColumn / MetricCard / InventoryItemCard** are FlowStock-specific composites (not generic shadcn), added because they're the actual repeating UI patterns across every screen — flagged here per the "intentional additions" convention.
- Drag-and-drop (Kanban board) uses `@hello-pangea/dnd` in source; this system's KanbanCard/Column are static visual recreations only.

## Content fundamentals
- **Voice**: plain, operational, second-person-light — mostly imperative/neutral ("Fill in the details for the new item", "Track parts, components, and products"), not "you"-heavy marketing copy. Copy describes what the screen does, not a sales pitch.
- **Casing**: Title Case for headings and nav labels ("Inventory Management", "Repair Jobs Kanban"); sentence case for body/help text and placeholders.
- **Micro-copy is functional, not cute**: "No repairs yet" / "Add New Item" / "View all →" — direct labels, arrow glyphs for "see more" links, no jokes or filler.
- **AI moments get a distinct, slightly playful voice**: "Quick Intake — type the repair and hit Enter", "AI Parsed — Review & Edit", "⌘+Enter to submit" — a small lightning-bolt (Zap) icon marks anything AI-assisted. This is the one place personality shows up.
- **Emoji**: essentially unused in UI chrome; the one exception is a 💡 lightbulb prefixing AI pricing hints ("💡 Suggested price..."). Don't spread emoji beyond that one AI-hint pattern.
- **Numbers over adjectives**: dashboard copy favors concrete stats ("68% completion rate", "3 items low") over vague claims.
- **Placeholder examples use real-feeling but obviously-fake data**: "John Smith — iPhone 15 Pro screen replacement", "e.g. FixIt Pro", join code "AB12CD" — keep mocked content in this same register (named person + device + concise issue).

## Visual foundations
- **Palette strategy — neutral base, two strategic accents**: the app is overwhelmingly slate/white/gray. Blue (primary actions, links, active nav) and purple (paired with blue in a gradient for AI/"quick" actions) are the only two brand hues used broadly — every other color (yellow, orange, green, red, emerald) is reserved as **fixed semantic meaning** for repair status or priority, never decorative. This is deliberate "strategic coloring": color always tells you something (status/priority/urgency), so screens stay calm and scannable rather than colorful for its own sake.
- **Status colors are pinned, not palette-of-the-day**: intake=slate, diagnosis=blue, waiting_parts=yellow, in_repair=orange, quality_check=purple, ready=green, collected=emerald, cancelled=red. Don't remix these.
- **Type**: no custom webfont — the system (`ui-sans-serif, system-ui, -apple-system...`) stack, i.e. native OS font. Monospace (`ui-monospace...`) is reserved for join codes, serial numbers, and SKUs. Headings are bold/black weight (700), often on a subtle `slate-900→slate-700` gradient-text treatment for page titles.
- **Backgrounds**: full pages sit on a very soft `slate-50→blue-50` diagonal gradient — never flat white, never a hard color block. The one exception is the pre-login Onboarding screen, which uses a dramatic dark `slate-900→blue-950→slate-900` gradient. No photography, illustration, texture, or pattern anywhere in the source.
- **Gradients**: reserved for two jobs — (1) brand/AI call-to-action surfaces (blue-600→purple-700, e.g. the Quick Intake bar, primary CTA buttons) and (2) the dark auth backdrop. Metric-tile icon chips use a *single-hue* gradient (e.g. blue-500→blue-600) for depth, not a rainbow.
- **Cards**: white, **no border**, `shadow-md`, `rounded-xl` (12px) — consistently border:none + shadow, never border+shadow together, and never a colored left-border accent strip.
- **Corner radii**: buttons/inputs `rounded-md` (8px), cards `rounded-xl` (12px), avatars/status pills `rounded-full`. Nothing sharp-cornered.
- **Shadows**: `shadow-md` is the default resting elevation for nearly everything (cards, kanban cards); `shadow-lg`/`shadow-xl` reserved for modals/sheets and hover states. No colored/glow shadows.
- **Hover / press states**: hover = subtle background darken or bg-tint swap (e.g. ghost button hover → light gray fill; kanban card hover → shadow-lg + slight scale); press states aren't heavily choreographed — mostly rely on browser default + color shift, no big shrink/bounce.
- **Animation**: minimal and utilitarian — accordion expand/collapse ease-out ~200ms, a spinning loader (Loader2) for async actions, transform/opacity transitions on the mobile sidebar slide-in. No bounces, no springs, no decorative motion.
- **Transparency / blur**: `backdrop-blur-sm` + `bg-white/80` is used specifically for sheets/cards that float over the gradient background (inventory sheet, activity cards) to keep the soft-gradient visible underneath; on the dark onboarding screen, `bg-white/10` + `border-white/20` creates frosted glass inputs/cards. Blur is always paired with a translucent white/near-white fill — never applied to solid-color surfaces.
- **Layout**: fixed 240px dark slate-900 sidebar (desktop) collapsing to a slide-in drawer + overlay on mobile; content area scrolls independently. No sticky/fixed headers beyond the mobile top bar.
- **Imagery color vibe**: n/a — the source product has no photography or illustration; all visual interest comes from color, type, and elevation.

## Iconography
- **Icon library**: [Lucide](https://lucide.dev) (`lucide-react`, confirmed via `components.json` → `"iconLibrary": "lucide"` and every page's imports) — thin 2px stroke, rounded caps, no fill. This is the only icon system in the source; no custom icon font, no PNG icon set.
- No SVG/PNG icon assets exist in the repo to copy (they're rendered from the `lucide-react` npm package at build time, not shipped as files) — this system links the equivalent individual icons from the Lucide CDN (`unpkg.com/lucide-static`) so markup and visuals match exactly.
- Emoji: not used as UI icons — the sole exception is the 💡 AI-pricing-hint prefix noted in Content Fundamentals above.
- Icon sizing follows two fixed steps: 16px (`w-4 h-4`, most inline icons) and 20px (`w-5 h-5`, section headers/empty states); icons take the surrounding text color unless they're carrying their own semantic color (status/priority).

## Logo
**No logo asset was found in the source repo.** The sidebar/onboarding "logo" is just a blue rounded-square chip with a Lucide `Wrench` icon and the wordmark "RepairX" set in bold sans type — there's no exported mark file. This system therefore renders the brand name in plain type wherever a mark would go (see `thumbnail.html`) rather than inventing one. If you have a real logo file, attach it and we'll drop it in.

## Fonts
No font files needed — FlowStock inherits the OS default UI font (Tailwind's `font-sans`/`font-mono` default stacks). Nothing to substitute.
