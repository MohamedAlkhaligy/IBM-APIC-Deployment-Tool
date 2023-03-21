import 'package:dotted_border/dotted_border.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../screens/add_environment_screen.dart';

class AddEnvironmentBlock extends StatefulWidget {
  const AddEnvironmentBlock({super.key});

  @override
  State<AddEnvironmentBlock> createState() => _AddEnvironmentBlockState();
}

class _AddEnvironmentBlockState extends State<AddEnvironmentBlock> {
  Color color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => setState(() => color = Colors.black),
      onExit: (event) => setState(() => color = Colors.white),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context)
            .pushReplacementNamed(AddEnvironmentScreen.routeName),
        child: DottedBorder(
          color: color,
          radius: const Radius.circular(15),
          strokeWidth: 2,
          dashPattern: const [10, 10],
          borderType: BorderType.RRect,
          child: SizedBox(
            height: 240,
            width: 240,
            child: Icon(
              FluentIcons.add,
              size: 45,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
