# Panduan Codebase untuk AI Agent (`CODEBASE_GUIDE.md`)

Dokumen ini adalah peta cepat agar AI agent dapat memahami arsitektur, alur data, dan lokasi kode tanpa menebak-nebak.

---

## 1. Peta Direktori Utama

- `lib/core/`
  - `constants/ui_keys.dart`: Semua `ValueKey` untuk widget interaktif dan pengujian (`UIKeys.<nama>`).
  - `database/`: Layer persistensi SQLite lokal (`DatabaseHelper`).
  - `services/native_bridge.dart`: Jembatan `MethodChannel` ke Android Native (notifikasi, floating bubble, widget).
  - `theme/` & `utils/`: Tema aplikasi dan formatter mata uang (`CurrencyFormatter`).
- `lib/features/`
  - `budget/`: Model (`budget_model.dart`, `expense_model.dart`, `pending_transaction_model.dart`) dan state utama (`repository/budget_repository.dart`).
  - `v2_sandbox/`: UI dan alur redesain V2 (`v2_dashboard_screen.dart`, `v2_add_budget_screen.dart`, `v2_numpad_screen.dart`, `v2_budget_planner_screen.dart`).
  - `dashboard/`, `quick_log/`, `rekap/`, `categories/`, `expense_catalog/`, `settings/`: Layar dan widget V1 serta fitur pendukung.
- `android/app/src/main/kotlin/com/hellorayy/jajan_tracker/`
  - `MainActivity.kt`: Handler `MethodChannel` dari Flutter.
  - `JajanNotificationListenerService.kt`: Menangkap notifikasi transaksi masuk/keluar untuk dicatat sebagai pending transaction.
  - `FloatingBubbleService.kt`: Overlay bubble untuk quick-log.
  - `JajanWidget4x2Provider.kt` & `JajanQuickTileService.kt`: Home widget dan Quick Settings tile.
  - *Catatan*: `ShopeeAccessibilityService` (pembacaan layar otomatis saat membuka app e-wallet) sudah dihapus.

---

## 2. Alur Data & State Utama

`BudgetRepository` (`ChangeNotifier`) adalah single source of truth untuk seluruh state keuangan:

1. **Sumber Saldo & Budget**:
   - `ewalletBalance`: `initialEwallet + ewalletIncome - ewalletSpent`
   - `cashBalance`: `initialCash + cashIncome - cashSpent`
   - `remainingWeeklySpendable`: Sisa budget mingguan yang bisa dibelanjakan (memperhitungkan target tabungan).
2. **Penyesuaian Saldo (Adjust)**:
   - **V2 (`v2_add_budget_screen.dart`)**: Memanggil `adjustSpendableBudget(targetAmount)` agar `remainingWeeklySpendable` langsung disamakan ke angka input user dengan mencatat selisihnya saja.
   - **V1 (`balance_adjustment_sheet.dart`)**: Memanggil `adjustRealBalance(actualBalance: ...)` untuk menyamakan saldo e-wallet/tunai.
3. **Persistensi**:
   - Mobile menggunakan SQLite (`DatabaseHelper`), sedangkan Web menggunakan state in-memory + `SharedPreferences`.

---

## 3. Aturan Penting saat Mengubah Kode

- **Cek `UI_MAP.md` lebih dulu** sebelum mengedit komponen visual atau layout.
- **Test Mock Compatibility**: Banyak file di `test/` mengimplementasikan `BudgetRepository` secara langsung (`implements BudgetRepository`). Jika menambah method baru di `BudgetRepository`, wajib tambahkan stub-nya di file test terkait.
- **Verifikasi Wajib**:
  - Jalankan `flutter analyze` untuk memastikan tidak ada error tipe atau import.
  - Jalankan `flutter test` untuk memastikan seluruh 112+ unit & widget test lulus.
