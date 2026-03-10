# TelurKu Firebase Database Configuration

## Database Structure (Firebase Realtime Database)

```json
{
  "aktuator": {
    "motor": true
  },
  "data": {
    "infra1": 1,
    "infra2": 20,
    "rtc": 1707883200
  },
  "kontrol": {
    "waktu_1": "09:00",
    "waktu_2": "15:00",
    "durasi_1": "30 menit",
    "durasi_2": "30 menit",
    "keterangan_1": "Panen Pagi",
    "keterangan_2": "Panen Sore"
  },
  "riwayat": {
    "telur_hari_ini": 0,
    "total_telur": 0,
    "last_reset_date": "2026-02-14"
  },
  "kandang": {
    "kandang_1": {
      "nama": "Kandang 1",
      "jumlah_ayam": 50,
      "dibuat": "2026-02-14"
    },
    "kandang_2": {
      "nama": "Kandang 2",
      "jumlah_ayam": 75,
      "dibuat": "2026-02-14"
    }
  },
  "panen": {
    "panen_1": {
      "kandang_id": "kandang_1",
      "kandang_nama": "Kandang 1",
      "jumlah_telur": 45,
      "tanggal": "2026-02-14",
      "jam": "09:00",
      "catatan": "Kondisi baik"
    }
  }
}
```

## Field Descriptions

### aktuator
- **motor** (boolean): Status motor/actuator

### data
- **infra1** (number): Sensor inframerah 1
- **infra2** (number): Sensor inframerah 2  
- **rtc** (number): Real-time clock timestamp

### kontrol
- **waktu_1** (string): Jadwal panen pertama (HH:MM format)
- **waktu_2** (string): Jadwal panen kedua (HH:MM format)
- **durasi_1** (string): Durasi panen pertama
- **durasi_2** (string): Durasi panen kedua
- **keterangan_1** (string): Deskripsi jadwal pertama
- **keterangan_2** (string): Deskripsi jadwal kedua

### riwayat
- **telur_hari_ini** (number): Total telur yang dihasilkan hari ini (auto-reset ke 0 setiap tengah malam)
- **total_telur** (number): Total kumulatif seluruh telur
- **last_reset_date** (string): Tanggal terakhir reset telur_hari_ini (YYYY-MM-DD format)

### kandang
Menyimpan data kandang-kandang yang tersedia dengan struktur:
- **nama** (string): Nama kandang
- **jumlah_ayam** (number): Jumlah ayam di kandang
- **dibuat** (string): Tanggal pembuatan kandang

### panen
Menyimpan history panen dengan struktur per record:
- **kandang_id** (string): ID kandang
- **kandang_nama** (string): Nama kandang
- **jumlah_telur** (number): Jumlah telur yang dipanen
- **tanggal** (string): Tanggal panen (YYYY-MM-DD format)
- **jam** (string): Jam panen (HH:MM format)
- **catatan** (string): Catatan/keterangan panen

## Auto-Reset Feature

Sistem `telur_hari_ini` akan otomatis mereset ke 0 setiap tengah malam (00:00) dengan:
1. Aplikasi mengecek `last_reset_date` saat startup
2. Jika tanggal berbeda dengan hari ini, akan mereset `telur_hari_ini` ke 0
3. Update `last_reset_date` ke tanggal hari ini

## Firebase Realtime Database Rules (Security)

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null",
    "aktuator": {
      ".write": "auth != null"
    },
    "data": {
      ".write": "auth != null"
    },
    "kontrol": {
      ".write": "auth != null"
    },
    "riwayat": {
      ".write": "auth != null"
    },
    "kandang": {
      ".write": "auth != null"
    },
    "panen": {
      ".write": "auth != null"
    }
  }
}
```

## Setup Instructions

1. Pastikan Firebase Realtime Database sudah diaktifkan di Firebase Console
2. Copy struktur JSON di atas ke database
3. Provider `TelurProvider` akan otomatis:
   - Membuat struktur awal jika belum ada
   - Mengecek dan mereset `telur_hari_ini` setiap hari
   - Sync data realtime dengan UI

4. Gunakan `TelurProvider` di `main.dart`:
```dart
MultiProvider(
  providers: [
    // ... other providers
    ChangeNotifierProvider(create: (_) => TelurProvider()),
  ],
  child: MyApp(),
)
```

## Methods Available in TelurProvider

- `addTelurHariIni(int jumlah)` - Tambah telur hari ini
- `setTotalTelur(int total)` - Set total telur kumulatif
- `resetTelurHariIni()` - Manual reset telur hari ini
- `manualReset()` - Reset semua data riwayat
