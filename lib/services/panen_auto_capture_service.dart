import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../providers/panen_provider.dart';
import '../providers/kandang_provider.dart';

/// Service untuk menghubungkan PanenScheduler dengan PanenProvider
/// Bertanggung jawab untuk trigger capture otomatis
class PanenAutoCaptureService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Trigger capture panen pagi (biasanya dipanggil scheduler jam 09:00)
  /// Membaca sensor value untuk SETIAP kandang dan trigger capture
  static Future<void> triggerMorningCapture(
    PanenProvider panenProvider,
    KandangProvider kandangProvider,
  ) async {
    try {
      if (kDebugMode) {
        print('🟢 Triggering Morning Panen Capture');
      }

      // Baca sensor data dari Firebase
      final dataRef = _database.ref('data');
      final snapshot = await dataRef.get();

      if (snapshot.exists) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

        // Mapping kandang ke sensor
        // Sesuaikan dengan struktur firebase kamu
        final sensorMap = {
          'kandang_1': data['infra1'] ?? 0,
          'kandang_2': data['infra2'] ?? 0,
          // Tambah kandang lain sesuai kebutuhan
        };

        // Trigger capture untuk setiap kandang
        sensorMap.forEach((kandangId, sensorValue) {
          // Get kandang nama dari KandangProvider
          try {
            final kandang = kandangProvider.kandangs.firstWhere(
              (k) => k.id == kandangId,
            );

            panenProvider.captureScheduledPanenPagi(
              kandangId,
              kandang.nama,
              sensorValue as int,
            );
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Kandang $kandangId tidak found: $e');
            }
          }
        });

        if (kDebugMode) {
          print('✅ Morning capture triggered for all kandang');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in triggerMorningCapture: $e');
      }
    }
  }

  /// Trigger capture panen sore (biasanya dipanggil scheduler jam 15:00)
  /// Membaca sensor value untuk SETIAP kandang dan hitung delta
  static Future<void> triggerAfternoonCapture(
    PanenProvider panenProvider,
    KandangProvider kandangProvider,
  ) async {
    try {
      if (kDebugMode) {
        print('🟡 Triggering Afternoon Panen Capture');
      }

      // Baca sensor data dari Firebase
      final dataRef = _database.ref('data');
      final snapshot = await dataRef.get();

      if (snapshot.exists) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

        // Mapping kandang ke sensor
        final sensorMap = {
          'kandang_1': data['infra1'] ?? 0,
          'kandang_2': data['infra2'] ?? 0,
          // Tambah kandang lain sesuai kebutuhan
        };

        // Trigger capture untuk setiap kandang (dengan delta)
        sensorMap.forEach((kandangId, sensorValue) {
          // Get kandang nama dari KandangProvider
          try {
            final kandang = kandangProvider.kandangs.firstWhere(
              (k) => k.id == kandangId,
            );

            panenProvider.captureScheduledPanenSore(
              kandangId,
              kandang.nama,
              sensorValue as int,
            );
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Kandang $kandangId tidak found: $e');
            }
          }
        });

        if (kDebugMode) {
          print('✅ Afternoon capture triggered for all kandang');
        }

        // Reset snapshot harian setelah panen sore selesai
        // (Persiapan untuk hari berikutnya)
        Future.delayed(const Duration(seconds: 5), () {
          panenProvider.resetDailySnapshots();
          if (kDebugMode) {
            print('🔄 Daily snapshots reset after afternoon capture');
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in triggerAfternoonCapture: $e');
      }
    }
  }

  /// Initialize auto-capture service
  /// Panggil ini saat app start untuk restore state hari ini
  static Future<void> initialize(PanenProvider panenProvider) async {
    try {
      if (kDebugMode) {
        print('🚀 Initializing PanenAutoCaptureService');
      }

      // Load today's snapshots dari Firebase
      await panenProvider.loadTodaySnapshots();

      // Restore historical panen data
      await panenProvider.restorePanenHistoryFromFirebase();

      if (kDebugMode) {
        print('✅ PanenAutoCaptureService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing PanenAutoCaptureService: $e');
      }
    }
  }
}
