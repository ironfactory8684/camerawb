import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:better_open_file/better_open_file.dart';
import 'package:camerawb/camera/util_media_preview_new.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/src/widgets/layout/awesome_bottom_actions.dart' as bottomAction;
import 'package:camerawesome/src/widgets/layout/awesome_top_actions.dart' as topAction;
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:volume_watcher/volume_watcher.dart';

import '../controller.dart';
import '../image_editors/image_editor.dart';

class UtilCameraPage extends StatelessWidget {

  final controller = Get.put(CamerController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CamerController>(
        builder: (_) =>  controller.isLoading.value ?
        Scaffold(body: Center(child: CircularProgressIndicator(),),):
        Scaffold(
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
            sensorConfig: SensorConfig.single(
                aspectRatio: CameraAspectRatios.ratio_4_3,flashMode: FlashMode.auto),
            saveConfig: SaveConfig.photo(),

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
  final CamerController controller;
  const TakePhotoUI(this.state, this.controller, {Key? key}) : super(key: key);

  @override
  State<TakePhotoUI> createState() => _TakePhotoUIState();
}

class _TakePhotoUIState extends State<TakePhotoUI> {

  bool isPreview = false;
  bool isSound = true;
  double? minZoom;
  double? maxZoom;

  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
    PerfectVolumeControl.stream.listen((volume)  async {
      //volume button is pressed,
      // this listener will be triggeret 3 times at one button press
      print("hello");
      // await widget.state.takePhoto();
      await widget.state.when(
        onPhotoMode: (photoState){
          photoState.takePhoto();
          setState(() {
            isPreview = true;
          });
          // widget.setPreview();
        },
        // onVideoMode: (videoState) => videoState.startRecording(),
        // onVideoRecordingMode: (videoState) => videoState.stopRecording(),
      );

    });
  }

  fetch()async {
    minZoom = await CamerawesomePlugin.getMinZoom();
    maxZoom = await CamerawesomePlugin.getMaxZoom();
    setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    viewportSize = MediaQuery.of(context).size;

    if(isLoading){
      return CupertinoActivityIndicator();
    }

    return GetBuilder<CamerController>(
      builder: (getCtr)=>WillPopScope(
        onWillPop: ()async {
          if(isPreview){
            setState(() {
              isPreview = false;
            });
          }
          return false;
        },
        child: Stack(
          children: [

            UtilCameraLayout(
                controller:widget.controller,
                state: widget.state,
                setPreview:(){
                  if(isSound){
                    NativeShutterSound.play();
                  }
                  setState(() {
                    isPreview= true;
                  });
                },
                maxZoom:maxZoom,
                minZoom:minZoom,
                isSound:getCtr.isVolume.value,
                setSound:()=>getCtr.setVolume()),
            if(isPreview)
              Positioned.fill(
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
                            break;
                          case CameraAspectRatios.ratio_16_9:
                            _aspectRatioValue = 16 / 9;
                            break;
                        }

                        if(getCtr.isAutoSkip.value){
                          Future.delayed(Duration.zero,()async {
                            await Future.delayed(Duration(seconds: getCtr.skipSec));
                            var imageName = '${DateTime.now().toString().substring(0, 10).replaceAll("-", "")}_${widget.controller.count}';

                            Uint8List bytes = File(snapshot.data!.captureRequest.when(single: (single)=>single.file!.path)).readAsBytesSync();
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
                          });
                        };
                        return Column(
                          children: [

                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height-100,
                              child: UtilMediaPreviewNew(
                                aspectRatioValue:_aspectRatioValue,
                                mediaCapture: snapshot.data,
                                fitWidth:MediaQuery.of(context).size.width,
                                onMediaTap: (mediaCapture) {
                                  OpenFile.open(
                                    mediaCapture.captureRequest
                                        .when(single: (single) => single.file?.path),
                                  );
                                },
                              ),
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
                                      // GestureDetector(
                                      //   onTap: () async {
                                      //     Uint8List bytes = File(snapshot.data!.captureRequest.when(single: (single)=>single.file!.path)).readAsBytesSync();
                                      //     var result =await Navigator.push(context, MaterialPageRoute(builder:
                                      //     (context)=>ImageEditor(image: bytes,
                                      //         controller:widget.controller,
                                      //         aspectRatio:_aspectRatioValue)))??false;
                                      //     if(result){
                                      //       setState(() {
                                      //         isPreview = false;
                                      //       });
                                      //     }
                                      //   },
                                      //   child: Icon(Icons.brush,color: Colors.white,),
                                      // ),
                                      GestureDetector(
                                        onTap: () async {

                                          // saveVideo(snapshot.data!.captureRequest.when(single: (single)=>single.file!.path));
                                          var imageName = '${DateTime.now().toString().substring(0, 10).replaceAll("-", "")}_${widget.controller.count}';

                                          Uint8List bytes = File(snapshot.data!.captureRequest.when(single: (single)=>single.file!.path)).readAsBytesSync();
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
        ),
      ),
    );

  }

  Future saveVideo(String fileName) async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
          if (await _requestPermission(Permission.storage) &&
              // access media location needed for android 10/Q
              await _requestPermission(Permission.accessMediaLocation) &&
              // manage external storage needed for android 11/R
              await _requestPermission(Permission.manageExternalStorage)) {
          directory = await getExternalStorageDirectory();


          if(directory!=null){
            String newPath = "";
            List<String> paths = directory.path.split("/");
            for (int x = 1; x < paths.length; x++) {
              String folder = paths[x];
              if (folder != "Android") {
                newPath += "/" + folder;

              } else {
                break;
              }
            }
            newPath = newPath + "/cameraWb";
            print(newPath);
            directory = Directory(newPath);

          }else{
            return false;
          }
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        var imageName = '${DateTime.now().toString().substring(0, 10).replaceAll("-", "")}_${widget.controller.count}';
        await File(fileName).rename(directory.path + "/$imageName");
        if (Platform.isIOS) {
          Uint8List bytes = File(fileName).readAsBytesSync();
          var result =
          await ImageGallerySaver.saveImage(
              bytes,
              quality: 100,
              name: imageName,
              isReturnImagePathOfIOS: true
          );
        }
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }

    return false;
  }
  
}

class CenterCropClipper extends CustomClipper<Path> {
  final double width;
  final double height;

  const CenterCropClipper({
    required this.width,
    required this.height,
  });

  @override
  Path getClip(Size size) {
    final center = size.center(Offset.zero);
    return Path()
      ..addRect(
        Rect.fromCenter(
          center: center,
          width: width,
          height: height,
        ),
      );
  }

  @override
  bool shouldReclip(covariant CenterCropClipper oldClipper) {
    return width != oldClipper.width || height != oldClipper.height;
  }
}