import 'package:camerawb/camera/util_capture_button.dart';
import 'package:camerawb/controller.dart';
import 'package:camerawb/setting_page.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
// import 'package:camerawesome/src/layouts/awesome/widgets/awesome_filter_name_indicator.dart';
// import 'package:camerawesome/src/layouts/awesome/widgets/awesome_filter_selector.dart';
import 'package:flutter/material.dart';

import '../gallery.dart';

class UtilCameraLayout extends StatelessWidget {
  final CameraState state;
  final OnMediaTap onMediaTap;
  final Function() setPreview;
  final Function() setSound;
  final bool isSound;
  final CamerController controller;
  final double? maxZoom;
  final double? minZoom;
  const UtilCameraLayout({
  super.key,

  required this.state,
  this.onMediaTap, required this.setPreview, required this.setSound, required this.isSound,
    this.minZoom, this.maxZoom, required this.controller
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        const SizedBox(height: 16),
        AwesomeTopActions(state: state,setSound:setSound,isSound:isSound),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              SizedBox(
                height: 50,
                child: StreamBuilder<bool>(
                  stream: state.filterSelectorOpened$,
                  builder: (_, snapshot) {
                    return
                      // snapshot.data == true
                      //   ? Align(
                      //   alignment: Alignment.bottomCenter,
                      //   child: AwesomeFilterNameIndicator(state: state))
                      //   :
                    Center(
                        child: AwesomeSensorTypeSelector(state: state));
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                right: 20,
                child: Row(
                  children: [
                    ZoomIndicatorLayout(
                      zoom: state.sensorConfig.zoom,
                      min: minZoom!,
                      max: maxZoom!,
                      sensorConfig: state.sensorConfig,
                    ),
                    IconButton(
                      onPressed: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context)=>ScreenGallery()));
                      },
                      icon: Icon(Icons.filter,color: Colors.white,),),

                  ],
                )

              ),

            ],
          ),
        ),
        const SizedBox(height: 12),
        // AwesomeBackground(
        //   child: AnimatedSize(
        //     duration: const Duration(milliseconds: 700),
        //     curve: Curves.fastLinearToSlowEaseIn,
        //     child: StreamBuilder<bool>(
        //       stream: state.filterSelectorOpened$,
        //       builder: (_, snapshot) {
        //         return snapshot.data == true
        //             ? AwesomeFilterSelector(state: state)
        //             : const SizedBox(
        //           width: double.infinity,
        //         );
        //       },
        //     ),
        //   ),
        // ),

        AwesomeBackground(
          child: SafeArea(
            top: false,
            child: Column(
              children: [


                AwesomeBottomActions(
                    controller:controller,
                    state: state,
                    setPreview:setPreview,
                    onMediaTap: onMediaTap),

              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AwesomeTopActions extends StatelessWidget {
  final CameraState state;
  final Function() setSound;
  final bool isSound;
  const AwesomeTopActions({
  super.key,
  required this.state, required this.setSound, required this.isSound,
  });

  @override
  Widget build(BuildContext context) {
    if (state is VideoRecordingCameraState) {
      return const SizedBox.shrink();
    } else {
      // final theme =  AwesomeThemeProvider.of(context).theme;
      // print(theme.buttonTheme.rotateWithCamera);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AwesomeFlashButton(state: state),
            IconButton(
              color: Colors.black26,
                onPressed: ()=> setSound(), icon: Icon(isSound?Icons.volume_up_outlined:Icons.volume_off_outlined,color: Colors.white,)),
            if (state is PhotoCameraState)
              AwesomeAspectRatioButton(state: state as PhotoCameraState),
            Flexible(
              child: state is VideoRecordingCameraState
                  ? AwesomePauseResumeButton(
                  state: state as VideoRecordingCameraState)
                  : AwesomeCameraSwitchButton(state: state),
            ),
          ],
        ),
      );
    }
  }
}

class AwesomeBottomActions extends StatelessWidget {
  final CameraState state;
  final OnMediaTap onMediaTap;
  final Function() setPreview;
  final CamerController controller;
  const AwesomeBottomActions({
  super.key,
  required this.state,
  required this.setPreview,
  this.onMediaTap, required, required  this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: (){

        }, icon: Icon(Icons.settings,)),
        UtilCaptureButton(state: state,
            setPreview:setPreview
        ),
        IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingPage(controller:controller)));
        }, icon: Icon(Icons.settings,color: Colors.white,))
        // Spacer(),
      ],
    );
  }
}

