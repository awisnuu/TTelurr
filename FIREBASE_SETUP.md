# Setup Firebase untuk TelurKu

## Langkah-langkah Setup Firebase

### 1. Buat Proyek Firebase
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Create Project"
3. Masukkan nama proyek: `TelurKu`
4. Pilih lokasi yang sesuai
5. Tunggu proyek selesai dibuat

### 2. Setup Firebase untuk Android
1. Di Firebase Console, klik "Add App" → Android
2. Masukkan Package Name: `com.example.telurku`
3. Ikuti petunjuk untuk download `google-services.json`
4. Letakkan file di: `android/app/`
5. Firebase secara otomatis akan menambahkan config ke build.gradle

### 3. Setup Firebase untuk iOS
1. Di Firebase Console, klik "Add App" → iOS
2. Masukkan Bundle ID: `com.example.telurku`
3. Download `GoogleService-Info.plist`
4. Buka proyek Xcode: `ios/Runner.xcworkspace`
5. Drag & drop file `GoogleService-Info.plist` ke bagian "Runner" di Xcode
6. Pastikan "Copy items if needed" tercentang

### 4. Setup Firebase untuk Web
1. Di Firebase Console, klik "Add App" → Web
2. Salin konfigurasi Firebase yang diberikan

### 5. Update `firebase_options.dart`
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Buka Project Settings
3. Scroll ke bawah untuk melihat konfigurasi setiap platform
4. Update nilai-nilai di file `lib/firebase_options.dart` dengan data dari Firebase Console

Contoh isi firebase_options.dart:
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: '1:YOUR_PROJECT_ID:web:YOUR_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'telurku',
  authDomain: 'telurku.firebaseapp.com',
  storageBucket: 'telurku.appspot.com',
  measurementId: 'YOUR_MEASUREMENT_ID',
);
```

### 6. Enable Authentication Methods
1. Di Firebase Console, buka "Authentication"
2. Klik tab "Sign-in method"
3. Enable "Email/Password"
4. Save

### 7. Setup Firestore Database (Optional)
1. Di Firebase Console, buka "Firestore Database"
2. Klik "Create database"
3. Pilih "Start in test mode" (untuk development)
4. Pilih lokasi yang sesuai

### 8. Jalankan Proyek
```bash
flutter pub get
flutter run
```

## Struktur Folder Assets

Buat folder berikut di root proyek:
```
assets/
├── images/
│   ├── logo.png (logo TelurKu Anda)
│   └── background.png (opsional)
└── icons/
    └── (icon-icon lainnya)
```

## Testing

1. Test Landing Page: Buka aplikasi, seharusnya tampil landing page dengan tombol "Masuk" dan "Daftar"
2. Test Sign Up: Klik "Daftar Akun Baru", isi form, klik "Daftar"
3. Test Login: Klik "Masuk", isi email dan password yang sudah terdaftar, klik "Masuk"
4. Periksa Firebase Console → Authentication untuk melihat user yang terdaftar

## Troubleshooting

**Error: "Platform exception"**
- Pastikan Firebase sudah terkoneksi dengan benar
- Update google-services.json (Android) atau GoogleService-Info.plist (iOS)

**Error: "Invalid API key"**
- Pastikan nilai di firebase_options.dart sudah benar sesuai Firebase Console

**Error: "Assets not found"**
- Pastikan folder assets sudah dibuat
- Pastikan pubspec.yaml sudah dikonfigurasi untuk assets
