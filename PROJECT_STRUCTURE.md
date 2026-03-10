# Struktur Proyek TelurKu

## Overview
Proyek ini adalah aplikasi Flutter untuk mengelola peternakan ayam dengan fitur:
- Landing Page
- Autentikasi (Sign Up, Login)
- Firebase Integration
- Bottom Navigation untuk navigasi antar halaman

## Struktur Folder

```
lib/
├── main.dart                    # Entry point aplikasi
├── firebase_options.dart        # Firebase configuration
├── providers/
│   └── auth_provider.dart       # State management untuk Auth
├── screens/
│   ├── landing_page.dart        # Landing page
│   ├── login_page.dart          # Halaman login
│   ├── signup_page.dart         # Halaman registrasi
│   └── (halaman lain akan ditambahkan)
├── models/
│   └── (Model data akan ditambahkan)
├── services/
│   └── (Service untuk API/Database akan ditambahkan)
└── utils/
    └── (Utility dan helper functions)

assets/
├── images/
│   └── logo.png                 # Logo TelurKu (SIAPKAN INI)
└── icons/
    └── (Icon-icon lainnya)
```

## File Penting

### `main.dart`
- Konfigurasi Firebase
- Setup Provider untuk state management
- Routing aplikasi
- Auth wrapper untuk menentukan halaman pertama

### `firebase_options.dart`
- Konfigurasi Firebase untuk setiap platform
- **HARUS DIUPDATE dengan data dari Firebase Console**

### `providers/auth_provider.dart`
- Mengelola login, signup, logout
- Menyimpan state user
- Error handling

### `screens/landing_page.dart`
- Halaman pertama saat app dibuka
- Tombol "Masuk" dan "Daftar"

### `screens/login_page.dart`
- Form login dengan email + password
- Validation
- Error handling
- Link ke signup page

### `screens/signup_page.dart`
- Form registrasi: nama, email, password, konfirmasi password
- Checkbox terms & conditions
- Validation
- Link ke login page

## Cara Menggunakan

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Setup Firebase (Lihat FIREBASE_SETUP.md)
```bash
# Setelah setup Firebase
flutter run
```

### 3. Test Fitur
- Landing Page akan tampil pertama kali
- Klik "Masuk" untuk login page (test belum ada user)
- Klik "Daftar Akun Baru" untuk signup page
- Setelah signup berhasil, otomatis login
- Setelah login, akan diarahkan ke dashboard (Coming Soon)

## Next Steps

1. **Setup Firebase** sesuai FIREBASE_SETUP.md
2. **Siapkan Logo** di folder assets/images/logo.png
3. **Test Landing Page & Auth** 
4. **Buat Dashboard/Home Page**
5. **Tambah fitur lain** (Data panen, kondisi kandang, dll)

## Dependencies yang Ditambahkan

```yaml
dependencies:
  firebase_core: ^3.3.0           # Firebase core
  firebase_auth: ^5.1.4           # Firebase authentication
  cloud_firestore: ^5.1.0         # Firebase database
  provider: ^6.1.0                # State management
  google_fonts: ^6.2.1            # Google fonts
```

## Color Scheme

- Primary: `#F4D03F` (Kuning - TelurKu brand)
- Secondary: Orange shade
- Background: Gradient (Orange → Amber → Green)
- Text: Grey variations

## Asset Configuration

Pastikan file berikut sudah ada:
- `assets/images/logo.png` - Logo TelurKu (150x150px recommended)
- Folder `assets/icons/` untuk icon tambahan

## Tips Development

1. **Hot Reload**: Tekan `r` di terminal untuk hot reload (ganti code)
2. **Hot Restart**: Tekan `R` di terminal untuk hot restart (reset state)
3. **Debug Mode**: Check error di bawah code di VSCode
4. **Firebase Console**: Monitor user, database dari web

## Environment Requirements

- Flutter SDK: ^3.10.7
- Dart: ^3.10.7
- Android SDK (untuk Android)
- Xcode (untuk iOS)
- Firebase Project sudah dibuat

## Troubleshooting

### Aplikasi Error saat Run
1. Jalankan `flutter clean`
2. Jalankan `flutter pub get`
3. Jalankan `flutter run`

### Firebase Error
1. Pastikan `firebase_options.dart` sudah di-update
2. Pastikan `google-services.json` ada di `android/app/`
3. Pastikan `GoogleService-Info.plist` ada di iOS

### Assets Not Found
1. Pastikan folder `assets/images/` sudah ada
2. Pastikan file ada di folder tersebut
3. Restart aplikasi setelah menambah file baru

## Support & Documentation

- [Flutter Documentation](https://flutter.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
