import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design_system.dart';
import 'wellness/screens.dart';
import 'wellness/state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(const CareApp());
}

class CareApp extends StatelessWidget {
  const CareApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '121 · Your care team',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Instrument Sans',
      scaffoldBackgroundColor: CareColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CareColors.green,
        primary: CareColors.green,
        surface: CareColors.canvas,
        onSurface: CareColors.navy,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: CareColors.muted,
          fontSize: 14,
          letterSpacing: 0,
          height: 1.2,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    home: Uri.base.queryParameters.containsKey('screen')
        ? WellnessScreen(
            state: WellnessState(),
            page: WellnessPage.values.firstWhere(
              (p) => p.name == Uri.base.queryParameters['screen'],
              orElse: () => WellnessPage.gallery,
            ),
          )
        : const CareHome(),
  );
}

class CareHome extends StatefulWidget {
  const CareHome({super.key});

  @override
  State<CareHome> createState() => _CareHomeState();
}

class _CareHomeState extends State<CareHome> {
  final Map<String, List<String>> _conversations = {};
  final WellnessState _wellness = WellnessState();
  int _selectedTab = 0;

  Future<void> _conversation({String? topic, bool existing = false}) async {
    final title = topic ?? 'Start a conversation';
    final messages = _conversations.putIfAbsent(title, () => []);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ConversationSheet(
        title: title,
        messages: messages,
        existing: existing,
        onSend: (message) => setState(() => messages.add(message)),
      ),
    );
  }

  void _careOptions(String title, String description) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => SheetContent(
        title: title,
        description: description,
        children: [
          FilledButton(
            onPressed: () {
              Navigator.pop(sheetContext);
              _conversation(topic: title);
            },
            child: const Text('Message your care team'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Local preview — messages are saved for this session only.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _schedule() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Choose your preferred visit date',
      confirmText: 'Continue',
    );
    if (date == null || !mounted) return;
    final formatted = MaterialLocalizations.of(context).formatMediumDate(date);
    await _conversation(topic: 'Visit request · $formatted');
  }

  Future<void> _openWellness(WellnessPage page) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WellnessScreen(
          state: _wellness,
          page: page,
          onNavigate: (index) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            setState(() => _selectedTab = index);
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  void _challenge() => _openWellness(
    _wellness.profileConfirmed ? WellnessPage.challenges : WellnessPage.welcome,
  );

  @override
  void dispose() {
    _wellness.dispose();
    super.dispose();
  }

  void _allConversations() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => SheetContent(
        title: 'Your conversations',
        description: 'Pick up where you left off.',
        children: [
          ConversationCard(
            onTap: () {
              Navigator.pop(sheetContext);
              _conversation(topic: 'Calf pain after travel', existing: true);
            },
          ),
          for (final entry in _conversations.entries.where(
            (entry) => entry.value.isNotEmpty,
          )) ...[
            const SizedBox(height: 12),
            ListTile(
              title: Text(entry.key),
              subtitle: Text('${entry.value.length} local messages'),
              onTap: () {
                Navigator.pop(sheetContext);
                _conversation(
                  topic: entry.key,
                  existing: entry.key == 'Calf pain after travel',
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFEDEAE4),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Scaffold(
          body: _selectedTab == 0 ? _dashboard() : _tabContent(),
          bottomNavigationBar: _navigation(),
        ),
      ),
    ),
  );

  Widget _dashboard() {
    final topInset = MediaQuery.paddingOf(context).top;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final extraHeight = textScale > 1 ? (textScale - 1) * 90 : 0.0;
    final bodyTop = topInset + 138 + extraHeight;
    return SingleChildScrollView(
      key: const PageStorageKey('home-scroll'),
      child: Stack(
        children: [
          Header(height: bodyTop + 123, topInset: topInset),
          Padding(
            padding: EdgeInsets.fromLTRB(16, bodyTop, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConversationCTA(onTap: () => _conversation()),
                const SizedBox(height: 42),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: CareTile(
                          title: 'Routine care',
                          description: 'Stay well, manage ongoing conditions',
                          asset: 'routine',
                          onTap: () => _careOptions(
                            'Routine care',
                            'Connect with your care team about staying well or managing an ongoing condition.',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CareTile(
                          title: 'Urgent care',
                          description: 'Colds, infections, injuries and more',
                          asset: 'urgent',
                          onTap: () => _careOptions(
                            'Urgent care',
                            'Start a conversation with your care team about a new concern.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Shortcut(
                          title: 'Schedule a Visit',
                          asset: 'schedule',
                          onTap: _schedule,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Shortcut(
                          title: 'Request Labs',
                          asset: 'labs',
                          onTap: () => _careOptions(
                            'Request Labs',
                            'Tell your care team which lab work you would like to discuss.',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Shortcut(
                          title: 'Join Challenge',
                          asset: 'challenge',
                          onTap: _challenge,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('Jump back in', style: label(18))),
                    Semantics(
                      button: true,
                      child: InkWell(
                        onTap: _allConversations,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            'See all',
                            style: label(14, color: CareColors.green),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ConversationCard(
                  onTap: () => _conversation(
                    topic: 'Calf pain after travel',
                    existing: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabContent() {
    final titles = [
      'Home',
      'Your care team',
      'Your health',
      'Your records',
      'Settings',
    ];
    final descriptions = [
      '',
      'Your care team is always within reach.',
      'Your health information will appear here when your account is connected.',
      'Your documents and visit records will appear here when your account is connected.',
      'This local prototype is not connected to an account.',
    ];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 28),
          Text(
            titles[_selectedTab],
            style: const TextStyle(
              fontFamily: 'Family',
              fontSize: 36,
              color: CareColors.navy,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            descriptions[_selectedTab],
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 28),
          if (_selectedTab == 1)
            FilledButton(
              onPressed: () => _conversation(),
              child: const Text('Start a conversation'),
            ),
          if (_selectedTab == 4) ...[
            ListTile(
              title: const Text('Challenge profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openWellness(WellnessPage.profile),
            ),
            ListTile(
              title: const Text('Connected devices'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openWellness(WellnessPage.devices),
            ),
            ListTile(
              title: const Text('Explore all screens'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openWellness(WellnessPage.gallery),
            ),
          ],
          if (_selectedTab == 4)
            const ListTile(
              title: Text('121'),
              subtitle: Text('Design preview · 1.0.0'),
              leading: Icon(Icons.info_outline),
            ),
          TextButton(
            onPressed: () => setState(() => _selectedTab = 0),
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }

  Widget _navigation() {
    const assets = ['home', 'team', 'data', 'records', 'settings'];
    const names = ['Home', 'Care team', 'Health data', 'Records', 'Settings'];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 23.5, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                5,
                (index) => Semantics(
                  selected: _selectedTab == index,
                  button: true,
                  label: names[index],
                  child: Tooltip(
                    message: names[index],
                    child: InkWell(
                      onTap: () {
                        if (index == 2) {
                          _openWellness(WellnessPage.health);
                        } else {
                          setState(() => _selectedTab = index);
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: [60.0, 38.0, 52.5, 60.0, 60.0][index],
                        height: 60,
                        decoration: BoxDecoration(
                          color: index != 0 && _selectedTab == index
                              ? const Color(0xFFEDF8E5)
                              : null,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: DesignAsset('icons/${assets[index]}'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({required this.height, required this.topInset, super.key});
  final double height;
  final double topInset;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: ColoredBox(
        color: CareColors.header,
        child: Stack(
          children: [
            const Positioned(
              left: -613.92,
              top: -17.9,
              child: DesignAsset('backgrounds/circles'),
            ),
            Positioned(
              left: -114.17,
              top: 33.55,
              child: Opacity(
                opacity: 0.06,
                child: Image.asset('assets/backgrounds/ellipse2.png'),
              ),
            ),
            Positioned(
              left: -102.97,
              top: 38.74,
              child: Opacity(
                opacity: 0.06,
                child: Image.asset('assets/backgrounds/ellipse1.png'),
              ),
            ),
            Positioned(
              left: -107.89,
              top: 33.55,
              child: Opacity(
                opacity: 0.06,
                child: Image.asset('assets/backgrounds/ellipse5.png'),
              ),
            ),
            Positioned(
              left: -48.31,
              top: 98.59,
              child: Opacity(
                opacity: 0.06,
                child: Image.asset('assets/backgrounds/ellipse4.png'),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.03,
                  child: Image.asset(
                    'assets/backgrounds/texture.png',
                    repeat: ImageRepeat.repeat,
                    scale: 3.66,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: topInset + 38,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good afternoon, PJ',
                    style: TextStyle(
                      fontFamily: 'Family',
                      fontWeight: FontWeight.w300,
                      fontSize: 36,
                      height: 38 / 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your care team is always within reach.',
                    style: label(
                      16,
                      color: CareColors.lime,
                      weight: FontWeight.w400,
                    ).copyWith(height: 22 / 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class SurfaceButton extends StatelessWidget {
  const SurfaceButton({
    required this.child,
    required this.onTap,
    this.radius = 24,
    this.color = Colors.transparent,
    this.border = true,
    super.key,
  });
  final Widget child;
  final VoidCallback onTap;
  final double radius;
  final Color color;
  final bool border;

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: border
          ? const BorderSide(color: CareColors.border)
          : BorderSide.none,
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(onTap: onTap, child: child),
  );
}

class ConversationCTA extends StatelessWidget {
  const ConversationCTA({required this.onTap, super.key});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SurfaceButton(
    color: const Color(0xFFF5F9F9),
    border: false,
    onTap: onTap,
    child: Stack(
      children: [
        const Positioned(
          left: -13,
          top: 0,
          child: DesignAsset('backgrounds/conversation'),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Start a conversation', style: label(18)),
                    const SizedBox(height: 4),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Message your care team —\n'),
                          TextSpan(
                            text: 'replies in minutes',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        height: 19 / 14,
                        color: CareColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: CareColors.green,
                  shape: BoxShape.circle,
                ),
                child: const DesignAsset('icons/plus'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class CareTile extends StatelessWidget {
  const CareTile({
    required this.title,
    required this.description,
    required this.asset,
    required this.onTap,
    super.key,
  });
  final String title, description, asset;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SurfaceButton(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: DesignAsset('icons/$asset'),
          ),
          const SizedBox(height: 10),
          Text(title, style: label(18)),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              height: 18 / 13,
              color: CareColors.muted,
            ),
          ),
        ],
      ),
    ),
  );
}

class Shortcut extends StatelessWidget {
  const Shortcut({
    required this.title,
    required this.asset,
    required this.onTap,
    super.key,
  });
  final String title, asset;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SurfaceButton(
    radius: 18,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      child: Column(
        children: [
          SizedBox(
            height: 32,
            width: 32,
            child: Center(child: DesignAsset('icons/$asset')),
          ),
          const SizedBox(height: 9),
          Text(title, textAlign: TextAlign.center, style: label(12)),
        ],
      ),
    ),
  );
}

class ConversationCard extends StatelessWidget {
  const ConversationCard({required this.onTap, super.key});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SurfaceButton(
    onTap: onTap,
    radius: 20,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(17, 15, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Calf pain after travel', style: label(16))),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF8FC),
                  borderRadius: BorderRadius.circular(500),
                ),
                child: Text('Active', style: label(11)),
              ),
              const SizedBox(width: 7),
              Text(
                '1 min',
                style: label(
                  12.6,
                  color: const Color(0xFF9CA7AD),
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Alex, is it just one leg that is bothering you? Any tenderness when touching it?',
            style: TextStyle(
              fontSize: 13.5,
              height: 19 / 13.5,
              color: CareColors.muted,
            ),
          ),
        ],
      ),
    ),
  );
}

class SheetContent extends StatelessWidget {
  const SheetContent({
    required this.title,
    required this.description,
    required this.children,
    super.key,
  });
  final String title, description;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      24,
      8,
      24,
      24 + MediaQuery.paddingOf(context).bottom,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: label(26)),
        const SizedBox(height: 12),
        Text(description, style: const TextStyle(fontSize: 16, height: 1.5)),
        const SizedBox(height: 24),
        ...children,
      ],
    ),
  );
}

class ConversationSheet extends StatefulWidget {
  const ConversationSheet({
    required this.title,
    required this.messages,
    required this.onSend,
    this.existing = false,
    super.key,
  });
  final String title;
  final List<String> messages;
  final ValueChanged<String> onSend;
  final bool existing;
  @override
  State<ConversationSheet> createState() => _ConversationSheetState();
}

class _ConversationSheetState extends State<ConversationSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _send() {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    widget.onSend(message);
    _controller.clear();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.78,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
            child: Row(
              children: [
                Expanded(child: Text(widget.title, style: label(22))),
                IconButton(
                  tooltip: 'Close conversation',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              'Local preview — messages are not sent to a care team.',
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                if (widget.existing)
                  const _MessageBubble(
                    text: 'Alex, is it just one leg that is bothering you? Any tenderness when touching it?',
                    fromTeam: true,
                  ),
                if (!widget.existing && widget.messages.isEmpty)
                  const Text(
                    'What would you like to talk about?',
                    style: TextStyle(fontSize: 18),
                  ),
                for (final message in widget.messages)
                  _MessageBubble(text: message),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Write a message',
                        labelText: 'Message',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) => IconButton.filled(
                      tooltip: 'Save message locally',
                      onPressed: value.text.trim().isEmpty ? null : _send,
                      icon: const Icon(Icons.arrow_upward),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.text, this.fromTeam = false});
  final String text;
  final bool fromTeam;
  @override
  Widget build(BuildContext context) => Align(
    alignment: fromTeam ? Alignment.centerLeft : Alignment.centerRight,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 320),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fromTeam ? Colors.white : const Color(0xFFE8F2DF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: CareColors.navy,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    ),
  );
}
