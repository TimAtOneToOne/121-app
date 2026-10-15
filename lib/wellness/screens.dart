import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../design_system.dart';
import 'state.dart';
import 'ui.dart';
export 'state.dart' show WellnessPage;
part 'onboarding.dart';
part 'challenges.dart';
part 'activity.dart';
part 'connections.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({
    required this.state,
    required this.page,
    this.onNavigate,
    super.key,
  });
  final WellnessState state;
  final WellnessPage page;
  final ValueChanged<int>? onNavigate;
  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  WellnessState get data => widget.state;
  WellnessPage get page => widget.page;
  late final TextEditingController first, last;
  final search = TextEditingController(),
      amount = TextEditingController(text: '7,500'),
      note = TextEditingController();
  final form = GlobalKey<FormState>();
  String stateFilter = 'All states (52)',
      activityKind = 'Steps',
      documentPurpose = '5K race entry · 50 pts';
  DateTime logDate = DateTime(2026, 4, 18);
  PlatformFile? document;
  String? documentName = 'spring-5k-receipt.pdf';
  int documentBytes = 1200000;
  Uint8List? photo;
  String photoName = 'Activity photo';
  bool busy = false, submitted = false;
  int question = 1;
  int? answer = 2;
  final permissions = [true, true, true];

  @override
  void initState() {
    super.initState();
    first = TextEditingController(text: data.firstName);
    last = TextEditingController(text: data.lastName);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (page == WellnessPage.profilePhoto) chooseProfilePhoto();
      if (page == WellnessPage.applePermission ||
          page == WellnessPage.garminPermission) {
        healthPermission();
      }
    });
  }

  @override
  void dispose() {
    for (final controller in [first, last, search, amount, note]) {
      controller.dispose();
    }
    super.dispose();
  }

  void refresh(VoidCallback change) {
    if (mounted) setState(change);
  }

  Future<void> open(WellnessPage target, {bool replace = false}) async {
    final route = MaterialPageRoute<void>(
      settings: RouteSettings(name: target.name),
      builder: (_) => WellnessScreen(
        state: data,
        page: target,
        onNavigate: widget.onNavigate,
      ),
    );
    if (replace) {
      await Navigator.of(context).pushReplacement(route);
    } else {
      await Navigator.of(context).push(route);
    }
    if (mounted) setState(() {});
  }

  void back() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      open(WellnessPage.gallery, replace: true);
    }
  }

  void navigateTab(int index) {
    if (index == 2) {
      open(WellnessPage.health);
      return;
    }
    if (widget.onNavigate != null) {
      widget.onNavigate!(index);
    } else if (index == 4) {
      open(WellnessPage.gallery);
    } else {
      back();
    }
  }

  void notice(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> information(String title, String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  String get title => switch (page) {
    WellnessPage.health => 'Health Data',
    WellnessPage.challenges => 'Challenges',
    WellnessPage.detail => 'Challenge',
    WellnessPage.progress ||
    WellnessPage.joined ||
    WellnessPage.complete ||
    WellnessPage.appleConnected ||
    WellnessPage.garminConnected => data.currentChallenge,
    WellnessPage.individualLeaderboard ||
    WellnessPage.propertyLeaderboard => 'Leaderboard',
    WellnessPage.log => 'Log activity',
    WellnessPage.document => 'Upload document',
    WellnessPage.photo => 'Add photo',
    WellnessPage.lesson || WellnessPage.quiz => 'Hydration 101',
    WellnessPage.submitted => 'Submitted',
    WellnessPage.sharing => 'Challenges',
    WellnessPage.devices => 'Devices',
    WellnessPage.apple || WellnessPage.applePermission => 'Apple Health',
    WellnessPage.garmin || WellnessPage.garminPermission => 'Garmin',
    WellnessPage.gallery => 'Explore screens',
    _ => '',
  };

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: data,
    builder: (context, _) => WellnessScaffold(
      state: data,
      title: title,
      brand: [
        WellnessPage.welcome,
        WellnessPage.profile,
        WellnessPage.profilePhoto,
        WellnessPage.confirmProfile,
      ].contains(page),
      onBack: back,
      onProfile: () => open(WellnessPage.profile),
      body: content(),
      footer: footer(),
      navigation:
          [
            WellnessPage.health,
            WellnessPage.welcome,
            WellnessPage.challenges,
            WellnessPage.individualLeaderboard,
            WellnessPage.propertyLeaderboard,
          ].contains(page)
          ? WellnessNav(
              onHome: () => navigateTab(0),
              onTeam: () => navigateTab(1),
              onHealth: () => navigateTab(2),
              onRecords: () => navigateTab(3),
              onSettings: () => navigateTab(4),
            )
          : null,
    ),
  );

  Widget content() => switch (page) {
    WellnessPage.health => healthData(),
    WellnessPage.welcome => welcome(),
    WellnessPage.profile || WellnessPage.profilePhoto => profile(),
    WellnessPage.confirmProfile => confirmProfile(),
    WellnessPage.challenges => challenges(),
    WellnessPage.detail => detail(),
    WellnessPage.joined => joined(),
    WellnessPage.progress => myProgress(),
    WellnessPage.individualLeaderboard ||
    WellnessPage.propertyLeaderboard => leaderboard(),
    WellnessPage.log => logForm(),
    WellnessPage.document => documentForm(),
    WellnessPage.photo => photoForm(),
    WellnessPage.lesson => lesson(),
    WellnessPage.quiz => quiz(),
    WellnessPage.submitted => submission(),
    WellnessPage.complete => completed(),
    WellnessPage.sharing => sharing(),
    WellnessPage.devices => devices(),
    WellnessPage.apple ||
    WellnessPage.applePermission ||
    WellnessPage.garmin ||
    WellnessPage.garminPermission => connect(),
    WellnessPage.appleConnected || WellnessPage.garminConnected => connected(),
    WellnessPage.gallery => gallery(),
  };

  Widget? footer() => switch (page) {
    WellnessPage.confirmProfile => vertical([
      ActionButton('Looks good!', () {
        data.profileConfirmed = true;
        data.update();
        open(WellnessPage.detail);
      }),
      ActionButton('Edit', () => open(WellnessPage.profile), secondary: true),
    ], gap: 10),
    WellnessPage.detail => vertical([
      ActionButton('Join challenge', () {
        data.join();
        open(WellnessPage.joined);
      }),
      ActionButton(
        'Full rules & eligibility',
        () => information(
          'Full rules & eligibility',
          'Earn points through daily activity, documents, photos, and learning modules. The goal is 1,000 points. Full challenge rules have not been provided for this preview.',
        ),
        secondary: true,
      ),
    ], gap: 8),
    WellnessPage.joined => vertical([
      ActionButton('Go to my progress', () => open(WellnessPage.progress)),
      ActionButton(
        'Back to challenges',
        () => open(WellnessPage.challenges),
        secondary: true,
      ),
    ], gap: 10),
    WellnessPage.progress => ActionButton(
      'Connect a device',
      () => open(WellnessPage.sharing),
    ),
    WellnessPage.log => ActionButton('Save log', submitted ? null : saveLog),
    WellnessPage.document => ActionButton(
      busy ? 'Opening file…' : 'Submit for review',
      documentName == null || busy || submitted ? null : submitDocument,
    ),
    WellnessPage.photo => ActionButton(
      busy ? 'Opening photos…' : 'Submit photo',
      photo == null || busy || submitted ? null : submitPhoto,
    ),
    WellnessPage.lesson => ActionButton(
      'Next question',
      () => open(WellnessPage.quiz),
    ),
    WellnessPage.quiz => ActionButton(
      question == 4 ? 'Complete module' : 'Next question',
      answer == null ? null : nextQuestion,
    ),
    WellnessPage.submitted => ActionButton(
      'Back to challenge',
      () => open(WellnessPage.progress),
    ),
    WellnessPage.complete => vertical([
      ActionButton('See my points', () => open(WellnessPage.progress)),
      ActionButton(
        'Back to challenges',
        () => open(WellnessPage.challenges),
        secondary: true,
      ),
    ], gap: 10),
    WellnessPage.devices => ActionButton('Cancel', back, secondary: true),
    WellnessPage.apple ||
    WellnessPage.applePermission ||
    WellnessPage.garmin ||
    WellnessPage.garminPermission => vertical([
      ActionButton('Connect $provider', healthPermission),
      ActionButton('Cancel', back, secondary: true),
    ], gap: 10),
    WellnessPage.appleConnected || WellnessPage.garminConnected => ActionButton(
      'Connect another device',
      () => open(WellnessPage.devices),
      secondary: true,
    ),
    _ => null,
  };

  Widget gallery() => scrollBody([
    bodyText(
      'Explore the 26 Figma screens and their interactive states. All health connections and submissions use local demo data.',
    ),
    for (final entry in screenNodes.entries)
      Panel(
        onTap: () => open(entry.key),
        padding: 14,
        child: split(
          vertical([
            heading(screenLabel(entry.key), size: 14),
            bodyText(entry.value, size: 12),
          ], gap: 4),
          const Icon(Icons.chevron_right),
        ),
      ),
  ]);
}

