import 'package:flutter/material.dart';

import '../data/duas_data.dart';
import '../widgets/app_background.dart';

class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Duas', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(12, kToolbarHeight + MediaQuery.of(context).padding.top + 8, 12, 16),
          itemCount: duaCategories.length,
          itemBuilder: (context, index) {
            final category = duaCategories[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                  child: Icon(category.icon, color: theme.colorScheme.primary),
                ),
                title: Text(category.name),
                subtitle: Text('${category.duas.length} duas'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DuaListScreen(category: category),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DuaListScreen extends StatelessWidget {
  const DuaListScreen({super.key, required this.category});

  final DuaCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(category.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: ListView.builder(
        padding: EdgeInsets.fromLTRB(12, kToolbarHeight + MediaQuery.of(context).padding.top + 8, 12, 16),
        itemCount: category.duas.length,
        itemBuilder: (context, index) {
          final dua = category.duas[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    dua.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dua.arabic,
                    style: theme.textTheme.headlineSmall?.copyWith(height: 2),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dua.transliteration,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(dua.translation, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Chip(
                      label: Text(dua.source),
                      labelStyle: theme.textTheme.bodySmall,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }
}
