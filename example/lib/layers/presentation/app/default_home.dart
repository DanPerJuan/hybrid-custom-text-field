import 'package:flutter/material.dart';

import '../screens/base_fields_screen.dart';
import '../screens/form_screen.dart';
import '../screens/phone_fields_screen.dart';
import '../screens/search_fields_screen.dart';

class DefaultHome extends StatelessWidget {
  const DefaultHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          title: const Text(
            'Hybrid Text Field',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF2563EB),
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFF93C5FD),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Base'),
              Tab(text: 'Phone'),
              Tab(text: 'Search'),
              Tab(text: 'Form'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BaseFieldsScreen(),
            PhoneFieldsScreen(),
            SearchFieldsScreen(),
            FormScreen(),
          ],
        ),
      ),
    );
  }
}
