import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:camerawb/db_helper.dart';

class Controller extends GetxController {
  var count = 0;
  RxBool isLoading = true.obs;
  @override
  // TODO: implement initialized
  @override
  onInit() async {
    var result = await DBHelper().select();
    count = result.length+1;
    isLoading = false.obs;
    update();
  }
  void increment(path) async {
    var result = await DBHelper().add(path);
    count++;
    update();
  }
}