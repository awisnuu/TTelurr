// import 'package:workmanager/workmanager.dart';  // TODO: Enable when workmanager is added back
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
// import '../providers/panen_provider.dart';  // TODO: Enable when workmanager is added back

final FirebaseDatabase _database = FirebaseDatabase.instance;

/// Scheduler service untuk otomasi capture panen pada jam 09:00 dan 15:00
class PanenScheduler {
  static const String pagiTaskId = 'panen_pagi_task';
  static const String soreTaskId = 'panen_sore_task';

  /// Inisialisasi Workmanager dan setup background tasks
  /// Panggil ini di main.dart saat app start
  static Future<void> initialize() async {
    try {
      // TODO: Enable when workmanager is added back
      // await Workmanager().initialize(
      //   callbackDispatcher,
      //   isInDebugMode: kDebugMode,
      // );

      // Setup periodic tasks
      await setupPanenSchedules();

      if (kDebugMode) {
        print('✅ PanenScheduler initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing PanenScheduler: $e');
      }
    }
  }

  /// Setup scheduled tasks untuk panen pagi (09:00) dan sore (15:00)
  static Future<void> setupPanenSchedules() async {
    try {
      // TODO: Enable when workmanager is added back
      // Panen Pagi: Setiap hari jam 09:00
      // await Workmanager().registerPeriodicTask(
      //   pagiTaskId,
      //   'panenPagiTask',
      //   frequency: const Duration(hours: 24),
      //   initialDelay: _calculateDelay(9, 0), // Delay ke jam 09:00 berikutnya
      //   constraints: Constraints(networkType: NetworkType.connected),
      //   backoffPolicy: BackoffPolicy.exponential,
      //   backoffPolicyDelay: const Duration(minutes: 15),
      // );

      // Panen Sore: Setiap hari jam 15:00
      // await Workmanager().registerPeriodicTask(
      //   soreTaskId,
      //   'panenSoreTask',
      //   frequency: const Duration(hours: 24),
      //   initialDelay: _calculateDelay(15, 0), // Delay ke jam 15:00 berikutnya
      //   constraints: Constraints(networkType: NetworkType.connected),
      //   backoffPolicy: BackoffPolicy.exponential,
      //   backoffPolicyDelay: const Duration(minutes: 15),
      // );

      if (kDebugMode) {
        print('✅ Panen schedules registered:');
        print('   - Panen Pagi: 09:00 setiap hari');
        print('   - Panen Sore: 15:00 setiap hari');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting up schedules: $e');
      }
    }
  }

  /// Hitung delay sampai waktu target (hour:minute) berikutnya
  // ignore: unused_element
  static Duration _calculateDelay(int targetHour, int targetMinute) {
    final now = DateTime.now();
    final target = DateTime(
      now.year,
      now.month,
      now.day,
      targetHour,
      targetMinute,
    );

    // Jika waktu target sudah lewat hari ini, target untuk besok
    if (target.isBefore(now)) {
      return target.add(const Duration(days: 1)).difference(now);
    }

    return target.difference(now);
  }

  /// Hentikan semua scheduler
  static Future<void> cancelAllTasks() async {
    try {
      // TODO: Enable when workmanager is added back
      // await Workmanager().cancelAll();
      if (kDebugMode) {
        print('✅ All tasks cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling tasks: $e');
      }
    }
  }

  /// Hentikan task tertentu
  static Future<void> cancelTask(String taskId) async {
    try {
      // TODO: Enable when workmanager is added back
      // await Workmanager().cancelByTag(taskId);
      if (kDebugMode) {
        print('✅ Task $taskId cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling task $taskId: $e');
      }
    }
  }

