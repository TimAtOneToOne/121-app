part of 'screens.dart';

extension _ActivityScreens on _WellnessScreenState {
  Widget logForm() => Form(
    key: form,
    child: scrollBody([
      bodyText(
        'No tracker needed. Enter what you did and earn the same points as a connected member.',
        size: 13,
      ),
      vertical([
        heading('What are you logging?', size: 13),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final kind in ['Steps', 'Active minutes', 'Other activity'])
              ChoiceChip(
                label: Text(kind),
                selected: activityKind == kind,
                onSelected: (_) => refresh(() => activityKind = kind),
                showCheckmark: false,
                backgroundColor: Colors.white,
                selectedColor: warm,
                side: BorderSide(
                  color: activityKind == kind
                      ? CareColors.navy
                      : CareColors.border,
                ),
                shape: const StadiumBorder(),
                labelStyle: label(
                  13,
                  color: activityKind == kind
                      ? CareColors.navy
                      : CareColors.muted,
                  weight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ], gap: 6),
      vertical([
        heading('Date', size: 13),
        Panel(
          color: CareColors.canvas,
          padding: 12,
          radius: 8,
          onTap: chooseDate,
          child: Row(
            children: [
              const FigmaAsset('ea61f.svg'),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  MaterialLocalizations.of(context).formatMediumDate(logDate),
                  style: label(16, weight: FontWeight.w400),
                ),
              ),
              const FigmaAsset('17de6.svg'),
            ],
          ),
        ),
      ], gap: 8),
      vertical([
        heading(activityKind, size: 13),
        TextFormField(
          controller: amount,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9,]')),
          ],
          style: label(22),
          decoration: fieldDecoration().copyWith(
            suffixText: activityKind == 'Steps' ? 'steps' : 'minutes',
          ),
          validator: (value) {
            final n = int.tryParse((value ?? '').replaceAll(',', ''));
            if (n == null || n <= 0) return 'Enter a number greater than zero';
            if (n > 1000000) return 'Enter a smaller activity total';
            return null;
          },
        ),
        bodyText(
          activityKind == 'Steps'
              ? 'Enter what your phone, pedometer, or tracker shows. Round numbers are fine.'
              : 'Enter the number of active minutes you completed.',
          size: 12,
        ),
      ], gap: 8),
      input(
        'Note (optional)',
        note,
        lines: 3,
        hint: 'Walked the loop at lunch',
      ),
    ], gap: 18),
  );

  Future<void> chooseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: logDate,
      firstDate: DateTime(2026),
      lastDate: now,
    );
    if (picked != null && mounted) refresh(() => logDate = picked);
  }

  void saveLog() {
    if (!(form.currentState?.validate() ?? false) || submitted) return;
    data.logActivity(
      activityKind,
      int.parse(amount.text.replaceAll(',', '')),
      logDate,
      note.text.trim(),
    );
    refresh(() => submitted = true);
    notice(
      'Activity saved locally. Daily logging credit is awarded once per date.',
    );
    open(WellnessPage.progress, replace: true);
  }

  Widget documentForm() => scrollBody([
    bodyText(
      'Add a receipt, form, or summary as proof. A reviewer approves it and your points post.',
      size: 13,
    ),
    Semantics(
      button: true,
      label: 'Choose a file',
      child: InkWell(
        onTap: busy ? null : chooseDocument,
        child: CustomPaint(
          painter: const _DashedBorder(),
          child: Container(
            height: 148,
            alignment: Alignment.center,
            child: vertical(
              [
                const Center(child: FigmaAsset('6518f.svg')),
                heading('Choose a file'),
                bodyText(
                  'PDF, JPG or PNG · up to 10 MB',
                  size: 12,
                  center: true,
                ),
              ],
              gap: 10,
              alignment: CrossAxisAlignment.center,
            ),
          ),
        ),
      ),
    ),
    if (documentName != null)
      Panel(
        color: CareColors.canvas,
        padding: 14,
        child: Row(
          children: [
            const FigmaAsset('dbd6b.svg'),
            const SizedBox(width: 12),
            Expanded(
              child: vertical([
                heading(documentName!, size: 14),
                bodyText(
                  '${(documentBytes / 1000000).toStringAsFixed(1)} MB · added just now',
                  size: 12,
                ),
              ], gap: 3),
            ),
            IconButton(
              tooltip: 'Remove document',
              onPressed: () => refresh(() {
                document = null;
                documentName = null;
              }),
              icon: const FigmaAsset('88219.svg'),
            ),
          ],
        ),
      ),
    vertical([
      heading('What is this for?', size: 13),
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: documentPurpose,
        decoration: fieldDecoration(),
        items:
            [
                  '5K race entry · 50 pts',
                  'Fitness class receipt · 50 pts',
                  'Activity plan · 50 pts',
                ]
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(v, style: label(16, weight: FontWeight.w400)),
                  ),
                )
                .toList(),
        onChanged: (value) => refresh(() => documentPurpose = value!),
      ),
    ], gap: 8),
  ], gap: 18);

  Future<void> chooseDocument() async {
    refresh(() => busy = true);
    try {
      final selected = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (selected == null || !mounted) return;
      final length = selected.lengthSync() ?? await selected.length();
      if (!mounted) return;
      if (length == null || length <= 0 || length > 10 * 1024 * 1024) {
        notice('Choose a non-empty PDF, JPG, or PNG smaller than 10 MB.');
        return;
      }
      final extension = selected.name.split('.').last.toLowerCase();
      if (!['pdf', 'jpg', 'jpeg', 'png'].contains(extension)) {
        notice('Choose a PDF, JPG, or PNG file.');
        return;
      }
      refresh(() {
        document = selected;
        documentName = selected.name;
        documentBytes = length;
      });
    } on PlatformException {
      if (mounted) notice('Could not open that file. Please try again.');
    } finally {
      if (mounted) refresh(() => busy = false);
    }
  }

  void submitDocument() {
    if (documentName == null || submitted) return;
    data.submit(documentName!, documentPurpose.split(' · ').first, 50);
    refresh(() => submitted = true);
    notice('Saved as a local preview submission. No file was uploaded.');
    open(WellnessPage.submitted, replace: true);
  }

  Widget photoForm() => scrollBody([
    bodyText('Snap proof of your activity', size: 13),
    Panel(
      color: warm,
      padding: 0,
      child: SizedBox(
        height: 228,
        child: photo == null
            ? Center(
                child: vertical([
                  const Center(child: FigmaAsset('a850b.svg')),
                  bodyText('Photo preview', size: 13, center: true),
                ], gap: 14),
              )
            : Image.memory(photo!, fit: BoxFit.cover, width: double.infinity),
      ),
    ),
    Row(
      children: [
        Expanded(
          child: ActionButton(
            'Retake',
            busy ? null : () => chooseActivityPhoto(ImageSource.camera),
            secondary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActionButton(
            'Library',
            busy ? null : () => chooseActivityPhoto(ImageSource.gallery),
            secondary: true,
          ),
        ),
      ],
    ),
    input(
      'Add a note (optional)',
      note,
      lines: 2,
      hint: 'Morning walk at the park',
    ),
    Row(
      children: [
        const FigmaAsset('0b020.svg'),
        const SizedBox(width: 8),
        Expanded(
          child: bodyText(
            photo == null
                ? 'Taken today at 7:14 am – counts for Apr 18'
                : 'Photo selected · counts for your selected activity',
            size: 12,
          ),
        ),
      ],
    ),
    Panel(
      color: warm,
      padding: 14,
      child: vertical([
        heading('Only your care team sees this', size: 14),
        bodyText(
          'Photos are never shown on the leaderboard or to other members.',
          size: 12,
        ),
      ], gap: 4),
    ),
  ], gap: 16);
  Future<void> chooseActivityPhoto(ImageSource source) async {
    refresh(() => busy = true);
    try {
      final result = await pickPhoto(source);
      if (result != null && mounted) {
        refresh(() {
          photo = result.$1;
          photoName = result.$2;
        });
      }
    } finally {
      if (mounted) refresh(() => busy = false);
    }
  }

  void submitPhoto() {
    if (photo == null || submitted) return;
    data.submit(
      note.text.trim().isEmpty ? photoName : note.text.trim(),
      'Photo',
      25,
    );
    refresh(() => submitted = true);
    notice('Photo submission saved locally. No photo was uploaded.');
    open(WellnessPage.submitted, replace: true);
  }

  Widget submission() => scrollBody(
    [
      const Illustration('submitted'),
      serif('Sent for review', center: true),
      bodyText(
        'Your ${data.lastSubmissionType == 'Photo' ? 'photo' : 'document'} is with a reviewer. Points post as soon as it’s approved.',
        center: true,
      ),
      Panel(
        color: CareColors.canvas,
        child: vertical([
          for (var i = 0; i < 3; i++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 21,
                      height: 21,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 2 ? Colors.white : null,
                        border: Border.all(
                          color: i == 0
                              ? CareColors.green
                              : i == 1
                              ? CareColors.navy
                              : CareColors.border,
                          width: i < 2 ? 2 : 1,
                        ),
                      ),
                      child: i == 0
                          ? const Center(child: FigmaAsset('a91e6.svg'))
                          : null,
                    ),
                    if (i < 2)
                      Container(width: 1, height: 35, color: CareColors.border),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: vertical([
                    heading(
                      ['Submitted', 'In review', 'Points posted'][i],
                      size: 14,
                    ),
                    bodyText(
                      [
                        'Today at 2:14 pm',
                        'Usually within 2 business days',
                        '+${data.lastSubmissionPoints} pts when approved',
                      ][i],
                      size: 12,
                    ),
                  ], gap: 3),
                ),
              ],
            ),
        ], gap: 8),
      ),
      Panel(
        color: CareColors.canvas,
        padding: 14,
        child: Row(
          children: [
            const FigmaAsset('dbd6b.svg'),
            const SizedBox(width: 12),
            Expanded(
              child: vertical([
                heading(data.lastSubmitted, size: 14),
                bodyText(
                  '${data.lastSubmissionType} – ${data.lastSubmissionPoints} pts pending',
                  size: 12,
                  color: const Color(0xFFC45300),
                ),
              ], gap: 3),
            ),
          ],
        ),
      ),
    ],
    top: 16,
    gap: 16,
  );

  Widget lesson() => scrollBody([
    split(
      bodyText('Learning Module', size: 13),
      pill('25 pts on completion', color: CareColors.green),
    ),
    heading('How much water should we drink?', size: 20),
    Semantics(
      button: true,
      label: 'Lesson video preview',
      child: InkWell(
        onTap: () => information(
          'Lesson video',
          'Video playback is not available in this preview. You can read the lesson below and continue to the questions.',
        ),
        child: const AspectRatio(
          aspectRatio: 350 / 196,
          child: FigmaAsset('3e442.png'),
        ),
      ),
    ),
    bodyText(
      'The most-cited guideline for drinking water is from the U.S. National Academies. It sets total daily water intake at about 3.7 liters (125 oz) for men and 2.7 liters (91 oz) for women. That counts all sources, and roughly 20% of it typically comes from food. So from drinks alone, that works out to about 3 liters (13 cups) for men and 2.2 liters (9 cups) for women.',
      size: 16,
    ),
  ], gap: 18);

  Widget quiz() {
    final item = quizItems[question - 1];
    return scrollBody([
      split(
        bodyText('Question ${question + 1} of 5', size: 13),
        pill('25 pts on completion', color: CareColors.green),
      ),
      progress((question + 1) / 5, height: 6),
      heading(item.$1, size: 20),
      for (var i = 0; i < item.$2.length; i++)
        Panel(
          color: CareColors.canvas,
          borderColor: answer == i ? CareColors.navy : CareColors.border,
          padding: 14,
          radius: 12,
          onTap: () => refresh(() => answer = i),
          child: Row(
            children: [
              if (answer == i)
                const FigmaAsset('23694.svg')
              else
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: CareColors.border, width: 1.5),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.$2[i],
                  style: label(15, weight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      Panel(
        color: warm,
        padding: 14,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FigmaAsset('1d6ad.svg'),
            const SizedBox(width: 10),
            Expanded(
              child: vertical([
                heading('Learn as you go', size: 14),
                bodyText(
                  'Modules take about five minutes. Answer all five questions to earn the full 25 points.',
                  size: 12,
                ),
              ], gap: 4),
            ),
          ],
        ),
      ),
    ], gap: 14);
  }

  void nextQuestion() {
    if (answer == null) return;
    if (question < 4) {
      refresh(() {
        question++;
        answer = null;
      });
      return;
    }
    final added = data.completeModule();
    notice(
      added
          ? 'Module complete! 25 points added to your local progress.'
          : 'You already earned points for this module.',
    );
    open(WellnessPage.progress, replace: true);
  }
}

const quizItems = <(String, List<String>)>[
  (
    'Roughly how much water should most adults drink each day?',
    [
      'About 2 cups',
      'About 4 cups',
      'About 8 cups',
      'It depends on activity and climate',
    ],
  ),
  (
    'What is included in total daily water intake?',
    [
      'Only plain water',
      'All drinks and water from food',
      'Only water during exercise',
      'Only water with meals',
    ],
  ),
  (
    'Roughly what percentage of water intake typically comes from food?',
    ['About 5%', 'About 20%', 'About 50%', 'About 80%'],
  ),
  (
    'Which habit would you like to try?',
    [
      'Keep water within reach',
      'Drink water with meals',
      'Plan water breaks during activity',
      'Build a routine that works for me',
    ],
  ),
];

class _DashedBorder extends CustomPainter {
  const _DashedBorder();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    canvas.drawRRect(rect, Paint()..color = warm);
    final path = Path()..addRRect(rect.deflate(1));
    final paint = Paint()
      ..color = CareColors.navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final metric in path.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 10) {
        canvas.drawPath(
          metric.extractPath(distance, (distance + 5).clamp(0, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorder oldDelegate) => false;
}
