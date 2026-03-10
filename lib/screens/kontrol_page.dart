import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kandang_model.dart';
import '../models/penjadwalan_model.dart';
import '../providers/kandang_provider.dart';
import '../providers/penjadwalan_provider.dart';

class KontrolPage extends StatefulWidget {
  const KontrolPage({super.key});

  @override
  State<KontrolPage> createState() => _KontrolPageState();
}

class _KontrolPageState extends State<KontrolPage> {
  int _selectedTab = 0; // 0: Penjadwalan, 1: Tambah Kandang

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade100,
              Colors.amber.shade100,
              Colors.greenAccent.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Tab Selector
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTab == 0
                                    ? Colors.orange.shade600
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Penjadwalan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _selectedTab == 0
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: _selectedTab == 0
                                  ? Colors.orange.shade600
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTab == 1
                                    ? Colors.orange.shade600
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Tambah Kandang',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _selectedTab == 1
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: _selectedTab == 1
                                  ? Colors.orange.shade600
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: _selectedTab == 0
                    ? _buildPenjadwalanTab()
                    : _buildTambahKandangTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPenjadwalanTab() {
    final penjadwalanProvider = context.watch<PenjadwalanProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atur Penjadwalan Panen',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola jadwal panen untuk semua kandang',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: penjadwalanProvider.penjadwalans.length,
            itemBuilder: (context, index) {
              final jadwal = penjadwalanProvider.penjadwalans[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jadwal.jam,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                jadwal.keterangan,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Durasi: ${jadwal.durasi}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Switch(
                                value: jadwal.aktif,
                                onChanged: (value) {
                                  penjadwalanProvider.togglePenjadwalan(
                                    jadwal.id,
                                  );
                                },
                                activeColor: Colors.green.shade600,
                              ),
                              Text(
                                jadwal.aktif ? 'Aktif' : 'Nonaktif',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: jadwal.aktif
                                      ? Colors.green.shade600
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _showEditJadwalDialog(context, jadwal),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                penjadwalanProvider.deletePenjadwalan(
                                  jadwal.id,
                                );
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Hapus'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showTambahJadwalBaru(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Jadwal Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTambahKandangTab() {
    final kandangProvider = context.watch<KandangProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kelola Kandang',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambah, edit, atau hapus kandang',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          // Daftar Kandang
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kandangProvider.kandangs.length,
            itemBuilder: (context, index) {
              final kandang = kandangProvider.kandangs[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kandang.nama,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${kandang.jumlahAyam} ekor ayam',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.home, color: Colors.orange.shade600),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _showEditKandangDialog(context, kandang),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                kandangProvider.deleteKandang(kandang.id);
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Hapus'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showTambahKandangDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Kandang Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditJadwalDialog(BuildContext context, Penjadwalan jadwal) {
    final jamController = TextEditingController(text: jadwal.jam);
    final durasiController = TextEditingController(text: jadwal.durasi);
    final keteranganController = TextEditingController(text: jadwal.keterangan);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Jadwal Panen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: jamController,
              decoration: const InputDecoration(
                hintText: 'Jam (HH:MM)',
                prefixIcon: Icon(Icons.schedule),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durasiController,
              decoration: const InputDecoration(
                hintText: 'Durasi (contoh: 30 menit)',
                prefixIcon: Icon(Icons.timer),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keteranganController,
              decoration: const InputDecoration(
                hintText: 'Keterangan',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (jamController.text.isNotEmpty &&
                  durasiController.text.isNotEmpty &&
                  keteranganController.text.isNotEmpty) {
                context.read<PenjadwalanProvider>().updatePenjadwalan(
                      jadwal.id,
                      jamController.text,
                      durasiController.text,
                      keteranganController.text,
                      jadwal.aktif,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showTambahJadwalBaru(BuildContext context) {
    final jamController = TextEditingController();
    final durasiController = TextEditingController();
    final keteranganController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Jadwal Panen Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: jamController,
              decoration: const InputDecoration(
                hintText: 'Jam (HH:MM)',
                prefixIcon: Icon(Icons.schedule),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durasiController,
              decoration: const InputDecoration(
                hintText: 'Durasi (contoh: 30 menit)',
                prefixIcon: Icon(Icons.timer),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keteranganController,
              decoration: const InputDecoration(
                hintText: 'Keterangan',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (jamController.text.isNotEmpty &&
                  durasiController.text.isNotEmpty &&
                  keteranganController.text.isNotEmpty) {
                context.read<PenjadwalanProvider>().addPenjadwalan(
                      'global',
                      'Semua Kandang',
                      jamController.text,
                      durasiController.text,
                      keteranganController.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showTambahKandangDialog(BuildContext context) {
    final namaController = TextEditingController();
    final jumlahAyamController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kandang Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                hintText: 'Nama Kandang',
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: jumlahAyamController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Jumlah Ayam',
                prefixIcon: Icon(Icons.pets),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (namaController.text.isNotEmpty &&
                  int.tryParse(jumlahAyamController.text) != null) {
                context.read<KandangProvider>().addKandang(
                      namaController.text,
                      int.parse(jumlahAyamController.text),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditKandangDialog(BuildContext context, Kandang kandang) {
    final namaController = TextEditingController(text: kandang.nama);
    final jumlahAyamController = TextEditingController(
      text: kandang.jumlahAyam.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Kandang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                hintText: 'Nama Kandang',
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: jumlahAyamController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Jumlah Ayam',
                prefixIcon: Icon(Icons.pets),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (namaController.text.isNotEmpty &&
                  int.tryParse(jumlahAyamController.text) != null) {
                context.read<KandangProvider>().updateKandang(
                      kandang.id,
                      namaController.text,
                      int.parse(jumlahAyamController.text),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
