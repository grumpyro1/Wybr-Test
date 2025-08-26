import 'package:flutter/material.dart';
import 'package:wybr/pages/donePage.dart';
import 'package:wybr/pages/materialIsuancePage.dart';
import 'package:wybr/pages/odooTest.dart';
import 'package:wybr/pages/referenceWOPage.dart';
import 'package:wybr/pages/testPage.dart';
import 'package:wybr/pages/workOrders.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({super.key});

  @override
  State<Mainscreen> createState() => _MainscreenState();
}

class _MainscreenState extends State<Mainscreen> {
  final GlobalKey<NavigatorState> _contentNavigatorKey = GlobalKey<NavigatorState>();

  void _navigateTo(String route) {
    _contentNavigatorKey.currentState?.pushNamedAndRemoveUntil(route, (_) => false);
  }

  final Map<String, Widget> _routes = {
    '/dashboard': Center(child: Text("Dashboard Placeholder")),
    '/incoming': Center(child: Text("Incoming Page Placeholder")),
    '/outgoing': WorkordersPage(),
    '/materialIssuance': MaterialIssuancePage(),
    '/reference': Referencewopage(),
    '/done':Donepage(),
    '/reports': Testpage(),
    '/settings': Odootest(),
    '/teams': Center(child: Text("Teams Placeholder")),
    '/documents': Center(child: Text("Documents Placeholder")),
    '/users': Center(child: Text("User Management Placeholder")),
    '/logout': Center(child: Text("Logout Placeholder")),
  };

  final List<Map<String, dynamic>> _sidebarItems = [
    {'icon': Icons.dashboard, 'label': "Dashboards", 'route': '/dashboard'},
    {'icon': Icons.assignment, 'label': "Work Requests", 'route': '/incoming'},
    {'icon': Icons.work, 'label': "Work Orders", 'route': '/outgoing'},
    {'icon': Icons.check_circle, 'label': "Material Issuance", 'route': '/materialIssuance'},
    {'icon': Icons.book, 'label': "Reference Work Orders", 'route': '/reference'},
    {'icon': Icons.schedule, 'label': "Completed Outgoing Deliveries", 'route': '/done'},
    {'icon': Icons.bar_chart, 'label': "Reports", 'route': '/reports'},
    {'icon': Icons.settings_applications, 'label': "System Settings", 'route': '/settings'},
    {'icon': Icons.people, 'label': "Teams", 'route': '/teams'},
    {'icon': Icons.folder, 'label': "Documents", 'route': '/documents'},
    {'divider': true},
    {'icon': Icons.settings, 'label': "User Management", 'route': '/users'},
    {'icon': Icons.logout, 'label': "Logout", 'route': '/logout'},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 800;

      return Scaffold(
        appBar: AppBar(
          title: const Text("Wybr Work Order"),
          leading: isSmall ? IconButton(icon: const Icon(Icons.menu),onPressed: () => Scaffold.of(context).openDrawer()): null),
        drawer: isSmall ? Drawer(child: SafeArea(child: _buildSidebar(isDrawer: true))): null,
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Row(
            children: [
              if (!isSmall) _buildSidebarContainer(),
              Expanded(child: _buildNavigator()),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSidebar({bool isDrawer = false}) {
    final textColor = isDrawer ? Colors.black : Colors.white;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: _sidebarItems.map((item) {
        if (item.containsKey('divider')) {
          return Divider(color: isDrawer ? Colors.grey[400] : Colors.white30);
        }
        return ListTile(
          leading: Icon(item['icon'], color: textColor),
          title: Text(item['label'], style: TextStyle(color: textColor)),
          onTap: () => _navigateTo(item['route']),
        );
      }).toList(),
    );
  }

  Widget _buildSidebarContainer() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SafeArea(child: _buildSidebar()),
    );
  }

  Widget _buildNavigator() {
    return Navigator(
      key: _contentNavigatorKey,
      initialRoute: '/reports',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => _routes[settings.name] ?? const Center(child: Text("Page not found")),
          settings: settings,
        );
      },
    );
  }
}
