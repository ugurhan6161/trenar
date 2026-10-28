import 'package:flutter/material.dart';
import 'package:hotelyn_dashboard/admin/view/admin_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRENAR Yönetim',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D5BF6),
        ),
        useMaterial3: true,
      ),
      home: const AdminPage(),
    );
  }
}
