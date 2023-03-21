import 'package:hive_flutter/hive_flutter.dart';

part 'environment.g.dart';

@HiveType(typeId: 0)
class Environment extends HiveObject {
  @HiveField(0)
  final String environmentID;

  @HiveField(1)
  String environmentName;

  @HiveField(2)
  final String clientID;

  @HiveField(3)
  final String clientSecret;

  @HiveField(4)
  final String serverURL;

  @HiveField(5)
  final String username;

  @HiveField(6)
  String password;

  @HiveField(7)
  String accessToken;

  @HiveField(8)
  final DateTime creationTime;

  @HiveField(9)
  DateTime lastVisited;

  Environment({
    required this.environmentID,
    required this.environmentName,
    required this.clientID,
    required this.clientSecret,
    required this.serverURL,
    required this.username,
    required this.password,
    required this.creationTime,
    required this.lastVisited,
    required this.accessToken,
  });

  @override
  String toString() {
    return 'Environment: $environmentName, Client ID: $clientID, Client Secret: $clientSecret Server URL: $serverURL, Username: $username, Password: $password, Creation Time: $creationTime, Last Visited: $lastVisited, Access Token: $accessToken';
  }
}
