import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import './add_environment_screen.dart';
import '../global_configurations.dart';
import '../models/environment.dart';
import '../providers/environments_provider.dart';
import '../widgets/add_environment_block.dart';
import '../widgets/environment_block.dart';
import '../widgets/home_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/environments';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SearchType { environmentName, username }

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  SortType sortType = SortType.recent;
  SearchType searchType = SearchType.environmentName;
  List<Environment> _environments = [];

  String searchPlaceholder(SearchType type) {
    switch (type) {
      case SearchType.environmentName:
        return "Search by environment name";
      // To be supported
      case SearchType.username:
        return "Search environments by username";
    }
  }

  void _sort(List<Environment> environments, SortType sortType) {
    switch (sortType) {
      case SortType.ascending:
        environments
            .sort((a, b) => a.environmentName.compareTo(b.environmentName));
        break;
      case SortType.created:
        environments.sort((a, b) => a.creationTime.compareTo(b.creationTime));
        break;
      case SortType.descending:
        environments
            .sort((a, b) => b.environmentName.compareTo(a.environmentName));
        break;
      case SortType.recent:
        environments.sort((a, b) => b.lastVisited.compareTo(a.lastVisited));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: const HomeAppBar(),
      content: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15),
          width: screenWidth,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black.withOpacity(0.1)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Create or select an environment"),
                    IconButton(
                      icon: const Icon(FluentIcons.add, size: 20),
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AddEnvironmentScreen.routeName),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black.withOpacity(0.1),
                ),
                child: Consumer<EnvironmentsProvider>(
                    builder: (context, environmentsProvider, child) {
                  _environments = environmentsProvider.environments;
                  _sort(_environments, sortType);
                  _environments = _environments
                      .where((element) => element.environmentName
                          .toLowerCase()
                          .contains(
                              _searchController.text.toLowerCase().trim()))
                      .toList();
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextBox(
                              controller: _searchController,
                              placeholder: searchPlaceholder(searchType),
                              onChanged: (name) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ComboBox<SortType>(
                            items: const [
                              ComboBoxItem(
                                value: SortType.ascending,
                                child: Text("Ascending"),
                              ),
                              ComboBoxItem(
                                value: SortType.created,
                                child: Text("Created"),
                              ),
                              ComboBoxItem(
                                value: SortType.descending,
                                child: Text("Descending"),
                              ),
                              ComboBoxItem(
                                value: SortType.recent,
                                child: Text("Recent"),
                              )
                            ],
                            icon: const Icon(FluentIcons.sort),
                            iconSize: 15,
                            onChanged: ((value) {
                              setState(() {
                                sortType = value!;
                                _sort(_environments, sortType);
                              });
                            }),
                            value: sortType,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: screenWidth,
                        height: screenHeight * 0.68,
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 30,
                            runSpacing: 30,
                            children: [
                              ...(_environments
                                  .map((environment) => EnvironmentBlock(
                                      environment, environmentsProvider))
                                  .toList()),
                              const AddEnvironmentBlock(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
