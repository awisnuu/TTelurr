# Penjelasan Detail: Dashboard & Riwayat

## 1. FUNGSI STATUS PANEN TERAKHIR (Dashboard Page)

### 📍 Apa itu "Status Panen Terakhir"?
Bagian ini menampilkan **panen terakhir untuk SETIAP kandang** secara individual. Bukan ringkasan, tapi detail per kandang.

### 🔄 Alur Kerja

```
┌─────────────────────────────────────────────────────────┐
│ STATUS PANEN TERAKHIR - Dashboard                       │
│                                                         │
│ Kandang 1:        ← Loop untuk setiap kandang          │
│  ├─ Panen Terakhir: pagi (09:00)                       │
│  ├─ Jumlah: 45 telur                                   │
│  ├─ Jam: 09:00                                         │
│  └─ Tanggal: 06-03-2026                                │
│                                                         │
│ Kandang 2:        ← Kandang berikutnya                 │
│  ├─ Panen Terakhir: sore (15:00)                       │
│  ├─ Jumlah: 71 telur                                   │
│  ├─ Jam: 15:00                                         │
│  └─ Tanggal: 06-03-2026                                │
│                                                         │
│ Kandang 3:                                              │
│  └─ Belum ada data panen ⚠️                            │
└─────────────────────────────────────────────────────────┘
```

### 🔍 Cara Kerjanya (Step-by-Step)

**Step 1: Loop setiap kandang**
```dart
ListView.builder(
  itemCount: kandangProvider.kandangs.length,  // 2 kandang
  itemBuilder: (context, idx) {
    final kandang = kandangProvider.kandangs[idx];  // Kandang 1, Kandang 2
```

**Step 2: Ambil panen terakhir untuk kandang itu**
```dart
final lastHarvest = panenProvider.getLastHarvestStatus(kandang.id);
// Panggil method yang mencari panen paling baru untuk kandang ini
```

**Step 3: Fungsi `getLastHarvestStatus()` di PanenProvider**
```dart
Panen? getLastHarvestStatus(String kandangId) {
  // 1. Cari semua panen untuk kandang ini
  final panenKandang = _panens
      .where((p) => p.kandangId == kandangId)
      .toList();
  
  // 2. Jika tidak ada, return null (tampilkan "Belum ada data")
  if (panenKandang.isEmpty) return null;
  
  // 3. Urutkan dari terbaru ke terlama
  panenKandang.sort((a, b) => b.tanggalPanen.compareTo(a.tanggalPanen));
  
  // 4. Return yang paling atas (paling baru)
  return panenKandang.first;
}
```

**Step 4: Tampilkan di UI**
```dart
if (lastHarvest == null) {
  // Tampilkan pesan: "Belum ada data panen"
} else {
  // Tampilkan kartu dengan:
  // - Kandang: ${lastHarvest.kandangNama}
  // - Jenis: ${lastHarvest.jenisPanen} (pagi/sore)
  // - Jumlah: ${lastHarvest.jumlahTelur} telur
  // - Jam: ${lastHarvest.jam}
  // - Tanggal: ${lastHarvest.tanggalPanen}
}
```

### 📊 Contoh Data Aktual

Misal di Firebase sudah ada data:
```
_panens = [
  // 2 hari lalu
  Panen(kandangId: 'kandang_1', jumlahTelur: 45, jam: '09:00', 
        tanggalPanen: 04-03-2026), // pagi
  Panen(kandangId: 'kandang_1', jumlahTelur: 42, jam: '15:00', 
        tanggalPanen: 04-03-2026), // sore
  
  // Kemarin
  Panen(kandangId: 'kandang_1', jumlahTelur: 48, jam: '09:00', 
        tanggalPanen: 05-03-2026), // pagi
  Panen(kandangId: 'kandang_1', jumlahTelur: 43, jam: '15:00', 
        tanggalPanen: 05-03-2026), // sore
  
  // Hari ini
  Panen(kandangId: 'kandang_2', jumlahTelur: 68, jam: '09:00', 
        tanggalPanen: 06-03-2026), // pagi
  Panen(kandangId: 'kandang_2', jumlahTelur: 71, jam: '15:00', 
        tanggalPanen: 06-03-2026), // sore
]
```

