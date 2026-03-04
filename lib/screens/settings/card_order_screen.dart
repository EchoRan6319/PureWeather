import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/settings_provider.dart';

class CardOrderScreen extends ConsumerStatefulWidget {
  const CardOrderScreen({super.key});

  static void show(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CardOrderScreen()),
    );
  }

  @override
  ConsumerState<CardOrderScreen> createState() => _CardOrderScreenState();
}

class _CardOrderScreenState extends ConsumerState<CardOrderScreen> {
  late List<String> _currentOrder;

  final Map<String, ({String title, IconData icon})> _cardInfo = {
    'hourly': (title: '24小时预报', icon: Icons.schedule_outlined),
    'daily': (title: '7天预报', icon: Icons.calendar_month_outlined),
    'airQuality': (title: '空气质量', icon: Icons.air_outlined),
    'details': (title: '详细信息', icon: Icons.info_outline),
  };

  @override
  void initState() {
    super.initState();
    _currentOrder = List.from(ref.read(settingsProvider).weatherCardOrder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('天气卡片排序'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_outlined),
            onPressed: () {
              setState(() {
                _currentOrder = ['hourly', 'daily', 'airQuality', 'details'];
              });
            },
            tooltip: '恢复默认',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '按住并拖动卡片右侧的图标，调整它们在天气详情页中的上下显示顺序。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _currentOrder.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _currentOrder.removeAt(oldIndex);
                  _currentOrder.insert(newIndex, item);
                });
                ref
                    .read(settingsProvider.notifier)
                    .setWeatherCardOrder(_currentOrder);
              },
              itemBuilder: (context, index) {
                final key = _currentOrder[index];
                final info = _cardInfo[key]!;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        info.icon,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      info.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.reorder_rounded),
                  ),
                ).animate(key: ValueKey(key)).fadeIn(delay: Duration(milliseconds: index * 50));
              },
            ),
          ),
        ],
      ),
    );
  }
}
