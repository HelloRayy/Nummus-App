# Design System v2 — Jajan Tracker

> **Catatan**: Dokumen ini adalah single source of truth untuk seluruh token visual, tipografi, surface, dan komponen UI pada update major **v2.0** (Dark-first Fintech Bento). Light mode akan ditambahkan pada **v2.1**.

---

## 1. Color Tokens

### Surfaces & Borders (Dark-First)
- `bgPrimary`: `#0B0C0E` — Background utama layar.
- `surfaceCard`: `#141619` — Background card bento, container list, dan navbar pill.
- `surfaceElevated`: `#1B1E23` — Background elemen aktif (tab aktif, tombol sekunder, dropdown).
- `borderSubtle`: `#24272E` — Hairline border `1px` untuk memisahkan card tanpa drop-shadow berat.

### Accents & Semantics
- `accentPrimary`: `#6E5CF6` — Indigo/Violet untuk greeting highlight, bar chart, dan metrik kredit.
- `semanticPositive`: `#28A774` — Emerald untuk saldo tersedia, tren positif, dan income gauge.
- `semanticWarning`: `#D97736` — Amber-Orange untuk pengeluaran, spending limit, dan alert.
- `semanticDanger`: `#E5484D` — Merah untuk error atau over-budget.

### Text
- `textPrimary`: `#F4F4F5` — Nominal uang, judul card, dan teks utama.
- `textSecondary`: `#A1A1AA` — Subjudul dan deskripsi singkat.
- `textMuted`: `#71717A` — Label kategori, timestamp, dan axis chart.

---

## 2. Typography

- **Font Family**: `Inter` (via `google_fonts` atau bundled asset).
- **Numeric Alignment**: Wajib aktifkan `FontFeature.tabularFigures()` (`tabular-nums`) pada seluruh nominal uang, persentase, dan angka metrik agar sejajar vertikal.

### Type Scale
- `displayBalance`: `28sp`, `FontWeight.w600`, letter-spacing `-0.5`
- `headlineGreeting`: `22sp`, `FontWeight.w500`, letter-spacing `-0.3`
- `cardTitle`: `15sp`, `FontWeight.w600`
- `metricValue`: `20sp`, `FontWeight.w600` (`tabular-nums`)
- `bodyRegular`: `14sp`, `FontWeight.w400`
- `labelMuted`: `12sp`, `FontWeight.w500`

---

## 3. Spacing, Radius & Elevation

- **Base Grid**: `4px` (`4, 8, 12, 16, 20, 24, 32`).
- **Screen Padding**: `16px` horizontal.
- **Bento Grid Gap**: `12px` antar card.
- **Border Radius**:
  - `radiusCard`: `18px`
  - `radiusPill`: `999px` (tab aktif, badge, floating navbar)
  - `radiusButton`: `12px`
- **Elevation**: `0` (flat). Kedalaman hanya dibentuk dari kontras `surfaceCard` terhadap `bgPrimary` + `1px` `borderSubtle`.

---

## 4. Core Components (v2)

1. **Bento Metric Card**: Container `surfaceCard`, `1px` `borderSubtle`, radius `18px`, padding `16px`. Maksimal 3 elemen teks (Label, Nilai utama, Delta/Sub-info).
2. **Segmented Spending Bar**: Deretan bar vertikal kecil dengan gradasi `semanticPositive` ke `semanticWarning` dan thumb indikator putih di posisi rasio pengeluaran saat ini.
3. **Charts (`fl_chart`)**: Bar chart dengan sudut atas membulat (`6px`) dan semi-circle donut gauge untuk breakdown kategori.
4. **Interactive Affordance**: Setiap elemen yang bisa di-tap wajib memiliki feedback visual (`InkWell` / `AnimatedScale`) dan min touch target `44x44dp`.
