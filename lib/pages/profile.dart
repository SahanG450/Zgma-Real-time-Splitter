import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
// ─────────────────────────────────────────────────────────────────────────────
// profile.dart — SmartPay Profile Page
// Add to main.dart routes:
//   '/profile': (context) => const ProfilePage(),
// Navigate from home.dart bottom nav Profile tap:
//   Navigator.pushNamed(context, '/profile');
// ─────────────────────────────────────────────────────────────────────────────

// ── App-wide theme colors ────────────────────────────────────────────────────
const _kAccent      = Color(0xFF5E5CE6);
const _kAccentLight = Color(0xFF7B79FF);
const _kNavy        = Color(0xFF1A1A6E);
const _kBg          = Color(0xFFF0F2F8);
const _kCard        = Colors.white;
const _kText        = Color(0xFF1A1A2E);
const _kMuted       = Color(0xFF8E8EA0);
const _kDanger      = Color(0xFFFF4757);
const _kPositive    = Color(0xFF5E5CE6);
const _kNegative    = Color(0xFFFF6B6B);
const _kSilver      = Color(0xFFE8EAF2);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ── Section expand state — true = open, false = collapsed ─────────────────
  final Map<String, bool> _expanded = {
    'My Cards'                  : true,
    'My Transactions'           : false,
    'Payment History'           : false,
    'Notifications & Reminders' : false,
    'Settings'                  : false,
    'Account'                   : false,
  };


  final _supabase = Supabase.instance.client;
  String? _avatarUrl;   // stores the full public URL after upload
  bool _uploadingPhoto = false;

// ── Pick image from gallery or camera ─────────────────────────────────────
  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();

    // Show source choice
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                )),
            const SizedBox(height: 20),
            _sourceOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 10),
            _sourceOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take a Photo',
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 10),
            if (_avatarUrl != null)
              _sourceOption(
                icon: Icons.delete_outline,
                label: 'Remove Photo',
                color: const Color(0xFFFF4757),
                onTap: () => Navigator.pop(context, null),
              ),
          ],
        ),
      ),
    );

    // Remove photo if selected
    if (source == null && _avatarUrl != null) {
      await _removePhoto();
      return;
    }
    if (source == null) return;

    // Pick the image
    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 80,   // compress to 80% — saves storage space
      maxWidth: 512,      // max 512px wide — enough for an avatar
      maxHeight: 512,
    );
    if (picked == null) return;

    await _uploadPhoto(File(picked.path));
  }