**Saat membuka Dashboard hari 06-03-2026 pukul 14:30:**

```
Kandang 1:
  getLastHarvestStatus('kandang_1')
  → Cari: semua panen dengan kandangId='kandang_1'
  → Dapat: [45 (04th, 09:00), 42 (04th, 15:00), 
             48 (05th, 09:00), 43 (05th, 15:00)]
  → Urutkan desc: [43 (05th, 15:00), 48 (05th, 09:00), ...]
  → Return: 43 telur, sore, 15:00, 05-03-2026

  TAMPILAN:
  ┌─────────────────────────┐
  │ Kandang 1               │
  │ Status: SORE (15:00)   │
  │ 43 telur               │
  │ 05-03-2026 pukul 15:00 │
  └─────────────────────────┘

Kandang 2:
  getLastHarvestStatus('kandang_2')
  → Cari: semua panen dengan kandangId='kandang_2'
  → Dapat: [68 (06th, 09:00), 71 (06th, 15:00)]
  → Urutkan desc: [71 (06th, 15:00), 68 (06th, 09:00)]
  → Return: 71 telur, sore, 15:00, 06-03-2026

  TAMPILAN:
  ┌─────────────────────────┐
  │ Kandang 2               │
  │ Status: SORE (15:00)   │
  │ 71 telur               │
  │ 06-03-2026 pukul 15:00 │
  └─────────────────────────┘
```

### ✅ Keuntungan Desain Ini
- ✅ User tahu kapan terakhir kali panen dilakukan
- ✅ Tahu berapa jumlah telur terakhir
- ✅ Tahu jenis panen (pagi/sore) dan jamnya
- ✅ Jika belum panen hari ini, tetap menunjukkan panen terakhir kemarin
- ✅ Per kandang, jadi transparan untuk setiap enclosure

---

## 2. LOGIKA RIWAYAT KESELURUHAN

### 📋 Apa itu Riwayat?
Sebuah halaman yang menampilkan **SEMUA data panen dalam rentang tanggal tertentu** dengan berbagai cara pengelompokan.

### 🔄 Alur Lengkap (Capture → Storage → Tampil)

```
┌──────────────────────────────────────────────────────────────┐
│ TIMELINE PANEN SEHARI-HARI                                   │
│                                                              │
│ 09:00 PAGI: Ambil telur (Panen Pagi)                        │
│ └─→ Data masuk: {kandang_1, 45, '09:00', pagi}             │
│ └─→ Sensor: infra1 = 45                                     │
│ └─→ Simpan ke _panens (PanenProvider)                      │
│                                                              │
│ 15:00 SORE: Ambil telur (Panen Sore)                        │
│ └─→ Sensor: infra1 = 100 (naik lagi!)                      │
│ └─→ Data masuk: {kandang_1, 100, '15:00', sore, prev: 45}  │
│ └─→ HITUNG DELTA: 100 - 45 = 55 telur sore                 │
│ └─→ Simpan ke _panens (PanenProvider)                      │
│                                                              │
│ SAMA SEPERTI KEMARIN...                                     │
│ 09:00 PAGI: 48 telur (reset/mulai dari 0)                  │
│ 15:00 SORE: Sensor 98 - Prev 48 = 50 telur                │
│                                                              │
│ DAN HARI BERIKUTNYA (HARI BARU)...                         │
│ Tanggal berubah ke besoknya, cycle berulang                │
└──────────────────────────────────────────────────────────────┘
```

### 📊 Database Structure di Memory (_panens List)

