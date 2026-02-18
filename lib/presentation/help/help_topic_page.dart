import 'package:flutter/material.dart';
import 'package:fin_pessoal/core/help/help_data.dart';

class HelpTopicPage extends StatelessWidget {
  const HelpTopicPage({super.key, required this.topic});

  final HelpTopic topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in topic.sections) ...[
            if (section.title != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  section.title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
            for (final p in section.paragraphs)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  p,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
