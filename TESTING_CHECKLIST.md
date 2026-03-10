# 📋 TESTING CHECKLIST - TelurKu Firebase Integration

## ✅ Konfigurasi yang Sudah Selesai

### 1. Logo ✅
- [x] Path updated: `assets/icons/telurku.png`
- [x] Logo akan ditampilkan di Landing Page dalam container circular putih
- [x] Fallback emoji jika file tidak ditemukan

### 2. Firebase Configuration ✅
- [x] Firebase Core terintegrasi di main.dart
- [x] Firebase Options untuk Android sudah dikonfigurasi
  - Project ID: `telurku-fa78c`
  - API Key: `AIzaSyCwF_fiwc1Cpsy570bvCYijRjHi1sd8n8U`
  - App ID: `1:22111260761:android:d9b30f13c92df54a002148`
  - Messaging Sender ID: `22111260761`
- [x] Firebase Options method sudah mendukung multiple platform (Android, iOS, Web, Windows, Linux, macOS)
- [x] Platform auto-detection sudah bekerja

### 3. Authentication ✅
- [x] Firebase Auth Provider sudah siap
- [x] Email/Password authentication ready
- [x] Error handling dengan pesan Bahasa Indonesia
- [x] Auto-redirect based on login status

### 4. UI/UX ✅
- [x] Landing Page dengan logo dan tombol Masuk/Daftar
- [x] Login Page dengan form validation
- [x] Signup Page dengan form lengkap
- [x] Home/Dashboard Page setelah login
- [x] Design sudah sesuai dengan mockup

---

## 🧪 TEST PLAN

