# 🎨 SISTEM SCHEDULER - VISUAL DIAGRAMS

## 1. Arsitektur Sistem

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  📱 FLUTTER APP (TelurKu)                                      │
│  ├─ main.dart                                                  │
│  │   ├─ PanenScheduler.initialize()  ← Background task setup  │
│  │   ├─ PanenAutoCaptureService.initialize()  ← Restore state │
│  │   └─ MultiProvider (PanenProvider, KandangProvider, ...)    │
│  │                                                              │
│  ├─ lib/services/                                              │
│  │   ├─ panen_scheduler.dart         ← Workmanager setup      │
│  │   └─ panen_auto_capture_service.dart  ← Bridge layer       │
│  │                                                              │
│  ├─ lib/providers/                                             │
│  │   ├─ panen_provider.dart          ← Time-window + snapshot │
│  │   ├─ kandang_provider.dart        ← Sensor reading         │
│  │   └─ ...                                                    │
│  │                                                              │
│  └─ lib/screens/                                               │
│      ├─ dashboard_page.dart          ← Show status & last harvest
│      ├─ riwayat_page.dart            ← Show history           │
│      └─ kontrol_page.dart            ← Manual test buttons     │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🔄 BACKGROUND SERVICE (Workmanager)                          │
│  ├─ Task ID: "panenPagiTask" (09:00 setiap hari)             │
│  ├─ Task ID: "panenSoreTask" (15:00 setiap hari)             │
│  └─ Execute: callbackDispatcher() → trigger capture          │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🔥 FIREBASE                                                   │
│  ├─ /data/                          ← Real-time sensor data    │
│  │   ├─ infra1: 45                                            │
│  │   └─ infra2: 68                                            │
│  │                                                              │
│  ├─ /panen_snapshot/YYYY-MM-DD/     ← Snapshot per hari       │
│  │   ├─ pagi: {kandang_1: 45, kandang_2: 68}                │
│  │   └─ sore: {kandang_1: 100, kandang_2: 150, delta...}   │
│  │                                                              │
│  └─ /riwayat/                       ← Panen records           │
│      ├─ -abc123: {Panen object pagi kandang_1}              │
│      ├─ -def456: {Panen object sore kandang_1}              │
│      └─ ...                                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Alur Executable Pagi (09:00)

```
┌───────────────────────────────────────────────────────────────┐
│ TIMELINE: 08:45 - 09:15                                       │
└───────────────────────────────────────────────────────────────┘

08:45:59
   ↓
08:59:59 (Workmanager countdown)
   ↓
09:00:00 ✅ TRIGGER TIME HIT!
   ↓
   ┌─────────────────────────────────────────┐
   │ callbackDispatcher() start execution     │
   │ └─→ panenPagiTask                        │
   │     └─→ _executePanenPagi()             │
   └─────────────────────────────────────────┘
   ↓
   ┌─────────────────────────────────────────┐
   │ Step 1: Read Firebase /data/             │
   │ ├─ infra1: 45  ← sensor value kandang 1 │
   │ └─ infra2: 68  ← sensor value kandang 2 │
   └─────────────────────────────────────────┘
   ↓
   ┌─────────────────────────────────────────┐
   │ Step 2: Save snapshot pagi to Firebase  │
   │ /panen_snapshot/2026-03-07/pagi/        │
   │ ├─ kandang_1: 45                        │
   │ ├─ kandang_2: 68                        │
   │ └─ timestamp: 2026-03-07T09:00:00Z      │
   └─────────────────────────────────────────┘
   ↓
   ┌─────────────────────────────────────────┐
   │ Step 3: Trigger Capture Methods         │
   │ └─ PanenAutoCaptureService             │
   │    .triggerMorningCapture()             │
   │    ├─ kandang_1 + 45 telur              │
   │    └─ kandang_2 + 68 telur              │
   └─────────────────────────────────────────┘
   ↓
   ┌─────────────────────────────────────────┐
   │ Step 4: Process for kandang_1           │
   │ ├─ captureScheduledPanenPagi()          │
   │ ├─ jumlahTelur = 45                     │
   │ ├─ jenisPanen = 'pagi'                  │
   │ ├─ sensorSnapshot = 45                  │
   │ ├─ Save _snapshotPagiHariIni['k1'] = 45│
   │ ├─ Add to _panens list                  │
   │ ├─ Save to Firebase /riwayat/           │
   │ └─ notifyListeners()                    │
   └─────────────────────────────────────────┘
   ↓
   ┌─────────────────────────────────────────┐
   │ Step 5: Process for kandang_2 (sama)    │
   │ ├─ jumlahTelur = 68                     │
   │ ├─ Save _snapshotPagiHariIni['k2'] = 68│
   │ └─ Save to Firebase /riwayat/           │
   └─────────────────────────────────────────┘
   ↓
09:00:15 ✅ SELESAI!
   ↓
Firebase state:
  /panen_snapshot/2026-03-07/pagi/ = {kandang_1: 45, kandang_2: 68}
  /riwayat/ = +2 records (pagi untuk k1 & k2)
  
Provider state:
  _snapshotPagiHariIni = {kandang_1: 45, kandang_2: 68}
  _panens = +2 items (pagi)
  
UI state:
  Dashboard: ✅ Panen Pagi (done)
  Last Harvest: Kandang 1 = 45 telur (pagi)
  
Next: Tunggu jam 15:00 untuk panen sore...
```

