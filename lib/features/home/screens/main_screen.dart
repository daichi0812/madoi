// lib/features/home/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madoi/features/auth/providers/auth_providers.dart';
import 'package:madoi/features/todo/screens/todo_screen.dart';
import 'package:madoi/features/vehicle/screens/vehicle_screen.dart';

// MainScreenをStatefulWidgetにすることで、選択中のタブの状態を管理
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 選択中のタブのインデックス
  int _selectedIndex = 0;

  // BottomNavigationBarで表示する画面のリスト
  final List<Widget> _pages = [
    const VehicleScreen(), // 0番目のタブ
    const TodoScreen(), // 1番目のタブ
    // 今後、書類管理やチャット画面などを追加していく
  ];

  // タブがタップされたときに呼ばれるメソッド
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('madoi'), // ここは将来的にワークスペース名などに変更
        actions: [
          // Consumerを使ってProviderにアクセスし、ログアウト機能を実装
          Consumer(
            builder: (context, ref, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  ref.read(authRepositoryProvider).signOut();
                },
              );
            },
          ),
        ],
      ),
      // 選択中のインデックスに応じて表示する画面を切り替え
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        // タップされたときの処理
        onTap: _onItemTapped,
        // 現在選択中のタブのインデックス
        currentIndex: _selectedIndex,
        // タブのアイテムリスト
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: '車両',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'ToDo'),
        ],
      ),
    );
  }
}
