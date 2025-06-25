// lib/features/vehicle/screens/vehicle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:madoi/features/vehicle/providers/vehicle_providers.dart';
import 'package:madoi/features/vehicle/widgets/vehicle_list_item.dart';

class VehicleScreen extends ConsumerWidget {
  const VehicleScreen({super.key});

  void _showAddVehicleDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final nicknameController = TextEditingController();
    final formKey = GlobalKey<FormState>(); // ★ バリデーション用のキー

    showDialog(
      context: context,
      builder: (context) {
        // Consumerを使い、ダイアログ内でもProviderを正しく監視
        return Consumer(
          builder: (context, ref, child) {
            final isLoading = ref.watch(vehicleControllerProvider);
            return AlertDialog(
              title: const Text('新しい車両を追加'),
              // ★ Formウィジェットで入力内容を管理
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '車両名 (例: ジムカーナDC2)',
                        hintText: '車両の正式名称や型式など',
                      ),
                      validator: (value) =>
                          (value?.isEmpty ?? true) ? '入力必須です' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nicknameController,
                      decoration: const InputDecoration(
                        labelText: '愛称・オーナー (例: 水野)',
                        hintText: '普段の呼び名など',
                      ),
                      validator: (value) =>
                          (value?.isEmpty ?? true) ? '入力必須です' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          // ★ バリデーションを実行
                          if (formKey.currentState?.validate() ?? false) {
                            await ref
                                .read(vehicleControllerProvider.notifier)
                                .addVehicle(
                                  context: context,
                                  name: nameController.text.trim(),
                                  nickname: nicknameController.text.trim(),
                                );
                            if (context.mounted) Navigator.of(context).pop();
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('追加'),
                ),
              ],
            );
          },
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
            // ★★★ 3. 「空の状態」のUIを改善 ★★★
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '車両が登録されていません',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '右下の「+」ボタンから最初の車両を追加しましょう！',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          // ★ ListViewに少し余白を追加
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: vehicleList.length,
            itemBuilder: (context, index) {
              final vehicle = vehicleList[index];
              return VehicleListItem(vehicle: vehicle);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: ${err.toString()}')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-vehicle',
        onPressed: () => _showAddVehicleDialog(context, ref),
        tooltip: '新しい車両を追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}
