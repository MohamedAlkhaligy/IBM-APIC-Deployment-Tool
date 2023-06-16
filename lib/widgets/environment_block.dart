import 'package:fluent_ui/fluent_ui.dart';
import 'package:ibm_apic_dt/global_configurations.dart';
import 'package:intl/intl.dart';

import '../screens/home_navigator_screen.dart';
import './confirmation_pop_up.dart';
import './responsive_text.dart';
import '../models/environment.dart';
import '../providers/environments_provider.dart';
import '../screens/environment_screen.dart';

class EnvironmentBlock extends StatefulWidget {
  final Environment _environment;
  final EnvironmentsProvider _environmentsProvider;

  const EnvironmentBlock(this._environment, this._environmentsProvider,
      {super.key});

  @override
  State<EnvironmentBlock> createState() => _EnvironmentBlockState();
}

class _EnvironmentBlockState extends State<EnvironmentBlock> {
  Color color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => setState(() => color = Colors.black),
      onExit: (event) => setState(() => color = Colors.white),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget._environmentsProvider.visitEnvironment(widget._environment);
          if (GlobalConfigurations.appType == AppType.singlePageApp) {
            HomeNavigatorScreen.pageController.jumpToPage(
              HomeNavigatorScreen.pages.indexWhere((pageWidget) =>
                  pageWidget is EnvironmentScreen &&
                  pageWidget.environment.environmentID ==
                      widget._environment.environmentID),
            );
          } else {
            Navigator.of(context).pushReplacementNamed(
                EnvironmentScreen.routeName,
                arguments: widget._environment);
          }
        },
        child: Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                border: Border.all(color: color),
                borderRadius: BorderRadius.circular(15)),
            height: 240,
            width: 240,
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                      icon:
                          Icon(FluentIcons.delete, color: Colors.red.lightest),
                      onPressed: () async {
                        final isConfirmed = await showDialog<bool>(
                              barrierDismissible: true,
                              context: context,
                              builder: (ctx) {
                                return ConfirmationPopUp(
                                    "Do you want to delete '${widget._environment.environmentName}' environment?");
                              },
                            ) ??
                            false;
                        if (isConfirmed) {
                          widget._environmentsProvider
                              .deleteEnvironment(widget._environment);
                        }
                      }),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ResponsiveText(widget._environment.environmentName,
                        textStyle: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    ResponsiveText(widget._environment.username),
                    ResponsiveText(widget._environment.serverURL),
                    ResponsiveText(
                        'Created At: ${DateFormat.yMEd().format(widget._environment.creationTime)}'),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
