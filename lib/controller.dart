import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:camerawb/db_helper.dart';
import 'package:hive/hive.dart';

import 'camera/local_storage.dart';

class CamerController extends GetxController {
  // final LocalStorage _localStorage = GetIt.I.get<LocalStorage>();
  final String _camerWb = 'camerWb';
  late Box box;
  var count = 0;
  var skipSec = 3;
  RxBool isLoading = true.obs;
  RxBool isVolume = true.obs;
  TextEditingController ctrSetNumber = TextEditingController();
  RxBool isAutoSkip = false.obs;
  @override
  // TODO: implement initialized
  @override
  onInit() async {
    var result = await DBHelper().select();
    box = await Hive.openBox(_camerWb);
    int? number = await box.get('number');
    if(number!=null){
      count = number;
    }else{
      count = result.length+1;
      await box.put('number',count);
    }
    bool? isVolumeHive = await box.get('isVolume');
    bool? isAutoSkipHive = await box.get('isAutoSkip');
    if(isAutoSkipHive!=null){
      isAutoSkip = isAutoSkipHive?true.obs:false.obs;
      int? skipSecHive = await box.get('skipSec');
      if(skipSecHive!=null){
        skipSec = skipSecHive;
      }
    }

    if(isVolumeHive!=null){
      isVolume= isVolumeHive?true.obs:false.obs;
    }

    ctrSetNumber.text = count.toString();
    isLoading = false.obs;
    update();
  }


  void setAutoSkip() async {
    if(isAutoSkip.value==true){
      isAutoSkip = false.obs;
    }else{
      isAutoSkip = true.obs;

    }
    await box.put('isAutoSkip',isAutoSkip.value);
    update();
  }

  void setAutoSkipSec(int value) async {
    skipSec = value;
    await box.put('skipSec',skipSec);
    update();
  }


  void setVolume() async {
    if(isVolume.value==true){
      isVolume = false.obs;
    }else{
      isVolume = true.obs;

    }
    await box.put('isVolume',isVolume.value);
    update();
  }

  void setNumber(int value) async {
    count = value;
    await box.put('number',count);
    update();
  }

  void increment(path) async {
    var result = await DBHelper().add(path);
    count++;
    await box.put('number',count);
    ctrSetNumber.text = count.toString();
    update();
  }
}