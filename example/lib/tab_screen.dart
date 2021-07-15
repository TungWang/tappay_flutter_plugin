import 'package:flutter/material.dart';
import 'package:tappayflutterplugin_example/direct_pay_screen.dart';
import 'package:tappayflutterplugin_example/google_pay_screen.dart';
import 'package:tappayflutterplugin_example/line_pay_screen.dart';

class TabScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  final List<Widget> _tabs = [
    GooglePayScreen(),
    DirectPayScreen(),
    LinePayScreen(),
  ];
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.android_outlined),
            label: 'GooglePay',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'DirectPay',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.line_weight),
            label: 'LinePay',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        currentIndex: _currentTabIndex,
      ),
    );
  }
}
