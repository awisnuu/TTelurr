# 📅 SISTEM SCHEDULER OTOMATIS - Implementasi & Integrasi

## 📋 Gambaran Umum

Sistem ini terdiri dari 3 komponen utama:

```
┌────────────────────────────────────────────────────────────┐
│                  SISTEM SCHEDULER OTOMATIS                 │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  1. PanenScheduler (Background Service)                   │
│     └─ Jalankan task background setiap jam 09:00 & 15:00  │
│     └─ Gunakan workmanager untuk persistent scheduling     │
│                                                            │
│  2. PanenProvider (State Management)                      │
│     └─ Track snapshot pagi & sore                         │
│     └─ Implement logic time-windowing & delta calc        │
│     └─ Restore data dari Firebase                         │
│                                                            │
│  3. PanenAutoCaptureService (Bridge Service)             │
│     └─ Hubungkan scheduler dengan provider               │
│     └─ Trigger capture saat schedule hit                 │
│     └─ Manage snapshot & reset daily                     │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## 🔧 LANGKAH INTEGRASI

### Step 1: Update pubspec.yaml ✅ (SUDAH DONE)

Package yang ditambahkan:
```yaml
dependencies:
  workmanager: ^0.5.1
```

### Step 2: Setup di main.dart

**EDIT main.dart SEBELUM runApp():**

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'lib/services/panen_scheduler.dart';
import 'lib/services/panen_auto_capture_service.dart';
import 'lib/providers/panen_provider.dart';
import 'lib/providers/kandang_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Scheduler (TAMBAH INI)
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
    // Initialize PanenProvider
    _panenProvider = PanenProvider();
    _kandangProvider = KandangProvider();
    
    // Initialize auto-capture service dengan provider
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
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.orange,
        ),
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

### Step 3: Update AndroidManifest.xml (untuk Android)

**File: `android/app/src/main/AndroidManifest.xml`**

Tambahkan permissions (JIKA BELUM ADA):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
    <application>
        <!-- Background task permissions untuk workmanager -->
        <service android:name="com.baseflow.background_geolocation.services.LocationUpdatesIntentService" />
    </application>
</manifest>
```

---

## 📊 ALUR KERJA OTOMATIS

### Pagi (09:00)

```
┌──────────────────────────────────────────────────────┐
│ Jam 09:00 (08:00 GMT+8)                             │
├──────────────────────────────────────────────────────┤
│                                                      │
│ 1. Workmanager / PanenScheduler detect jam 09:00   │
│                                                      │
│ 2. Execute _executePanenPagi() background task     │
│    └─ Baca sensor Firebase (infra1, infra2)        │
│    └─ Simpan snapshot pagi ke Firebase             │
│    └─ Trigger callback ke PanenProvider            │
│                                                      │
│ 3. PanenAutoCaptureService.triggerMorningCapture() │
│    └─ Loop setiap kandang                          │
│    └─ Call captureScheduledPanenPagi() untuk       │
│       kandang_1 & kandang_2                        │
│                                                      │
│ 4. PanenProvider.captureScheduledPanenPagi()       │
│    └─ Add panen ke _panens list                    │
│    └─ Simpan snapshot ke _snapshotPagiHariIni      │
│    └─ Save ke Firebase riwayat/                    │
│    └─ notifyListeners() → UI update               │
│                                                      │
│ ✅ PANEN PAGI RECORDED                             │
│                                                      │
└──────────────────────────────────────────────────────┘
```

**Data di Firebase setelah panen pagi:**

```
/panen_snapshot/2026-03-07/pagi/ {
  kandang_1: 45,
  kandang_2: 68,
  timestamp: "2026-03-07T09:00:00.000Z"
}

/riwayat/ {
  -panen_1: {
    id: "...",
    kandang_id: "kandang_1",
    kandang_nama: "Kandang 1",
    jumlah_telur: 45,
    jam: "09:00",
    jenis_panen: "pagi",
    sensor_snapshot: 45,
    panen_sebelumnya: null,
    catatan: "Auto-capture PAGI dari scheduler",
    ...
  }
}
```

### Sore (15:00)

