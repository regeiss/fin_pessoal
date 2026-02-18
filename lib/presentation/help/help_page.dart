import 'package:flutter/material.dart';
import 'package:fin_pessoal/core/help/help_data.dart';
import 'package:fin_pessoal/presentation/help/help_topic_page.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<HelpTopic> get _filtered =>
      _query.trim().isEmpty ? HelpData.allTopics : HelpData.search(_query);

  void _openTopic(HelpTopic topic) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HelpTopicPage(topic: topic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topics = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Central de Ajuda'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                hintText: 'Buscar na ajuda...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: topics.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: theme.colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum resultado para "$_query"',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(topic.icon, color: theme.colorScheme.primary),
                          title: Text(topic.title),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openTopic(topic),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
