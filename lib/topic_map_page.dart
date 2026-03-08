import 'dart:math';
import 'package:flutter/material.dart';
import 'topic_detail_page.dart';

// ✅ FIX: Use a typed class instead of Map<String,dynamic> — no more Color cast errors
class _TopicData {
  final String label;
  final bool locked;
  final double dx, dy;
  final Color color1, color2;

  const _TopicData({
    required this.label,
    required this.locked,
    required this.dx,
    required this.dy,
    required this.color1,
    required this.color2,
  });
}

class TopicMapPage extends StatefulWidget {
  final String chapterTitle;
  const TopicMapPage({super.key, required this.chapterTitle});

  @override
  State<TopicMapPage> createState() => _TopicMapPageState();
}

class _TopicMapPageState extends State<TopicMapPage>
    with TickerProviderStateMixin {
  int _bottomNavIndex = 0;
  AnimationController? _masterCtrl;

  static const Color purpleDark  = Color(0xFF4A1070);
  static const Color purpleMid   = Color(0xFF7B2FA0);
  static const Color purpleLight = Color(0xFFB06FCC);
  static const Color purplePale  = Color(0xFFEDD6F7);

  // ✅ Typed list — no Map casting needed
  static const List<_TopicData> _topics = [
    _TopicData(label: 'Topic 1', locked: false, dx: 0.06, dy: 0.60,
        color1: Color(0xFFBB6EE0), color2: Color(0xFF6A1B9A)),
    _TopicData(label: 'Topic 2', locked: true,  dx: 0.36, dy: 0.44,
        color1: Color(0xFFCC7EEE), color2: Color(0xFF7B2FA0)),
    _TopicData(label: 'Topic 3', locked: true,  dx: 0.60, dy: 0.24,
        color1: Color(0xFFD490F5), color2: Color(0xFF8E44AD)),
    _TopicData(label: 'Topic 4', locked: true,  dx: 0.80, dy: 0.06,
        color1: Color(0xFFDDA0FF), color2: Color(0xFF9B59B6)),
  ];

  static const List<List<int>> _connections = [[0,1],[1,2],[2,3]];

  static const List<_FloatItem> _floaties = [
    _FloatItem('⭐', 0.88, 0.32, 22),
    _FloatItem('✏️', 0.05, 0.36, 20),
    _FloatItem('📐', 0.72, 0.52, 22),
    _FloatItem('🔭', 0.45, 0.70, 20),
    _FloatItem('📚', 0.18, 0.85, 22),
    _FloatItem('🧪', 0.82, 0.75, 20),
    _FloatItem('🎯', 0.55, 0.88, 18),
    _FloatItem('💡', 0.30, 0.14, 20),
    _FloatItem('🖊️', 0.90, 0.55, 18),
    _FloatItem('🧮', 0.40, 0.90, 20),
  ];

  @override
  void initState() {
    super.initState();
    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _masterCtrl?.forward();
    });
  }

  @override
  void dispose() {
    _masterCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq           = MediaQuery.of(context);
    final double sw    = mq.size.width;
    final double sh    = mq.size.height;
    final double safeT = mq.padding.top;
    const double navH    = 58.0;
    const double appBarH = 56.0;
    final double mapH  = sh - safeT - appBarH - navH;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            SizedBox(
              width: sw,
              height: mapH,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // ① Background
                  Positioned.fill(
                    child: _Background(floaties: _floaties),
                  ),

                  // ② Curved lines — topics only, typed painter
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CurvePainter(
                        topics: _topics,
                        connections: _connections,
                        mapW: sw,
                        mapH: mapH,
                      ),
                    ),
                  ),

                  // ③ Overview — STANDALONE, no connections at all
                  _OverviewNode(
                    x: 0.06 * sw,
                    y: 0.10 * mapH,
                    controller: _masterCtrl,
                    purpleDark: purpleDark,
                    purpleMid: purpleMid,
                    purplePale: purplePale,
                    onTap: () => _openSheet(context, 'Overview'),
                  ),

                  // ④ Topic nodes
                  ..._topics.asMap().entries.map((e) => _TopicNodeWidget(
                        data: e.value,
                        index: e.key,
                        mapW: sw,
                        mapH: mapH,
                        controller: _masterCtrl,
                        onTap: () => e.value.locked
                            ? _lockedSheet(context)
                            : _openSheet(context, e.value.label),
                      )),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A1070), Color(0xFF7B2FA0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft:  Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
              color: purpleDark.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: Text(widget.chapterTitle,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2),
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 16),
      ]),
    );
  }

  void _lockedSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF7B2FA0), Color(0xFF4A1070)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Topic Locked 🔒',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: purpleDark)),
                const SizedBox(height: 4),
                const Text('Complete earlier topics first!',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void _openSheet(BuildContext ctx, String label) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 44, height: 5,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(height: 20),
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFFB06FCC), Color(0xFF4A1070)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 14),
          Text(label,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: purpleDark)),
          const SizedBox(height: 6),
          const Text("Ready to explore? Let's go! 🚀",
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: purpleDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () {
  Navigator.pop(ctx);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TopicDetailPage(topicTitle: label),
    ),
  );
},
              child: const Text('Start Learning 🎓',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      Icons.home_rounded, Icons.search_rounded,
      Icons.access_time_rounded, Icons.person_rounded,
      Icons.settings_rounded,
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, -3)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final bool active = _bottomNavIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _bottomNavIndex = i),
            child: Icon(items[i],
                size: 26,
                color:
                    active ? purpleDark : const Color(0xFFBBBBBB)),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// OVERVIEW NODE
