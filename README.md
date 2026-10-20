<div align="center">

  <img src="assets/logo-hitam.png" alt="Fernche Logo" width="120" />

  # Fernche
  ### Financial Ledger & Repository Mobile App

  <p align="center">
    Aplikasi pencatatan keuangan pribadi, manajemen anggaran, dan arsip catatan finansial modern berbasis Flutter dengan fitur Android Home Screen Widget.
  </p>

  <p align="center">
    <img src="https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green" alt="Platform" />
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License" />
  </p>

</div>

---

## 📌 Tentang Fernche

**Fernche** (*Financial Ledger & Repository*) adalah aplikasi mobile personal finance all-in-one yang dirancang untuk membantu Anda memantau arus kas, mengatur anggaran belanja, menyimpan catatan/dokumen penting, dan menjaga kesehatan finansial sehari-hari secara offline dan aman.

Aplikasi ini mengusung pendekatan **Offline-First** menggunakan basis data lokal SQLite berkinerja tinggi, sehingga data Anda sepenuhnya privat dan dapat diakses kapan saja tanpa perlu koneksi internet.

---

## ✨ Fitur Unggulan

- 📊 **Dashboard & Visualisasi Finansial**:
  - Ringkasan total saldo, pemasukan, dan pengeluaran secara real-time.
  - Grafik tren dan distribusi pengeluaran interaktif menggunakan `fl_chart`.
  - Sistem pengingat & pemantauan batas anggaran (*Budget Tracking*).

- 💳 **Buku Kas & Pencatatan Transaksi (Ledger)**:
  - Input transaksi pemasukan dan pengeluaran cepat dan intuitif.
  - Kategorisasi transaksi dengan ikon dan tag warna.
  - Filter berdasarkan periode tanggal, jenis transaksi, dan kategori.

- 📁 **Repository & Catatan (Notes)**:
  - Ruang penyimpanan catatan transaksi, rencana belanja, atau pengingat keuangan.
  - Pencarian dan pengelompokan catatan dengan cepat.

- 📱 **Android Home Screen Widgets**:
  - **Quick Add Widget**: Tombol jalan pintas di layar utama ponsel untuk mencatat transaksi seketika.
  - **Monthly Summary Widget**: Memantau saldo dan ringkasan keuangan bulan berjalan tanpa membuka aplikasi.

- 📤 **Laporan & Ekspor Data**:
  - Ekspor seluruh laporan transaksi ke format spreadsheet Excel (`.xlsx`).
  - Fitur backup dan restore data lokal untuk keamanan jangka panjang.

- 🎨 **Desain Elegan & Responsif**:
  - Desain antarmuka modern dengan tipografi dari Google Fonts.
  - Dukungan tema Gelap (Dark Mode) dan Terang (Light Mode).

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: [Flutter](https://flutter.dev/) (Channel stable)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Storage**: [sqflite](https://pub.dev/packages/sqflite) & [path](https://pub.dev/packages/path)
- **Data Visualization**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Widgets**: [home_widget](https://pub.dev/packages/home_widget)
- **Export & Documents**: [excel](https://pub.dev/packages/excel), [share_plus](https://pub.dev/packages/share_plus), [path_provider](https://pub.dev/packages/path_provider)
- **Typography & UI**: [google_fonts](https://pub.dev/packages/google_fonts), [intl](https://pub.dev/packages/intl)

---

## 🚀 Panduan Memulai (Developer Setup)

### Prasyarat
- Flutter SDK (>= 3.11.4)
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Android SDK (API 34+)

### Instalasi & Menjalankan Aplikasi

1. **Clone repository:**
   ```bash
   git clone https://github.com/Ibnuwu/fernche.git
   cd fernche
   ```

2. **Unduh dependencies:**
   ```bash
   flutter pub get
   ```

3. **Jalankan pada perangkat emulator atau fisik:**
   ```bash
   flutter run
   ```

4. **Build APK Rilis:**
   ```bash
   flutter build apk --release
   ```
   File APK hasil kompilasi akan berada di direktori:
   `build/app/outputs/flutter-apk/app-release.apk`

---

## 📥 Unduh & Instalasi Aplikasi (User Guide)

1. Unduh file **`app-release.apk`** dari menu [Releases](https://github.com/Ibnuwu/fernche/releases).
2. Di perangkat Android Anda, buka file APK yang telah diunduh.
3. Izinkan opsi *"Install from unknown sources"* jika diminta oleh sistem Android.
4. Buka aplikasi **Fernche** dan mulai catat transaksi keuangan Anda!

---

## 📄 Lisensi

Project ini dilisensikan di bawah [MIT License](LICENSE).
