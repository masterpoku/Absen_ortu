import 'package:d_info/d_info.dart';
import 'package:d_view/d_view.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../source/source_db.dart';

class FilterAbsensiPage extends StatefulWidget {
  const FilterAbsensiPage({Key? key, required this.user}) : super(key: key);
  final Map user;

  @override
  State<FilterAbsensiPage> createState() => _FilterAbsensiPageState();
}

class _FilterAbsensiPageState extends State<FilterAbsensiPage> {
  final controllerFrom = TextEditingController();
  final controllerTo = TextEditingController();

  startFilter() {
    if (controllerFrom.text == '' || controllerTo.text == '') {
      DInfo.toastError('Input Tanggal Harus Diisi');
    } else {
      getListFilter();
    }
  }

  List<Map<String, dynamic>> listFilter = [];
  RxBool loading = false.obs;

  getListFilter() async {
    loading.value = true;
    listFilter = await SourceDB.filterAbsensi(
      widget.user['rfid'],
      controllerFrom.text,
      controllerTo.text,
    );
    setState(() {});
    loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Filter Absen'),
        actions: [
          IconButton(
            onPressed: () => startFilter(),
            icon: const Icon(Icons.check),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
            decoration: BoxDecoration(
              color: Colors.cyan[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text('dari'),
                DView.spaceWidth(8),
                Expanded(
                  child: DateTimeField(
                    controller: controllerFrom,
                    format: DateFormat('yyyy-MM-dd'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
                    },
                  ),
                ),
                DView.spaceWidth(8),
                const Text('sampai'),
                DView.spaceWidth(8),
                Expanded(
                  child: DateTimeField(
                    controller: controllerTo,
                    format: DateFormat('yyyy-MM-dd'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
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
                      'Nama',
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
              return listFilter.isEmpty
                  ? DView.empty('Belum ada absen berdasarkan filter')
                  : ListView.separated(
                      padding: const EdgeInsets.all(0),
                      itemCount: listFilter.length,
                      itemBuilder: (context, index) {
                        Map item = listFilter[index];
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
