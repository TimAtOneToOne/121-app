part of 'screens.dart';

extension _Connections on _WellnessScreenState {
  String get provider =>
      [
        WellnessPage.garmin,
        WellnessPage.garminPermission,
        WellnessPage.garminConnected,
      ].contains(page)
      ? 'Garmin'
      : 'Apple Health';

  Widget sharing() => scrollBody(
    [
      const Illustration('sharing'),
      serif('Enable Health Data\nSharing', size: 32, center: true),
      bodyText(
        'Connect Apple Health, fitness app, or a wearable so Challenges can log your activity automatically — no manual entry needed.',
        center: true,
      ),
      Panel(
        color: warm,
        padding: 14,
        child: vertical([
          heading('Fully optional (same credit either way)', size: 14),
          bodyText(
            'You can self-report any challenge instead — it earns the same credit. Your raw health values stay personal. Only your participation status is ever visible to Caesars.',
            size: 12,
          ),
        ], gap: 4),
      ),
      Panel(
        child: vertical([
          bodyText('WHAT GETS SHARED IF YOU CONNECT', size: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FigmaAsset('fb264.svg'),
              const SizedBox(width: 10),
              Expanded(
                child: bodyText(
                  'Aggregated activity totals + goal completion are shared with Caesars at the property level for challenge competition (e.g. Ak-Chin vs. Scottsdale). No individual breakdown.',
                  size: 13,
                  color: ink,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FigmaAsset('fb264.svg'),
              const SizedBox(width: 10),
              Expanded(
                child: bodyText(
                  'Individual health data is not shared with Caesars. It can be shared with your TextCare provider — only with your consent — to improve your healthcare.',
                  size: 13,
                  color: ink,
                ),
              ),
            ],
          ),
          privacyLink(),
        ], gap: 12),
      ),
      ActionButton('Connect App & Devices', () => open(WellnessPage.devices)),
      ActionButton('Cancel', back, secondary: true),
      bodyText(
        'You can change this anytime in Settings.',
        size: 12,
        center: true,
      ),
    ],
    top: 0,
    gap: 18,
  );

  Widget privacyLink() => InkWell(
    onTap: () => information(
      'Privacy Policy & Patient Agreement',
      'The privacy-policy destination has not been provided for this preview. No health account is connected, and no health data is accessed or shared.',
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            'Privacy Policy & Patient Agreement',
            style: label(13).copyWith(decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(width: 4),
        const FigmaAsset('b7c46.svg'),
      ],
    ),
  );

  Widget deviceIcon(String name, {double size = 48}) {
    if (name == 'Impilo') {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF4034DF),
                  borderRadius: BorderRadius.all(Radius.circular(11.25)),
                ),
              ),
            ),
            Positioned(left: 6.15, top: 13.5, child: FigmaAsset('ed2f0.svg')),
          ],
        ),
      );
    }
    if (name == 'Suunto') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11.25),
        child: Container(
          width: 48,
          height: 48,
          color: Colors.black,
          child: Stack(
            children: [
              Positioned(
                left: 3,
                top: 10.38,
                width: 40.5,
                height: 27.24,
                child: const FigmaAsset('b371c.png'),
              ),
            ],
          ),
        ),
      );
    }
    if (name == 'Peloton') return const FigmaAsset('058fb.svg');
    return ClipRRect(
      borderRadius: BorderRadius.circular(11.25),
      child: FigmaAsset(
        {
          'Apple Health': '57309.png',
          'Garmin': 'addac.png',
          'Strava': '02cb3.png',
          'Fitbit': 'f6747.png',
        }[name]!,
        width: size,
        height: size,
      ),
    );
  }

  Widget devices() => scrollBody(
    [
      heading('Connected Devices', size: 16),
      for (final name in ['Apple Health', 'Garmin'])
        deviceRow(name, connected: data.demoConnections.contains(name)),
      const SizedBox(height: 10),
      rule(),
      const SizedBox(height: 10),
      heading('Available Devices', size: 16),
      for (final name in ['Strava', 'Fitbit', 'Impilo', 'Suunto', 'Peloton'])
        deviceRow(name),
    ],
    top: 24,
    gap: 16,
  );

  Widget deviceRow(String name, {bool connected = false}) => InkWell(
    onTap: () {
      if (name == 'Apple Health' || name == 'Garmin') {
        open(name == 'Apple Health' ? WellnessPage.apple : WellnessPage.garmin);
      } else {
        information(
          'Connect $name',
          '$name connection is not available in this preview. You can still log activities manually and earn the same points.',
        );
      }
    },
    child: Row(
      children: [
        deviceIcon(name),
        const SizedBox(width: 16),
        Expanded(child: heading(name)),
        if (connected) const FigmaAsset('8fccc.svg'),
        const SizedBox(width: 12),
        const FigmaAsset('dfe01.svg'),
      ],
    ),
  );

  Widget connect() => scrollBody(
    [
      Center(child: deviceIcon(provider, size: 64)),
      serif('Connect with $provider', center: true),
      bodyText(
        'Connect $provider and your daily activities post to the challenge automatically — nothing to log.',
        center: true,
      ),
      bodyText(
        'By clicking connect, you agree to share your data with One to One Health.',
        center: true,
      ),
      Center(child: privacyLink()),
      Panel(
        child: vertical([
          heading('What TextCare reads', size: 14),
          for (final item
              in provider == 'Apple Health'
                  ? ['Steps', 'Walking + running distance', 'Workout minutes']
                  : [
                      'Daily steps',
                      'Distance',
                      'Active minutes',
                      'Sleep duration',
                    ])
            Row(
              children: [
                FigmaAsset(
                  provider == 'Apple Health' ? '80c1b.svg' : 'fb264.svg',
                ),
                const SizedBox(width: 10),
                Expanded(child: bodyText(item)),
              ],
            ),
        ], gap: 12),
      ),
    ],
    top: provider == 'Garmin' ? 28 : 8,
    gap: 18,
  );

  Future<void> healthPermission() async {
    final allowed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFFF2F1F7),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, updateSheet) => SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(sheetContext, false),
                        child: const Text(
                          'Don’t Allow',
                          style: TextStyle(
                            color: Color(0xFF0085FF),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Health Access',
                          textAlign: TextAlign.center,
                          style: label(
                            17,
                            color: Colors.black,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: permissions.any((v) => v)
                            ? () => Navigator.pop(sheetContext, true)
                            : null,
                        child: const Text(
                          'Allow',
                          style: TextStyle(
                            color: Color(0xFF0085FF),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bodyText(
                  'Demo permission preview · no health data accessed',
                  size: 11,
                  center: true,
                ),
                const SizedBox(height: 14),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Stack(
                    children: [
                      Positioned(
                        left: 17.54,
                        top: 7.48,
                        child: FigmaAsset('d42a0.svg'),
                      ),
                      Positioned(
                        left: 14,
                        top: 42,
                        child: FigmaAsset('dcbb0.svg'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  child: bodyText(
                    '“TextCare” would like to access and update your Health data',
                    size: 13,
                    center: true,
                    color: const Color(0xFF45454A),
                  ),
                ),
                permissionRow(
                  'Turn On All',
                  permissions.every((v) => v),
                  (value) => updateSheet(() {
                    for (var i = 0; i < permissions.length; i++) {
                      permissions[i] = value;
                    }
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: bodyText('ALLOW “TEXTCARE” TO READ:', size: 12),
                  ),
                ),
                for (var i = 0; i < 3; i++)
                  permissionRow(
                    [
                      'Steps',
                      'Walking + Running Distance',
                      'Workout Minutes',
                    ][i],
                    permissions[i],
                    (value) => updateSheet(() => permissions[i] = value),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: bodyText(
                    'Apps are not allowed to read data they have not been granted access to.',
                    size: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (allowed == true) {
      data.demoConnections.add(provider);
      data.update();
      notice(
        'Demo connection saved. No device permissions or health data were accessed.',
      );
      open(
        provider == 'Apple Health'
            ? WellnessPage.appleConnected
            : WellnessPage.garminConnected,
      );
    } else if (allowed == false) {
      notice('Connection declined. You can log activities manually.');
    }
  }

  Widget permissionRow(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: label(16, color: Colors.black, weight: FontWeight.w400),
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: const Color(0xFF2AC954),
        ),
      ],
    ),
  );

  Widget connected() => scrollBody([
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F2D8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const FigmaAsset('96061.svg'),
          const SizedBox(width: 10),
          Expanded(
            child: heading('$provider connected – syncing daily', size: 13),
          ),
        ],
      ),
    ),
    Panel(
      child: vertical([
        split(
          heading('Today', size: 14),
          pill('+10 pts', color: CareColors.green),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('8,412', style: label(36, color: ink)),
            const SizedBox(width: 8),
            bodyText('steps'),
          ],
        ),
        bodyText('Synced from $provider at 10:58 am', size: 12),
        progress(.84),
        bodyText('84% of your 10,000-step day goal', size: 12),
      ], gap: 10),
    ),
    Panel(
      color: CareColors.canvas,
      child: vertical([
        split(
          heading('This week', size: 14),
          bodyText('5 of 7 days', size: 12),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 7; i++)
              vertical(
                [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i < 5 ? warm : Colors.white,
                      shape: BoxShape.circle,
                      border: i < 5
                          ? null
                          : Border.all(color: CareColors.border),
                    ),
                    child: i < 5 ? const FigmaAsset('324a8.svg') : null,
                  ),
                  bodyText(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i], size: 12),
                ],
                gap: 6,
                alignment: CrossAxisAlignment.center,
              ),
          ],
        ),
      ], gap: 12),
    ),
    Panel(
      color: CareColors.canvas,
      child: vertical([
        heading('Where your points came from', size: 14),
        for (final item in [
          (provider, '480 pts'),
          ('Logged by you', '120 pts'),
          ('Document', '55 pts'),
          ('Module', '25 pts'),
        ])
          split(
            bodyText(item.$1, size: 13),
            Text(item.$2, style: label(13, color: ink)),
          ),
        rule(),
        split(
          heading('Total', size: 14),
          Text('${data.points} / 1,000 pts', style: label(14)),
        ),
      ], gap: 12),
    ),
    bodyText(
      'Demo data · no device is connected to this preview.',
      size: 11,
      center: true,
    ),
  ], gap: 16);
}
