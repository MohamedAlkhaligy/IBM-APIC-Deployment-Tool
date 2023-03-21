import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

import './responsive_text.dart';
import '../models/environment.dart';
import '../screens/environment_screen.dart';

class EnvironmentBlock extends StatefulWidget {
  final Environment _environment;

  const EnvironmentBlock(this._environment, {super.key});

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
        onTap: () => Navigator.of(context).pushReplacementNamed(
            EnvironmentScreen.routeName,
            arguments: widget._environment),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                border: Border.all(color: color),
                borderRadius: BorderRadius.circular(15)),
            height: 240,
            width: 240,
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ResponsiveText(widget._environment.environmentName,
                    textStyle: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                ResponsiveText(widget._environment.serverURL),
                ResponsiveText(widget._environment.username),
                ResponsiveText(
                    'Created At: ${DateFormat.yMEd().format(widget._environment.creationTime)}'),
              ],
            )),
      ),
    );
  }
}