### **Test 1: Landing Page Loading**
**Expected Result:**
- [ ] Aplikasi membuka ke Landing Page
- [ ] Logo TelurKu (`telurku.png`) tampil di container circular putih
- [ ] Taxt "TelurKu" dan tagline "Kelola Peternakan Ayam Anda dengan Mudah" terlihat
- [ ] Tombol "Masuk" berwarna kuning (#F4D03F)
- [ ] Tombol "Daftar Akun Baru" berwarna oranye border

```dart
// Testing code untuk cek di console
print('Landing Page Loaded: Logo path = assets/icons/telurku.png');
```

---

### **Test 2: Navigation - Masuk Button**
**Steps:**
1. Klik tombol "Masuk" di Landing Page
2. Tunggu 1 detik untuk transition

**Expected Result:**
- [ ] Navigasi ke Login Page berhasil
- [ ] Login Page menampilkan field Email dan Password
- [ ] Form sudah siap untuk input

---

### **Test 3: Navigation - Daftar Button**
**Steps:**
1. Dari Landing Page, klik "Daftar Akun Baru"
2. Atau dari Login Page, klik "Daftar di sini"

**Expected Result:**
- [ ] Navigasi ke Signup Page berhasil
- [ ] Form daftar dengan field: Nama, Email, Password, Konfirmasi Password
- [ ] Checkbox Terms & Conditions muncul

---

### **Test 4: Signup dengan Firebase Connection**
**Steps:**
1. Buka Signup Page
2. Isi form:
   ```
   Nama: Test User
   Email: testuser@example.com
   Password: Test@123456
   Konfirmasi Password: Test@123456
   ✓ Setuju Terms
   ```
3. Klik tombol "Daftar"

**Expected Result:**
- [ ] Loading indicator muncul di tombol
- [ ] Tidak ada error (seharusnya)
- [ ] Setelah sukses, otomatis login
- [ ] Navigate ke Home Page
- [ ] Greeting menampilkan "Test User"

**Jika Ada Error:**
- [ ] Catat error message
- [ ] Check Firebase Console untuk melihat user baru di Authentication
- [ ] Verifikasi credentials di `lib/firebase_options.dart`

---

### **Test 5: Login dengan Firebase Connection**
**Steps:**
1. Buka Landing Page
2. Klik "Masuk"
3. Isi form:
   ```
   Email: testuser@example.com
   Password: Test@123456
   ```
4. Klik tombol "Masuk"

**Expected Result:**
- [ ] Loading indicator muncul
- [ ] Firebase Auth berhasil autentikasi
- [ ] Redirect ke Home Page
- [ ] Greeting menampilkan "Test User"
- [ ] User avatar berisi huruf "T"

---

### **Test 6: Error Handling - Wrong Password**
**Steps:**
1. Go to Login Page
2. Isi dengan email benar tapi password salah:
   ```
   Email: testuser@example.com
   Password: WrongPassword123
   ```
3. Klik "Masuk"

**Expected Result:**
- [ ] Error message: "Password salah."
- [ ] SnackBar/Toast menampilkan error
- [ ] Tetap di Login Page (tidak proceed)

---

### **Test 7: Error Handling - Email Not Found**
**Steps:**
1. Go to Login Page
2. Isi dengan email yang belum terdaftar:
   ```
   Email: notregistered@example.com
   Password: Password123
   ```
3. Klik "Masuk"

**Expected Result:**
- [ ] Error message: "Email tidak terdaftar."
- [ ] SnackBar menampilkan error
- [ ] Tetap di Login Page

---

### **Test 8: Logout**
**Steps:**
1. Setelah login, berada di Home Page
2. Klik avatar profile di top-right appbar
3. Pilih "Logout"

**Expected Result:**
- [ ] Loading indicator muncul sebentar
- [ ] Redirect ke Landing Page
- [ ] Tidak ada data user yang tersimpan

---

### **Test 9: Firebase Console Verification**
**Steps:**
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project "telurku-fa78c"
3. Go to Authentication tab

**Expected Result:**
- [ ] User yang didaftar melalui app muncul di list
- [ ] Email dan Timestamp sudah tercatat
- [ ] Sign-in method: Email/Password

---

## 🛠️ Troubleshooting

### **Error: "Firebase initialization failed"**
**Cause:** firebase_options.dart credentials tidak match dengan Firebase project
**Solution:**
1. Buka Firebase Console
2. Go to Project Settings
3. Bandingkan dengan `lib/firebase_options.dart`
4. Update manual jika ada perbedaan

### **Error: "Null check operator used on a null value"**
**Cause:** Login state belum loading
**Solution:**
1. Tunggu dialog loading selesai
2. Cek internet connection
3. Restart app (R untuk Hot Restart)

### **Error: "CORS error" (Web platform)**
**Cause:** Web Firebase configuration belum setup
**Solution:**
1. Update `firebase_options.dart` web credentials
2. Setup Firebase untuk web platform di Console
3. Enable Authorization header di CORS

### **Logo tidak tampil**
**Cause:** Asset path atau file tidak ada
**Solution:**
```
1. Verify file ada di: assets/icons/telurku.png
2. Run: flutter clean && flutter pub get
3. Hot Restart (Shift+Ctrl+F5)
```

---

## 📊 Firebase Connection Status

### Android ✅ READY
- Project ID: `telurku-fa78c`
- Authentication: Email/Password ✅
- Firestore: Ready (optional)
- App ID: `1:22111260761:android:d9b30f13c92df54a002148`

### iOS ⚠️ PENDING
- Needs: GoogleService-Info.plist
- Setup: Generate from Firebase Console
- Status: Not yet configured

### Web ⚠️ PENDING
- Needs: Web API Key & credentials
- Setup: Add to firebase_options.dart
- Status: Placeholder only

### Windows ⚠️ PENDING
- Status: Requires Developer Mode on Windows
- Note: Not required for MVP

---

## 🚀 How to Run Tests

### **Method 1: Android Physical Device**
```bash
# Connect Android device via USB
flutter devices
flutter run -d <device_id>
```

### **Method 2: Android Emulator**
```bash
# Open Android Emulator first, then:
flutter run -d emulator-5554
```

### **Method 3: Chrome Web (Limited)**
```bash
# Will work after web Firebase config
flutter run -d chrome
```

### **Method 4: Windows Desktop (Requires Developer Mode)**
```bash
# Enable Developer Mode first, then:
flutter run -d windows
```

---

## ✨ Test Results Template

```markdown
### Test Run: [DATE]

#### Environment:
- Device: [Android/iOS/Web/Windows]
- Flutter Version: [VERSION]
- Firebase Project: telurku-fa78c

#### Results:
- Landing Page: ✅/❌
- Logo Display: ✅/❌
- Navigation (Login): ✅/❌
- Navigation (Signup): ✅/❌
- Signup + Firebase: ✅/❌
- Login + Firebase: ✅/❌
- Error Handling: ✅/❌
- Logout: ✅/❌
- Firebase Console: ✅/❌

#### Issues Found:
1. [Issue description]
2. [Issue description]

#### Notes:
[Additional observations]
```

---

## 📝 Command Reference

| Command | Purpose |
|---------|---------|
| `flutter clean` | Clear build cache |
| `flutter pub get` | Install dependencies |
| `flutter run -d <device>` | Run app |
| `r` | Hot reload |
| `R` | Hot restart |
| `q` | Quit app |
| `flutter devices` | List available devices |

---

## 🎯 Next Steps After Testing

1. ✅ Verify Firebase connection for Android
2. ⏳ Setup Firebase for iOS (if needed)
3. ⏳ Setup Firebase for Web (if needed)
4. ⏳ Add Real-time Database features
5. ⏳ Implement dashboard with live data

---

**Last Updated:** 13 Feb 2026
**Status:** Ready for Testing ✅
