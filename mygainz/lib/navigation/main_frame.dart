import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/exercises/providers/workout_provider.dart';
import '../features/home/pages/home_page.dart';
import '../features/exercises/pages/exercise_page.dart';
import '../features/workout_logging/pages/log_page.dart';
import '../features/progress/pages/progress_page.dart';
import '../features/profile/pages/profile_page.dart';

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
  late PageController _pageController;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const ExercisePage(),
    const LogPage(),
    const ProgressPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      // Animate page transition
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  // Helper method to build animated icons with proper colors
  Widget _buildAnimatedIcon({
    required String assetPath,
    required bool isSelected,
    required IconData fallbackIcon,
  }) {
    final Color iconColor =
        isSelected ? const Color.fromARGB(255, 170, 222, 247) : Colors.white;

    return AnimatedScale(
      scale: isSelected ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: assetPath.isNotEmpty
          ? ColorFiltered(
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              child: Image.asset(
                assetPath,
                width: 24,
                height: 24,
              ),
            )
          : Icon(
              fallbackIcon,
              color: iconColor,
              size: 24,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
        actions: [
          Consumer<WorkoutProvider>(
            builder: (context, workoutProvider, child) {
              return IconButton(
                icon: workoutProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white),
                onPressed: workoutProvider.isLoading
                    ? null
                    : () async {
                        await workoutProvider.refreshWorkouts();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data refreshed!'),
                              duration: Duration(seconds: 1),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                tooltip: 'Refresh Data',
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: _widgetOptions,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(
                assetPath: 'assets/icons/ui_icons/home.png',
                isSelected: _selectedIndex == 0,
                fallbackIcon: Icons.home,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(
                assetPath: 'assets/icons/ui_icons/dumbell.png',
                isSelected: _selectedIndex == 1,
                fallbackIcon: Icons.fitness_center,
              ),
              label: 'Exercise',
            ),
            BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: _selectedIndex == 2 ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Icon(
                  Icons.add,
                  color: _selectedIndex == 2
                      ? const Color.fromARGB(255, 170, 222, 247)
                      : Colors.white,
                ),
              ),
              label: 'Log',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(
                assetPath: 'assets/icons/ui_icons/statistic.png',
                isSelected: _selectedIndex == 3,
                fallbackIcon: Icons.bar_chart,
              ),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(
                assetPath: 'assets/icons/ui_icons/user.png',
                isSelected: _selectedIndex == 4,
                fallbackIcon: Icons.person,
              ),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(255, 170, 222, 247),
          unselectedItemColor: Colors.white,
          backgroundColor: const Color(0xFF1B2027),
          onTap: _onItemTapped,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
