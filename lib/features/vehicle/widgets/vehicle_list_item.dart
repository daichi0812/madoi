import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:madoi/features/todo/providers/todo_providers.dart';
import 'package:madoi/features/vehicle/models/vehicle_model.dart';

class VehicleListItem extends ConsumerWidget {
  final VehicleModel vehicle;
  const VehicleListItem({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // この車両に紐づくToDoの情報を監視します
    final todosAsync = ref.watch(todosProvider(vehicle.id));
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      clipBehavior: Clip.antiAlias, // Cardの角丸を子ウィジェットにも適用
      child: InkWell(
        onTap: () => context.push('/vehicle/${vehicle.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              // 車両アイコン
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withAlpha(26),
                foregroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.directions_car),
              ),
              const SizedBox(width: 16),
              // 車両名と愛称
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (vehicle.nickname.isNotEmpty)
                      Text(
                        vehicle.nickname,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ToDo数と最終更新日 (非同期で表示)
              todosAsync.when(
                data: (todos) {
                  // 未完了のToDoのみをカウント
                  final incompleteTodos = todos.where((t) => !t.isDone).length;
                  // ToDoリストから最新の更新日を取得、なければ車両の作成日を使用
                  final DateTime lastUpdate = todos.isNotEmpty
                      ? todos
                            .map((t) => (t.completedAt ?? t.createdAt).toDate())
                            .reduce((a, b) => a.isAfter(b) ? a : b)
                      : vehicle.createdAt.toDate();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.checklist_rtl,
                            size: 16,
                            // 未完了タスクがあれば色を変えて注意を引く
                            color: incompleteTodos > 0
                                ? Colors.orange.shade700
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$incompleteTodos',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: incompleteTodos > 0
                                  ? Colors.orange.shade800
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '更新日: ${DateFormat('MM/dd').format(lastUpdate)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  );
                },
                // データ取得中はインジケーターを表示
                loading: () => const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                // エラー時はアイコンを表示
                error: (err, stack) =>
                    const Icon(Icons.error_outline, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
