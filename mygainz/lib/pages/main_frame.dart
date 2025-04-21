import 'package:flutter/material.dart';

class MainFramePage extends StatelessWidget {
  const MainFramePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainFrame());
  }
}

class MainFrame extends StatefulWidget {
  const MainFrame({super.key});

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
  static const List<Widget> _widgetOptions = <Widget>[
    Text('Index 0: Home', style: optionStyle),
    Text('Index 1: Exercise', style: optionStyle),
    Text('Index 2: Log', style: optionStyle),
    Text('Index 3: Progress', style: optionStyle),
    Text('Index 4: Profile', style: optionStyle),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2027),
        title: Row(
          children: [
            Image.asset('assets/logo.png', width: 32, height: 32),
            const SizedBox(width: 8),
            const Text(
              'My Gainz',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: Image.asset(
                'assets/icons/ui_icons/home.png',
                width: 24,
                height: 24,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: Image.asset(
                'assets/icons/ui_icons/dumbell.png',
                width: 24,
                height: 24,
              ),
            ),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Log'),
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: Image.asset(
                'assets/icons/ui_icons/statistic.png',
                width: 24,
                height: 24,
              ),
            ),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: Image.asset(
                'assets/icons/ui_icons/user.png',
                width: 24,
                height: 24,
              ),
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 170, 222, 247),
        unselectedItemColor: Colors.white,
        backgroundColor: Color(0xFF1B2027),
        onTap: _onItemTapped,
      ),
    );
  }
}
