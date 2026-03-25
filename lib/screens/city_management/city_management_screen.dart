import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../models/weather_models.dart';
import '../../providers/city_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/weather_provider.dart';

/// 城市管理屏幕
class CityManagementScreen extends ConsumerStatefulWidget {
  const CityManagementScreen({super.key});

  @override
  ConsumerState<CityManagementScreen> createState() => _CityManagementScreenState();
}

/// 城市管理屏幕状态
class _CityManagementScreenState extends ConsumerState<CityManagementScreen> {
  /// 搜索输入控制器
  final _searchController = TextEditingController();
  
  /// 搜索结果
  List<Location> _searchResults = [];
  
  /// 是否正在搜索
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 搜索城市
  /// 
  /// [query] 搜索关键词
  Future<void> _searchCities(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      final results = await locationService.searchLocations(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  /// 添加城市
  /// 
  /// [location] 城市位置信息
  /// [navigateBack] 是否返回上一页
  Future<void> _addCity(Location location, {bool navigateBack = true}) async {
    await ref.read(cityManagerProvider.notifier).addCityAndSetDefault(location);
    
    _searchController.clear();
    setState(() {
      _searchResults = [];
    });
    
    await ref.read(weatherProvider.notifier).loadWeather(location);
    
    if (mounted && navigateBack) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('已切换到 {location}', args: {'location': location.name}),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 删除城市
  /// 
  /// [city] 要删除的城市
  Future<void> _removeCity(Location city) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('删除城市')),
        content: Text(context.tr('确定要删除 {city} 吗？', args: {'city': city.name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('取消')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.tr('删除')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(cityManagerProvider.notifier).removeCity(city.id);
      final cities = ref.read(cityManagerProvider);
      if (cities.isEmpty) {
        await ref.read(locationInitProvider.notifier).initLocation(force: true);
        final locationState = ref.read(locationInitProvider);
        if (locationState.error != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('已删除全部城市，定位失败。请搜索城市或检查定位权限。')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// 获取当前位置
  Future<void> _getCurrentLocation() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final accuracyLevel =
          ref.read(settingsProvider).locationAccuracyLevel;
      final position = await locationService.getCurrentPosition();
      
      if (position != null) {
        final location = await locationService.getLocationFromCoords(
          position.latitude,
          position.longitude,
          accuracyLevel: accuracyLevel,
        );
        await _addCity(location);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('无法获取位置，请检查权限设置')),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('定位失败: {error}', args: {'error': e})),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cities = ref.watch(cityManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('城市管理')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: context.tr('搜索城市'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _searchCities(value);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.my_location),
                        label: Text(context.tr('定位当前位置')),
                        onPressed: _getCurrentLocation,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isNotEmpty
                    ? _buildSearchResults()
                    : _buildCityList(cities),
          ),
        ],
      ),
    );
  }

  /// 构建副标题
  /// 
  /// [adm1] 行政区域一级
  /// [adm2] 行政区域二级
  /// 
  /// 返回副标题字符串
  String _buildSubtitle(String adm1, String adm2) {
    final parts = <String>[];
    if (adm1.isNotEmpty) parts.add(adm1);
    if (adm2.isNotEmpty && adm2 != adm1) parts.add(adm2);
    return parts.isEmpty ? '' : parts.join(' ');
  }

  /// 构建搜索结果列表
  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        final subtitle = _buildSubtitle(location.adm1, location.adm2);
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: context.uiTokens.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.uiTokens.cardBorder),
          ),
          child: ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(location.name),
            subtitle: subtitle.isEmpty ? null : Text(subtitle),
            trailing: FilledButton.tonal(
              onPressed: () => _addCity(location),
              child: Text(context.tr('添加')),
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
      },
    );
  }

  /// 构建城市列表
  /// 
  /// [cities] 城市列表
  Widget _buildCityList(List<Location> cities) {
    if (cities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('还没有添加城市'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('搜索城市或使用定位添加'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cities.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(cityManagerProvider.notifier).reorderCities(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final city = cities[index];
        return _CityListItem(
          key: ValueKey(city.id),
          city: city,
          onTap: () async {
            await ref.read(cityManagerProvider.notifier).setDefaultCity(city.id);
            await ref.read(weatherProvider.notifier).loadWeather(city);
            if (context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          onDelete: () => _removeCity(city),
          index: index,
        );
      },
    );
  }
}

/// 城市列表项组件
class _CityListItem extends ConsumerWidget {
  /// 城市信息
  final Location city;
  
  /// 点击回调
  final VoidCallback onTap;
  
  /// 删除回调
  final VoidCallback onDelete;
  
  /// 索引
  final int index;

  /// 创建城市列表项实例
  /// 
  /// [city] 城市信息
  /// [onTap] 点击回调
  /// [onDelete] 删除回调
  /// [index] 索引
  const _CityListItem({
    super.key,
    required this.city,
    required this.onTap,
    required this.onDelete,
    required this.index,
  });

  /// 构建副标题
  /// 
  /// [adm1] 行政区域一级
  /// [adm2] 行政区域二级
  /// 
  /// 返回副标题字符串
  static String _buildSubtitle(String adm1, String adm2) {
    final parts = <String>[];
    if (adm1.isNotEmpty) parts.add(adm1);
    if (adm2.isNotEmpty && adm2 != adm1) parts.add(adm2);
    return parts.isEmpty ? '' : parts.join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherForCityProvider(city));
    final isDefault = city.isDefault;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDefault
            ? context.uiTokens.selectedBackground
            : context.uiTokens.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault
              ? context.uiTokens.selectedBorder
              : context.uiTokens.cardBorder,
        ),
      ),
      child: ListTile(
        leading: Icon(
          isDefault
              ? Icons.check_circle_rounded
              : (city.isLocated ? Icons.my_location_rounded : Icons.location_on_outlined),
          color: isDefault
              ? context.uiTokens.selectedBorder
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          city.name,
          style: isDefault ? const TextStyle(fontWeight: FontWeight.w600) : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_buildSubtitle(city.adm1, city.adm2).isNotEmpty)
              Text(_buildSubtitle(city.adm1, city.adm2)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (city.isLocated)
                  _StatusTag(label: context.tr('定位'), icon: Icons.my_location_rounded),
                if (isDefault)
                  _StatusTag(label: context.tr('默认'), icon: Icons.check_circle_rounded),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            weatherAsync.when(
              data: (weather) {
                if (weather == null) return const SizedBox();
                return Text(
                  '${weather.current.temp}°',
                  style: Theme.of(context).textTheme.titleLarge,
                );
              },
              loading: () => const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (error, stack) => const Icon(Icons.error_outline, size: 20),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
        onTap: onTap,
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
  }
}

class _StatusTag extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatusTag({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.uiTokens.selectedForeground.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: context.uiTokens.selectedBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.uiTokens.selectedForeground),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.uiTokens.selectedForeground,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