---

## 3. Alur Executable Sore (15:00) dengan Delta

```
┌───────────────────────────────────────────────────────────────┐
│ TIMELINE: 14:45 - 15:15                                       │
│ (Antara pagi dan sore, ayam terus bertelur)                   │
└───────────────────────────────────────────────────────────────┘

09:15 (Setelah panen pagi)
   ↓
   Ayam terus bertelur selama 6 jam...
   
   Sensor infra1: 45 → 60 → 80 → 95 → 100 (15:00)
   Sensor infra2: 68 → 75 → 95 → 120 → 150 (15:00)
   ↓
14:59:59 (Workmanager countdown)
   ↓
15:00:00 ✅ TRIGGER TIME HIT!
   ↓
   ┌──────────────────────────────────────────┐
   │ callbackDispatcher() start execution      │
   │ └─→ panenSoreTask                         │
   │     └─→ _executePanenSore()              │
   └──────────────────────────────────────────┘
   ↓
   ┌──────────────────────────────────────────┐
   │ Step 1: Read Firebase /data/              │
   │ ├─ infra1: 100  ← sensor value sekarang  │
   │ └─ infra2: 150                           │
   └──────────────────────────────────────────┘
   ↓
   ┌──────────────────────────────────────────┐
   │ Step 2: Get snapshot pagi dari Firebase   │
   │ /panen_snapshot/2026-03-07/pagi/         │
   │ ├─ kandang_1: 45  ← nilai pagi           │
   │ └─ kandang_2: 68                         │
   └──────────────────────────────────────────┘
   ↓
   ┌──────────────────────────────────────────┐
   │ Step 3: Calculate DELTA                   │
   │ Kandang 1: 100 - 45 = 55 telur sore      │
   │ Kandang 2: 150 - 68 = 82 telur sore      │
   └──────────────────────────────────────────┘
   ↓
   ┌──────────────────────────────────────────┐
   │ Step 4: Save snapshot sore + delta        │
   │ /panen_snapshot/2026-03-07/sore/         │
   │ ├─ kandang_1: 100                        │
   │ ├─ kandang_2: 150                        │
   │ ├─ delta_kandang_1: 55                   │
   │ ├─ delta_kandang_2: 82                   │
   │ └─ timestamp: 2026-03-07T15:00:00Z       │
   └──────────────────────────────────────────┘
   ↓
   ┌──────────────────────────────────────────┐
   │ Step 5: Trigger Afternoon Capture         │
   │ PanenAutoCaptureService                  │
   │ .triggerAfternoonCapture()               │
   │ ├─ kandang_1 + delta 55                  │
   │ └─ kandang_2 + delta 82                  │
   └──────────────────────────────────────────┘
   ↓
   ┌──────────────────────────────────────────┐
   │ Step 6: Process kandang_1 (sore)         │
   │ ├─ captureScheduledPanenSore()           │
   │ ├─ Get _snapshotPagiHariIni['k1'] = 45  │
   │ ├─ jumlahTelur = 100 - 45 = 55          │
   │ ├─ jenisPanen = 'sore'                   │
   │ ├─ sensorSnapshot = 100                  │
   │ ├─ panenSebelumnya = 45  ← untuk ref     │
   │ ├─ Save _snapshotSoreHariIni['k1'] = 100│
   │ ├─ Add to _panens list                   │
   │ ├─ Save to Firebase /riwayat/            │
   │ └─ notifyListeners()                     │
   └──────────────────────────────────────────┘
   ↓
   ┌──────────────────────────────────────────┐
   │ Step 7: Process kandang_2 (sore) (sama)  │
   │ ├─ jumlahTelur = 150 - 68 = 82           │
   │ ├─ Save _snapshotSoreHariIni['k2'] = 150│
   │ └─ Save to Firebase /riwayat/            │
   └──────────────────────────────────────────┘
   ↓
   ┌──────────────────────────────────────────┐
   │ Step 8: Reset daily snapshots            │
   │ ├─ _snapshotPagiHariIni.clear()          │
   │ ├─ _snapshotSoreHariIni.clear()          │
   │ └─ Persiapan untuk hari berikutnya       │
   └──────────────────────────────────────────┘
   ↓
15:00:30 ✅ SELESAI!
   ↓
Firebase state:
  /panen_snapshot/2026-03-07/ = {
    pagi: {kandang_1: 45, kandang_2: 68},
    sore: {kandang_1: 100, kandang_2: 150, delta_k1: 55, delta_k2: 82}
  }
  /riwayat/ = +2 records (sore untuk k1 & k2)
  
Provider state:
  _snapshotPagiHariIni = {} (cleared)
  _snapshotSoreHariIni = {} (cleared)
  _panens = +4 items total (2 pagi + 2 sore)
  
UI state:
  Dashboard: ✅ Panen Sore (done)
  Last Harvest: Kandang 1 = 55 telur (sore, delta)
  Riwayat: TOTAL = 45 + 55 + 68 + 82 = 250 telur hari ini

Next: Besok jam 09:00, cycle berulang...
```

