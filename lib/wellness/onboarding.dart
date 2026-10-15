part of 'screens.dart';

extension _Onboarding on _WellnessScreenState {
  Widget welcome() => scrollBody(
    [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 236,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: FigmaAsset('4d6ff.png')),
              const Positioned(
                top: 34,
                child: FigmaAsset('e450f.png', width: 203, height: 113),
              ),
              Positioned(
                top: 174,
                child: Text(
                  'WELLNESS CHALLENGE',
                  style: label(
                    13,
                    color: Colors.white,
                  ).copyWith(letterSpacing: 3),
                ),
              ),
            ],
          ),
        ),
      ),
      serif('New Challenge'),
      Panel(
        color: warm,
        child: vertical([
          Align(alignment: Alignment.centerLeft, child: pill('MAY 2026')),
          Text(
            'CAESARS WELLNESS - SITE COMPETITION',
            style: label(11, weight: FontWeight.w400),
          ),
          heading('Steps Showdown', size: 20),
          bodyText(
            'Sync Apple Health or Android Health to track daily steps automatically — or log your steps or distance by hand. Both earn the same points.',
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => open(
              data.profileConfirmed
                  ? WellnessPage.detail
                  : WellnessPage.profile,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Learn more & join'),
                const SizedBox(width: 8),
                const FigmaAsset('d4213.svg'),
              ],
            ),
          ),
        ], gap: 12),
      ),
    ],
    top: 10,
    gap: 22,
  );

  Widget profile() {
    final matches = properties.asMap().entries.where((entry) {
      final p = entry.value;
      return (stateFilter == 'All states (52)' || p.state == stateFilter) &&
          '${p.name} ${p.city}'.toLowerCase().contains(
            search.text.toLowerCase(),
          );
    }).toList();
    return Form(
      key: form,
      child: scrollBody(
        [
          serif('Welcome to Challenges', size: 28),
          bodyText(
            'Caesars Wellness challenges. Confirm your profile and home property to get started.',
          ),
          Row(
            children: [
              MemberAvatar(state: data, size: 64),
              const SizedBox(width: 14),
              vertical(
                [
                  heading('Profile photo'),
                  InkWell(
                    onTap: chooseProfilePhoto,
                    child: Text(
                      'Change photo',
                      style: label(14)
                          .copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
                gap: 5,
                alignment: CrossAxisAlignment.start,
              ),
            ],
          ),
          input(
            'First name',
            first,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter your first name'
                : null,
          ),
          input(
            'Last name',
            last,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter your last name'
                : null,
          ),
          heading('Your home property', size: 13),
          Row(
            children: [
              bodyText('State', size: 13),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: stateFilter,
                  decoration: fieldDecoration(),
                  items: const ['All states (52)', 'AZ', 'CA']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) => refresh(() => stateFilter = value!),
                ),
              ),
            ],
          ),
          TextField(
            controller: search,
            onChanged: (_) => refresh(() {}),
            decoration: fieldDecoration(hint: 'Search by property or city…')
                .copyWith(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: FigmaAsset('94fbe.svg'),
                  ),
                ),
          ),
          Panel(
            padding: 0,
            child: vertical([
              if (matches.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No matching properties. Try another search.'),
                ),
              for (var i = 0; i < matches.length; i++) ...[
                if (i > 0) rule(),
                Material(
                  color: data.propertyIndex == matches[i].key
                      ? warm
                      : Colors.white,
                  child: InkWell(
                    onTap: () {
                      data.propertyIndex = matches[i].key;
                      data.update();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: split(
                        vertical([
                          heading(matches[i].value.name, size: 14),
                          bodyText(
                            '${matches[i].value.city}, ${matches[i].value.state}',
                            size: 12,
                          ),
                        ], gap: 3),
                        data.propertyIndex == matches[i].key
                            ? const FigmaAsset('374ca.svg')
                            : const SizedBox(width: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ], gap: 0),
          ),
          bodyText(
            'Pick where you work most often — this sets the property you compete in.',
            size: 12,
          ),
          ActionButton('Continue', () {
            if (!(form.currentState?.validate() ?? false)) return;
            data.firstName = first.text.trim();
            data.lastName = last.text.trim();
            data.update();
            open(WellnessPage.confirmProfile);
          }),
        ],
        top: 18,
        gap: 12,
      ),
    );
  }

  Widget confirmProfile() => scrollBody(
    [
      serif('Confirm your profile', size: 28),
      bodyText('Looks good? You can update this later in settings.'),
      Panel(
        child: vertical([
          Row(
            children: [
              MemberAvatar(state: data, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: vertical([
                  heading(data.fullName, size: 18),
                  bodyText('${data.firstName} for short'),
                ], gap: 4),
              ),
            ],
          ),
          rule(),
          vertical([
            bodyText('HOME PROPERTY', size: 11),
            heading(data.propertyName),
            bodyText(properties[data.propertyIndex].address, size: 13),
          ], gap: 5),
        ], gap: 14),
      ),
      Panel(
        color: warm,
        padding: 14,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FigmaAsset('96061.svg'),
            const SizedBox(width: 8),
            Expanded(
              child: vertical([
                heading('You’ll compete for ${data.shortProperty}', size: 14),
                bodyText(
                  'Your points count toward this property on the property leaderboard.',
                  size: 12,
                ),
              ], gap: 4),
            ),
          ],
        ),
      ),
    ],
    top: 18,
    gap: 16,
  );

  Future<void> chooseProfilePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: CareColors.canvas,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        child: SafeArea(
          top: false,
          child: vertical([
            vertical([
              heading('Profile photo', size: 18),
              bodyText('Shown to teammates on the leaderboard.', size: 13),
            ], gap: 4),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FigmaAsset('1f133.svg'),
              title: const Text('Take a photo'),
              subtitle: const Text('Use the camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            rule(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FigmaAsset('f9121.svg'),
              title: const Text('Choose from library'),
              subtitle: const Text('Pick an existing photo'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ActionButton(
              'Cancel',
              () => Navigator.pop(context),
              secondary: true,
            ),
          ], gap: 12),
        ),
      ),
    );
    if (source == null || !mounted) return;
    final result = await pickPhoto(source);
    if (result != null && mounted) {
      data.profilePhoto = result.$1;
      data.update();
    }
  }

  InputDecoration fieldDecoration({String? hint}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9CA7AD)),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: CareColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: CareColors.navy, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );
  Widget input(
    String title,
    TextEditingController controller, {
    String? Function(String?)? validator,
    int lines = 1,
    String? hint,
  }) => vertical([
    heading(title, size: 13),
    TextFormField(
      controller: controller,
      validator: validator,
      maxLines: lines,
      decoration: fieldDecoration(hint: hint),
      style: label(16, weight: FontWeight.w400),
    ),
  ], gap: 8);

  Future<(Uint8List, String)?> pickPhoto(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (image == null) return null;
      final bytes = await image.readAsBytes();
      if (bytes.length > 10 * 1024 * 1024) {
        if (mounted) notice('Choose a photo smaller than 10 MB.');
        return null;
      }
      return (bytes, image.name);
    } on PlatformException catch (error) {
      if (mounted) {
        notice(
          error.code.contains('denied')
              ? 'Photo access was declined. You can choose another source.'
              : 'Could not open the camera or photo library. Please try again.',
        );
      }
      return null;
    }
  }
}
