import 'dart:io';
import 'dart:typed_data';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
// import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:native_shutter_sound/native_shutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camerawb/camera/util_camera.layout.dart';
import 'package:camerawb/camera/util_media_preview.dart';
import 'package:camerawb/db_helper.dart';

import '../controller.dart';
import '../image_editors/image_editor.dart';

class UtilCameraPage extends StatelessWidget {

  final controller = Get.put(Controller());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<Controller>(
        builder: (_) =>  controller.isLoading.value ?
        Scaffold(body: Center(child: CircularProgressIndicator(),),):
        WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body:
        CameraAwesomeBuilder.custom(
          builder: (cameraState, previewSize, previewRect) {
            return cameraState.when(
              onPreparingCamera: (state) =>
              const Center(child: CircularProgressIndicator()),
              onPhotoMode: (state) => TakePhotoUI(state,controller),
            );
          },
          previewFit: CameraPreviewFit.fitWidth,
          aspectRatio: CameraAspectRatios.ratio_16_9,
          saveConfig: SaveConfig.photo(pathBuilder: _path),
        ),
        // CameraAwesomeBuilder.awesome(
        //     onMediaTap: (mediaCapture) {
        //       print(mediaCapture);
        //     },
        //     saveConfig: SaveConfig.photo(pathBuilder: _path)),
      ),
    ));
  }

  Future<String> _path() async {
    final appDir = await getApplicationDocumentsDirectory();
    final testDir = await Directory('${appDir.path}/wbFile').create(recursive: true);
    print(appDir);
    final String fileExtension ='jpg';
    final String filePath =
        '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    return filePath;

  }


}

late Size viewportSize;

class TakePhotoUI extends StatefulWidget {
  final PhotoCameraState state;
  final Controller controller;
  const TakePhotoUI(this.state, this.controller, {Key? key}) : super(key: key);

  @override
  State<TakePhotoUI> createState() => _TakePhotoUIState();
}

class _TakePhotoUIState extends State<TakePhotoUI> {

  bool isPreview = false;
  bool isSound = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    viewportSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        UtilCameraLayout(state: widget.state,setPreview:(){
          if(isSound){
            NativeShutterSound.play();
          }
          setState(() {
            isPreview= true;
          });
        },
            isSound:isSound,
        setSound:()=> setState(() {isSound = !isSound;})),
        if(isPreview)Positioned.fill(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              color: Colors.black,
              child: StreamBuilder<MediaCapture?>(
                stream: widget.state.captureState$,
                builder: (_, snapshot) {
                  if (snapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  double _aspectRatioValue = 16 / 9;
                  switch(widget.state.sensorConfig.aspectRatio){
                      case CameraAspectRatios.ratio_4_3:
                      _aspectRatioValue = 4 / 3;
                      break;
                      case CameraAspectRatios.ratio_1_1:
                      _aspectRatioValue = 1;
                  }
                  return Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height-100,
                        child:
                  ClipPath(
                  clipper: CenterCropClipper(
                  aspectRatio: _aspectRatioValue,
                    isWidthLarger: MediaQuery.of(context).size.width>MediaQuery.of(context).size.height-100,
                  ),
                  child: UtilMediaPreview(
                  mediaCapture: snapshot.data!,
                  onMediaTap: (MediaCapture mediaCapture) {
                  // ignore: avoid_print
                  print("Tap on $mediaCapture");
                  },
                  ),
                  )
                        // Center(
                        //   child: ,
                        // ),
                      ),
                      Container(
                        height: 100,
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('파일명 : ${DateTime.now().toString().substring(0, 10).replaceAll("-", "")}_${widget.controller.count}.jpg',style: TextStyle(color: Colors.white),),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      isPreview = false;
                                    });
                                  },
                                  child: Text('다시 찍기',style: TextStyle(color: Colors.white),),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    Uint8List bytes = File(snapshot.data!.filePath).readAsBytesSync();
                                    var result =await Navigator.push(context, MaterialPageRoute(builder:
                                    (context)=>ImageEditor(image: bytes,
                                        controller:widget.controller,
                                        aspectRatio:_aspectRatioValue)))??false;
                                    if(result){
                                      setState(() {
                                        isPreview = false;
                                      });
                                    }
                                  },
                                  child: Icon(Icons.brush,color: Colors.white,),
                                ),
                                GestureDetector(
                                  onTap: () async {

                                    var imageName = '${DateTime.now().toString().substring(0, 10).replaceAll("-", "")}_${widget.controller.count}';
                                    Uint8List bytes = File(snapshot.data!.filePath).readAsBytesSync();
                                    var result =
                                    await ImageGallerySaver.saveImage(
                                        bytes,
                                        quality: 100,
                                        name: imageName,
                                        isReturnImagePathOfIOS: true

                                    );
                                    widget.controller.increment(imageName);
                                    setState(() {
                                      isPreview = false;
                                    });
                                  },
                                  child: Text('사진 사용',style: TextStyle(color: Colors.white),),
                                )
                              ],),
                          ],
                        ),)

                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}