---

## 4. Data Flow Chart

```
                      🌍 FIREBASE
                           │
                ┌──────────┼──────────┐
                ↓          ↓          ↓
            /data/    /panen_      /riwayat/
          (real-time  snapshot)    (history)
            │          │          │
            │          │          │
            ↓          ↓          ↓
    ┌──────────────────────────────────────┐
    │     PanenScheduler (Background)      │
    │   Jam 09:00  |  Jam 15:00            │
    └──────────────────────────────────────┘
            │          │
            └──┬───────┘
               ↓
    ┌──────────────────────────────────────┐
    │  PanenAutoCaptureService (Bridge)    │
    │  - triggerMorningCapture()           │
    │  - triggerAfternoonCapture()         │
    └──────────────────────────────────────┘
            │
            ↓
    ┌──────────────────────────────────────┐
    │       PanenProvider (Snapshot)       │
    │  _snapshotPagiHariIni                │
    │  _snapshotSoreHariIni                │
    │  captureScheduledPanenPagi()         │
    │  captureScheduledPanenSore()         │
    └──────────────────────────────────────┘
            │
            ├─→ _panens list (memory)
            │
            └─→ Firebase /riwayat/
                    │
                    ↓
            ┌─────────────────────┐
            │  DashboardPage      │
            │  - Last harvest     │
            │  - Current status   │
            └─────────────────────┘
                    │
            ┌─────────────────────┐
            │  RiwayatPage        │
            │  - History list     │
            │  - Daily totals     │
            │  - Grouped by date  │
            └─────────────────────┘
```

---

## 5. Time-Window Illustration

```
KEMARIN                          HARI INI                      BESOK
│                               │                              │
├─ 15:01 ──────────────────────→├─ 09:00 (CAPTURE PAGI)       │
│  Start Accumulation          │  │                           │
│                              │  ├─ 45 telur = Total 6+ jam  │
│                              │  │                           │
│  (Ayam terus bertelur        │  ├─ 09:01 ──────────────→    │
│   selama 18 jam di kandang)  │  │ Start Accumulation       │
│                              │  │                          │
├─ 23:59 ────────────────────→ │  ├─ 15:00 (CAPTURE SORE)   │
│                              │  │ Delta: 100 - 45 = 55    │
│  Sensor di kandang 1:        │  │                         │
│  Terus naik 45 → 100         │  │ Snapshot sore selesai   │
│                              │  │ Reset untuk besok      │
└──────────────────────────────┴──────────────────────────────┴─────

WINDOW PAGI = 18 jam   | WINDOW SORE = 6 jam    | (Lebih banyak telur pagi)
Akumulasi lebih banyak | Akumulasi lebih sedikit |
```

---

## 6. Provider State Machine

