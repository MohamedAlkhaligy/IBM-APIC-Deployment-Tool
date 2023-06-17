import 'package:fluent_ui/fluent_ui.dart';
import 'package:ibm_apic_dt/global_configurations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/home_navigator_screen.dart';
import '../screens/home_screen.dart';
import '../icons/github_icons.dart';

class HomeAppBar extends StatefulWidget {
  final String text;

  const HomeAppBar({this.text = "IBM API Connect Deployment Tool", super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
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
          Text(widget.text),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Github.githubCircled,
                  size: 20,
                ),
                onPressed: () async => await launchUrl(Uri.parse(
                    "https://github.com/MohamedAlkhaligy/IBM-APIC-Deployment-Tool")),
              ),
              IconButton(
                icon: const Icon(
                  FluentIcons.home,
                  size: 20,
                ),
                onPressed: () {
                  if (GlobalConfigurations.appType == AppType.singlePageApp) {
                    setState(() => HomeNavigatorScreen.pageController
                        .jumpToPage(
                            HomeNavigatorScreen.viewEnvironmentsPageIndex));
                  } else {
                    Navigator.of(context)
                        .pushReplacementNamed(HomeScreen.routeName);
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
