import 'dart:math';

import 'package:flutter/material.dart';

import '../services/app_state.dart';

/// Keeps settings, progress deletion, and external links behind a local check.
class ParentGate {
  ParentGate._();

  static final Random _random = Random();

  static Future<bool> request(BuildContext context, AppState app) async {
    final a = 3 + _random.nextInt(7);
    final b = 2 + _random.nextInt(8);
    final controller = TextEditingController();
    var wrong = false;

    final solved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(app.t('parent_gate_title')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app
                      .t('parent_gate_prompt')
                      .replaceAll('{a}', '$a')
                      .replaceAll('{b}', '$b'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: app.t('confirm'),
                    errorText: wrong ? app.t('parent_gate_wrong') : null,
                  ),
                  onSubmitted: (_) => _check(
                    controller,
                    a + b,
                    setState,
                    dialogContext,
                    () => wrong = true,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(app.t('parent_gate_cancel')),
              ),
              FilledButton(
                onPressed: () => _check(
                  controller,
                  a + b,
                  setState,
                  dialogContext,
                  () => wrong = true,
                ),
                child: Text(app.t('parent_gate_continue')),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (solved != true || !context.mounted) return false;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(app.t('parent_gate_title')),
            content: Text(app.t('parent_gate_confirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(app.t('cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(app.t('confirm')),
              ),
            ],
          ),
        ) ??
        false;
  }

  static void _check(
    TextEditingController controller,
    int expected,
    StateSetter setState,
    BuildContext dialogContext,
    VoidCallback markWrong,
  ) {
    if (int.tryParse(controller.text.trim()) == expected) {
      Navigator.of(dialogContext).pop(true);
    } else {
      markWrong();
      setState(() {
        controller.clear();
      });
    }
  }
}
