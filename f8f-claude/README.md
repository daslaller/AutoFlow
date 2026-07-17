# Flowstock — Embeddable Workflow Automation Tool

Pixel-perfect Flutter recreation of the **Flow Builder** design from the Claude Design handoff.

## Run

```bash
flutter pub get
flutter run -d chrome   # or windows / macos
```

## What's included

- Top bar with workflow name, Active/Paused pill, Embed, Run Test
- Collapsible node library (16 types across Triggers / Repair Ops / Messaging / AI / Logic)
- Interactive canvas: pan, zoom (scroll + controls), bezier wires, ports, minimap
- Inspector with field editors + JSON node definition
- Demo graph: Ready-for-pickup notifier
- Embed dialog with `defineNodes()` snippet
- Simulated run animation with toast

## Design source

Handoff lives in `_handoff/embeddable-workflow-automation-tool/`. Primary file: `project/Flow Builder.dc.html`.

The canvas is a custom engine matching the handoff's interaction model (not vyuh/fl_nodes), so layout, ports, and chrome stay pixel-aligned with the prototype.
