import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'lib/firebase_options.dart';
import 'lib/services/panen_scheduler.dart';
import 'lib/services/panen_auto_capture_service.dart';
import 'lib/providers/panen_provider.dart';
import 'lib/providers/kandang_provider.dart';
import 'lib/providers/penjadwalan_provider.dart';
// Import halaman utama kamu
// import 'lib/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) print('✅ Firebase initialized');
  } catch (e) {
    if (kDebugMode) print('❌ Firebase init error: $e');
  }

  // Initialize Scheduler untuk auto panen 09:00 dan 15:00
  try {
    await PanenScheduler.initialize();
    if (kDebugMode) {
      print('═══════════════════════════════════════');
      print('🚀 TELURKU SCHEDULER ACTIVATED');
      print('═══════════════════════════════════════');
      print('📅 Panen Pagi: Setiap hari jam 09:00');
      print('📅 Panen Sore: Setiap hari jam 15:00');
      print('═══════════════════════════════════════');
    }
  } catch (e) {
    if (kDebugMode) print('❌ Scheduler init error: $e');
  }

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
  late PenjadwalanProvider _penjadwalanProvider;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    if (kDebugMode) print('🔄 Initializing providers...');

    // Create providers
    _panenProvider = PanenProvider();
    _kandangProvider = KandangProvider();
    _penjadwalanProvider = PenjadwalanProvider();

    try {
      // Initialize auto-capture service (restore data dari Firebase)
      await PanenAutoCaptureService.initialize(_panenProvider);

      if (kDebugMode) {
        print('✅ All providers initialized');
        print('✅ PanenAutoCaptureService ready');
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Error initializing services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Panen Provider - untuk manage panen data & auto capture
        ChangeNotifierProvider<PanenProvider>.value(value: _panenProvider),
        // Kandang Provider - untuk manage kandang dan real-time sensor
        ChangeNotifierProvider<KandangProvider>.value(value: _kandangProvider),
        // Penjadwalan Provider - untuk manage jadwal panen
        ChangeNotifierProvider<PenjadwalanProvider>.value(
          value: _penjadwalanProvider,
        ),
        // Tambah provider lain sesuai kebutuhan
      ],
      child: MaterialApp(
        title: 'TelurKu - Smart Poultry Farm',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.orange,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.light,
          ),
        ),
        home: const HomePage(), // Ganti dengan halaman home kamu
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  @override
  void dispose() {
    _panenProvider.dispose();
    _kandangProvider.dispose();
    _penjadwalanProvider.dispose();
    super.dispose();
  }
}

// PLACEHOLDER HOME PAGE
// Ganti dengan halaman home kamu yang actual
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TelurKu - Scheduler Ready'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✅ Sistem Scheduler Aktif',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Panen akan dicatat otomatis:',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Panen Pagi: 09:00 setiap hari',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const Text(
                    '• Panen Sore: 15:00 setiap hari',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Data akan tersimpan otomatis ke Firebase',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Status Scheduler
            const Text(
              'Status Scheduler Hari Ini',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer<PanenProvider>(
              builder: (context, panenProvider, _) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        title: 'Panen Pagi',
                        icon: '🌅',
                        status: panenProvider.isPanenPagiRecordedToday(
                          'kandang_1',
                        ),
                        time: '09:00',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatusCard(
                        title: 'Panen Sore',
                        icon: '🌆',
                        status: panenProvider.isPanenSoreRecordedToday(
                          'kandang_1',
                        ),
                        time: '15:00',
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Test Buttons (untuk development/testing)
            if (kDebugMode) ...[
              const Text(
                '🧪 Testing Buttons (Debug Mode)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 12),
              Consumer2<PanenProvider, KandangProvider>(
                builder: (context, panenProvider, kandangProvider, _) {
                  return Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await PanenAutoCaptureService.triggerMorningCapture(
                            panenProvider,
                            kandangProvider,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Manual panen pagi triggered'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.sunny),
                        label: const Text('Test: Trigger Panen Pagi (09:00)'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await PanenAutoCaptureService.triggerAfternoonCapture(
                            panenProvider,
                            kandangProvider,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Manual panen sore triggered'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.cloud),
                        label: const Text('Test: Trigger Panen Sore (15:00)'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          panenProvider.resetDailySnapshots();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✅ Daily snapshots reset (prep tomorrow)',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset Daily Snapshots'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Info Box
            Container(
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
                    'ℹ️ Cara Kerja',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Sistem akan secara otomatis menjalankan panen pagi pada jam 09:00\n'
                    '2. Sensor akan dibaca dan nilai disimpan ke Firebase\n'
                    '3. Pada jam 15:00, sistem akan menjalankan panen sore\n'
                    '4. Nilai sore akan dikurangi dengan nilai pagi (delta calculation)\n'
                    '5. Semua data tersimpan di Firebase untuk historical record\n'
                    '6. Dashboard menampilkan status terakhir dan riwayat produksi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data Info
            Consumer<PanenProvider>(
              builder: (context, panenProvider, _) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📊 Data Hari Ini',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Total panen tercatat: ${panenProvider.panens.length} record',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Panen pagi kandang_1: ${panenProvider.getPanenPagiTodayValue('kandang_1') ?? 'Belum'} telur',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Panen sore kandang_1: ${panenProvider.getPanenSoreTodayValue('kandang_1') ?? 'Belum'} telur',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String icon,
    required bool status,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: status
            ? LinearGradient(
                colors: [Colors.green.shade300, Colors.green.shade600],
              )
            : LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade500],
              ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status ? '✅ Selesai' : '⏳ Menunggu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