```
┌──────────────────────────────────────────────────────┐
│ Jam 15:00 (14:00 GMT+8)                            │
├──────────────────────────────────────────────────────┤
│                                                      │
│ 1. Workmanager detect jam 15:00                    │
│                                                      │
│ 2. Execute _executePanenSore() background task    │
│    └─ Baca sensor Firebase (infra1, infra2)       │
│    └─ Baca snapshot pagi dari Firebase            │
│    └─ Hitung DELTA: sore - pagi                  │
│    └─ Simpan snapshot sore ke Firebase            │
│                                                      │
│ 3. PanenAutoCaptureService.triggerAfternoonCapture│
│    └─ Loop setiap kandang                         │
│    └─ Call captureScheduledPanenSore() dengan    │
│       delta calculation                            │
│                                                      │
│ 4. PanenProvider.captureScheduledPanenSore()      │
│    └─ Get nilai pagi dari _snapshotPagiHariIni    │
│    └─ Hitung: jumlahTelur = sensorValue - nilaiPagi
│    └─ Add panen ke _panens list                   │
│    └─ Save ke Firebase riwayat/                   │
│    └─ notifyListeners() → UI update              │
│                                                      │
│ 5. Reset snapshots (persiapan hari berikutnya)   │
│    └─ _snapshotPagiHariIni.clear()                │
│    └─ _snapshotSoreHariIni.clear()                │
│                                                      │
│ ✅ PANEN SORE RECORDED (dengan delta)             │
│                                                      │
└──────────────────────────────────────────────────────┘
```

**Contoh Calculation:**

```
Sensor pagi (09:00): 45 telur
  → Stored in _snapshotPagiHariIni['kandang_1'] = 45

Antara 09:00-15:00: Ayam bertelur lebih banyak
Sensor sore (15:00): 100 telur

DELTA CALCULATION:
  jumlahTelur = 100 - 45 = 55 telur ✅
  
PANEN SORE SAVED:
  {
    kandang_id: 'kandang_1',
    jumlah_telur: 55,
    jam: '15:00',
    jenis_panen: 'sore',
    sensor_snapshot: 100,
    panen_sebelumnya: 45,  ← Nilai pagi untuk reference
    catatan: 'Auto-capture SORE dari scheduler (delta: 100 - 45)'
  }
```

---

## 🔄 RESET HARIAN

Setelah panen sore berhasil:

```
┌─────────────────────────────────────┐
│ Persiapan untuk Hari Berikutnya     │
├─────────────────────────────────────┤
│                                     │
│ Call: panenProvider.resetDailySnapshots()
│                                     │
│ Actions:                            │
│ └─ Clear _snapshotPagiHariIni       │
│ └─ Clear _snapshotSoreHariIni       │
│ └─ notifyListeners()                │
│                                     │
│ Besok jam 09:00:                    │
│ └─ Snapshot pagi baru akan terisi   │
│ └─ Cycle berulang...                │
│                                     │
└─────────────────────────────────────┘
```

---

## 📱 FITUR TAMBAHAN DI UI

### 1. Manual Trigger (Testing/Debug)

Tambahkan button di halaman Kontrol:

```dart
ElevatedButton(
  onPressed: () async {
    final panenProvider = context.read<PanenProvider>();
    await PanenAutoCaptureService.triggerMorningCapture(panenProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Manual morning capture triggered')),
    );
  },
  child: const Text('🧪 Test: Trigger Panen Pagi'),
),

ElevatedButton(
  onPressed: () async {
    final panenProvider = context.read<PanenProvider>();
    await PanenAutoCaptureService.triggerAfternoonCapture(panenProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Manual afternoon capture triggered')),
    );
  },
  child: const Text('🧪 Test: Trigger Panen Sore'),
),
```

### 2. Display Scheduler Status di Dashboard

```dart
Consumer<PanenProvider>(
  builder: (context, panenProvider, _) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⏰ Status Scheduler Otomatis',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    panenProvider.isPanenPagiRecordedToday('kandang_1')
                        ? '✅ Pagi'
                        : '⏳ Menunggu',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jam 09:00',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    panenProvider.isPanenSoreRecordedToday('kandang_1')
                        ? '✅ Sore'
                        : '⏳ Menunggu',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jam 15:00',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  },
)
```

