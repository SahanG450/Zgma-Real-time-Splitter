import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './Classes/addBill.dart';
import './Classes/session.dart';
import './Classes/abstract/addBill.dart';
import './controllers/addBill.dart';
import './controllers/group_controller.dart';
import './sessionSummery.dart';

// ─── Theme Colors — matching home.dart exactly ────────────────────────────────
const kBgPage     = Color(0xFFF0F2F8);   // same as Scaffold bg in home
const kBgCard     = Colors.white;
const kBgField    = Color(0xFFF5F6FA);
const kHeaderFrom = Color(0xFF0B0B55);   // gradient start
const kHeaderTo   = Color(0xFF3B3783);   // gradient end
const kAccent     = Color(0xFF5E5CE6);   // primary purple
const kGreen      = Color(0xFF1DB97B);
const kRed        = Color(0xFFFF6B6B);
const kYellow     = Color(0xFFE8D70B);
const kTextPrim   = Color(0xFF1A1A2E);
const kTextSec    = Color(0xFF9E9E9E);
const kBorder     = Color(0xFFF0F0F0);
const kBorderFocus= Color(0xFF5E5CE6);

// UI-level split selector (kept separate from the domain `SplitType`
// abstract class in Classes/abstract/addBill.dart, which is a strategy
// interface, not an enum).
enum BillSplitType { equal, amount, percentage, shares }

class PastBill {
  final String id, title, group, category, status;
  final int amountCents;
  final DateTime date;
  const PastBill({
    required this.id, required this.title, required this.group,
    required this.amountCents, required this.category,
    required this.date, required this.status,
  });
}

// ─── Add Bill Page ────────────────────────────────────────────────────────────
class AddBillPage extends StatefulWidget {
  const AddBillPage({super.key});

  @override
  State<AddBillPage> createState() => _AddBillPageState();
}

