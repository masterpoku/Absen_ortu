import 'package:absensi_arduino_ortu/page/filter_absensi_page.dart';
import 'package:absensi_arduino_ortu/source/source_db.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../config/app_asset.dart';
import '../config/var.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.user}) : super(key: key);
  final Map user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> listWeek = [];

  RxBool loading = false.obs;

  getListWeek() async {
    loading.value = true;
    listWeek = await SourceDB.getAbsensiWeek(widget.user['rfid']);
    setState(() {});
    loading.value = false;
  }

  void whatsAppOpen() async {
    await FlutterLaunch.launchWhatsapp(
      phone: "+628978885716",
      message: "Halo, saya dengan orang tua nya ${widget.user['name']}",
    );
  }

  @override
  void initState() {
    getListWeek();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: DView.nothing(),
        leadingWidth: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(AppAsset.icSchool, height: 30),
            const Icon(Icons.school),
            DView.spaceWidth(),
            const Text(
              Var.schollName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Transform.translate(
        offset: const Offset(-12, 12),
        child: GestureDetector(
          onTap: () => whatsAppOpen(),
          child: Image.asset(
            AppAsset.wa,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 80,
                      child: Text('Nama'),
                    ),
                    Text(
                      ': ${widget.user['name']}',
                    ),
                  ],
                ),
                DView.spaceHeight(8),
                Row(
                  children: [
                    const SizedBox(
                      width: 80,
                      child: Text('Kelas'),
                    ),
                    Text(
                      ': ${widget.user['id_class']}',
                    ),
                  ],
                ),
                DView.spaceHeight(8),
                Row(
                  children: [
                    const SizedBox(
                      width: 80,
                      child: Text('Absen'),
                    ),
                    Text(
                      ': ${widget.user['absensi']['time'] ?? 'Tidak Masuk'}',
                    ),
                  ],
                ),
                DView.spaceHeight(8),
              ],
            ),
          ),
          DView.spaceHeight(8),
          ElevatedButton(
            onPressed: () {
              Get.to(() => FilterAbsensiPage(user: widget.user));
            },
            child: const Text('Filter Absen'),
          ),
          DView.spaceHeight(),
          Material(
            elevation: 2,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black87,
                radius: 16,
                child: Text(
                  'No',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              horizontalTitleGap: 0,
              title: Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Tanggal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'Jam Masuk',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (loading.value) return DView.loadingCircle();
              return listWeek.isEmpty
                  ? DView.empty('Belum ada absen untuk minggu ini')
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: listWeek.length,
                      itemBuilder: (context, index) {
                        Map item = listWeek[index];
                        String jamMasuk = item['time'] ?? 'Tidak Masuk';
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            child: Text('${index + 1}'),
                          ),
                          horizontalTitleGap: 0,
                          tileColor: jamMasuk == 'Tidak Masuk'
                              ? Colors.red[200]
                              : null,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  DateFormat('EEEE, dd/MM/yyyy', 'id_ID')
                                      .format(
                                    DateTime.parse(item['date']),
                                  ),
                                ),
                              ),
                              Text(jamMasuk),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        endIndent: 16,
                        indent: 16,
                      ),
                    );
            }),
          ),
        ],
      ),
    );
  }
}
