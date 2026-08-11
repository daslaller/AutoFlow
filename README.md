# F8F

An embeddable, visual trigger/condition/action automation/workflow builder
for Flutter hosts (built for [RepairX](https://github.com/daslaller/repairx),
usable by any host).

**2026-08-10 — merged from two variants into one.** This repo used to hold
two independent implementations side by side, `f8f-claude` ("Flowstock") and
`f8f-figma` ("AutoFlow"). Both were read end to end, compared, and found to
share the same real gap: neither actually executed named multi-output
branches (an if-else node's `true`/`false` ports were modeled but the
execution walk ignored which one was taken). `f8f-figma` had the stronger
host-embeddable API contract, zero backend coupling, and a genuinely
feature-complete v1 editor (undo/redo, variables panel, validation, mobile
layout) — it's the surviving package, now at `f8f/`. `f8f-claude` was
deleted after its UX was evaluated and found already matched by what
`f8f-figma` shipped (a categorized, searchable node palette; see
`f8f/lib/features/builder/node_palette.dart`).

The branching gap itself is now fixed: this package's execution/preview
engine is backed by [`daslaller/HeidNodes`](https://github.com/daslaller/HeidNodes)'
`fl_nodes_core`, which does correctly execute named branches end to end —
see `f8f/docs/ENGINE.md` for the full story, including what changed, what
didn't, and what's deliberately left as follow-up work (the interactive
canvas still can't *drag-wire* a second output port — only the execution
side was rewired here).

## The package

Everything lives under `f8f/` — a Flutter package, Dart package name
`autoflow` (kept for now; see `f8f/docs/ENGINE.md` if you're wondering why
the package name and the repo name differ — same shape as RepairX itself,
whose Dart package name is `mobilx_repairx`). Read `f8f/README.md` for how
to embed it, and `f8f/docs/HOST_API.md` for the full API reference.

## Design

Visual language is Anchor design-system tokens, now host-overridable — see
`f8f/docs/ENGINE.md`'s "Host theming" section. RepairX embeds this package
skinned to its own Rail design tokens rather than the shipped Anchor
default.