class _AddBillPageState extends State<AddBillPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedTab = 2; // "Add Bill" is index 2

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'icon': Icons.home_outlined,           'label': 'Home'},
      {'icon': Icons.swap_horiz_outlined,     'label': 'Debts'},
      {'icon': Icons.receipt_long_outlined,   'label': 'Add Bill'},
      {'icon': Icons.notifications_outlined,  'label': 'Alerts'},
      {'icon': Icons.person_outline,          'label': 'Profile'},
    ];

    return Scaffold(
      backgroundColor: kBgPage,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _ManualBillTab(),
                    _ScanBillTab(),
                    _ScheduleBillTab(),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomNav(tabs),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kHeaderFrom, kHeaderTo],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
          child: Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Bill',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      )),
                  SizedBox(height: 2),
                  Text('Create and split a bill',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      )),
                ],
              ),
              const Spacer(),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.history_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: kBgPage,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          labelColor: Colors.white,
          unselectedLabelColor: kTextSec,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Manual'),
            Tab(text: 'Scan'),
            Tab(text: 'Schedule'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(List<Map<String, dynamic>> tabs) {
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
              final isActive = _selectedTab == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedTab = i);
                    switch (tabs[i]['label']) {
                      case 'Home':
                        Navigator.pushReplacementNamed(context, '/home');
                        break;
                      case 'Debts':
                        Navigator.pushReplacementNamed(context, '/debts');
                        break;
                      case 'Add Bill':
                        break;
                      case 'Alerts':
                        Navigator.pushReplacementNamed(context, '/notifications');
                        break;
                      case 'Profile':
                        Navigator.pushReplacementNamed(context, '/profile');
                        break;
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(tabs[i]['icon'] as IconData,
                          size: 22,
                          color: isActive ? kAccent : const Color(0xFFBBBBBB)),
                      const SizedBox(height: 4),
                      Text(tabs[i]['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? kAccent : const Color(0xFFBBBBBB),
                          )),
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

// ─────────────────────────────────────────────────────────────────────────────
//  TAB 1 — MANUAL BILL
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
//  TAB 1 — MANUAL BILL
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
//  TAB 1 — MANUAL BILL
// ─────────────────────────────────────────────────────────────────────────────
class _ManualBillTab extends StatefulWidget {
  const _ManualBillTab();
  @override
  State<_ManualBillTab> createState() => _ManualBillTabState();
}

class _ManualBillTabState extends State<_ManualBillTab> {
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl   = TextEditingController();

  String?       _selectedGroup;
  String        _category  = 'food';
  BillSplitType _splitType = BillSplitType.equal;
  DateTime      _billDate  = DateTime.now();
  bool          _isSubmitting = false;

  static const tempuserid = "2d45d11c-eddf-4a9c-b70e-0ac23bcc3a54";
  List<String> _groups = [];

  @override
  void initState() {
    super.initState();
    print("DEBUG: _ManualBillTab initState");
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    print("DEBUG: _loadGroups UI triggered");
    try {
      final groups = await getGroups(tempuserid);
      print("DEBUG: _loadGroups UI success: Found ${groups.length} groups");
      if (mounted) {
        setState(() {
          _groups = groups;
        });
      }
    } catch (e) {
      print("DEBUG: _loadGroups UI error: $e");
    }
  }

  static const _categories = [
    ('food',      '🍽️', 'Food'),
    ('transport', '🚗', 'Transport'),
    ('groceries', '🛒', 'Groceries'),
    ('hotel',     '🏨', 'Hotel'),
    ('fun',       '🎉', 'Entertainment'),
    ('other',     '📦', 'Other'),
  ];

  Category _categoryFromKey(String key) {
    switch (key) {
      case 'food':       return Category.food;
      case 'transport':  return Category.transport;
      case 'groceries':  return Category.groceries;
      case 'hotel':      return Category.hotel;
      case 'fun':        return Category.entertainment;
      case 'other':
      default:           return Category.other;
    }
  }

  SplitType _resolveSplitType(BillSplitType type) {
    switch (type) {
      case BillSplitType.equal:
        return EqualSplit();
      case BillSplitType.amount:
        return AmountSplit();
      case BillSplitType.percentage:
        return PercentageSplit({});
      case BillSplitType.shares:
        return SharesSplit({});
    }
  }

  // API POINT: POST /api/session/create
  Future<void> _submitBill() async {
    if (_selectedGroup == null) {
      _showSnack('Please select a group', isError: true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final bill = ManualBill(
      title: _titleCtrl.text.trim(),
      sessionType: "manual",
      totalAmount: double.parse(_amountCtrl.text),
      groupId: _selectedGroup!,
      category: _categoryFromKey(_category),
      splitType: _resolveSplitType(_splitType),
      participants: const [],
      billDate: _billDate,
      description: _descCtrl.text.trim(),
    );

    try {
      bill.validate();
    } catch (e) {
      _showSnack(e.toString(), isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await createBill(bill);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SessionSummaryPage(result: result)),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: isError ? kRed : kGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
    ));
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _amountCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel('Bill title'),
            _StyledField(
              controller: _titleCtrl,
              hint: 'e.g. Dinner at Ministry of Crab',
              validator: (v) => (v == null || v.isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 14),

            _FieldLabel('Total amount'),
            _AmountField(controller: _amountCtrl),
            const SizedBox(height: 14),

            _FieldLabel('Group'),
            _GroupDropdown(
              groups: _groups,
              selected: _selectedGroup,
              onChanged: (v) => setState(() => _selectedGroup = v),
              onRefresh: _loadGroups,
            ),
            const SizedBox(height: 10),

            _FieldLabel('Category'),
            _CategoryGrid(
              categories: _categories,
              selected: _category,
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 10),

            _FieldLabel('Split type'),
            _SplitTypeRow(
              selected: _splitType,
              onChanged: (v) => setState(() => _splitType = v),
            ),
            const SizedBox(height: 14),

            _FieldLabel('Bill date'),
            _DatePickerRow(
              date: _billDate,
              onChanged: (d) => setState(() => _billDate = d),
            ),
            const SizedBox(height: 14),

            _FieldLabel('Description (optional)'),
            _StyledField(
              controller: _descCtrl,
              hint: 'Add a note…',
              maxLines: 3,
            ),
            const SizedBox(height: 22),

            _PrimaryButton(
              label: _isSubmitting ? 'Creating bill…' : 'Add Bill & Generate QR',
              icon: Icons.qr_code_rounded,
              onTap: _isSubmitting ? null : _submitBill,
            ),

            const SizedBox(height: 28),
            const _PastBillsSection(),
          ],
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
//  TAB 2 — SCAN BILL
// ─────────────────────────────────────────────────────────────────────────────
class _ScanBillTab extends StatefulWidget {
  const _ScanBillTab();
  @override
  State<_ScanBillTab> createState() => _ScanBillTabState();
}

class _ScanBillTabState extends State<_ScanBillTab> {
  bool _scanning = false;
  bool _scanned  = false;

  // API POINT: POST /api/v1/ocr/scan  (multipart image)
  // Returns: { success, data: { title, total_amount, items[], provider_id? } }
  void _startScan() {
    setState(() { _scanning = true; _scanned = false; });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() { _scanning = false; _scanned = true; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        children: [
          GestureDetector(
            onTap: _scanning ? null : _startScan,
            child: Container(
              height: 210,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _scanning ? kAccent : kBorder,
                  width: _scanning ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12, offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _scanning
                  ? _ScanAnimation()
                  : _scanned
                  ? _ScannedPreview()
                  : _ScanPlaceholder(),
            ),
          ),
          const SizedBox(height: 14),

          if (!_scanned)
            _PrimaryButton(
              label: _scanning ? 'Scanning…' : 'Open Camera / Upload Receipt',
              icon: _scanning ? Icons.crop_free_rounded : Icons.camera_alt_rounded,
              onTap: _scanning ? null : _startScan,
            ),

          if (_scanned) ...[
            const SizedBox(height: 6),
            _ScannedBillForm(),
          ],

          const SizedBox(height: 28),
          const _PastBillsSection(),
        ],
      ),
    );
  }
}

class _ScanPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: kAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.document_scanner_rounded, color: kAccent, size: 30),
        ),
        const SizedBox(height: 14),
        const Text('Tap to scan a receipt',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextPrim)),
        const SizedBox(height: 5),
        const Text('Uses OCR to auto-fill bill details',
            style: TextStyle(fontSize: 12, color: kTextSec)),
      ],
    );
  }
}

