part of 'screens.dart';

const availableChallenges = [
  ('Hydration Habit', 'Nutrition · starts Apr 1 · 4 weeks', Color(0xFFF6F4FA)),
  (
    'Mindful Minutes',
    'Mental health · starts Apr 1 · 6 weeks',
    Color(0xFFF3F8F7),
  ),
  ('Give Back Day', 'Community · one-day event', Color(0xFFFBF8FA)),
  ('Budget Basics', 'Financial wellbeing · 5 modules', Color(0xFFFBF8FA)),
];

extension _Challenges on _WellnessScreenState {
  Widget healthData() => scrollBody(
    [
      Panel(
        color: warm,
        padding: 14,
        onTap: () => open(WellnessPage.challenges),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                children: [
                  const Positioned(
                    left: 1,
                    top: 3,
                    child: FigmaAsset('43e4b.svg'),
                  ),
                  const Positioned(
                    left: 31,
                    top: 0,
                    child: FigmaAsset('90807.svg'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: vertical([
                heading('Caesars Wellness Challenges', size: 16),
                bodyText(
                  '${data.joined.length} active  -  Step Into Spring ends in 12 days',
                  size: 12,
                ),
              ], gap: 3),
            ),
            const FigmaAsset('0bc31.svg'),
          ],
        ),
      ),
      split(
        heading('Latest Metric'),
        bodyText('Daily Steps • Synced 10:58 am', size: 12, color: ink),
      ),
      const _StepsChart(),
      for (final row in [0, 1])
        Row(
          children: [
            for (final col in [0, 1]) ...[
              if (col == 1) const SizedBox(width: 12),
              Expanded(
                child: Panel(
                  padding: 0,
                  radius: 8,
                  color: CareColors.canvas,
                  onTap: () => open(
                    [
                      WellnessPage.document,
                      WellnessPage.progress,
                      WellnessPage.devices,
                      WellnessPage.log,
                    ][row * 2 + col],
                  ),
                  child: SizedBox(
                    height: 130,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 64,
                          child: Center(
                            child: row == 1 && col == 1
                                ? const SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 10,
                                          top: 4,
                                          child: FigmaAsset('c2f66.svg'),
                                        ),
                                        Positioned(
                                          left: 20,
                                          top: 25,
                                          child: FigmaAsset('d6ed2.svg'),
                                        ),
                                      ],
                                    ),
                                  )
                                : FigmaAsset(
                                    [
                                      'f90fe.svg',
                                      'ed157.svg',
                                      '66187.svg',
                                    ][row * 2 + col],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        bodyText(
                          [
                            'Labs',
                            'Activities',
                            'Medical Devices',
                            'Manual Logs',
                          ][row * 2 + col],
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
    ],
    top: 26,
    gap: 20,
  );

  Widget challenges() => scrollBody(
    [
      bodyText('ACTIVE: ${data.joined.length}', size: 12),
      for (final name in data.joined)
        Panel(
          onTap: () {
            data.currentChallenge = name;
            data.update();
            open(WellnessPage.progress);
          },
          child: vertical([
            Row(
              children: [
                if (name == 'Step Into Spring') ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const FigmaAsset('c1798.png', width: 40, height: 40),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: vertical([
                    heading(name),
                    bodyText(
                      name == 'Know Your Blood Pressure'
                          ? 'Preventive care · ends Jun 30'
                          : 'Physical activity · 12 days left',
                      size: 12,
                    ),
                  ], gap: 4),
                ),
              ],
            ),
            progress(
              name == 'Know Your Blood Pressure'
                  ? 2 / 3
                  : data.pointsFor(name) / 1000,
              color: name == 'Know Your Blood Pressure'
                  ? CareColors.green
                  : CareColors.navy,
            ),
            split(
              Text(
                name == 'Know Your Blood Pressure'
                    ? '2 of 3 actions complete'
                    : '${data.pointsFor(name)} / 1,000 pts',
                style: label(12),
              ),
              bodyText(
                name == 'Know Your Blood Pressure'
                    ? '${data.pointsFor(name)} pts earned'
                    : '#5 of 42 · ${data.shortProperty}',
                size: 12,
              ),
            ),
          ], gap: 12),
        ),
      const SizedBox(height: 0),
      bodyText(
        'AVAILABLE: ${availableChallenges.where((c) => !data.joined.contains(c.$1)).length}',
        size: 12,
      ),
      for (final challenge in availableChallenges.where(
        (c) => !data.joined.contains(c.$1),
      ))
        Panel(
          color: challenge.$3,
          padding: 14,
          onTap: () => openChallenge(challenge.$1),
          child: Row(
            children: [
              Expanded(
                child: vertical([
                  heading(challenge.$1, size: 14),
                  bodyText(challenge.$2, size: 12),
                ], gap: 4),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(55, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  textStyle: label(12),
                ),
                onPressed: () => openChallenge(challenge.$1),
                child: const Text('Join'),
              ),
            ],
          ),
        ),
    ],
    top: 10,
    gap: 16,
  );

  void openChallenge(String title) {
    data.currentChallenge = title;
    data.update();
    open(WellnessPage.detail);
  }

  Widget detail() => scrollBody(
    [
      Wrap(
        spacing: 8,
        children: [
          pill('Physical activity'),
          pill('Team ${data.shortProperty}', color: CareColors.green),
        ],
      ),
      vertical([
        serif(data.currentChallenge),
        bodyText('Apr 1 – Apr 30 · 1,000 points to finish', size: 12),
      ], gap: 8),
      rule(),
      bodyText(
        data.currentChallenge == 'Step Into Spring'
            ? 'Move a little more this spring. Log steps, activity minutes, or anything that gets you going — however you like to track it.'
            : 'Build a healthy habit with your team. Choose the activities that work for you and track your progress throughout the challenge.',
      ),
      const SizedBox(height: 0),
      heading('Ways to earn points'),
      Panel(
        padding: 0,
        child: vertical([
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) rule(),
            InkWell(
              onTap: () => open(
                [
                  WellnessPage.apple,
                  WellnessPage.log,
                  WellnessPage.document,
                  WellnessPage.photo,
                  WellnessPage.lesson,
                ][i],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: split(
                  vertical([
                    heading(
                      [
                        'Connect Apple Health',
                        'Log it yourself',
                        'Upload a document',
                        'Add a photo',
                        'Explore learning module',
                      ][i],
                      size: 14,
                    ),
                    bodyText(
                      [
                        'Steps sync automatically each day',
                        'Enter steps, minutes, or activity',
                        'Class receipt, event form, or plan',
                        'Snap proof of a walk or workout',
                        '5-minute lesson and quick quiz',
                      ][i],
                      size: 12,
                    ),
                  ], gap: 3),
                  Text(
                    [
                      '10 pts / day',
                      '10 pts / day',
                      '50 pts',
                      '25 pts',
                      '25 pts',
                    ][i],
                    style: label(12),
                  ),
                ),
              ),
            ),
          ],
        ], gap: 0),
      ),
      Panel(
        color: warm,
        padding: 14,
        child: vertical([
          heading('Every path earns the same points', size: 14),
          bodyText(
            'Connect a device or log it yourself — no phone or tracker required to finish.',
            size: 12,
          ),
        ], gap: 4),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FigmaAsset('d08d6.svg'),
            const SizedBox(width: 10),
            Flexible(child: heading('42 teammates are already in', size: 14)),
          ],
        ),
      ),
    ],
    top: 24,
    gap: 14,
  );

