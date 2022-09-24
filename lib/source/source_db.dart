
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SourceDB {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static Future<Map> login(String idStudent, String password) async {
    var response = await _db
        .collection('Student')
        .where('id_siswa', isEqualTo: idStudent)
        .where('password', isEqualTo: password)
        .get();
    if (response.size > 0) {
      var user = response.docs[0].data();
      user['absensi'] = (await getAbsenToday(user['rfid']));
      return user;
    }
    return {};
  }

  static Future<Map<String, dynamic>> getAbsenToday(String rfid) async {
    var response = await _db
        .collection('Absensi')
        .where('rfid', isEqualTo: rfid)
        .where(
          'date',
          isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        )
        .get();
    if (response.size > 0) {
      return response.docs[0].data();
    }
    return {};
  }

  static Future<List<Map<String, dynamic>>> getAbsensiWeek(String rfid) async {
    DateTime now = DateTime.now();
    List<String> weeks = [
      DateFormat('yyyy-MM-dd').format(now),
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1))),
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 2))),
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 3))),
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 4))),
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 5))),
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 6))),
    ];
    var response = await _db
        .collection('Absensi')
        .where('date', isGreaterThanOrEqualTo: weeks.last)
        .get();

    List<Map<String, dynamic>> list = response.docs
        .where((e) => e.data()['rfid'] == rfid)
        .toList()
        .map((e) => e.data())
        .toList();
    List<Map<String, dynamic>> newWeeks = weeks.map((e) {
      Map<String, dynamic> data = {
        'rfid': rfid,
        'date': e,
        'time': 'Tidak Masuk',
      };
      var absensi = list.where((element) => element['date'] == e).toList();
      if (absensi.isNotEmpty) {
        data = absensi.first;
      }
      return data;
    }).toList();
    // response.docs.map((e) => e.data()).toList();
    // list.sort((a, b) => b['date'].compareTo(a['date']));
    return newWeeks;
  }

  static Future<List<Map<String, dynamic>>> filterAbsensi(
    String rfid,
    String from,
    String to,
  ) async {
    var response = await _db
        .collection('Absensi')
        .where('date', isGreaterThanOrEqualTo: from)
        .get();
    List<Map<String, dynamic>> list = response.docs
        .where((e) => e.data()['rfid'] == rfid)
        .toList()
        .map((e) => e.data())
        .toList();

    List<Map<String, dynamic>> listFilter = [];
    DateTime dateFrom = DateTime.parse(from);
    DateTime dateTo = DateTime.parse(to);
    int totalDays = dateTo.difference(dateFrom).inDays;
    for (var i = 0; i <= totalDays; i++) {
      String currentDay =
          DateFormat('yyyy-MM-dd').format(dateTo.subtract(Duration(days: i)));
      Map<String, dynamic> data = {
        'rfid': rfid,
        'date': currentDay,
        'time': 'Tidak Masuk',
      };
      var absensi =
          list.where((element) => element['date'] == currentDay).toList();
      if (absensi.isNotEmpty) {
        data = absensi.first;
      }
      listFilter.add(data);
    }
    return listFilter;
  }
}
