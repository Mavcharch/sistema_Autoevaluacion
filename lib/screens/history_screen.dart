import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/history_entry.dart';
import '../services/storage_service.dart';
import '../widgets/stat_card.dart';

/// Pantalla de historial de evaluaciones.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storage = StorageService();
  List<HistoryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _storage.getHistory();
    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  Future<void> _delete(String id) async {
    await _storage.deleteEntry(id);
    _load();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Vaciar historial?'),
        content: const Text(
          'Se eliminarán todas las evaluaciones guardadas. Esta acción no se '
          'puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _storage.clearHistory();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.emerald))
            : RefreshIndicator(
                color: AppColors.emerald,
                onRefresh: _load,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      title: Text(
                        'Historial',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      actions: [
                        if (_entries.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.delete_sweep_outlined),
                            onPressed: _clearAll,
                            tooltip: 'Vaciar historial',
                          ),
                      ],
                    ),
                    if (_entries.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmpty(),
                      )
                    else ...[
                      SliverToBoxAdapter(child: _buildSummary()),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final entry = _entries[index];
                            return _HistoryTile(
                              entry: entry,
                              onDelete: () => _delete(entry.id),
                            );
                          },
                          childCount: _entries.length,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history,
                size: 64, color: AppColors.gray.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              'Aún no hay evaluaciones',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Cuando evalúes código, aparecerá aquí tu historial.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    if (_entries.isEmpty) return const SizedBox.shrink();
    final avg = _entries.map((e) => e.overallScore).reduce((a, b) => a + b) /
        _entries.length;
    final best = _entries
        .map((e) => e.overallScore)
        .reduce((a, b) => a > b ? a : b);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Evaluaciones',
              value: '${_entries.length}',
              icon: Icons.analytics_outlined,
              color: AppColors.emerald,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              title: 'Promedio',
              value: avg.round().toString(),
              icon: Icons.trending_up,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              title: 'Mejor',
              value: best.round().toString(),
              icon: Icons.emoji_events_outlined,
              color: AppColors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onDelete;

  const _HistoryTile({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(entry.overallScore);
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Puntuación circular
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.overallScore.round().toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: entry.language.brandColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          entry.language.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: entry.language.brandColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '· ${entry.grade}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.codePreview.replaceAll('\n', ' '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11.5,
                        height: 1.3,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(entry.evaluatedAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.code,
                            size: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.totalLines} líneas',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'hace ${diff.inDays} d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