String screenLabel(WellnessPage page) => switch (page) {
  WellnessPage.welcome => 'New user landing',
  WellnessPage.profile => 'Profile & home property',
  WellnessPage.profilePhoto => 'Change profile photo',
  WellnessPage.confirmProfile => 'Confirm profile',
  WellnessPage.individualLeaderboard => 'Individual leaderboard',
  WellnessPage.propertyLeaderboard => 'Property leaderboard',
  WellnessPage.applePermission => 'Apple Health permissions',
  WellnessPage.garminPermission => 'Garmin permissions',
  WellnessPage.appleConnected => 'Apple Health connected',
  WellnessPage.garminConnected => 'Garmin connected',
  WellnessPage.health => 'Health data',
  WellnessPage.challenges => 'Challenges',
  WellnessPage.detail => 'Challenge detail',
  WellnessPage.joined => 'Challenge confirmation',
  WellnessPage.progress => 'My progress',
  WellnessPage.log => 'Manual activity log',
  WellnessPage.document => 'Upload document',
  WellnessPage.photo => 'Upload photo',
  WellnessPage.lesson => 'Learning module',
  WellnessPage.quiz => 'Quiz',
  WellnessPage.submitted => 'Submission status',
  WellnessPage.complete => 'Challenge complete',
  WellnessPage.sharing => 'Enable health data sharing',
  WellnessPage.devices => 'Device list',
  WellnessPage.apple => 'Connect Apple Health',
  WellnessPage.garmin => 'Connect Garmin',
  WellnessPage.gallery => 'Explore screens',
};