  Widget joined() => scrollBody(
    [
      const Illustration('joined'),
      serif('You’re in!', center: true),
      bodyText('${data.currentChallenge}:  Apr 1 – Apr 30', center: true),
      const SizedBox(height: 0),
      Panel(
        child: vertical([
          heading('What happens next'),
          bodyText(
            'Apps that sync appear automatically — no action needed.',
            size: 12,
          ),
          bodyText(
            'Log anything else yourself: minutes, a photo, or a document.',
            size: 12,
          ),
          bodyText('Points post when activities are approved.', size: 12),
        ], gap: 14),
      ),
      Panel(
        color: warm,
        child: split(
          vertical([
            heading('Weekly reminder', size: 14),
            bodyText('A nudge each Friday to log your week', size: 12),
          ], gap: 3),
          Switch(
            value: data.weeklyReminder,
            onChanged: (value) {
              data.weeklyReminder = value;
              data.update();
            },
            activeTrackColor: CareColors.green,
          ),
        ),
      ),
    ],
    top: 24,
    gap: 12,
  );

  Widget myProgress() => scrollBody(
    [
      Panel(
        child: vertical([
          split(
            heading('Your points', size: 14),
            bodyText('12 days left', size: 12),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${data.points}', style: label(36, color: ink)),
              const SizedBox(width: 8),
              bodyText('of 1,000 pts'),
            ],
          ),
          progress(data.points / 1000),
          split(
            Text('#5 of 42 at ${data.shortProperty}', style: label(12)),
            bodyText(
              '${(1000 - data.points).clamp(0, 1000)} pts to finish',
              size: 12,
            ),
          ),
        ], gap: 10),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: Panel(
                padding: 0,
                color: CareColors.canvas,
                radius: 12,
                onTap: () => open(
                  [
                    WellnessPage.log,
                    WellnessPage.photo,
                    WellnessPage.document,
                    WellnessPage.lesson,
                  ][i],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 2,
                  ),
                  child: vertical([
                    Center(
                      child: FigmaAsset(
                        ['9a062.svg', 'f87c8.svg', '0f983.svg', '4d064.svg'][i],
                      ),
                    ),
                    Text(
                      ['Manual Log', 'Photo', 'Document', 'Module'][i],
                      textAlign: TextAlign.center,
                      style: label(11),
                    ),
                  ], gap: 6),
                ),
              ),
            ),
          ],
        ],
      ),
      Panel(
        child: vertical([
          split(
            heading('Recent activity', size: 14),
            bodyText('All sources', size: 12),
          ),
          if (data.activities.isEmpty)
            bodyText(
              'Your activities will appear here. Log your first activity to get started.',
              size: 13,
            ),
          for (var i = 0; i < data.activities.length; i++) ...[
            if (i > 0) rule(),
            InkWell(
              onTap: () => open(
                data.activities[i].pending
                    ? WellnessPage.submitted
                    : WellnessPage.log,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: split(
                  vertical([
                    heading(data.activities[i].title, size: 13),
                    bodyText(data.activities[i].subtitle, size: 11),
                  ], gap: 2),
                  Text(
                    data.activities[i].pending
                        ? 'Pending'
                        : '+${data.activities[i].points} pts',
                    style: label(
                      12,
                      color: data.activities[i].pending
                          ? const Color(0xFFC45300)
                          : CareColors.green,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ], gap: 12),
      ),
      LinkRow(
        'See the leaderboard',
        'Your rank and how ${data.shortProperty} is doing',
        () => open(WellnessPage.individualLeaderboard),
      ),
      if (data.points >= 1000)
        ActionButton(
          'View challenge completion',
          () => open(WellnessPage.complete),
        ),
    ],
    top: 16,
    gap: 16,
  );

  Widget leaderboard() {
    final property = page == WellnessPage.propertyLeaderboard;
    const names = [
      'Aisha M.',
      'Robert T.',
      'Carla P.',
      'Dana R.',
      'You',
      'Marcus T.',
      'Lin N.',
    ];
    const initials = ['AM', 'RT', 'CP', 'DR', 'PJ', 'MT', 'LN'];
    final points = [
      '1,000',
      '940',
      '870',
      '720',
      '${data.points}',
      '640',
      '610',
    ];
    const propertyNames = [
      'Caesars Republic Scottsdale',
      'Harrah’s Ak-Chin',
      'Harrah’s Northern California',
      'Harrah’s Resort SoCal',
      'Harrah’s Las Vegas',
      'Caesars Palace',
    ];
    const percentages = [88, 82, 71, 64, 58, 44];
    const counts = [
      '38 of 43',
      '34 of 42',
      '27 of 38',
      '21 of 33',
      '18 of 31',
      '12 of 27',
    ];
    return scrollBody(
      [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EFE7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              for (var i = 0; i < 2; i++)
                Expanded(
                  child: Material(
                    color: property == (i == 1)
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    elevation: property == (i == 1) ? 1 : 0,
                    child: InkWell(
                      onTap: () => open(
                        i == 0
                            ? WellnessPage.individualLeaderboard
                            : WellnessPage.propertyLeaderboard,
                        replace: true,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          i == 0 ? 'Individual' : 'Properties',
                          textAlign: TextAlign.center,
                          style: label(
                            14,
                            color: property == (i == 1)
                                ? ink
                                : CareColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Panel(
          color: CareColors.canvas,
          borderColor: CareColors.navy,
          child: property
              ? vertical([
                  Row(
                    children: [
                      Text('#2', style: label(20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: vertical([
                          heading('Harrah’s Ak-Chin'),
                          bodyText('Your property – 42 members', size: 12),
                        ], gap: 3),
                      ),
                      Text('82%', style: label(20)),
                    ],
                  ),
                  progress(.82),
                  bodyText('34 of 42 teammates have earned points', size: 12),
                ], gap: 10)
              : Row(
                  children: [
                    Text('#5', style: label(20)),
                    const SizedBox(width: 14),
                    MemberAvatar(state: data),
                    const SizedBox(width: 14),
                    Expanded(
                      child: vertical([
                        heading('You'),
                        bodyText('Harrah’s Ak-Chin  5-day streak', size: 12),
                      ], gap: 3),
                    ),
                    Text('${data.points} pts', style: label(14)),
                  ],
                ),
        ),
        Panel(
          padding: 0,
          child: vertical([
            for (var i = 0; i < (property ? 6 : 7); i++) ...[
              if (i > 0) rule(),
              Container(
                color: (property ? i == 1 : i == 4) ? warm : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 26,
                      child: Text(
                        '${i + 1}',
                        style: label(14, color: CareColors.muted),
                      ),
                    ),
                    if (!property) ...[
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: i == 4 ? Colors.white : warm,
                        child: Text(
                          i == 4 ? data.initials : initials[i],
                          style: label(12, color: CareColors.muted),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: property
                          ? vertical([
                              split(
                                heading(propertyNames[i], size: 14),
                                Text('${percentages[i]}%', style: label(12)),
                              ),
                              progress(
                                percentages[i] / 100,
                                color: i == 1
                                    ? CareColors.navy
                                    : const Color(0xFFDDDBD8),
                                height: 6,
                              ),
                              bodyText(
                                '${counts[i]} members earning',
                                size: 11,
                              ),
                            ], gap: 6)
                          : vertical([
                              split(
                                heading(names[i], size: 14),
                                Text('${points[i]} pts', style: label(13)),
                              ),
                              bodyText(
                                'Harrah’s Ak-Chin${i == 0 ? ' · finished' : ''}',
                                size: 11,
                              ),
                            ], gap: 3),
                    ),
                  ],
                ),
              ),
            ],
          ], gap: 0),
        ),
      ],
      top: 15,
      gap: 16,
    );
  }

  Widget completed() => scrollBody(
    [
      const Illustration('complete'),
      serif('Challenge complete!', center: true),
      bodyText('${data.currentChallenge}   Apr 1 – Apr 30', center: true),
      Panel(
        color: CareColors.canvas,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final stat in [
              ('1,000', 'points earned'),
              ('24', 'days logged'),
              ('4', 'ways used'),
            ])
              vertical(
                [
                  Text(stat.$1, textAlign: TextAlign.center, style: label(23)),
                  bodyText(stat.$2, size: 11, center: true),
                ],
                gap: 4,
                alignment: CrossAxisAlignment.center,
              ),
          ],
        ),
      ),
      LinkRow(
        '${data.shortProperty} finished #2 of 6',
        '82% of your property earned points',
        () => open(WellnessPage.propertyLeaderboard),
        icon: 'd08d6.svg',
      ),
      LinkRow(
        'See the final leaderboard',
        'Your rank and how ${data.shortProperty} is doing',
        () => open(WellnessPage.individualLeaderboard),
      ),
    ],
    top: 16,
    gap: 16,
  );
}

class _StepsChart extends StatelessWidget {
  const _StepsChart();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 180,
    child: Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 36,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final n in ['2,693', '2,020', '1,346', '673'])
                      bodyText(n, size: 12),
                  ],
                ),
              ),
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (i == 6) ...[
                        Text('831', style: label(18)),
                        const SizedBox(height: 8),
                      ],
                      Semantics(
                        label:
                            '${[1960, 2450, 1960, 2693, 1890, 1960, 831][i]} steps',
                        child: Container(
                          width: 8,
                          height: [
                            105.0,
                            131.0,
                            105.0,
                            144.0,
                            101.0,
                            105.0,
                            35.0,
                          ][i],
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF005171), Color(0xFF2FBBEE)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const FigmaAsset('f0807.svg'),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(width: 36, child: bodyText('MAR', size: 12)),
            for (final day in ['20', '21', '22', '23', '24', '25', 'Today'])
              Expanded(child: bodyText(day, size: 12, center: true)),
          ],
        ),
      ],
    ),
  );
}
