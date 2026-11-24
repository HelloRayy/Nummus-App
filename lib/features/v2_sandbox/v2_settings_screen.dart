import 'package:flutter/material.dart';
import '../../core/services/native_bridge.dart';
import '../../core/theme/v2_tokens.dart';
import '../budget/repository/budget_repository.dart';

class V2SettingsScreen extends StatefulWidget {
  final BudgetRepository repository;

  const V2SettingsScreen({super.key, required this.repository});

  @override
  State<V2SettingsScreen> createState() => _V2SettingsScreenState();
}

class _V2SettingsScreenState extends State<V2SettingsScreen>
    with WidgetsBindingObserver {
  final NativeBridge _bridge = NativeBridge.instance;

  bool _hasOverlayPermission = false;
  bool _isHudActive = false;
  bool _hasNotifListenerPermission = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStatus();
    }
  }

  Future<void> _refreshStatus() async {
    final overlay = await _bridge.checkOverlayPermission();
    final hudRunning = await _bridge.isFloatingBubbleRunning();
    final notifListener = await _bridge.checkNotificationListenerPermission();
    if (!mounted) return;
    setState(() {
      _hasOverlayPermission = overlay;
      _isHudActive = hudRunning;
      _hasNotifListenerPermission = notifListener;
      _loading = false;
    });
  }

  Future<void> _onToggleHud(bool value) async {
    if (value && !_hasOverlayPermission) {
      await _bridge.openOverlaySettings();
      return;
    }
    await _bridge.toggleFloatingBubble(value);
    await _refreshStatus();
  }

  Future<void> _confirmResetData() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: V2Colors.surfaceCard,
        title: const Text(
          'Reset Semua Data?',
          style: TextStyle(color: V2Colors.textPrimary),
        ),
        content: const Text(
          'Semua pengeluaran dan budget minggu ini akan di-reset ke Rp 0.',
          style: TextStyle(color: V2Colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: V2Colors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: V2Colors.semanticDanger,
            ),
            onPressed: () async {
              await widget.repository.resetAllExpenses();
              await widget.repository.updateBudget(
                weeklyIncome: 0,
                weeklySavingsTarget: 0,
              );
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: const Text('Reset ke 0'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      appBar: AppBar(
        backgroundColor: V2Colors.bgPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: V2Colors.textPrimary),
        title: const Text(
          'Pengaturan & HUD',
          style: TextStyle(
            color: V2Colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _buildGuideCard(),
                const SizedBox(height: 20),
                const Text(
                  'KONTROL HUD',
                  style: TextStyle(
                    color: V2Colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                _buildOptionCard(
                  title: 'Floating HUD Melingkar',
                  subtitle: _hasOverlayPermission
                      ? 'Tampilkan bola budget melayang dengan 4 tombol cepat di atas aplikasi lain.'
                      : 'Butuh izin "Tampilkan di atas aplikasi lain" terlebih dahulu.',
                  trailing: Switch(
                    value: _isHudActive,
                    onChanged: _onToggleHud,
                    activeThumbColor: V2Colors.accentPrimary,
                  ),
                  actionLabel:
                      _hasOverlayPermission ? null : 'Buka Izin Overlay',
                  onActionTap: _hasOverlayPermission
                      ? null
                      : () => _bridge.openOverlaySettings(),
                ),
                const SizedBox(height: 12),
                _buildOptionCard(
                  title: 'Sinkronisasi Notifikasi E-Wallet',
                  subtitle: _hasNotifListenerPermission
                      ? 'Aktif. Notifikasi pembayaran ShopeePay otomatis memotong limit HUD.'
                      : 'Aktifkan akses notifikasi agar transaksi e-wallet otomatis sinkron ke HUD.',
                  trailing: Icon(
                    _hasNotifListenerPermission
                        ? Icons.check_circle
                        : Icons.arrow_forward_ios,
                    color: _hasNotifListenerPermission
                        ? V2Colors.accentPrimary
                        : V2Colors.textSecondary,
                    size: _hasNotifListenerPermission ? 22 : 16,
                  ),
                  onTap: () => _bridge.openNotificationListenerSettings(),
                ),
                const SizedBox(height: 28),
                const Text(
                  'DATA',
                  style: TextStyle(
                    color: V2Colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                _buildOptionCard(
                  title: 'Reset Semua Data',
                  subtitle: 'Hapus semua transaksi dan reset budget minggu ini ke Rp 0.',
                  titleColor: V2Colors.semanticDanger,
                  trailing: const Icon(
                    Icons.delete_outline,
                    color: V2Colors.semanticDanger,
                  ),
                  onTap: _confirmResetData,
                ),
              ],
            ),
    );
  }

  Widget _buildGuideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: V2Colors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cara Aktifkan HUD di ShopeePay',
            style: TextStyle(
              color: V2Colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          _GuideStep(
            number: '1',
            text: 'Beri izin "Tampilkan di atas aplikasi lain" lalu nyalakan toggle Floating HUD Melingkar.',
          ),
          SizedBox(height: 6),
          _GuideStep(
            number: '2',
            text: 'Aktifkan Sinkronisasi Notifikasi E-Wallet supaya sisa limit HUD otomatis terpotong saat bayar.',
          ),
          SizedBox(height: 6),
          _GuideStep(
            number: '3',
            text: 'Tips: Matikan Battery Optimization untuk Jajan Tracker di pengaturan HP agar HUD tidak mati di background.',
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required Widget trailing,
    Color titleColor = V2Colors.textPrimary,
    String? actionLabel,
    VoidCallback? onActionTap,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: V2Colors.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: V2Colors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                trailing,
              ],
            ),
            if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onActionTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: V2Colors.accentPrimary,
                    side: const BorderSide(color: V2Colors.accentPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(actionLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String number;
  final String text;

  const _GuideStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number. ',
          style: const TextStyle(
            color: V2Colors.accentPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: V2Colors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
