import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// home.dart — SmartPay Home / Landing Page
// Navigate here after sign-in / sign-up / intro completes:
//   Navigator.pushReplacementNamed(context, '/home');
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;

  // ── Dummy data — replace with real data from your backend ──────────────────
  final String _userName    = 'Dilan Perera';
  final String _netBalance  = 'LKR 12,540';
  final String _owedToYou   = 'LKR 18,200';
  final String _youOwe      = 'LKR 5,660';

  final List<Map<String, dynamic>> _sessions = [
    {
      'icon'   : Icons.restaurant,
      'color'  : const Color(0xFF5E5CE6),
      'name'   : 'Ministry of Crab',
      'people' : '5 people · OPEN',
      'amount' : 'LKR 18,400',
      'progress': 0.75,
    },
    {
      'icon'   : Icons.directions_car,
      'color'  : const Color(0xFFE8D70B),
      'name'   : 'PickMe to Galle',
      'people' : '3 people · OPEN',
      'amount' : 'LKR 6,200',
      'progress': 0.35,
    },
  ];

  final List<Map<String, dynamic>> _activity = [
    {
      'icon'    : Icons.home_outlined,
      'color'   : const Color(0xFF8E8EA0),
      'title'   : 'Kumar paid you',
      'subtitle': 'Beach villa · Last week',
      'amount'  : '+ LKR 4,800',
      'positive': true,
    },
    {
      'icon'    : Icons.restaurant_outlined,
      'color'   : const Color(0xFF5E5CE6),
      'title'   : 'You paid Nimal',
      'subtitle': 'Ministry of Crab · 2 days ago',
      'amount'  : '- LKR 2,300',
      'positive': false,
    },
    {
      'icon'    : Icons.directions_car_outlined,
      'color'   : const Color(0xFF7B79FF),
      'title'   : 'Sahan paid you',
      'subtitle': 'PickMe to Galle · Yesterday',
      'amount'  : '+ LKR 1,550',
      'positive': true,
    },
  ];
  // ──────────────────────────────────────────────────────────────────────────

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Header ───────────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader()),

              // ── QR Scan banner ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _buildQRBanner(),
                ),
              ),

              // ── Active sessions ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: _buildSectionHeader('Active sessions', onNew: () {}),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: _buildSessionCard(_sessions[i]),
                  ),
                  childCount: _sessions.length,
                ),
              ),

              // ── Recent activity ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: _buildSectionHeader('Recent activity'),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, i == 0 ? 10 : 0, 20, 0),
                    child: _buildActivityRow(_activity[i],
                        last: i == _activity.length - 1),
                  ),
                  childCount: _activity.length,
                ),
              ),

              // Bottom padding for nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // ── Bottom nav bar ───────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }
//spliTer123@C
  // ── Header widget ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B0B55), Color(0xFF3B3783)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  // Notification bell
                  Stack(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 22),
                      ),
                      Positioned(
                        top: 8, right: 9,
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // NET BALANCE label
              Text(
                'NET BALANCE',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _netBalance,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 18),

              // Owed / Owe cards
              Row(
                children: [
                  Expanded(child: _buildBalanceChip(
                    label: "You're owed",
                    amount: _owedToYou,
                    icon: Icons.south_west,
                    positive: true,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildBalanceChip(
                    label: 'You owe',
                    amount: _youOwe,
                    icon: Icons.north_east,
                    positive: false,
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceChip({
    required String label,
    required String amount,
    required IconData icon,
    required bool positive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 13,
                  color: positive
                      ? const Color(0xFF1DB97B)
                      : const Color(0xFFFF6B6B)),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.6),
                  )),
            ],
          ),
          const SizedBox(height: 5),
          Text(amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              )),
        ],
      ),
    );
  }

  // ── QR scan banner ─────────────────────────────────────────────────────────
  Widget _buildQRBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF5E5CE6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.qr_code_2, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scan a QR to join',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    )),
                SizedBox(height: 2),
                Text('Tap to open the camera',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    )),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward,
              color: Color(0xFF5E5CE6), size: 20),
        ],
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, {VoidCallback? onNew}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.3,
            )),
        if (onNew != null)
          GestureDetector(
            onTap: onNew,
            child: const Row(
              children: [
                Icon(Icons.add, size: 15, color: Color(0xFF5E5CE6)),
                SizedBox(width: 3),
                Text('New',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5E5CE6),
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
      ],
    );
  }

  // ── Session card ───────────────────────────────────────────────────────────
  Widget _buildSessionCard(Map<String, dynamic> s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: (s['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(s['icon'] as IconData,
                    color: s['color'] as Color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        )),
                    const SizedBox(height: 2),
                    Text(s['people'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                        )),
                  ],
                ),
              ),
              Text(s['amount'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: s['progress'] as double,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(
                  s['color'] as Color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Activity row ───────────────────────────────────────────────────────────
  Widget _buildActivityRow(Map<String, dynamic> a, {bool last = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft:     const Radius.circular(16),
          topRight:    const Radius.circular(16),
          bottomLeft:  Radius.circular(last ? 16 : 4),
          bottomRight: Radius.circular(last ? 16 : 4),
        ),
        boxShadow: last
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ]
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: (a['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(a['icon'] as IconData,
                      color: a['color'] as Color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['title'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          )),
                      const SizedBox(height: 2),
                      Text(a['subtitle'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          )),
                    ],
                  ),
                ),
                Text(
                  a['amount'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: a['positive']
                        ? const Color(0xFF5E5CE6)
                        : const Color(0xFFFF6B6B),
                  ),
                ),
              ],
            ),
          ),
          if (!last)
            const Divider(height: 1, indent: 72, color: Color(0xFFF0F0F0)),
        ],
      ),
    );
  }

  // ── Bottom navigation bar ──────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final tabs = [
      {'icon': Icons.home_outlined,         'label': 'Home'},
      {'icon': Icons.swap_horiz_outlined,   'label': 'Debts'},
      {'icon': null,                         'label': 'Scan'},   // center FAB
      {'icon': Icons.notifications_outlined,'label': 'Alerts'},
      {'icon': Icons.person_outline,        'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final isScan = tabs[i]['label'] == 'Scan';
              final isActive = _selectedTab == i;

              if (isScan) {
                // ── Centre QR FAB ──────────────────────────────────────────
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _selectedTab = i);
                    },
                    child: Center(
                      child: Container(
                        width: 56, height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFF5E5CE6),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x445E5CE6),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.qr_code_scanner,
                            color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (i == 4) { // Profile tab index
                      Navigator.pushNamed(context, '/profile');
                    } else {
                      HapticFeedback.lightImpact();
                      setState(() => _selectedTab = i);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tabs[i]['icon'] as IconData,
                        size: 22,
                        color: isActive
                            ? const Color(0xFF5E5CE6)
                            : const Color(0xFFBBBBBB),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tabs[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive
                              ? const Color(0xFF5E5CE6)
                              : const Color(0xFFBBBBBB),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}