import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Classes/session.dart';
import 'addBill.dart'
    show kBgPage, kHeaderFrom, kHeaderTo, kAccent, kGreen, kRed, kYellow, kTextPrim, kTextSec, kBorder;

class SessionSummaryPage extends StatelessWidget {
  final SessionCreateResult result;
  const SessionSummaryPage({super.key, required this.result});

  static const _catEmoji = {
    'food': '🍽️',
    'transport': '🚗',
    'groceries': '🛒',
    'hotel': '🏨',
    'entertainment': '🎉',
    'fun': '🎉',
    'other': '📦',
  };

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return kGreen;
      case 'CANCELLED':
        return kRed;
      case 'SETTLED':
        return kTextSec;
      default:
        return kYellow;
    }
  }

  String _fmtAmount(num amount) {
    final lkr = amount / 100; // stored as cents per project convention
    return 'LKR ${lkr.toStringAsFixed(2)}';
  }

  String _fmtDateTime(DateTime? d) {
    if (d == null) return '—';
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final local = d.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${m[local.month - 1]} ${local.year}, $hh:$mm';
  }

  String _label(String raw) => raw.isEmpty ? raw : raw[0].toUpperCase() + raw.substring(1);

  @override
  Widget build(BuildContext context) {
    final session = result.session;
    final qr = result.qr;
    final emoji = _catEmoji[session.category] ?? '📦';
    final statusColor = _statusColor(session.status);

    return Scaffold(
      backgroundColor: kBgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, session),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  children: [
                    _buildQrCard(qr, statusColor, session.status),
                    const SizedBox(height: 16),
                    _buildDetailsCard(session, emoji),
                    const SizedBox(height: 24),
                    _buildDoneButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SessionSummary session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kHeaderFrom, kHeaderTo],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bill Created',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700,
                        color: Colors.white, letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text(session.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard(QrData qr, Color statusColor, String status) {
    Uint8List? bytes;
    try {
      bytes = qr.imageBytes;
    } catch (_) {
      bytes = null;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status,
                style: TextStyle(color: statusColor, fontSize: 11,
                    fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ),
          const SizedBox(height: 16),
          Container(
            width: 200, height: 200,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(14),
            ),
            child: bytes != null
                ? Image.memory(bytes, fit: BoxFit.contain)
                : const Center(
              child: Icon(Icons.qr_code_2_rounded, size: 80, color: kTextSec),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Scan to join or pay this bill',
              style: TextStyle(fontSize: 12, color: kTextSec)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy Token',
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: qr.token));
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: () {
                    // TODO: wire up share_plus with the QR image / deep link
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: kAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kAccent.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: kAccent),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: kAccent, fontSize: 12.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(SessionSummary session, String emoji) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kTextPrim)),
                    Text(_label(session.category),
                        style: const TextStyle(fontSize: 12, color: kTextSec)),
                  ],
                ),
              ),
              Text(_fmtAmount(session.amount),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kTextPrim)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: kBorder),
          ),
          _detailRow('Split type', _label(session.splitType)),
          _detailRow('Session ID', session.id, mono: true, truncate: true),
          _detailRow('Group', session.groupId, mono: true, truncate: true),
          if (session.description != null && session.description!.isNotEmpty)
            _detailRow('Note', session.description!),
          _detailRow('Created', _fmtDateTime(session.createdAt)),
          _detailRow('Expires', _fmtDateTime(session.expiresAt)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool mono = false, bool truncate = false}) {
    final display = truncate && value.length > 14
        ? '${value.substring(0, 6)}…${value.substring(value.length - 4)}'
        : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 12.5, color: kTextSec)),
          ),
          Expanded(
            child: Text(display,
                style: TextStyle(
                  fontSize: 12.5,
                  color: kTextPrim,
                  fontWeight: FontWeight.w600,
                  fontFamily: mono ? 'monospace' : null,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
        ),
        alignment: Alignment.center,
        child: const Text('Done',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}