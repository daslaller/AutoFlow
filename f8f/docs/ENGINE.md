# Engine: Preview runs on HeidNodes

Preview is backed by
[`daslaller/HeidNodes`](https://github.com/daslaller/HeidNodes)'
`fl_nodes_core` (via `fl_nodes_visual_scripting`). The canvas you edit is
still AutoFlow's own Flutter widgets — HeidNodes is the **executor**, not
the editor.

The practical effect: an If/Else or Switch node's untaken branch does not
run. Named output ports (`true`/`false`, `case1`/`default`, …) are wired in
the editor and honored at Preview time.

## Why this exists

F8F used to ship a from-scratch simulator that walked a flat topological
order and **ignored port identity**. Both sides of an if-else always
animated as "running". `fl_nodes_core` is the engine that actually executes
named branches (typed ports, control-flow-aware walk). Proof:
`packages/fl_nodes_core/test/runner_branching_test.dart` in HeidNodes, and
this package's `test/simulation_engine_branching_test.dart`.

The editor canvas was a separate gap: output hit-testing used a single
anchor, so you could not drag `true` to one node and `false` to another.
That is fixed — `PortGeometry` places each catalog port, the card draws
them, and `Wire.fromPort` is set from the port you dragged.

## What `SimulationEngine` does

Public API is unchanged: `run({nodes, wires, input, onStatus, onEvent,
codePreview, catalog, shouldCancel, useRandomFailures})` still returns
`RunReport` / `NodeResult` / `PreviewEvent`.

Internally, `run()`:

1. Builds one `fl_nodes_visual_scripting` prototype per `CanvasNode`.
2. Adds nodes and wires to an `AutomationEngine`, using catalog `PortDef.id`
   strings as port names.
3. Runs it. If/Else and Switch pick a named control port; only that
   subgraph walks.
4. Status/events still use the same timing (120ms idle, 280ms running,
   80ms settle) so Preview *feels* the same, only the untaken branch stays
   `idle`.

`executionOrder()` is still a naive topological list that ignores branches
on purpose ("what depends on what", not "what would run").

A failed node stops its downstream branch (same as production). Random
preview failures (`useRandomFailures: true`) therefore no longer light up
unrelated nodes.

## Host theming

Semantic tokens (`AnchorColors.primary`, kind accents, status colors, …)
read from `AnchorColors.active` (`AnchorColorsData`). Set it before
mounting `AutoFlowBuilder`. Numbered shades (`slate500`, `blue50`, …) stay
fixed — see `lib/theme/anchor_colors.dart`.

## Follow-up

**Loop** is still a catalog stub: one `out` port, runs once like an action.
Real iterate-over-list semantics (body vs after, per-item context) are not
implemented. Delay is the same shape — a wait node, not a scheduler.
