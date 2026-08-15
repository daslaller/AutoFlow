# Engine: HeidNodes for canvas and Preview

The editor canvas **and** Preview execution are
[`daslaller/HeidNodes`](https://github.com/daslaller/HeidNodes)
`fl_nodes_core` (via `fl_nodes_visual_scripting`). AutoFlow supplies the
product chrome (palette, inspector, records, host API) around
`FlNodesWidget`. There is one live `FlNodesController`; Preview runs that
graph instead of translating it into a second homemade canvas.

The practical effect: an If/Else or Switch node's untaken branch does not
run. Named output ports (`true`/`false`, `case1`/`default`, …) are HeidNodes
control ports — independently wirable in the editor and honored at Preview
time.

## Why this exists

F8F used to ship a from-scratch simulator that walked a flat topological
order and **ignored port identity**. Both sides of an if-else always
animated as "running". `fl_nodes_core` is the engine that actually executes
named branches (typed ports, control-flow-aware walk). Proof:
`packages/fl_nodes_core/test/runner_branching_test.dart` in HeidNodes, and
this package's `test/simulation_engine_branching_test.dart`.

The editor used to be a second, homemade canvas (`WorkflowCanvas` +
`PortGeometry`). That duplicated hit-testing and wiring that HeidNodes
already implements. The canvas now *is* `FlNodesWidget`; AutoFlow chrome
(palette, inspector, records) sits around it. Palette drag-ghosts are not
graph nodes.

`WorkflowDoc` v2 remains the host save format. AutoFlow loads it into the
HeidNodes controller (preserving instance ids) and exports it back on edit.

## What `SimulationEngine` does

Public API is unchanged: `run({nodes, wires, input, onStatus, onEvent,
codePreview, catalog, shouldCancel, useRandomFailures})` still returns
`RunReport` / `NodeResult` / `PreviewEvent`. Headless callers get a
throwaway HeidNodes graph; the in-editor Preview button runs the live
controller instead.

Internally, `run()`:

1. Registers one HeidNodes prototype per catalog type (trigger / multi-out
   condition / action).
2. Loads `WorkflowDoc` nodes and wires onto a `FlNodesController`, keeping
   AutoFlow `iid`s as HeidNodes node ids.
3. Builds and executes the graph. If/Else and Switch pick a named control
   port; only that subgraph walks.
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
mounting `AutoFlowBuilder`. Named default-look alternatives
(`AnchorThemePresets`: `anchor`, `midnight`, `workshop`, `harbor`,
`studio`) are also `AnchorColorsData` instances. Numbered shades
(`slate500`, `blue50`, …) stay fixed — see `lib/theme/anchor_colors.dart`.
The HeidNodes canvas reads those tokens for grid, node chrome, and ports.

## Follow-up

**Loop** is still a catalog stub: one `out` port, runs once like an action.
Real iterate-over-list semantics (body vs after, per-item context) are not
implemented. Delay is the same shape — a wait node, not a scheduler.
