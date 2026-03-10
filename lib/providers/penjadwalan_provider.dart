import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/penjadwalan_model.dart';

class PenjadwalanProvider extends ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  late DatabaseReference _penjadwalanRef;

  List<Penjadwalan> _penjadwalans = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  List<Penjadwalan> get penjadwalans => _penjadwalans;
  bool get isLoading => _isLoading;

  /// Initialize provider dengan user ID dan load data dari Firebase
  Future<void> initializeWithUser(String userId) async {
    _penjadwalanRef = _database.ref('kontrol/penjadwalan');

    // Clear previous listener
    await _subscription?.cancel();

    // Load data dari Firebase dengan real-time listener
    _subscription = _penjadwalanRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _penjadwalans = data.entries.map((entry) {
          return Penjadwalan.fromJson({
            'id': entry.key,
            ...entry.value as Map<dynamic, dynamic>,
          });
        }).toList();

        // Sort berdasarkan nomor untuk urutan yang rapi
        _penjadwalans.sort((a, b) {
          int numA = int.tryParse(a.id.replaceAll('penjadwalan', '')) ?? 999;
          int numB = int.tryParse(b.id.replaceAll('penjadwalan', '')) ?? 999;
          return numA.compareTo(numB);
        });
      } else {
        _penjadwalans = [];
      }
      _isLoading = false;
      notifyListeners();
    });

    _isLoading = false;
    notifyListeners();
  }

  /// Get next penjadwalan number (penjadwalan1, penjadwalan2, dst)
  String _getNextPenjadwalanKey() {
    if (_penjadwalans.isEmpty) return 'penjadwalan1';

    int maxNum = 0;
    for (var p in _penjadwalans) {
      int num = int.tryParse(p.id.replaceAll('penjadwalan', '')) ?? 0;
      if (num > maxNum) maxNum = num;
    }
    return 'penjadwalan${maxNum + 1}';
  }

  /// Clear semua data saat logout
  Future<void> clearData() async {
    await _subscription?.cancel();
    _penjadwalans = [];
    _isLoading = true;
    notifyListeners();
  }

  List<Penjadwalan> getPenjadwalanByKandang(String kandangId) {
    return _penjadwalans.where((p) => p.kandangId == kandangId).toList();
  }

  Future<void> addPenjadwalan(
    String kandangId,
    String kandangNama,
    String jam,
    String durasi,
    String keterangan,
  ) async {
    try {
      final newId = _getNextPenjadwalanKey();

      final newPenjadwalan = Penjadwalan(
        id: newId,
        kandangId: kandangId,
        kandangNama: kandangNama,
        jam: jam,
        durasi: durasi,
        keterangan: keterangan,
        aktif: true,
      );

      await _penjadwalanRef.child(newId).set(newPenjadwalan.toJson());
      // Data akan automatically di-update via listener
    } catch (e) {
      print('Error adding penjadwalan: $e');
    }
  }

  Future<void> updatePenjadwalan(
    String id,
    String jam,
    String durasi,
    String keterangan,
    bool aktif,
  ) async {
    try {
      final index = _penjadwalans.indexWhere((p) => p.id == id);
      if (index != -1) {
        final updated = Penjadwalan(
          id: id,
          kandangId: _penjadwalans[index].kandangId,
          kandangNama: _penjadwalans[index].kandangNama,
          jam: jam,
          durasi: durasi,
          keterangan: keterangan,
          aktif: aktif,
        );

        await _penjadwalanRef.child(id).set(updated.toJson());
        // Data akan automatically di-update via listener
      }
    } catch (e) {
      print('Error updating penjadwalan: $e');
    }
  }

  Future<void> deletePenjadwalan(String id) async {
    try {
      await _penjadwalanRef.child(id).remove();
      // Data akan automatically di-update via listener
    } catch (e) {
      print('Error deleting penjadwalan: $e');
    }
  }

  Future<void> togglePenjadwalan(String id) async {
    try {
      final index = _penjadwalans.indexWhere((p) => p.id == id);
      if (index != -1) {
        final updated = Penjadwalan(
          id: _penjadwalans[index].id,
          kandangId: _penjadwalans[index].kandangId,
          kandangNama: _penjadwalans[index].kandangNama,
          jam: _penjadwalans[index].jam,
          durasi: _penjadwalans[index].durasi,
          keterangan: _penjadwalans[index].keterangan,
          aktif: !_penjadwalans[index].aktif,
        );

        await _penjadwalanRef.child(id).set(updated.toJson());
        // Data akan automatically di-updated via listener
      }
    } catch (e) {
      print('Error toggling penjadwalan: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
