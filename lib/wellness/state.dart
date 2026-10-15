import 'package:flutter/foundation.dart';

enum WellnessPage {
  health,
  welcome,
  profile,
  profilePhoto,
  confirmProfile,
  challenges,
  detail,
  joined,
  progress,
  individualLeaderboard,
  propertyLeaderboard,
  log,
  document,
  photo,
  lesson,
  quiz,
  submitted,
  complete,
  sharing,
  devices,
  apple,
  applePermission,
  garmin,
  garminPermission,
  appleConnected,
  garminConnected,
  gallery,
}

const screenNodes = <WellnessPage, String>{
  WellnessPage.health: '88:13096',
  WellnessPage.welcome: '88:13835',
  WellnessPage.profile: '88:13895',
  WellnessPage.profilePhoto: '88:14003',
  WellnessPage.confirmProfile: '88:13962',
  WellnessPage.challenges: '88:15863',
  WellnessPage.detail: '88:14090',
  WellnessPage.joined: '88:14232',
  WellnessPage.progress: '88:15981',
  WellnessPage.individualLeaderboard: '88:16088',
  WellnessPage.propertyLeaderboard: '90:16886',
  WellnessPage.log: '88:13594',
  WellnessPage.document: '88:13648',
  WellnessPage.photo: '88:13699',
  WellnessPage.lesson: '88:13802',
  WellnessPage.quiz: '88:13749',
  WellnessPage.submitted: '88:14634',
  WellnessPage.complete: '88:14715',
  WellnessPage.sharing: '88:14979',
  WellnessPage.devices: '88:15032',
  WellnessPage.apple: '88:14806',
  WellnessPage.applePermission: '88:14875',
  WellnessPage.garmin: '88:15138',
  WellnessPage.garminPermission: '88:15182',
  WellnessPage.appleConnected: '88:16549',
  WellnessPage.garminConnected: '88:13498',
};

const properties = <({String name, String city, String state, String address})>[
  (
    name: 'Caesars Republic Scottsdale',
    city: 'Scottsdale',
    state: 'AZ',
    address: 'Scottsdale, AZ',
  ),
  (
    name: "Harrah’s Ak-Chin Hotel & Casino",
    city: 'Maricopa',
    state: 'AZ',
    address: '15406 N Maricopa Rd · Maricopa, AZ 85139',
  ),
  (
    name: "Harrah’s Northern California",
    city: 'Ione',
    state: 'CA',
    address: 'Ione, CA',
  ),
  (
    name: "Harrah’s Resort Southern California",
    city: 'Funner',
    state: 'CA',
    address: 'Funner, CA',
  ),
];

class Activity {
  const Activity(
    this.title,
    this.subtitle,
    this.points, {
    this.pending = false,
  });
  final String title, subtitle;
  final int points;
  final bool pending;
}

class WellnessState extends ChangeNotifier {
  String firstName = 'PJ', lastName = 'Endsley';
  int propertyIndex = 1;
  bool profileConfirmed = false, weeklyReminder = true;
  Uint8List? profilePhoto;
  String currentChallenge = 'Step Into Spring';
  final joined = {'Step Into Spring', 'Know Your Blood Pressure'};
  final demoConnections = {'Apple Health', 'Garmin'};
  final Map<String, int> _points = {
    'Step Into Spring': 680,
    'Know Your Blood Pressure': 150,
  };
  final Map<String, List<Activity>> _activities = {
    'Step Into Spring': [
      const Activity('Steps: 8,412', 'Apple Health · Today', 10),
      const Activity('Steps: 7,500', 'Logged by you · Apr 17', 10),
      const Activity('Photo: morning walk', 'Approved · Apr 16', 25),
      const Activity(
        'Document: 5K Race Receipt',
        'In review · Apr 15',
        50,
        pending: true,
      ),
      const Activity(
        'Learning Module: Hydration 101',
        'Completed · Apr 14',
        25,
      ),
    ],
  };
  final Set<String> _creditedLogs = {
    'Step Into Spring:2026-4-17',
    'Step Into Spring:2026-4-18',
  };
  final Set<String> _creditedModules = {'Step Into Spring'};
  String lastSubmitted = 'spring-5k-receipt.pdf';
  String lastSubmissionType = '5K race entry';
  int lastSubmissionPoints = 50;
  String get initials => firstName.trim().isEmpty
      ? 'PJ'
      : firstName
            .trim()
            .substring(0, firstName.trim().length.clamp(1, 2))
            .toUpperCase();
  String get fullName => '$firstName $lastName';
  int pointsFor(String challenge) => _points[challenge] ?? 0;
  int get points => pointsFor(currentChallenge);
  List<Activity> get activities =>
      _activities.putIfAbsent(currentChallenge, () => []);
  String get propertyName => properties[propertyIndex].name;
  String get shortProperty =>
      propertyIndex == 1 ? 'Ak-Chin' : properties[propertyIndex].city;
  void update() => notifyListeners();
  void join() {
    joined.add(currentChallenge);
    notifyListeners();
  }

  void logActivity(String kind, int amount, DateTime date, String note) {
    final key = '$currentChallenge:${date.year}-${date.month}-${date.day}';
    final credit = _creditedLogs.add(key) ? 10 : 0;
    _points[currentChallenge] = points + credit;
    activities.insert(
      0,
      Activity(
        '$kind: $amount',
        'Logged by you · ${date.month}/${date.day}${note.isEmpty ? '' : ' · $note'}',
        credit,
      ),
    );
    notifyListeners();
  }

  bool completeModule() {
    if (!_creditedModules.add(currentChallenge)) return false;
    _points[currentChallenge] = points + 25;
    activities.insert(
      0,
      const Activity('Learning Module: Hydration 101', 'Completed · Today', 25),
    );
    notifyListeners();
    return true;
  }

  void submit(String name, String type, int credit) {
    lastSubmitted = name;
    lastSubmissionType = type;
    lastSubmissionPoints = credit;
    activities.insert(
      0,
      Activity('$type: $name', 'In review · Today', credit, pending: true),
    );
    notifyListeners();
  }
}
