import 'package:fluent_ui/fluent_ui.dart';

import '../screens/home_screen.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      color: Colors.black.withOpacity(0.6),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("IBM API Connect Deployment Tool"),
          IconButton(
            icon: const Icon(
              FluentIcons.home,
              size: 20,
            ),
            onPressed: () => Navigator.of(context)
                .pushReplacementNamed(HomeScreen.routeName),
          )
        ],
      ),
    );
  }
}