class AwesomeBackground extends StatelessWidget {
  final Widget child;

  const AwesomeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: child,
    );
  }
}

class ZoomIndicatorLayout extends StatefulWidget {
  final double zoom;
  final double min;
  final double max;
  final SensorConfig sensorConfig;

  const ZoomIndicatorLayout({
    required this.zoom,
    required this.min,
    required this.max,
    required this.sensorConfig,
  });

  @override
  State<ZoomIndicatorLayout> createState() => ZoomIndicatorLayoutState();
}

class ZoomIndicatorLayoutState extends State<ZoomIndicatorLayout> {

  double initZoom =1.0;
  @override
  Widget build(BuildContext context) {

    return RotatedBox(
      quarterTurns: 4,
      child: Row(
        children: [
          IconButton(onPressed: (){
            if(widget.min<initZoom){
              setState(() {

                initZoom = initZoom-1;
                widget.sensorConfig.setZoom(initZoom/10);
              });

            }
          }, icon: Icon(Icons.remove,color: Colors.white,)),
          Slider(
            value: initZoom,
            onChanged: (newValue) {
              setState(() {
                initZoom = newValue;
              });

              widget.sensorConfig.setZoom(newValue/10);
            },
            min: widget.min,
            max: widget.max,

          ),
          IconButton(onPressed: (){
            if(widget.max>initZoom){
              setState(() {

                initZoom = initZoom+1;
                widget.sensorConfig.setZoom(initZoom/10);
              });

            }
          }, icon: Icon(Icons.add,color: Colors.white,)),
        ],
      ),
    );

    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     // Show 3 dots for zooming: min, 1.0X and max zoom. The closer one shows
    //     // text, the other ones a dot.
    //     _ZoomIndicator(
    //       normalValue: 0.0,
    //       zoom: zoom,
    //       selected: displayZoom < 1.0,
    //       min: min,
    //       max: max,
    //       sensorConfig: sensorConfig,
    //     ),
    //     Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 8),
    //       child: _ZoomIndicator(
    //         normalValue: (1 - min) / (max - min),
    //         zoom: zoom,
    //         selected: !(displayZoom < 1.0 || displayZoom == max),
    //         min: min,
    //         max: max,
    //         sensorConfig: sensorConfig,
    //       ),
    //     ),
    //     _ZoomIndicator(
    //       normalValue: 1.0,
    //       zoom: zoom,
    //       selected: displayZoom == max,
    //       min: min,
    //       max: max,
    //       sensorConfig: sensorConfig,
    //     ),
    //   ],
    // );
  }
}

class _ZoomIndicator extends StatelessWidget {
  final double zoom;
  final double min;
  final double max;
  final double normalValue;
  final SensorConfig sensorConfig;
  final bool selected;

  const _ZoomIndicator({
    required this.zoom,
    required this.min,
    required this.max,
    required this.normalValue,
    required this.sensorConfig,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final baseTheme = AwesomeThemeProvider.of(context).theme;
    final baseButtonTheme = baseTheme.buttonTheme;
    final displayZoom = (max - min) * zoom + min;
    Widget content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      transitionBuilder: (child, anim) {
        return ScaleTransition(scale: anim, child: child);
      },
      child: selected
          ? AwesomeBouncingWidget(
        key: ValueKey("zoomIndicator_${normalValue}_selected"),
        onTap: () {
          sensorConfig.setZoom(normalValue);
        },
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(0.0),
          child: AwesomeCircleWidget(
            theme: baseTheme,
            child: Text(
              "${displayZoom.toStringAsFixed(1)}X",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      )
          : AwesomeBouncingWidget(
        key: ValueKey("zoomIndicator_${normalValue}_unselected"),
        onTap: () {
          sensorConfig.setZoom(normalValue);
        },
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(16.0),
          child: AwesomeCircleWidget(
            theme: baseTheme.copyWith(
              buttonTheme: baseButtonTheme.copyWith(
                backgroundColor: baseButtonTheme.foregroundColor,
                padding: EdgeInsets.zero,
              ),
            ),
            child: const SizedBox(width: 6, height: 6),
          ),
        ),
      ),
    );

    // Same width for each dot to keep them in their position
    return SizedBox(
      width: 56,
      child: Center(
        child: content,
      ),
    );
  }
}