```
_panens = [
  // HARI 1: 04-03-2026
  Panen {
    id: 'panen_1',
    kandangId: 'kandang_1',
    kandangNama: 'Kandang 1',
    jumlahTelur: 45,
    tanggalPanen: 04-03-2026,  ← KEY untuk filtering
    jam: '09:00',
    jenisPanen: 'pagi',         ← Ada 2 per hari
    sensorSnapshot: 45,         ← Nilai sensor saat ambil
    panenSebelumnya: null,      ← Pagi tidak perlu
    catatan: 'Kondisi baik',
  },
  
  Panen {
    id: 'panen_2',
    kandangId: 'kandang_1',
    kandangNama: 'Kandang 1',
    jumlahTelur: 55,
    tanggalPanen: 04-03-2026,  ← SAMA, tapi berbeda jam
    jam: '15:00',
    jenisPanen: 'sore',
    sensorSnapshot: 100,        ← Sensor mencapai 100
    panenSebelumnya: 45,        ← Nilai panen sebelumnya
    catatan: 'Hitung: 100 - 45 = 55',
  },
  
  // HARI 2: 05-03-2026
  Panen {
    id: 'panen_3',
    kandangId: 'kandang_1',
    kandangNama: 'Kandang 1',
    jumlahTelur: 48,
    tanggalPanen: 05-03-2026,  ← BEDA HARI
    jam: '09:00',
    jenisPanen: 'pagi',
    sensorSnapshot: 48,
    panenSebelumnya: null,
    catatan: 'Sensor di-reset ke 0',
  },
  
  Panen {
    id: 'panen_4',
    kandangId: 'kandang_1',
    kandangNama: 'Kandang 1',
    jumlahTelur: 50,
    tanggalPanen: 05-03-2026,  ← SAMA HARI
    jam: '15:00',
    jenisPanen: 'sore',
    sensorSnapshot: 98,
    panenSebelumnya: 48,
    catatan: 'Hitung: 98 - 48 = 50',
  },
  
  // ... dst untuk kandang_2, dst untuk hari lain
]
```

### 🎯 User Membuka Riwayat & Memilih Tanggal

```
┌─────────────────────────────────────┐
│ Riwayat Panen                       │
│                                     │
│ Filter Tanggal:                    │
│ [📅 04-03-2026] sd [📅 06-03-2026]│
│                                     │
│ [CARI]  ← Klik ini                 │
└─────────────────────────────────────┘
```

### 🔍 Step-by-Step Proses Filtering

**Step 1: User pilih tanggal**
```dart
_selectedStartDate = 04-03-2026
_selectedEndDate = 06-03-2026
```

**Step 2: Panggil method filtering**
```dart
List<Panen> panens = panenProvider.getPanenByDateRange(
  DateTime(2026, 3, 4),
  DateTime(2026, 3, 6),
);
```

**Step 3: Fungsi `getPanenByDateRange()` filter data**
```dart
List<Panen> getPanenByDateRange(DateTime startDate, DateTime endDate) {
  return _panens.where((p) {
    // Cek apakah tanggal panen ANTARA start dan end (inclusive)
    return p.tanggalPanen.isAfter(startDate) &&
           p.tanggalPanen.isBefore(endDate.add(const Duration(days: 1)));
  }).toList();
}

// Hasil: [panen_1, panen_2, panen_3, panen_4]
// (Semua 4 panen antara 04-03 hingga 06-03)
```

**Step 4: Hitung Total Produksi**
```dart
int total = panens.isEmpty ? 0 : 
  panens.map<int>((p) => p.jumlahTelur).reduce((a, b) => a + b);

// total = 45 + 55 + 48 + 50 = 198 telur
// Ditampilkan di card atas berwarna orange gradient
```

### 📊 UI Riwayat - Apa yang Ditampilkan

```
┌──────────────────────────────────────────────┐
│ RIWAYAT PANEN (04-03 sd 06-03)              │
├──────────────────────────────────────────────┤
│                                              │
│ ┌────────────────────────────────────────┐  │
│ │ TOTAL PRODUKSI                         │  │
│ │ 198 🥚                                 │  │
│ │ 4 pencatatan panen                     │  │
│ └────────────────────────────────────────┘  │
│                                              │
│ ┌────────────────────────────────────────┐  │
│ │ 04-03-2026                             │  │
│ ├────────────────────────────────────────┤  │
│ │ • Pagi  (09:00): Kandang 1 - 45 telur  │  │
│ │ • Sore  (15:00): Kandang 1 - 55 telur  │  │
│ │ TOTAL HARI: 100 telur                  │  │
│ └────────────────────────────────────────┘  │
│                                              │
│ ┌────────────────────────────────────────┐  │
│ │ 05-03-2026                             │  │
│ ├────────────────────────────────────────┤  │
│ │ • Pagi  (09:00): Kandang 1 - 48 telur  │  │
│ │ • Sore  (15:00): Kandang 1 - 50 telur  │  │
│ │ TOTAL HARI: 98 telur                   │  │
│ └────────────────────────────────────────┘  │
│                                              │
│ ┌────────────────────────────────────────┐  │
│ │ 06-03-2026                             │  │
│ ├────────────────────────────────────────┤  │
│ │ • Pagi  (09:00): Kandang 2 - 68 telur  │  │
│ │ • Sore  (15:00): Kandang 2 - 71 telur  │  │
│ │ TOTAL HARI: 139 telur                  │  │
│ └────────────────────────────────────────┘  │
│                                              │
└──────────────────────────────────────────────┘
```