### 3. Log Scheduler di Debug Console

Setup di app start untuk lihat activity:

```dart
// Di main.dart setelah Firebase init
if (kDebugMode) {
  print('═══════════════════════════════════════');
  print('🚀 TelurKu Scheduler Started');
  print('═══════════════════════════════════════');
  print('📅 Panen Pagi: Setiap hari jam 09:00');
  print('📅 Panen Sore: Setiap hari jam 15:00');
  print('═══════════════════════════════════════');
}
```

---

## ⚙️ KONFIGURASI

### 1. Ubah Jam Schedule

Edit di `panen_scheduler.dart`, function `setupPanenSchedules()`:

```dart
// Pagi: ubah parameter jam dan menit
initialDelay: _calculateDelay(9, 0),  // ubah jam 9 ke jam lain

// Sore: ubah parameter jam dan menit
initialDelay: _calculateDelay(15, 0),  // ubah jam 15 ke jam lain
```

### 2. Ubah Mapping Kandang ke Sensor

Edit di `panen_auto_capture_service.dart`:

```dart
final sensorMap = {
  'kandang_1': data['infra1'] ?? 0,
  'kandang_2': data['infra2'] ?? 0,
  'kandang_3': data['infra3'] ?? 0,  // Tambah jika ada kandang baru
};
```

### 3. Disable Auto-Capture (untuk testing manual)

Di main.dart:

```dart
// Comment out ini jika ingin disable scheduler
// await PanenScheduler.initialize();
```

---

## 🐛 TROUBLESHOOTING

### ❓ Q: "Scheduler tidak jalan"
**A:** Periksa:
1. ✅ Package workmanager sudah install? (`flutter pub get`)
2. ✅ AndroidManifest.xml sudah updated?
3. ✅ `PanenScheduler.initialize()` dipanggil di main.dart?
4. ✅ Device battery optimization not blocking app?

### ❓ Q: "Data tidak tersimpan ke Firebase"
**A:** Periksa:
1. ✅ Firebase connection active
2. ✅ Rules di Firebase allow write
3. ✅ Path `/riwayat/` dan `/panen_snapshot/` ada

### ❓ Q: "Delta calculation salah"
**A:** Periksa:
1. ✅ Snapshot pagi tercatat di _snapshotPagiHariIni
2. ✅ Snapshot pagi tersimpan di Firebase
3. ✅ isPanenPagiRecordedToday() return true
4. ✅ Nilai sensor sore > nilai sensor pagi

### ❓ Q: "Capture ganda (captured twice)"
**A:** Solusi:
1. Sistem sudah ada guard: `if (isPanenPagiRecordedToday(kandangId))`
2. Jika masih ganda, reset Firebase: hapus `/panen_snapshot/hari-ini`
3. Restart app dan trigger ulang

---

## 📝 CHECKLIST IMPLEMENTASI

- [ ] Update pubspec.yaml dengan workmanager
- [ ] Buat PanenScheduler service
- [ ] Buat PanenAutoCaptureService bridge
- [ ] Update PanenProvider dengan snapshot tracking & capture methods
- [ ] Edit main.dart: `await PanenScheduler.initialize()`
- [ ] Update AndroidManifest.xml permissions
- [ ] Test manual capture button
- [ ] Verifikasi data tersimpan ke Firebase
- [ ] Check delta calculation akurat
- [ ] Setup debug UI untuk scheduler status
- [ ] Deploy ke device real untuk testing jam 09:00 dan 15:00

---

## 🎯 NEXT STEPS

1. **Edit main.dart** dengan code di Step 2
2. **Run flutter pub get** untuk install workmanager
3. **Build & test** di device real
4. **Monitor logs** di console untuk verify scheduler running
5. **Test manual** dengan button di halaman Kontrol
6. **Check Firebase** untuk verify data tersimpan dengan benar

Selamat! Sistem scheduler otomatis siap digunakan 🚀
