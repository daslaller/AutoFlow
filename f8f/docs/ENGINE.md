# Engine: this package now runs on HeidNodes

**2026-08-10.** F8F (this package, née "AutoFlow") used to ship its own
from-scratch preview simulator (`SimulationEngine`, walking a naive flat
topological order). It now delegates to
[`daslaller/HeidNodes`](https://github.com/daslaller/HeidNodes)'
`fl_nodes_core` — a general node-graph rendering + execution engine — via
the `fl_nodes_visual_scripting` package built on top of it.

## Why

Two F8F variants existed side by side in `daslaller/F8F`: `f8f-claude`
("Flowstock") and `f8f-figma` (this package, "AutoFlow"). Both had the same
real gap, confirmed by reading both engines end to end: **neither actually
executed named multi-output branches.** An `if-else` node's `true`/`false`
ports were modeled correctly in the data (`NodeTypeDef.outputs`,
`Wire.fromPort`), but the execution walk ignored port identity entirely —
`SimulationEngine.executionOrder`'s naive topological sort visited every
node downstream of *either* branch, so a preview run animated both sides of
an if-else as "running", every time, regardless of the condition.

HeidNodes' `fl_nodes_core` is the one of the three engines (this one,
Flowstock's, and HeidNodes') that actually solves this — at the data model,
the interactive canvas, and the executor simultaneously — with a real,
non-toy implementation (typed ports, a topological+control-flow-aware
build phase, per-control-port subgraphs, loop support beyond simple
if/else). See `daslaller/HeidNodes`'
`packages/fl_nodes_core/test/runner_branching_test.dart` for direct proof,
and this package's own `test/simulation_engine_branching_test.dart` for
proof through *this* package's public API.

`f8f-claude`/Flowstock was deleted from the F8F repo as part of this same
change — its UX was evaluated (categorized node palette, top bar, minimap)
and found to already be matched or exceeded by what this package ships
(`NodePalette` already groups by `NodeKind` with search; see
`lib/features/builder/node_palette.dart`), so there was nothing distinctive
left to port over.

## What actually changed

`lib/features/run/simulation_engine.dart`'s **public API is unchanged** —
same `SimulationEngine` class, same `run({nodes, wires, input, onStatus,
onEvent, codePreview, catalog, shouldCancel, useRandomFailures})` signature,
same `RunReport`/`NodeResult`/`PreviewEvent` return shapes. Nothing calling
it (`WorkflowController`) needed to change.

Internally, `run()` now:
1. Builds one `fl_nodes_visual_scripting` node prototype per `CanvasNode`
   instance (not per catalog type — see the file's comments for why: this
   engine is rebuilt fresh on every `run()` call rather than persisted via
   `fl_nodes_core`'s own project JSON, so there's no need for the
   typed-field machinery that would matter if it were being serialized).
2. Adds each node and wire to a real `AutomationEngine`
   (`fl_nodes_visual_scripting`), using the exact `PortDef.id` strings the
   catalog already declares as fl_nodes_core port names — `if-else`'s
   `true`/`false` outputs map directly onto named control-output ports.
3. Runs it. fl_nodes_core's executor decides which branch to walk; the
   `if-else` node's own logic (unchanged — still `ExpressionEvaluator.
   evaluateCondition`) only determines *which* named port to forward to.
4. Reports go through the exact same `onStatus`/`onEvent`/timing (120ms
   idle pause, 280ms running, 80ms settle) as before — a host watching
   preview animate sees no difference in feel, only correctness: the
   untaken branch's nodes now stay `idle` for the whole run instead of also
   flashing running/success.

`executionOrder()` (a separate, simpler utility — a naive topological
listing that ignores branches on purpose, used by callers that want "roughly
what depends on what" rather than "what would actually run") is untouched.

**One deliberate behavior change:** the old simulator kept walking every
remaining node after one failed (all nodes ran regardless of any earlier
failure, since the walk had no real dependency semantics to begin with). The
new one stops propagating past a node that throws — same as `fl_nodes_core`
itself does, and the same thing a *real* production execution must do
(you don't want a downstream send/print action to fire after the step that
was supposed to gate it failed). This affects `useRandomFailures: true` runs
(passed as `!preview` at the `WorkflowController` call site) — a randomly-
failed node now halts the rest of that node's downstream branch instead of
every other node still lighting up around it.

## Host theming

Neither F8F variant had a real host-theme-injection seam — both hardcoded
their palette. `lib/theme/anchor_colors.dart`'s semantic tokens (`primary`,
`accent`, `success`, the five node-kind accents, status colors, ...) now
read from a swappable `AnchorColors.active` (`AnchorColorsData`), the same
"static getter over a mutable active instance" shape RepairX's own
`AppColors`/`Money.active` already use — so a host sets
`AnchorColors.active = AnchorColorsData(...)` (e.g. built from its own
design tokens) before mounting `AutoFlowBuilder`, and every existing
`AnchorColors.primary`-style call site in this package keeps working
unchanged. Named default-look alternatives (`AnchorThemePresets`:
`anchor`, `midnight`, `workshop`, `harbor`, `studio`) are also just
`AnchorColorsData` instances — `AnchorThemePresets.apply('midnight')` or
the demo's `?theme=midnight`. The raw numbered palette (`slate500`,
`blue50`, ...), used for minor decorative accents in a few widgets, stays
fixed — see `lib/theme/anchor_colors.dart`'s doc comments for why
overriding those individually isn't the goal.

## What's still worth doing (not done here)

`docs/HOST_API.md`'s "Known limitations" note on the **interactive canvas**
still applies: `workflow_canvas.dart`/`wire_painter.dart` always resolve a
node's output to a single fixed anchor point regardless of how many output
ports it has, so a user still can't *drag-wire* a `true` branch to one node
and a `false` branch to another through the UI — only hand-authored/imported
`WorkflowDoc` JSON (like the demo graph) can produce that today. This change
fixes *execution* correctness (the branch that's wired now genuinely runs
alone); it does not touch canvas interaction. Migrating the canvas widget
itself onto `fl_nodes_core`'s `FlNodesWidget` (which solves the interactive
side of this natively — see HeidNodes' own example app) would close that
gap, but is a substantially larger UI rewrite than this change and is left
as explicit future work rather than attempted partially here.
