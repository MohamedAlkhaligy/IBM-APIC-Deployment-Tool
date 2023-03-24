import 'package:fluent_ui/fluent_ui.dart';
import 'package:ibm_apic_dt/models/environment.dart';
import 'package:ibm_apic_dt/screens/home_screen.dart';
import 'package:ibm_apic_dt/widgets/loader.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../providers/environments_provider.dart';
import '../services/auth_service.dart';
import '../utilities/error_handling_utilities.dart';
import '../widgets/home_app_bar.dart';

class AddEnvironmentScreen extends StatefulWidget {
  const AddEnvironmentScreen({super.key});

  static const String routeName = '/environments/add';

  @override
  State<AddEnvironmentScreen> createState() => _AddEnvironmentScreenState();
}

class _AddEnvironmentScreenState extends State<AddEnvironmentScreen> {
  final TextEditingController _environmentNameController =
      TextEditingController();
  final TextEditingController _clientIDController =
      TextEditingController(text: "599b7aef-8841-4ee2-88a0-84d49c4d6ff2");
  final TextEditingController _clientSecretController =
      TextEditingController(text: "0ea28423-e73b-47d4-b40e-ddb45c48bb0c");
  final TextEditingController _serverURLController =
      TextEditingController(text: "https://127.0.0.1:2000");
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  bool areFormFieldsFilled() {
    return _passwordController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _serverURLController.text.isNotEmpty &&
        _environmentNameController.text.isNotEmpty &&
        _clientIDController.text.isNotEmpty &&
        _clientSecretController.text.isNotEmpty;
  }

  @override
  void dispose() {
    super.dispose();
    _environmentNameController.dispose();
    _serverURLController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _clientIDController.dispose();
    _clientSecretController.dispose();
  }

  Future<void> login(BuildContext context) async {
    if (!areFormFieldsFilled()) {
      ErrorHandlingUtilities.instance.showPopUpError("Missing Field(s)!");
    } else {
      setState(() {
        _isLoading = true;
      });

      String accessToken = await AuthService.getInstance().login(
        clientID: _clientIDController.text,
        clientSecret: _clientSecretController.text,
        serverURL: _serverURLController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );

      if (accessToken.isNotEmpty) {
        final logger = Logger();
        Environment environment = Environment(
          clientID: _clientIDController.text.trim(),
          clientSecret: _clientSecretController.text.trim(),
          environmentID: const Uuid().v1(),
          environmentName: _environmentNameController.text.trim(),
          serverURL: _serverURLController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          accessToken: accessToken,
          creationTime: DateTime.now(),
          lastVisited: DateTime.now(),
        );
        if (mounted) {
          Provider.of<EnvironmentsProvider>(context, listen: false)
              .addEnvironment(environment);
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        }
        logger.i("AuthScreen:Login");
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: const HomeAppBar(),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: screenWidth,
          height: 600,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 500,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black.withOpacity(0.2)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text("Create your environment",
                        style: TextStyle(fontSize: 24)),
                    TextBox(
                      header: "Environment Name",
                      controller: _environmentNameController,
                      onSubmitted: (_) => login(context),
                    ),
                    TextBox(
                      header: "Client ID",
                      controller: _clientIDController,
                      onSubmitted: (_) => login(context),
                    ),
                    TextBox(
                      header: "Client Secret",
                      controller: _clientSecretController,
                      onSubmitted: (_) => login(context),
                    ),
                    TextBox(
                      header: "Server URL",
                      controller: _serverURLController,
                      placeholder: "scheme://host[:port]",
                      onSubmitted: (_) => login(context),
                    ),
                    TextBox(
                      header: "Username",
                      controller: _usernameController,
                      onSubmitted: (_) => login(context),
                    ),
                    TextBox(
                      header: "Password",
                      controller: _passwordController,
                      obscureText: true,
                      onSubmitted: (_) => login(context),
                    ),
                    _isLoading
                        ? const Loader()
                        : Button(
                            child: const Text("Create environment"),
                            onPressed: () => login(context),
                          )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
