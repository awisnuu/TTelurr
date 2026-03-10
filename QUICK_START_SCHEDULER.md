# 🚀 QUICK START - Scheduler Otomatis Panen

## ⚡ Setup dalam 5 Langkah

### Step 1: Pastikan pubspec.yaml Updated ✅

Cek di `pubspec.yaml` sudah ada:
```yaml
dependencies:
  workmanager: ^0.5.1
```

Kalau belum, jalankan:
```bash
flutter pub add workmanager
```

### Step 2: Copy 3 File Service (SUDAH DONE)

✅ Sudah di `lib/services/`:
- `panen_scheduler.dart` ← Background task scheduler
- `panen_auto_capture_service.dart` ← Bridge ke provider

### Step 3: Update PanenProvider ✅ (SUDAH DONE)

✅ Sudah ada:
- Snapshot tracking properties
- `captureScheduledPanenPagi()` method
- `captureScheduledPanenSore()` method
- Firebase save & restore methods

### Step 4: Update main.dart ⏳ (KAMU SEKARANG)

**Edit `lib/main.dart` seperti ini:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// ✅ TAMBAH 2 IMPORT INI
import 'lib/services/panen_scheduler.dart';
import 'lib/services/panen_auto_capture_service.dart';

// Import provider & page lain seperti biasa
import 'lib/providers/panen_provider.dart';
import 'lib/providers/kandang_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ TAMBAH BLOK INI (Initialize Scheduler)
  await PanenScheduler.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late PanenProvider _panenProvider;
  late KandangProvider _kandangProvider;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Create providers
    _panenProvider = PanenProvider();
    _kandangProvider = KandangProvider();
    
    // ✅ TAMBAH BLOK INI (Initialize auto-capture)
    await PanenAutoCaptureService.initialize(_panenProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PanenProvider>.value(value: _panenProvider),
        ChangeNotifierProvider<KandangProvider>.value(value: _kandangProvider),
        // Provider lain...
      ],
      child: MaterialApp(
        title: 'TelurKu',
        theme: ThemeData(useMaterial3: true, primarySwatch: Colors.orange),
        home: const HomePage(), // Atau halaman home kamu
      ),
    );
  }

  @override
  void dispose() {
    _panenProvider.dispose();
    _kandangProvider.dispose();
    super.dispose();
  }
}
```

### Step 5: Test Manual (Optional)

Tambahkan button di halaman Kontrol untuk testing:

```dart
Consumer2<PanenProvider, KandangProvider>(
  builder: (context, panenProvider, kandangProvider, _) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            await PanenAutoCaptureService.triggerMorningCapture(
              panenProvider,
              kandangProvider,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Panen Pagi triggered')),
            );
          },
          child: const Text('🧪 Test: Panen Pagi'),
        ),
        ElevatedButton(
          onPressed: () async {
            await PanenAutoCaptureService.triggerAfternoonCapture(
              panenProvider,
              kandangProvider,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Panen Sore triggered')),
            );
          },
          child: const Text('🧪 Test: Panen Sore'),
        ),
      ],
    );
  },
)
```

---

## 📝 Checklist

- [ ] `pubspec.yaml` sudah punya `workmanager: ^0.5.1`
- [ ] 2 file service ada di `lib/services/`
- [ ] `PanenProvider` sudah updated dengan methods baru
- [ ] `main.dart` sudah import scheduler & capture service
- [ ] `main.dart` sudah call `PanenScheduler.initialize()`
- [ ] `main.dart` sudah call `PanenAutoCaptureService.initialize()`
- [ ] Run `flutter pub get`
- [ ] Build & test

---

## 🎯 Testing

### Test Manual (Sebelum jam 09:00 atau 15:00)

1. Klik button "Test: Panen Pagi" di halaman Kontrol
2. Lihat Firebase real-time database (path: `/riwayat/`)
3. Verifikasi data tersimpan dengan benar

### Test Otomatis

1. Tunggu hingga jam 09:00
2. Cek console log: `✅ Morning capture triggered`
3. Cek Firebase: data panen pagi sudah tersimpan
4. Tunggu jam 15:00
5. Cek delta calculation benar

---

## 🐛 Troubleshooting Cepat

| Problem | Solution |
|---------|----------|
| "Scheduler tidak jalan" | Sudah jalankan `flutter pub get`? |
| "Data tidak tersimpan FB" | Cek Firebase rules allow write |
| "Delta calculation salah" | Cek snapshot pagi tercatat di Firebase |
| "Build error" | Clean: `flutter clean` → `flutter pub get` |

---

## 📊 Monitoring

### Lihat Logs Scheduler

Di Android Studio:
```
Run > Logcat → search "Triggering" atau "captured"
```

### Lihat Data di Firebase

Console: https://console.firebase.google.com/
→ Realtime Database → `riwayat/` folder

### Lihat State di App

Dashboard akan menampilkan:
- ✅ atau ⏳ status untuk Panen Pagi
- ✅ atau ⏳ status untuk Panen Sore

---

## 🎉 Done!

Sistem scheduler otomatis sudah siap! 

**Kapan saja jam 09:00 dan 15:00 (24/7), sistem akan:**
1. ✅ Baca sensor dari Firebase
2. ✅ Hitung delta (sore - pagi)
3. ✅ Simpan ke Firebase `/riwayat/`
4. ✅ Update UI secara real-time

Tidak perlu klik tombol lagi! 🎊

---

## 📚 Dokumentasi Lengkap

Lihat file ini untuk detail lebih lanjut:
- `SCHEDULER_IMPLEMENTATION_GUIDE.md` - Setup lengkap & customization
- `PENJELASAN_DASHBOARD_RIWAYAT.md` - Cara kerja dashboard & riwayat
- `MAIN_DART_EXAMPLE.dart` - Contoh lengkap main.dart dengan UI

---

**Questions?** Check console logs atau review SCHEDULER_IMPLEMENTATION_GUIDE.md 🚀