---

## 3. SKENARIO RESET / HARI BARU

### 🔄 Apa yang Terjadi saat Reset Sensor?

**Scenario 1: Sensor RESET ke 0 di pagi hari**
```
HARI 1 (04-03):
├─09:00 Pagi: Sensor 45 → capture → Panen 45 telur
│           (jenisPanen: 'pagi', panenSebelumnya: null)
│
├─15:00 Sore: Sensor 100 → capture
│           (jenisPanen: 'sore', panenSebelumnya: 45)
│           DELTA: 100 - 45 = 55 telur ✓
│
└─23:59:59: Sensor dicek ulang = 100

HARI 2 (05-03):
├─09:00 Pagi: [RESET SENSOR ke 0 oleh user]
│           Kemudian ayam bertelur → Sensor 48
│           → capture → Panen 48 telur
│           (jenisPanen: 'pagi', panenSebelumnya: null)
│
├─15:00 Sore: Sensor 98 → capture
│           (jenisPanen: 'sore', panenSebelumnya: 48)
│           DELTA: 98 - 48 = 50 telur ✓
│
└─23:59:59: Sensor = 98

HARI 3 (06-03): ... (cycle berulang)
```

**Scenario 2: Sensor TIDAK RESET (Masih 100 dari kemarin)**
```
HARI 2 PAGI (05-03):
├─ Sensor menunjukkan 100 (belum di-reset)
├─ Tapi HARI BARU, jadi capture sebagai 'pagi'
├─ Masalah: jenisPanen='pagi' tapi sensorSnapshot=100?
│
└─ Solusi: Pengguna harus reset terlebih dahulu
   atau gunakan logika khusus untuk tangani ini
```

### 📅 Data Tersimpan Permanen di PanenProvider

```
Setiap kali ada panen (pagi atau sore), data disimpan ke _panens:

_panens.add(Panen(...))  // Simpan ke memory
notifyListeners()         // Update UI

Data PERSISTEN di sini sampai:
1. App di-close & semua hilang (jika tidak save ke Firebase) ⚠️
2. Atau di-backup/sinkronisasi ke Firebase
3. Atau dihapus manual via deletePanen()
```

### ⚠️ PENTING: Persistence / Penyimpanan Jangka Panjang

Saat ini, `_panens` adalah in-memory list. Artinya:
- ✅ Tersimpan SEPANJANG app berjalan
- ✅ Riwayat tetap tampil selama app tidak ditutup
- ❌ Hilang saat app ditutup jika tidak save ke Firebase!

Untuk persistence long-term, perlu:
1. **Option A**: Save ke SharedPreferences (lokal) → JsonEncode/Decode
2. **Option B**: Save ke Firebase Realtime Database → Auto-sync
3. **Option C**: Save ke SQLite/Hive → Local DB

**Current Flow yang Perlu:** 
```
User capture panen → addPanen() → _panens (memory)
                                    ↓
                            Seharusnya ke Firebase
                                    ↓
                         Save untuk jangka panjang
```

---

## 4. DIAGRAM LENGKAP: DATA FLOW

