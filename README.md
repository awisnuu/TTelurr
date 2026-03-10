# TelurKu

Aplikasi Flutter untuk manajemen peternakan ayam petelur dengan sistem panen otomatis.

## Fitur Utama

- 🔐 Authentication (Login/Signup dengan Firebase)
- 📊 Dashboard monitoring real-time
- 🏠 Manajemen Kandang
- 📅 Penjadwalan Panen Otomatis (Pagi 09:00 & Sore 15:00)
- 📈 Riwayat Panen dengan filter tanggal
- 🐛 Debug Screen untuk testing scheduler
- 🔄 Real-time sensor monitoring (infra1, infra2)

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase account
- Android Studio / VS Code

### Installation

1. Clone repository:
```bash
git clone https://github.com/awisnuu/TTelurr.git
cd TTelurr
```

2. Install dependencies:
```bash
flutter pub get
```

3. Setup Firebase:
   - Lihat file `FIREBASE_SETUP.md` untuk panduan lengkap
   - Update `lib/firebase_options.dart` dengan konfigurasi project Anda

4. Run aplikasi:
```bash
flutter run
```

## Dokumentasi

- [QUICK_START.md](QUICK_START.md) - Panduan cepat memulai
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Setup Firebase
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - Struktur project
- [SCHEDULER_IMPLEMENTATION_GUIDE.md](SCHEDULER_IMPLEMENTATION_GUIDE.md) - Panduan scheduler

## Teknologi

- **Flutter** - Framework UI
- **Firebase Authentication** - User authentication
- **Firebase Realtime Database** - Database real-time
- **Provider** - State management

## Debug Feature

Untuk testing panen scheduler:
1. Login ke aplikasi
2. Klik icon profile di kanan atas
3. Pilih "Debug Panen"
4. Test simpan panen pagi/sore secara manual

## License

This project is for educational purposes.
