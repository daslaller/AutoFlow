import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flowstock/controller/flow_controller.dart';
import 'package:flowstock/data/node_catalog.dart';
import 'package:flowstock/theme/flowstock_colors.dart';
import 'package:flowstock/widgets/icons/lucide_path_icon.dart';
import 'package:flowstock/widgets/shared_widgets.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key, required this.controller});

  final FlowController controller;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  late final TextEditingController _nameCtrl;

  FlowController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: c.wfName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([c.chromeTick, c.viewportTick]),
      builder: (context, _) {
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: FsColors.white.withValues(alpha: 0.85),
                border: const Border(
                  bottom: BorderSide(color: FsColors.slate200),
                ),
              ),
              child: Row(
                children: [
                  const BrandMark(),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 230,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Automations',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: FsColors.slate500,
                            height: 1.2,
                          ),
                        ),
                        TextField(
                          controller: _nameCtrl,
                          onChanged: c.setWfName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: FsColors.slate900,
                            height: 1.3,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  _ActivePill(
                    active: c.active,
                    onTap: c.toggleActive,
                  ),
                  const Spacer(),
                  if (c.running)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Text(
                        'Executing steps…',
                        style: TextStyle(
                          fontSize: 12,
                          color: FsColors.slate500,
                        ),
                      ),
                    ),
                  HoverButton(
                    onTap: c.openEmbed,
                    style: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hoverStyle: BoxDecoration(
                      color: FsColors.slate100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox(
                      height: 34,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 13),
                        child: Row(
                          children: [
                            LucidePathIcon(
                              pathData: Ic.codeBrackets,
                              size: 14,
                              color: FsColors.slate700,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Embed',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: FsColors.slate700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RunButton(
                    running: c.running,
                    onTap: c.runFlow,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActivePill extends StatelessWidget {
  const _ActivePill({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: active ? FsColors.green100 : FsColors.slate100,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? FsColors.green500 : FsColors.slate400,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                active ? 'Active' : 'Paused',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: active ? FsColors.green700 : FsColors.slate500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RunButton extends StatefulWidget {
  const _RunButton({required this.running, required this.onTap});

  final bool running;
  final VoidCallback onTap;

  @override
  State<_RunButton> createState() => _RunButtonState();
}

class _RunButtonState extends State<_RunButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: FsColors.brandGradient,
            boxShadow: FsColors.shadowMd,
          ),
          foregroundDecoration: _hover
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withValues(alpha: 0.08),
                )
              : null,
          child: Row(
            children: [
              if (widget.running)
                const SpinningRing(size: 12)
              else
                const LucidePathIcon(
                  pathData: Ic.play,
                  size: 13,
                  color: Colors.white,
                  filled: true,
                  strokeWidth: 0,
                ),
              const SizedBox(width: 8),
              Text(
                widget.running ? 'Running…' : 'Run Test',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
