# Anchor Design System

Anchor is a generic, original design system for operations/workflow SaaS products — the kind of internal tool that runs a Kanban work pipeline, a quick-add/AI-assisted intake bar, and inventory/asset tracking. It is not tied to any specific company or product; "Anchor" is a placeholder brand invented for this system.

## Origin note
This system's visual language, component inventory, and interaction patterns were derived from studying [daslaller/b44-flowstock](https://github.com/daslaller/b44-flowstock) (branch `main`), a repair-shop management SaaS built on Base44 (React + Tailwind + shadcn/ui, "new-york" style). That source product was scoped to phone/laptop repair shops (repair job intake, a repair Kanban pipeline, parts inventory). This system keeps the underlying visual system and component shapes but genericizes all copy, data, prop names, and domain vocabulary so it can be reused for any operations/workflow product — task tracking, project pipelines, asset/inventory management, etc. Explore the source repo directly if you want the original repair-shop-specific implementation, its `entities/` JSON schemas, or full Radix-based primitives this system simplified.

## Index — what's in this project
- `styles.css` + `tokens/` — CSS custom properties (colors, type, spacing, shadows) and their specimen cards
- `components/core/` — Button, Badge, Card
- `components/forms/` — Input, Label, Textarea, Select, Checkbox, RadioGroup
- `components/feedback/` — Progress, Skeleton, Alert
- `components/navigation/` — Tabs
- `components/overlays/` — Dialog, Sheet, Popover, Tooltip
- `components/data-display/` — Avatar, Separator, Accordion
- `components/domain/` — StatusBadge, PriorityIcon, MetricCard, KanbanCard, KanbanColumn, InventoryItemCard (generic workflow composites built from the primitives above)
- `ui_kits/anchor/` — interactive click-through recreation of a Dashboard, work-item Pipeline (Kanban), and Inventory view
- `assets/` — see Iconography below (no logo file exists — see note)
- `SKILL.md` — Claude Code-compatible skill wrapper for this system

## Components
Core: Button, Badge, Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter.
Forms: Input, Label, Textarea, Select, Checkbox, RadioGroup.
Feedback: Progress, Skeleton, Alert.
Navigation: Tabs.
Overlays: Dialog, Sheet, Popover, Tooltip.
Data display: Avatar, Separator, Accordion.
Domain (generic workflow composites): StatusBadge, PriorityIcon, MetricCard, KanbanCard, KanbanColumn, InventoryItemCard.