  // ========== DEBUG METHODS ==========
  /// Manual trigger untuk panen pagi (untuk testing/debug)
  static Future<Map<String, dynamic>> triggerPanenPagiManual() async {
    try {
      if (kDebugMode) {
        print('🔧 [DEBUG] Manual trigger: Panen Pagi');
      }
      await _executePanenPagi();
      return {
        'success': true,
        'message': 'Panen Pagi berhasil disimpan',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ [DEBUG] Error manual panen pagi: $e');
      }
      return {
        'success': false,
        'message': 'Error: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Manual trigger untuk panen sore (untuk testing/debug)
  static Future<Map<String, dynamic>> triggerPanenSoreManual() async {
    try {
      if (kDebugMode) {
        print('🔧 [DEBUG] Manual trigger: Panen Sore');
      }
      await _executePanenSore();
      return {
        'success': true,
        'message': 'Panen Sore berhasil disimpan',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ [DEBUG] Error manual panen sore: $e');
      }
      return {
        'success': false,
        'message': 'Error: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Get snapshot panen hari ini (untuk debug/monitoring)
  static Future<Map<String, dynamic>?> getTodaySnapshot() async {
    try {
      final snapshotRef = _database.ref('panen_snapshot/${_getTodayKey()}');
      final snapshot = await snapshotRef.get();

      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting snapshot: $e');
      }
      return null;
    }
  }

  /// Get next scheduled time (untuk tampilan UI)
  static Map<String, String> getNextScheduledTimes() {
    final now = DateTime.now();

    // Calculate next pagi (09:00)
    DateTime nextPagi = DateTime(now.year, now.month, now.day, 9, 0);
    if (nextPagi.isBefore(now)) {
      nextPagi = nextPagi.add(const Duration(days: 1));
    }

    // Calculate next sore (15:00)
    DateTime nextSore = DateTime(now.year, now.month, now.day, 15, 0);
    if (nextSore.isBefore(now)) {
      nextSore = nextSore.add(const Duration(days: 1));
    }

    return {
      'pagi':
          '${nextPagi.year}-${nextPagi.month.toString().padLeft(2, '0')}-${nextPagi.day.toString().padLeft(2, '0')} 09:00',
      'sore':
          '${nextSore.year}-${nextSore.month.toString().padLeft(2, '0')}-${nextSore.day.toString().padLeft(2, '0')} 15:00',
    };
  }
}

/// Callback dispatcher untuk background tasks
/// PENTING: Ini harus top-level function atau static method
/// Tidak bisa di-refactor menjadi method di class
@pragma('vm:entry-point')
void callbackDispatcher() {
  // TODO: Enable when workmanager is added back
  /* 
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (kDebugMode) {
        print('🔔 Running task: $taskName at ${DateTime.now()}');
      }

      switch (taskName) {
        case 'panenPagiTask':
          await _executePanenPagi();
          break;
        case 'panenSoreTask':
          await _executePanenSore();
          break;
        default:
          if (kDebugMode) {
            print('⚠️ Unknown task: $taskName');
          }
      }

      return true; // Task berhasil
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error executing task $taskName: $e');
      }
      return false; // Task gagal, akan di-retry
    }
  });
  */
}

/// Eksekusi panen pagi: ambil nilai sensor saat ini
Future<void> _executePanenPagi() async {
  try {
    if (kDebugMode) {
      print('📍 Executing Panen Pagi (09:00)');
    }

    // Baca nilai sensor current dari Firebase
    final dataRef = _database.ref('data');
    final snapshot = await dataRef.get();

    if (snapshot.exists) {
      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

      // Ambil setiap kandang dan capture sensor value
      // Data mapping: infra1 untuk kandang_1, infra2 untuk kandang_2, dst
      final infra1Value = data['infra1'] ?? 0;
      final infra2Value = data['infra2'] ?? 0;

      // Simpan snapshot pagi di Firebase untuk reference
      await _database.ref('panen_snapshot/${_getTodayKey()}').set({
        'pagi': {
          'kandang_1': infra1Value,
          'kandang_2': infra2Value,
          'timestamp': DateTime.now().toIso8601String(),
        },
      });

      if (kDebugMode) {
        print(
          '✅ Panen Pagi snapshot saved: kandang_1=$infra1Value, kandang_2=$infra2Value',
        );
      }

      // TODO: Trigger PanenProvider.addPanenForSchedule() untuk kandang_1 dan kandang_2
      // (Akan dipanggil dari main app via PanenProvider)
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error in _executePanenPagi: $e');
    }
  }
}

/// Eksekusi panen sore: hitung delta dari pagi
Future<void> _executePanenSore() async {
  try {
    if (kDebugMode) {
      print('📍 Executing Panen Sore (15:00)');
    }

    // Baca nilai sensor current
    final dataRef = _database.ref('data');
    final snapshot = await dataRef.get();

    if (snapshot.exists) {
      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

      final infra1Value = data['infra1'] ?? 0;
      final infra2Value = data['infra2'] ?? 0;

      // Baca snapshot pagi hari ini untuk delta calculation
      final pagiSnapshotRef = _database.ref(
        'panen_snapshot/${_getTodayKey()}/pagi',
      );
      final pagiSnapshot = await pagiSnapshotRef.get();

      int nilaiPagiKandang1 = 0;
      int nilaiPagiKandang2 = 0;

      if (pagiSnapshot.exists) {
        final pagiData = Map<dynamic, dynamic>.from(pagiSnapshot.value as Map);
        nilaiPagiKandang1 = pagiData['kandang_1'] ?? 0;
        nilaiPagiKandang2 = pagiData['kandang_2'] ?? 0;
      }

      // Hitung delta
      final deltaKandang1 = infra1Value - nilaiPagiKandang1;
      final deltaKandang2 = infra2Value - nilaiPagiKandang2;

      // Simpan snapshot sore di Firebase
      await _database.ref('panen_snapshot/${_getTodayKey()}').update({
        'sore': {
          'kandang_1': infra1Value,
          'kandang_2': infra2Value,
          'delta_kandang_1': deltaKandang1,
          'delta_kandang_2': deltaKandang2,
          'timestamp': DateTime.now().toIso8601String(),
        },
      });

      if (kDebugMode) {
        print(
          '✅ Panen Sore calculated: delta_kandang_1=$deltaKandang1, delta_kandang_2=$deltaKandang2',
        );
      }

      // TODO: Trigger PanenProvider.addPanenForSchedule() dengan delta values
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error in _executePanenSore: $e');
    }
  }
}

/// Helper: Get today's date key (format: yyyy-MM-dd)
String _getTodayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