class _ScanAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(kAccent), strokeWidth: 2.5),
        const SizedBox(height: 16),
        const Text('Scanning receipt…',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kAccent)),
        const SizedBox(height: 6),
        Text('POST /api/v1/ocr/scan',
            style: TextStyle(color: kTextSec.withOpacity(0.7), fontSize: 11,
                fontFamily: 'monospace')),
      ],
    );
  }
}

class _ScannedPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: kGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.check_rounded, color: kGreen, size: 26),
        ),
        const SizedBox(height: 12),
        const Text('Receipt scanned',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kGreen)),
        const SizedBox(height: 4),
        const Text('Review and confirm details below',
            style: TextStyle(fontSize: 12, color: kTextSec)),
      ],
    );
  }
}

class _ScannedBillForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBanner(
          'OCR filled the form — review before submitting.',
          icon: Icons.auto_fix_high_rounded,
          color: kAccent,
        ),
        const SizedBox(height: 14),
        _FieldLabel('Bill title'),
        _StyledField(initialValue: 'Ministry of Crab — Table 4', hint: ''),
        const SizedBox(height: 12),
        _FieldLabel('Total amount'),
        _StyledField(initialValue: '18400', hint: '',
            keyboardType: TextInputType.number),
        const SizedBox(height: 18),
        // API POINT: POST /api/v1/bills
        _PrimaryButton(
          label: 'Confirm & Add Bill',
          icon: Icons.check_circle_outline_rounded,
          onTap: () {},
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TAB 3 — SCHEDULE BILL
// ─────────────────────────────────────────────────────────────────────────────
class _ScheduleBillTab extends StatefulWidget {
  const _ScheduleBillTab();
  @override
  State<_ScheduleBillTab> createState() => _ScheduleBillTabState();
}

class _ScheduleBillTabState extends State<_ScheduleBillTab> {
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _recurrence = 'monthly';
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));

  static const _recurrences = [
    ('daily', 'Daily'), ('weekly', 'Weekly'),
    ('monthly', 'Monthly'), ('yearly', 'Yearly'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose(); _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoBanner(
            'Scheduled bills auto-create on the set date and notify all members.',
            icon: Icons.info_outline_rounded,
            color: const Color(0xFFE8A20B),
          ),
          const SizedBox(height: 18),

          _FieldLabel('Bill title'),
          _StyledField(
            controller: _titleCtrl,
            hint: 'e.g. Monthly Netflix split',
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 14),

          _FieldLabel('Amount (LKR)'),
          _AmountField(controller: _amountCtrl),
          const SizedBox(height: 14),

          _FieldLabel('Recurrence'),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _recurrences.map((r) {
              final sel = _recurrence == r.$1;
              return GestureDetector(
                onTap: () => setState(() => _recurrence = r.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? kAccent : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? kAccent : kBorder),
                    boxShadow: sel ? [] : [
                      BoxShadow(color: Colors.black.withOpacity(0.04),
                          blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text(r.$2,
                      style: TextStyle(
                        color: sel ? Colors.white : kTextSec,
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                      )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          _FieldLabel('Start date'),
          _DatePickerRow(
            date: _startDate,
            onChanged: (d) => setState(() => _startDate = d),
          ),
          const SizedBox(height: 22),

          // API POINT: POST /api/v1/bills/schedule
          _PrimaryButton(
            label: 'Schedule Bill',
            icon: Icons.schedule_rounded,
            onTap: () {},
          ),

          const SizedBox(height: 28),
          const _PastBillsSection(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text,
          style: const TextStyle(
              color: kTextPrim, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _StyledField({
    this.controller, this.initialValue,
    required this.hint, this.maxLines = 1,
    this.keyboardType = TextInputType.text, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: kTextPrim, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextSec, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorderFocus, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kRed)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  const _AmountField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
      style: const TextStyle(color: kTextPrim, fontSize: 20, fontWeight: FontWeight.w700),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Amount is required';
        final a = double.tryParse(v);
        if (a == null || a <= 0) return 'Enter a valid amount';
        return null;
      },
      decoration: InputDecoration(
        prefixText: 'LKR  ',
        prefixStyle: const TextStyle(color: kTextSec, fontSize: 15, fontWeight: FontWeight.w500),
        hintText: '0.00',
        hintStyle: const TextStyle(color: kTextSec, fontSize: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorderFocus, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kRed)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      ),
    );
  }
}

class _GroupDropdown extends StatelessWidget {
  final List<String> groups;
  final String? selected;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRefresh;

  const _GroupDropdown({
    required this.groups,
    required this.selected,
    required this.onChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: Text(groups.isEmpty ? 'Tap to load groups...' : 'Select a group',
              style: const TextStyle(color: kTextSec, fontSize: 14)),
          onTap: () {
            if (groups.isEmpty) {
              print("DEBUG: Droown tapped while empty, calling onRefresh...");
              onRefresh();
            }
          },
          dropdownColor: Colors.white,
          iconEnabledColor: kTextSec,
          style: const TextStyle(color: kTextPrim, fontSize: 14),
          isExpanded: true,
          items: groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<(String, String, String)> categories;
  final String selected;
  final ValueChanged<String> onChanged;
  const _CategoryGrid({required this.categories, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8, crossAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: categories.map((cat) {
        final sel = selected == cat.$1;
        return GestureDetector(
          onTap: () => onChanged(cat.$1),
          child: Container(
            decoration: BoxDecoration(
              color: sel ? kAccent.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? kAccent : kBorder),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04),
                    blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cat.$2, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text(cat.$3,
                    style: TextStyle(
                      color: sel ? kAccent : kTextSec,
                      fontSize: 11,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// FIXED — now uses BillSplitType (the UI enum) instead of SplitType
// (the abstract strategy class from Classes/abstract/addBill.dart, which
// has no `.values` because it is not an enum).
class _SplitTypeRow extends StatelessWidget {
  final BillSplitType selected;
  final ValueChanged<BillSplitType> onChanged;
  const _SplitTypeRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: BillSplitType.values.map((t) {
        final sel = selected == t;
        final label = t.name[0].toUpperCase() + t.name.substring(1);
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(t),
            child: Container(
              margin: EdgeInsets.only(
                right: t != BillSplitType.values.last ? 6 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? kAccent : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? kAccent : kBorder),
                boxShadow: sel ? [] : [
                  BoxShadow(color: Colors.black.withOpacity(0.04),
                      blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              alignment: Alignment.center,
              child: Text(label,
                  style: TextStyle(
                    color: sel ? Colors.white : kTextSec,
                    fontSize: 11,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                  )),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  const _DatePickerRow({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${date.day.toString().padLeft(2, '0')} / '
        '${date.month.toString().padLeft(2, '0')} / ${date.year}';

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (ctx, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: kAccent,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: kTextPrim,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: kAccent, size: 18),
            const SizedBox(width: 10),
            Text(formatted, style: const TextStyle(color: kTextPrim, fontSize: 14)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: kTextSec, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _PrimaryButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5E5CE6), Color(0xFF3B3783)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: kAccent.withOpacity(0.3),
                blurRadius: 12, offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrResultCard extends StatelessWidget {
  final String qrCode;
  const _QrResultCard({required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGreen.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: kGreen.withOpacity(0.08),
              blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: kGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_rounded, color: kGreen, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bill created',
                      style: TextStyle(color: kGreen, fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  Text('QR code ready to share',
                      style: TextStyle(color: kTextSec, fontSize: 11)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: kAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kAccent.withOpacity(0.2)),
                  ),
                  child: const Text('Share',
                      style: TextStyle(color: kAccent, fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Replace with QrImageView(data: qrCode, size: 130) from qr_flutter
          Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              color: kBgField,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_2_rounded, color: kAccent, size: 80),
                Text(qrCode, style: const TextStyle(color: kTextSec, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // API POINT: GET /api/v1/bills/{id}/qr
          Text('GET /api/v1/bills/{id}/qr',
              style: TextStyle(color: kTextSec.withOpacity(0.6),
                  fontSize: 10, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  const _InfoBanner(this.message, {required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(color: color, fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAST BILLS SECTION  — API POINT: GET /api/v1/bills?limit=10
// ─────────────────────────────────────────────────────────────────────────────
class _PastBillsSection extends StatelessWidget {
  static final _bills = [
    PastBill(id: 'b1', title: 'Dinner at Ministry of Crab',
        group: 'Ministry of Crab', amountCents: 1840000,
        category: 'food', date: DateTime(2026, 6, 22), status: 'active'),
    PastBill(id: 'b2', title: 'PickMe — Colombo → Galle',
        group: 'PickMe to Galle', amountCents: 620000,
        category: 'transport', date: DateTime(2026, 6, 18), status: 'active'),
    PastBill(id: 'b3', title: 'Beach Villa groceries',
        group: 'Beach Villa', amountCents: 480000,
        category: 'groceries', date: DateTime(2026, 6, 15), status: 'settled'),
    PastBill(id: 'b4', title: 'Airbnb — Mirissa stay',
        group: 'Beach Villa', amountCents: 3200000,
        category: 'hotel', date: DateTime(2026, 6, 10), status: 'settled'),
  ];

  const _PastBillsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Past Bills',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                    color: kTextPrim, letterSpacing: -0.3)),
            // API POINT: GET /api/v1/bills?limit=50
            GestureDetector(
              onTap: () {},
              child: const Row(
                children: [
                  Text('See all',
                      style: TextStyle(fontSize: 13, color: kAccent,
                          fontWeight: FontWeight.w600)),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded, size: 11, color: kAccent),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_bills.length, (i) => Padding(
          padding: EdgeInsets.only(bottom: i < _bills.length - 1 ? 10 : 0),
          child: _PastBillCard(bill: _bills[i]),
        )),
      ],
    );
  }
}

class _PastBillCard extends StatelessWidget {
  final PastBill bill;
  const _PastBillCard({required this.bill});

  static const _catData = {
    'food':      ('🍽️', Color(0xFF5E5CE6)),
    'transport': ('🚗', Color(0xFF5E5CE6)),
    'groceries': ('🛒', Color(0xFF1DB97B)),
    'hotel':     ('🏨', Color(0xFFE8A20B)),
    'fun':       ('🎉', Color(0xFF9B59B6)),
    'other':     ('📦', Color(0xFF9E9E9E)),
  };

  String _fmtAmount(int cents) {
    final lkr = cents / 100;
    return lkr >= 1000
        ? 'LKR ${(lkr / 1000).toStringAsFixed(1)}k'
        : 'LKR ${lkr.toStringAsFixed(0)}';
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final cat = _catData[bill.category] ?? ('📦', const Color(0xFF9E9E9E));
    final isSettled = bill.status == 'settled';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: cat.$2.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Text(cat.$1, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w600, color: kTextPrim)),
                const SizedBox(height: 3),
                Text('${bill.group}  ·  ${_fmtDate(bill.date)}',
                    style: const TextStyle(fontSize: 12, color: kTextSec)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_fmtAmount(bill.amountCents),
                  style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w700, color: kTextPrim)),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSettled
                      ? const Color(0xFF9E9E9E).withOpacity(0.1)
                      : kGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(bill.status,
                    style: TextStyle(
                      color: isSettled ? kTextSec : kGreen,
                      fontSize: 10, fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Entry point ─────────────────────────────────────────────────────────────
void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: AddBillPage(),
));