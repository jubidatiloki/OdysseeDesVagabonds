import 'package:flutter/material.dart';

import '../theme.dart';
import '../version.dart';
import '../widgets/consultation.dart';

/// Page « À propos » : présentation du projet (à compléter).
class AProposScreen extends StatelessWidget {
  const AProposScreen({super.key, this.menu});

  final Widget? menu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: menu,
      appBar: AppBar(title: const Text('À propos')),
      body: LargeurLimitee(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Image.asset(
                kLogo,
                width: 160,
                height: 160,
                errorBuilder: (context, error, stack) => Icon(
                  Icons.hiking,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "L'odyssée des vagabonds",
              style: styleAmbiance(theme.textTheme.headlineSmall),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Version $kVersionApp · $kDateVersion',
              key: Key('version-app'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Center(
              child: TexteAVenir('Présentation du projet à venir.'),
            ),
          ],
        ),
      ),
    );
  }
}