// =============================================================================
class _OverviewNode extends StatelessWidget {
  final double x, y;
  final AnimationController? controller;
  final Color purpleDark, purpleMid, purplePale;
  final VoidCallback onTap;

  const _OverviewNode({
    required this.x, required this.y,
    required this.controller,
    required this.purpleDark, required this.purpleMid,
    required this.purplePale, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final box = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 118, height: 56,
        decoration: BoxDecoration(
          color: purplePale,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: purpleMid, width: 2.5),
          boxShadow: [
            BoxShadow(
                color: purpleDark.withOpacity(0.22),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        alignment: Alignment.center,
        child: Text('Overview',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: purpleDark,
                letterSpacing: 0.3)),
      ),
    );

    if (controller == null) return Positioned(left: x, top: y, child: box);

    return Positioned(
      left: x, top: y,
      child: AnimatedBuilder(
        animation: controller!,
        builder: (_, child) {
          final v = Curves.elasticOut
              .transform(controller!.value.clamp(0.0, 1.0));
          return Opacity(
            opacity: controller!.value.clamp(0.0, 1.0),
            child: Transform.scale(scale: v, child: child),
          );
        },
        child: box,
      ),
    );
  }
}

// =============================================================================
// TOPIC NODE WIDGET
// =============================================================================
class _TopicNodeWidget extends StatelessWidget {
  final _TopicData data;
  final int index;
  final double mapW, mapH;
  final AnimationController? controller;
  final VoidCallback onTap;

  const _TopicNodeWidget({
    required this.data, required this.index,
    required this.mapW, required this.mapH,
    required this.controller, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double x = data.dx * mapW;
    final double y = data.dy * mapH;

    final circle = GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.locked)
            Container(
              width: 24, height: 24,
              margin: const EdgeInsets.only(bottom: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [data.color1, data.color2]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: data.color2.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: const Icon(Icons.lock_rounded,
                  color: Colors.white, size: 13),
            ),
          Container(
            width: 74, height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [data.color1, data.color2],
                center: Alignment.topLeft,
                radius: 1.6,
              ),
              boxShadow: [
                BoxShadow(
                    color: data.color2.withOpacity(0.45),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 6)),
                BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(-2, -2)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(data.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                    shadows: [
                      Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 1))
                    ])),
          ),
        ],
      ),
    );

    if (controller == null) return Positioned(left: x, top: y, child: circle);

    final double start = (index * 0.18).clamp(0.0, 0.55);
    final anim = CurvedAnimation(
      parent: controller!,
      curve: Interval(start, (start + 0.5).clamp(0.0, 1.0),
          curve: Curves.elasticOut),
    );

    return Positioned(
      left: x, top: y,
      child: AnimatedBuilder(
        animation: anim,
        builder: (_, child) => Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Transform.scale(
              scale: anim.value.clamp(0.0, 1.0), child: child),
        ),
        child: circle,
      ),
    );
  }
}