// ── Upload to Supabase Storage ─────────────────────────────────────────────
  Future<void> _uploadPhoto(File file) async {
    setState(() => _uploadingPhoto = true);

    try {
      // final userId = _supabase.auth.currentUser?.id;
      final userId = 1;
      if (userId == null) throw Exception('Not logged in');

      // File path inside the bucket: avatars/USER_ID.jpg
      // Using userId as filename ensures each user has one avatar
      // and uploading a new one automatically overwrites the old one
      final filePath = '$userId.jpg';

      // Upload — upsert: true overwrites if file already exists
      await _supabase.storage
          .from('avatars')
          .upload(
        filePath,
        file,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      // Get the public URL
      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Add a cache-busting timestamp so Flutter reloads the new image
      final urlWithCache = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      // Save URL to your users table in the database
      await _supabase
          .from('users')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      setState(() {
        _avatarUrl = urlWithCache;
        _uploadingPhoto = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated'),
            backgroundColor: Color(0xFF5E5CE6),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _uploadingPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: const Color(0xFFFF4757),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

// ── Remove photo from storage ──────────────────────────────────────────────
  Future<void> _removePhoto() async {
    setState(() => _uploadingPhoto = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.storage
          .from('avatars')
          .remove(['$userId.jpg']);

      await _supabase
          .from('users')
          .update({'avatar_url': null})
          .eq('id', userId);

      setState(() {
        _avatarUrl = null;
        _uploadingPhoto = false;
      });
    } catch (e) {
      setState(() => _uploadingPhoto = false);
    }
  }

// ── Load existing photo on page open ──────────────────────────────────────
// Call this in initState
  Future<void> _loadAvatar() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final data = await _supabase
        .from('users')
        .select('avatar_url')
        .eq('id', userId)
        .single();

    if (data['avatar_url'] != null) {
      setState(() => _avatarUrl = data['avatar_url']);
    }
  }

// ── Helper widget for source picker ──────────────────────────────────────
  Widget _sourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFF1A1A2E),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EAF2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                )),
          ],
        ),
      ),
    );
  }
  //////////////////////
  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  void _toggle(String key) {
    HapticFeedback.lightImpact();
    setState(() => _expanded[key] = !(_expanded[key] ?? false));
  }

  // ── Dummy user data — replace with real backend data ──────────────────────
  String _displayName  = 'Dilan Perera';
  String _email        = 'dilan@example.com';
  String _phone        = '+94 77 123 4567';
  String _avatarLetter = 'D';

  bool _notifyNewBill        = true;
  bool _notifySettlement     = true;
  bool _notifyReminders      = false;
  bool _darkMode             = false;
  bool _allowGroupAdd        = true;
  bool _biometricLock        = false;
  String _selectedTheme      = 'Navy Blue';

  final List<Map<String, dynamic>> _cards = [
    {'type': 'Visa',       'last4': '4242', 'color': _kAccent},
    {'type': 'Mastercard', 'last4': '8821', 'color': _kNavy},
  ];

  final List<Map<String, dynamic>> _paymentHistory = [
    {'title': 'Ministry of Crab',   'date': 'May 12, 2025', 'amount': '- LKR 1,600', 'pos': false},
    {'title': 'Kumar paid you',     'date': 'May 10, 2025', 'amount': '+ LKR 4,800', 'pos': true},
    {'title': 'PickMe to Galle',    'date': 'May 8, 2025',  'amount': '- LKR 2,300', 'pos': false},
    {'title': 'Sahan paid you',     'date': 'May 5, 2025',  'amount': '+ LKR 1,550', 'pos': true},
    {'title': 'Beach Villa split',  'date': 'Apr 28, 2025', 'amount': '- LKR 3,200', 'pos': false},
  ];

  final List<Map<String, dynamic>> _debtsOwed = [
    {'name': 'Nimal',  'desc': 'Ministry of Crab',  'amount': 'LKR 1,600'},
    {'name': 'Kasun',  'desc': 'Beach Villa',        'amount': 'LKR 3,200'},
  ];

  final List<Map<String, dynamic>> _debtsToMe = [
    {'name': 'Sahan',  'desc': 'PickMe to Galle',   'amount': 'LKR 2,300'},
    {'name': 'Amali',  'desc': 'Group dinner',       'amount': 'LKR 950'},
    {'name': 'Dinesh', 'desc': 'Ella trip',          'amount': 'LKR 4,100'},
  ];
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ───────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(context)),

          // ── Collapsible sections ──────────────────────────────────────────
          _collapsibleSection(
            key: 'My Cards',
            icon: Icons.credit_card_outlined,
            child: _buildCardsSection(),
          ),
          _collapsibleSection(
            key: 'My Transactions',
            icon: Icons.swap_horiz_outlined,
            child: _buildTransactionsSection(),
          ),
          _collapsibleSection(
            key: 'Payment History',
            icon: Icons.history_outlined,
            child: _buildPaymentHistory(),
          ),
          _collapsibleSection(
            key: 'Notifications & Reminders',
            icon: Icons.notifications_outlined,
            child: _buildNotifications(),
          ),
          _collapsibleSection(
            key: 'Settings',
            icon: Icons.settings_outlined,
            child: _buildSettings(context),
          ),
          _collapsibleSection(
            key: 'Account',
            icon: Icons.manage_accounts_outlined,
            child: _buildAccountActions(context),
            isDanger: true,
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ── Collapsible section wrapper ─────────────────────────────────────────────
  SliverToBoxAdapter _collapsibleSection({
    required String key,
    required IconData icon,
    required Widget child,
    bool isDanger = false,
  }) {
    final isOpen = _expanded[key] ?? false;
    final color  = isDanger ? _kDanger : _kAccent;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Container(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Tap header ──────────────────────────────────────────────
              GestureDetector(
                onTap: () => _toggle(key),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          key,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDanger ? _kDanger : _kText,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isOpen ? color : _kMuted,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Animated content ─────────────────────────────────────────
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Column(
                  children: [
                    Divider(height: 1, color: _kSilver),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: child,
                    ),
                  ],
                ),
                crossFadeState: isOpen
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 280),
                sizeCurve: Curves.easeInOut,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  const Text('Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  const Spacer(),
                  // Edit button
                  GestureDetector(
                    onTap: () => _showEditProfileSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.25)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              color: Colors.white, size: 13),
                          SizedBox(width: 5),
                          Text('Edit',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Avatar + name
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7B79FF), _kAccent],
                          ),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3),
                        ),
                        child: Center(
                          child: Text(
                            _avatarLetter,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 26, height: 26,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_outlined,
                              size: 14, color: _kAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      )),
                  const SizedBox(height: 4),
                  Text(_email,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.65),
                      )),
                  const SizedBox(height: 4),
                  Text(_phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.65),
                      )),
                ],
              ),

              const SizedBox(height: 20),

              // Quick stats row
              Row(
                children: [
                  _quickStat('Groups', '4'),
                  _vDivider(),
                  _quickStat('Bills', '18'),
                  _vDivider(),
                  _quickStat('Settled', '12'),
                  _vDivider(),
                  _quickStat('Pending', '6'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.6),
              )),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
    width: 1, height: 32,
    color: Colors.white.withOpacity(0.2),
  );

  // ── Section title sliver ────────────────────────────────────────────────────

  // ── Cards section ───────────────────────────────────────────────────────────
  Widget _buildCardsSection() {
    return Column(
      children: [
        // Existing cards
        ..._cards.map((card) => _cardTile(card)),
        const SizedBox(height: 10),
        // Add card button
        GestureDetector(
          onTap: () => _showAddCardSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kAccent.withOpacity(0.3),
                  style: BorderStyle.solid),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: _kAccent, size: 18),
                SizedBox(width: 8),
                Text('Add New Card',
                    style: TextStyle(
                      color: _kAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardTile(Map<String, dynamic> card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [(card['color'] as Color),
            (card['color'] as Color).withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (card['color'] as Color).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 26,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(Icons.credit_card,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card['type'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                Text('•••• •••• •••• ${card['last4']}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                color: Colors.white.withOpacity(0.7), size: 18),
            onPressed: () => setState(
                    () => _cards.remove(card)),
          ),
        ],
      ),
    );
  }

  // ── My Transactions ─────────────────────────────────────────────────────────
  Widget _buildTransactionsSection() {
    final totalOwed = _debtsOwed.fold(0, (sum, d) {
      final n = int.tryParse(
          d['amount'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
      return sum + n;
    });
    final totalToMe = _debtsToMe.fold(0, (sum, d) {
      final n = int.tryParse(
          d['amount'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
      return sum + n;
    });

    return Column(
      children: [
        // Summary row
        Row(
          children: [
            Expanded(
              child: _txSummaryCard(
                label: 'I Owe',
                amount: 'LKR $totalOwed',
                icon: Icons.north_east,
                color: _kNegative,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _txSummaryCard(
                label: 'Owed to Me',
                amount: 'LKR $totalToMe',
                icon: Icons.south_west,
                color: _kPositive,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // I owe list
        _txGroupHeader('I need to pay', _kNegative),
        ..._debtsOwed.map((d) => _txRow(d, negative: true)),
        const SizedBox(height: 14),

        // Owed to me list
        _txGroupHeader('People owe me', _kPositive),
        ..._debtsToMe.map((d) => _txRow(d, negative: false)),
      ],
    );
  }

  Widget _txSummaryCard({
    required String label,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: _kMuted)),
            ],
          ),
          const SizedBox(height: 6),
          Text(amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              )),
        ],
      ),
    );
  }

  Widget _txGroupHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
              width: 4, height: 14,
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kText,
              )),
        ],
      ),
    );
  }

  Widget _txRow(Map<String, dynamic> d, {required bool negative}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: negative
                ? _kNegative.withOpacity(0.12)
                : _kPositive.withOpacity(0.12),
            child: Text(
              d['name'].toString()[0],
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: negative ? _kNegative : _kPositive,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d['name'],
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kText)),
                Text(d['desc'],
                    style: const TextStyle(
                        fontSize: 12, color: _kMuted)),
              ],
            ),
          ),
          Text(d['amount'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: negative ? _kNegative : _kPositive,
              )),
        ],
      ),
    );
  }

  // ── Payment history ─────────────────────────────────────────────────────────
  Widget _buildPaymentHistory() {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: _paymentHistory.asMap().entries.map((e) {
          final i = e.key;
          final h = e.value;
          final isLast = i == _paymentHistory.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: (h['pos'] as bool)
                            ? _kPositive.withOpacity(0.1)
                            : _kNegative.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        (h['pos'] as bool)
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 18,
                        color: (h['pos'] as bool)
                            ? _kPositive
                            : _kNegative,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h['title'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _kText,
                              )),
                          Text(h['date'],
                              style: const TextStyle(
                                  fontSize: 11, color: _kMuted)),
                        ],
                      ),
                    ),
                    Text(h['amount'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: (h['pos'] as bool)
                              ? _kPositive
                              : _kNegative,
                        )),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 1, indent: 68, color: _kSilver),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Notifications ───────────────────────────────────────────────────────────
  Widget _buildNotifications() {
    return _cardList([
      _toggleRow(
        icon: Icons.receipt_long_outlined,
        label: 'New Bill Alerts',
        subtitle: 'Notify when someone adds a bill',
        value: _notifyNewBill,
        onChanged: (v) => setState(() => _notifyNewBill = v),
      ),
      _toggleRow(
        icon: Icons.check_circle_outline,
        label: 'Settlement Alerts',
        subtitle: 'Notify when a payment is confirmed',
        value: _notifySettlement,
        onChanged: (v) => setState(() => _notifySettlement = v),
      ),
      _toggleRow(
        icon: Icons.alarm_outlined,
        label: 'Payment Reminders',
        subtitle: 'Weekly nudge for pending debts',
        value: _notifyReminders,
        onChanged: (v) => setState(() => _notifyReminders = v),
        isLast: true,
      ),
    ]);
  }

  // ── Settings ────────────────────────────────────────────────────────────────
  Widget _buildSettings(BuildContext context) {
    return _cardList([
      _toggleRow(
        icon: Icons.fingerprint,
        label: 'Biometric Lock',
        subtitle: 'Use fingerprint to open app',
        value: _biometricLock,
        onChanged: (v) => setState(() => _biometricLock = v),
      ),
      _toggleRow(
        icon: Icons.group_add_outlined,
        label: 'Allow Group Invites',
        subtitle: 'Let others add you to groups',
        value: _allowGroupAdd,
        onChanged: (v) => setState(() => _allowGroupAdd = v),
      ),
      _arrowRow(
        icon: Icons.palette_outlined,
        label: 'App Theme',
        subtitle: _selectedTheme,
        onTap: () => _showThemeSheet(context),
      ),
      _arrowRow(
        icon: Icons.person_outline,
        label: 'Display Name',
        subtitle: _displayName,
        onTap: () => _showEditProfileSheet(context),
      ),
      _arrowRow(
        icon: Icons.currency_exchange_outlined,
        label: 'Default Currency',
        subtitle: 'LKR — Sri Lankan Rupee',
        onTap: () {},
        isLast: true,
      ),
    ]);
  }

  // ── Account actions ─────────────────────────────────────────────────────────
  Widget _buildAccountActions(BuildContext context) {
    return Column(
      children: [
        // Logout
        GestureDetector(
          onTap: () => _showLogoutDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04),
                    blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: _kAccent, size: 18),
                SizedBox(width: 8),
                Text('Log Out',
                    style: TextStyle(
                      color: _kAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Delete account
        GestureDetector(
          onTap: () => _showDeleteAccountSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: _kDanger.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kDanger.withOpacity(0.25)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_forever_outlined,
                    color: _kDanger, size: 18),
                SizedBox(width: 8),
                Text('Delete My Account',
                    style: TextStyle(
                      color: _kDanger,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Reusable card list container ────────────────────────────────────────────
  Widget _cardList(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _kAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _kAccent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _kText,
                        )),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: _kMuted)),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: _kAccent,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 64, color: _kSilver),
      ],
    );
  }

  Widget _arrowRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _kAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _kAccent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _kText,
                          )),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 11, color: _kMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: _kMuted, size: 18),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 64, color: _kSilver),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BOTTOM SHEETS & DIALOGS
  // ══════════════════════════════════════════════════════════════════════════

  // ── Edit Profile Sheet ──────────────────────────────────────────────────────
  void _showEditProfileSheet(BuildContext context) {
    final nameCtrl  = TextEditingController(text: _displayName);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _sheet(
        title: 'Edit Profile',
        child: Column(
          children: [
            _sheetField(nameCtrl,  'Display Name',  Icons.person_outline),
            const SizedBox(height: 14),
            _sheetField(emailCtrl, 'Email Address', Icons.email_outlined,
                keyboard: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _sheetField(phoneCtrl, 'Phone Number',  Icons.phone_outlined,
                keyboard: TextInputType.phone),
            const SizedBox(height: 24),
            _sheetButton('Save Changes', () {
              setState(() {
                _displayName  = nameCtrl.text;
                _email        = emailCtrl.text;
                _phone        = phoneCtrl.text;
                _avatarLetter = _displayName.isNotEmpty
                    ? _displayName[0].toUpperCase()
                    : 'U';
              });
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  // ── Add Card Sheet ──────────────────────────────────────────────────────────
  void _showAddCardSheet(BuildContext context) {
    final numberCtrl = TextEditingController();
    final nameCtrl   = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl    = TextEditingController();
    String cardType = 'Visa';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => _sheet(
          title: 'Add New Card',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card type selector
              Row(
                children: ['Visa', 'Mastercard', 'Amex'].map((t) {
                  final sel = cardType == t;
                  return GestureDetector(
                    onTap: () => setLocal(() => cardType = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? _kAccent
                            : _kAccent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel
                                ? _kAccent
                                : _kAccent.withOpacity(0.2)),
                      ),
                      child: Text(t,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : _kAccent,
                          )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              _sheetField(numberCtrl, 'Card Number',
                  Icons.credit_card_outlined,
                  keyboard: TextInputType.number),
              const SizedBox(height: 14),
              _sheetField(nameCtrl, 'Cardholder Name',
                  Icons.person_outline),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _sheetField(expiryCtrl, 'MM / YY',
                        Icons.calendar_today_outlined,
                        keyboard: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _sheetField(cvvCtrl, 'CVV',
                        Icons.lock_outline,
                        keyboard: TextInputType.number,
                        obscure: true),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _sheetButton('Add Card', () {
                if (numberCtrl.text.length >= 4) {
                  setState(() {
                    _cards.add({
                      'type' : cardType,
                      'last4': numberCtrl.text.length >= 4
                          ? numberCtrl.text
                          .substring(numberCtrl.text.length - 4)
                          : '????',
                      'color': _kAccent,
                    });
                  });
                }
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Theme Sheet ─────────────────────────────────────────────────────────────
  void _showThemeSheet(BuildContext context) {
    final themes = [
      {'name': 'Navy Blue',    'color': _kNavy},
      {'name': 'Deep Purple',  'color': _kAccent},
      {'name': 'Midnight',     'color': const Color(0xFF0A0A14)},
      {'name': 'Ocean',        'color': const Color(0xFF0077B6)},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _sheet(
        title: 'Choose Theme',
        child: Column(
          children: themes.map((t) {
            final selected = _selectedTheme == t['name'];
            return GestureDetector(
              onTap: () {
                setState(() => _selectedTheme = t['name'] as String);
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? _kAccent.withOpacity(0.08)
                      : _kSilver,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? _kAccent : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: t['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(t['name'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected ? _kAccent : _kText,
                        )),
                    const Spacer(),
                    if (selected)
                      const Icon(Icons.check_circle,
                          color: _kAccent, size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Logout dialog ───────────────────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: _kText)),
        content: const Text(
            'Are you sure you want to log out of SmartPay?',
            style: TextStyle(color: _kMuted, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: _kMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              // TODO: clear session and navigate to login
              Navigator.pushNamedAndRemoveUntil(
                  context, '/', (route) => false);
            },
            child: const Text('Log Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Delete Account Sheet ────────────────────────────────────────────────────
  void _showDeleteAccountSheet(BuildContext context) {
    String? selectedReason;
    final reasons = [
      'I no longer use this app',
      'Privacy concerns',
      'Too many notifications',
      'Switching to another app',
      'Technical issues',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => _sheet(
          title: 'Delete Account',
          titleColor: _kDanger,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kDanger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: _kDanger, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will permanently delete all your data, groups, and transaction history.',
                        style: TextStyle(
                            fontSize: 12,
                            color: _kDanger,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text('Why are you leaving?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  )),
              const SizedBox(height: 10),
              ...reasons.map((r) {
                final sel = selectedReason == r;
                return GestureDetector(
                  onTap: () => setLocal(() => selectedReason = r),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: sel
                          ? _kDanger.withOpacity(0.08)
                          : _kSilver,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? _kDanger : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(r,
                              style: TextStyle(
                                fontSize: 13,
                                color: sel ? _kDanger : _kText,
                                fontWeight: sel
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              )),
                        ),
                        if (sel)
                          const Icon(Icons.check_circle,
                              color: _kDanger, size: 16),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedReason != null
                        ? _kDanger
                        : _kDanger.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: selectedReason != null
                      ? () {
                    Navigator.pop(context);
                    // TODO: call delete account API
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  }
                      : null,
                  child: const Text('Permanently Delete Account',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sheet wrapper ───────────────────────────────────────────────────────────
  Widget _sheet({
    required String title,
    required Widget child,
    Color titleColor = _kText,
  }) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: _kSilver,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: titleColor,
              )),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _sheetField(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        TextInputType keyboard = TextInputType.text,
        bool obscure = false,
      }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14, color: _kText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _kMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: _kAccent, size: 18),
        filled: true,
        fillColor: _kSilver,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _sheetButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kAccent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            )),
      ),
    );
  }
}