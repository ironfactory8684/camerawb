import 'package:camerawb/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingPage extends StatefulWidget {
  final CamerController controller;
  const SettingPage({Key? key, required this.controller}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CamerController>(
        builder: (_) =>Scaffold(
          appBar: AppBar(
            title: Text('설정'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                ListTile(title: Text("카메라 소리 설정"), trailing: Switch(onChanged: (value){
                  _.setVolume();
                }, value: _.isVolume.value,),),
                Padding(
                  padding: const EdgeInsets.only(left:15.0,right: 15),
                  child: Row(children: [
                    Text("시작 카운트 변경",style: TextStyle(fontSize: 16),),
                    Spacer(),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _.ctrSetNumber,
                        keyboardType:TextInputType.number,
                        textAlign: TextAlign.end,
                        decoration: InputDecoration()
                      ,),
                    ),
                    SizedBox(width: 10,),
                    OutlinedButton(onPressed: () {
                      if(_.ctrSetNumber.text.isNotEmpty&&isNumeric(_.ctrSetNumber.text)){

                        _.setNumber(int.parse((_.ctrSetNumber.text)));
                      }
                    }, child: Text('변경')),
                  ],),
                ),
                ListTile(title: Text("자동저장 설정"), trailing: Switch(onChanged: (value){
                  _.setAutoSkip();
                }, value: _.isAutoSkip.value,),),
                if(_.isAutoSkip.value)Padding(
                  padding: const EdgeInsets.only(left:15.0,right: 15),
                  child: Row(children: [
                    Text("자동저장 카운트 변경",style: TextStyle(fontSize: 16),),
                    Spacer(),
                    DropdownButton(items: [
                      DropdownMenuItem(child: Text("3"),value: 3,),
                      DropdownMenuItem(child: Text("5"),value: 5,),
                      DropdownMenuItem(child: Text("7"),value: 7,),
                      DropdownMenuItem(child: Text("10"),value: 10,)
                    ], onChanged: (value){
                      if(value!=null){
                        _.setAutoSkipSec(value!);
                      }
                    },value: _.skipSec,)
                  ],),
                ),

              ],
            ),
          ),
        )
    );

  }
  bool isNumeric(String s) {
    if(s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }
}