// =============================================================================
// CURVE PAINTER — typed, no Map casting
// =============================================================================
class _CurvePainter extends CustomPainter {
  final List<_TopicData> topics;
  final List<List<int>> connections;
  final double mapW, mapH;

  const _CurvePainter({
    required this.topics, required this.connections,
    required this.mapW, required this.mapH,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final conn in connections) {
      final a = topics[conn[0]];
      final b = topics[conn[1]];

      final double ax = a.dx * mapW + 37;
      final double ay = a.dy * mapH + 62;
      final double bx = b.dx * mapW + 37;
      final double by = b.dy * mapH + 62;

      final paint = Paint()
        ..shader = LinearGradient(colors: [
          a.color1.withOpacity(0.75),
          b.color1.withOpacity(0.75),
        ]).createShader(Rect.fromPoints(Offset(ax, ay), Offset(bx, by)))
        ..strokeWidth = 3.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final cpx = (ax + bx) / 2 + (ay - by) * 0.2;
      final cpy = (ay + by) / 2 + (bx - ax) * 0.12;

      canvas.drawPath(
          Path()..moveTo(ax, ay)..quadraticBezierTo(cpx, cpy, bx, by),
          paint);

      // Glowing end dots
      canvas.drawCircle(Offset(ax, ay), 6,
          Paint()
            ..color = a.color1
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawCircle(
          Offset(ax, ay), 4, Paint()..color = Colors.white.withOpacity(0.9));

      canvas.drawCircle(Offset(bx, by), 6,
          Paint()
            ..color = b.color1
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawCircle(
          Offset(bx, by), 4, Paint()..color = Colors.white.withOpacity(0.9));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// =============================================================================
// BACKGROUND
// =============================================================================
class _Background extends StatelessWidget {
  final List<_FloatItem> floaties;
  const _Background({required this.floaties});

  static const _icons = [
    _IconItem(Icons.edit_rounded,         0.03, 0.05, 28,  10),
    _IconItem(Icons.straighten_rounded,   0.62, 0.01, 34,  -6),
    _IconItem(Icons.calculate_outlined,   0.83, 0.12, 30,   4),
    _IconItem(Icons.science_outlined,     0.87, 0.40, 26, -14),
    _IconItem(Icons.architecture_rounded, 0.70, 0.62, 28,  18),
    _IconItem(Icons.menu_book_outlined,   0.48, 0.76, 32,  -4),
    _IconItem(Icons.brush_rounded,        0.14, 0.82, 26,  20),
    _IconItem(Icons.content_cut_rounded,  0.03, 0.57, 24, -18),
    _IconItem(Icons.push_pin_outlined,    0.54, 0.20, 22,  22),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, bc) {
      final w = bc.maxWidth, h = bc.maxHeight;
      return Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF5E6FF), Color(0xFFFBF4FF), Color(0xFFF0E8FF)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        ..._icons.map((d) => Positioned(
              left: d.dx * w, top: d.dy * h,
              child: Transform.rotate(
                angle: d.angle * pi / 180,
                child: Icon(d.icon,
                    size: d.size,
                    color: const Color(0xFF9B4FBF).withOpacity(0.09)),
              ),
            )),
        ...floaties.map((f) => Positioned(
              left: f.dx * w, top: f.dy * h,
              child: Text(f.emoji,
                  style: TextStyle(
                      fontSize: f.size * 0.85,
                      color: Colors.black.withOpacity(0.10))),
            )),
        // Corner blobs
        Positioned(top: -40, right: -40,
          child: Container(width: 140, height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFCC88E8).withOpacity(0.18),
              shape: BoxShape.circle))),
        Positioned(bottom: -50, left: -30,
          child: Container(width: 120, height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF9B59B6).withOpacity(0.12),
              shape: BoxShape.circle))),
      ]);
    });
  }
}

// =============================================================================
// HELPER DATA CLASSES
// =============================================================================
class _FloatItem {
  final String emoji;
  final double dx, dy, size;
  const _FloatItem(this.emoji, this.dx, this.dy, this.size);
}

class _IconItem {
  final IconData icon;
  final double dx, dy, size, angle;
  const _IconItem(this.icon, this.dx, this.dy, this.size, this.angle);
}