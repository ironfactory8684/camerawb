import 'package:hive/hive.dart';

class LocalStorage {
  final String _camerWb = 'camerWb';
  Future saveNumber(
      {required int? number}) async {

    final Box box = await Hive.openBox(_camerWb);
    await box.put('number', number);
  }

  Future<int?> loadNumber() async {
    final Box box = await Hive.openBox(_camerWb);
    int? result = await box.get('number');
    return result;
  }


}