```
APP START
   ↓
   ├─ PanenProvider created
   ├─ loadTodaySnapshots()  ← Restore dari Firebase
   ├─ restorePanenHistoryFromFirebase()  ← Load historical data
   └─ Ready! 
      │
      ├─→ State: _snapshotPagiHariIni = {}
      ├─→ State: _snapshotSoreHariIni = {}
      └─→ State: _panens = [... all historical items]
      
JAM 08:59:59
   ↓
   Waiting for 09:00...
   
JAM 09:00:00 ✅
   ↓
   Scheduler trigger → captureScheduledPanenPagi()
   │
   ├─ Check: isPanenPagiRecordedToday('k1') ? 
   │  └─ Jika false → lanjut
   │  └─ Jika true  → skip (sudah tercatat)
   │
   ├─ Add Panen object ke _panens
   ├─ Save _snapshotPagiHariIni['k1'] = 45
   ├─ Save ke Firebase
   ├─ notifyListeners()  ← UI update
   │
   └─ State:
      ├─ _snapshotPagiHariIni = {kandang_1: 45}
      ├─ _panens = [+1 item pagi]
      └─ isPanenPagiRecordedToday('k1') = true ✅
      
JAM 09:00 → 14:59
   ↓
   Waiting for 15:00...
   (Sensor terus naik: 45 → 100)
   
JAM 15:00:00 ✅
   ↓
   Scheduler trigger → captureScheduledPanenSore()
   │
   ├─ Get _snapshotPagiHariIni['k1'] = 45
   ├─ Calculate: delta = 100 - 45 = 55
   ├─ Add Panen object (sore) ke _panens
   ├─ Save _snapshotSoreHariIni['k1'] = 100
   ├─ Save ke Firebase
   ├─ notifyListeners()  ← UI update
   │
   └─ State:
      ├─ _snapshotPagiHariIni = {kandang_1: 45}  (masih ada)
      ├─ _snapshotSoreHariIni = {kandang_1: 100}
      ├─ _panens = [pagi item, +1 item sore]
      └─ isPanenSoreRecordedToday('k1') = true ✅
      
JAM 15:00:05 (After reset)
   ↓
   resetDailySnapshots()
   
   └─ State:
      ├─ _snapshotPagiHariIni.clear() → {}
      ├─ _snapshotSoreHariIni.clear() → {}
      └─ Ready untuk besok pagi!
      
BESOK JAM 09:00
   ↓
   Cycle berulang... ♻️
```

---

## 7. Firebase Structure

```
Firebase Realtime Database:

telurku-fa78c (your project)
│
├─ data/
│  ├─ infra1: 45        ← Real-time sensor kandang 1
│  └─ infra2: 68        ← Real-time sensor kandang 2
│
├─ panen_snapshot/
│  └─ 2026-03-07/       ← Date key (YYYY-MM-DD)
│     ├─ pagi/
│     │  ├─ kandang_1: 45
│     │  ├─ kandang_2: 68
│     │  └─ timestamp: "2026-03-07T09:00:00Z"
│     └─ sore/
│        ├─ kandang_1: 100
│        ├─ kandang_2: 150
│        ├─ delta_kandang_1: 55
│        ├─ delta_kandang_2: 82
│        └─ timestamp: "2026-03-07T15:00:00Z"
│
└─ riwayat/
   ├─ -abc123def/
   │  ├─ id: "panen_1"
   │  ├─ kandang_id: "kandang_1"
   │  ├─ kandang_nama: "Kandang 1"
   │  ├─ jumlah_telur: 45
   │  ├─ jam: "09:00"
   │  ├─ jenis_panen: "pagi"
   │  ├─ sensor_snapshot: 45
   │  ├─ panen_sebelumnya: null
   │  ├─ tanggal_panen: "2026-03-07T09:00:00Z"
   │  └─ catatan: "Auto-capture PAGI dari scheduler"
   │
   ├─ -def456ghi/ (sore record)
   │  ├─ id: "panen_2"
   │  ├─ kandang_id: "kandang_1"
   │  ├─ jumlah_telur: 55          ← DELTA! (100-45)
   │  ├─ jam: "15:00"
   │  ├─ jenis_panen: "sore"
   │  ├─ sensor_snapshot: 100      ← Current (100)
   │  ├─ panen_sebelumnya: 45      ← Previous (45) for delta
   │  └─ catatan: "Auto-capture SORE dari scheduler (delta: 100 - 45)"
   │
   └─ ... (more records)
```

---

Sekarang konsep jauh lebih jelas dengan visual! 🎨