```
┌─────────────────────────────────────────────────────────────┐
│                    ALUR DATA LENGKAP                        │
└─────────────────────────────────────────────────────────────┘

CAPTURE PANEN:
┌──────────────┐
│ Jam 09:00    │
│ Panen Pagi   │
└──────┬───────┘
       │
       ▼
┌─────────────────────────────────┐
│ KandangProvider                 │
│ infra1Value = 45 (sensor)       │
│ captureSensorSnapshot()         │
└──────┬──────────────────────────┘
       │ Get sensor value
       ▼
┌─────────────────────────────────┐
│ PanenProvider                   │
│ addPanenFromSensor(             │
│   kandangId: 'kandang_1'        │
│   sensorValue: 45               │
│   jenisPanen: 'pagi'            │
│   jam: '09:00'                  │
│   panenSebelumnya: null         │
│ )                               │
└──────┬──────────────────────────┘
       │ Add to _panens
       ▼
┌─────────────────────────────────┐
│ _panens List (Memory)           │
│ [                               │
│   Panen(45, 'pagi', 09:00),     │
│   ... (other panens)            │
│ ]                               │
└──────┬──────────────────────────┘
       │
       ├────► DashboardPage (Status Panen Terakhir)
       │      getLastHarvestStatus('kandang_1')
       │      → Tampikan 45 telur, 09:00, pagi
       │
       └────► RiwayatPage (History)
              getPanenByDateRange(start, end)
              → Filter & tampilkan semua panen
```

---

## 5. CHEAT SHEET - Capture vs Display

| Aspek | **Capture (Saat Panen)** | **Display (Dashboard)** | **Display (Riwayat)** |
|-------|--------------------------|------------------------|----------------------|
| **Method yang Digunakan** | `addPanenFromSensor()` | `getLastHarvestStatus()` | `getPanenByDateRange()` |
| **Data Source** | KandangProvider (sensor) + Input | PanenProvider (last record) | PanenProvider (filtered) |
| **Proses** | Sensor value → Add to _panens | Get paling baru → Sort desc | Filter by date range → Sum |
| **Hasil** | Tersimpan di _panens | 1 record per kandang | Multiple records, grouped |
| **Update UI** | `notifyListeners()` | `Consumer<PanenProvider>` | `Consumer<PanenProvider>` |
| **Contoh** | `45, 55 (delta), 48, 50` | `50 (terakhir)` | `45+55+48+50=198` |

---

## 6. TROUBLESHOOTING COMMON ISSUES

### ❓ Q: "Kenapa riwayat kosong?"
**A:** Periksa:
1. Apakah sudah ada data di `_panens`?
2. Apakah tanggal filter benar? (cek format DateTime)
3. Apakah `getPanenByDateRange()` correctly filtering?

### ❓ Q: "Status Panen Terakhir malah menunjukkan data lama?"
**A:** Periksa:
1. Apakah `getLastHarvestStatus()` benar-benar mengurutkan desc?
2. Apakah `sort()` sudah dipanggil?
3. Apakah `return first` mengambil yang paling atas?

### ❓ Q: "Delta calculation salah (09:00 dapat 55, seharusnya 45)"
**A:** Periksa:
1. Apakah `panenSebelumnya` diisi dengan nilai pagi?
2. Apakah kondisi `if (jenisPanen == 'sore' && panenSebelumnya != null)` terpenuhi?
3. Apakah rumus `sensorValue - panenSebelumnya` benar?

### ❓ Q: "Data hilang saat app ditutup"
**A:** Normal! Data di `_panens` adalah in-memory. Solusi:
1. Implementasikan save ke Firebase
2. Atau gunakan SharedPreferences/SQLite untuk local persistence
3. Atau render/download sebelum tutup app

---

## 7. RINGKASAN SINGKAT

| Komponen | Fungsi |
|----------|--------|
| **Status Panen Terakhir** | Tampil panen terakhir SETIAP kandang di dashboard |
| **Riwayat** | Tampil SEMUA panen dalam rentang tanggal |
| **PanenProvider** | Toko data (store, retrieve, filter) |
| **KandangProvider** | Sumber sensor real-time |
| **Capture** | Sensor → Add to _panens (memory) |
| **Display** | _panens → Filter/Sort → UI |
| **Persistence** | ⚠️ Belum ada (hanya memory) |

Apa ada yang masih belum jelas?
