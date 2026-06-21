import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../vision_settings_scope.dart';

Future<void> showGeminiApiKeyDialog(BuildContext context) async {
  final repo = VisionSettingsScope.of(context);
  final controller = TextEditingController(text: repo.geminiApiKey);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.nightSurface,
        title: const Text('Clave Gemini IA'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Para reconocer varias fichas con IA necesitas una clave gratuita de Google AI Studio. '
              'Se guarda solo en tu teléfono.',
              style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'AIza...',
              ),
            ),
          ],
        ),
        actions: [
          if (repo.hasGeminiApiKey)
            TextButton(
              onPressed: () async {
                await repo.clearGeminiApiKey();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(
                'Quitar',
                style: TextStyle(color: AppColors.neonRose),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              await repo.saveGeminiApiKey(controller.text);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );

  controller.dispose();
}