### Intentional additions / gaps
- **Rebuilt without source** (imported in the source repo's pages, file missing from its manual export): Skeleton, Textarea, Tabs, Select. Built to match on-screen usage; treat as best-effort recreations.
- **Not a full shadcn set** — the source's `components/ui/` folder defines 35 shadcn primitives total; this system covers the ~20 actually exercised by a product screen. Not built: a richer Radix Accordion variant, AlertDialog, Breadcrumb, Calendar, Carousel, Chart, Collapsible, Command, ContextMenu, Drawer, DropdownMenu, Form, HoverCard, InputOTP, Menubar, NavigationMenu, Pagination, Resizable, ScrollArea. Ask if you want any of these built out.
- **StatusBadge / PriorityIcon / KanbanCard / KanbanColumn / MetricCard / InventoryItemCard** are the generic workflow composites (not standard shadcn), because they're the actual repeating UI patterns of this kind of ops product — pipeline stage, priority, KPI tile, board card/lane, inventory tile.
- Drag-and-drop (Kanban board) is not reproduced — KanbanCard/Column are static visual recreations only.

## Content fundamentals
- **Voice**: plain, operational, second-person-light — mostly imperative/neutral ("Fill in the details for the new item", "Track assets and resources"), not "you"-heavy marketing copy. Copy describes what the screen does, not a sales pitch.
- **Casing**: Title Case for headings and nav labels ("Inventory", "Work Pipeline"); sentence case for body/help text and placeholders.
- **Micro-copy is functional, not cute**: "No items yet" / "Add New Item" / "View all →" — direct labels, arrow glyphs for "see more" links, no jokes or filler.
- **AI moments get a distinct, slightly playful voice**: "Quick Add — type a task and hit Enter", a small lightning-bolt (Zap) icon marks anything AI-assisted. This is the one place personality shows up.
- **Emoji**: essentially unused in UI chrome. Don't introduce emoji into card labels, buttons, or status pills.
- **Numbers over adjectives**: dashboard copy favors concrete stats ("68% completion rate", "3 items low") over vague claims.
- **Placeholder examples use real-feeling but obviously-fake data**: "Alex Kim — Fix checkout payment bug", workspace name "Acme Co" — keep mocked content in this same register (named person + concrete task, plain company name).

## Visual foundations
- **Palette strategy — neutral base, two strategic accents**: overwhelmingly slate/white/gray. Blue (primary actions, links, active nav) and purple (paired with blue in a gradient for AI/"quick" actions) are the only two brand hues used broadly — every other color (yellow, orange, green, red, emerald) is reserved as **fixed semantic meaning** for status or priority, never decorative. Color always tells you something (status/priority/urgency), so screens stay calm and scannable rather than colorful for its own sake.
- **Status colors are pinned, not palette-of-the-day**: backlog=slate, triage=blue, blocked=yellow, in_progress=orange, review=purple, ready=green, done=emerald, cancelled=red. Don't remix these.
- **Type**: no custom webfont — the system (`ui-sans-serif, system-ui, -apple-system...`) stack, i.e. native OS font. Monospace (`ui-monospace...`) is reserved for join codes, IDs, and SKUs. Headings are bold/black weight (700), often on a subtle `slate-900→slate-700` gradient-text treatment for page titles.
- **Backgrounds**: full pages sit on a very soft `slate-50→blue-50` diagonal gradient — never flat white, never a hard color block. The one exception is a pre-login/auth screen, which uses a dramatic dark `slate-900→blue-950→slate-900` gradient. No photography, illustration, texture, or pattern anywhere.
- **Gradients**: reserved for two jobs — (1) brand/AI call-to-action surfaces (blue-600→purple-700, e.g. the Quick Add bar, primary CTA buttons) and (2) the dark auth backdrop. Metric-tile icon chips use a *single-hue* gradient (e.g. blue-500→blue-600) for depth, not a rainbow.
- **Cards**: white, **no border**, `shadow-md`, `rounded-xl` (12px) — consistently border:none + shadow, never border+shadow together, and never a colored left-border accent strip.
- **Corner radii**: buttons/inputs `rounded-md` (8px), cards `rounded-xl` (12px), avatars/status pills `rounded-full`. Nothing sharp-cornered.
- **Shadows**: `shadow-md` is the default resting elevation for nearly everything (cards, kanban cards); `shadow-lg`/`shadow-xl` reserved for modals/sheets and hover states. No colored/glow shadows.
- **Hover / press states**: hover = subtle background darken or bg-tint swap (e.g. ghost button hover → light gray fill; kanban card hover → shadow-lg + slight scale); press states aren't heavily choreographed — mostly rely on browser default + color shift, no big shrink/bounce.
- **Animation**: minimal and utilitarian — accordion expand/collapse ease-out ~200ms, a spinning loader for async actions, transform/opacity transitions on the mobile sidebar slide-in. No bounces, no springs, no decorative motion.
- **Transparency / blur**: `backdrop-blur-sm` + `bg-white/80` for sheets/cards that float over the gradient background (inventory sheet, activity cards) to keep the soft-gradient visible underneath; on the dark auth screen, `bg-white/10` + `border-white/20` creates frosted glass inputs/cards. Blur is always paired with a translucent white/near-white fill — never applied to solid-color surfaces.
- **Layout**: fixed 240px dark slate-900 sidebar (desktop) collapsing to a slide-in drawer + overlay on mobile; content area scrolls independently. No sticky/fixed headers beyond a mobile top bar.
- **Imagery color vibe**: n/a — no photography or illustration; all visual interest comes from color, type, and elevation.

## Iconography
- **Icon library**: [Lucide](https://lucide.dev) — thin 2px stroke, rounded caps, no fill. This is the only icon system; no custom icon font, no PNG icon set.
- No SVG/PNG icon assets exist to copy locally (source rendered them from the `lucide-react` npm package at build time) — this system links individual icons from the Lucide CDN (`unpkg.com/lucide-static`) so markup and visuals match.
- Emoji: not used as UI icons.
- Icon sizing follows two fixed steps: 16px (most inline icons) and 20px (section headers/empty states); icons take the surrounding text color unless they're carrying their own semantic color (status/priority).

## Logo
**No logo asset exists.** Wherever a mark would go, this system renders the brand name "Anchor" in plain bold type next to a small colored icon chip (see `thumbnail.html`, `ui_kits/anchor/Sidebar.jsx`) rather than inventing a logo mark. Attach a real logo file if you have one.

## Fonts
No font files needed — inherits the OS default UI font (`font-sans`/`font-mono` stacks). Nothing to substitute.

## Naming / rebranding this system
"Anchor" and every example name ("Acme Co", "Alex Kim", etc.) are placeholders invented for this generic system — swap them for your real product/company name across `readme.md`, `thumbnail.html`, `ui_kits/anchor/Sidebar.jsx`, and any card copy that says "Acme Co".
