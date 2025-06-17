// lib/features/vehicle/screens/vehicle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoi/features/vehicle/providers/vehicle_providers.dart';
import 'package:madoi/features/workspace/providers/workspace_providers.dart';

class VehicleScreen extends ConsumerWidget {
  const VehicleScreen({super.key});

  void _showAddVehicleDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final nicknameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新しい車両を追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '車両名 (例: ジムカーナDC2)',
                ),
              ),
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: '愛称・オーナー (例: 水野)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final nickname = nicknameController.text.trim();
                final workspaceId = ref.read(activeWorkspaceProvider).value?.id;

                if (name.isNotEmpty &&
                    nickname.isNotEmpty &&
                    workspaceId != null) {
                  ref
                      .read(vehicleRepositoryProvider)
                      .addVehicle(
                        name: name,
                        nickname: nickname,
                        workspaceId: workspaceId,
                      );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);

    return Scaffold(
      body: vehicles.when(
        data: (vehicleList) {
          if (vehicleList.isEmpty) {
            return const Center(
              child: Text('まだ車両が登録されていません。\n右下のボタンから追加してください。'),
            );
          }
          return ListView.builder(
            itemCount: vehicleList.length,
            itemBuilder: (context, index) {
              final vehicle = vehicleList[index];
              return ListTile(
                title: Text(vehicle.name),
                subtitle: Text(vehicle.nickname),
                onTap: () {
                  // TODO: 車両詳細画面に遷移
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVehicleDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
