import 'package:camerawb/camera/util_capture_button.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/src/layouts/awesome/widgets/awesome_filter_name_indicator.dart';
import 'package:camerawesome/src/layouts/awesome/widgets/awesome_filter_selector.dart';
import 'package:flutter/material.dart';

import '../gallery.dart';

class UtilCameraLayout extends StatelessWidget {
  final CameraState state;
  final OnMediaTap onMediaTap;
  final Function() setPreview;
  final Function() setSound;
  final bool isSound;
  const UtilCameraLayout({
  super.key,
  required this.state,
  this.onMediaTap, required this.setPreview, required this.setSound, required this.isSound,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
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
                      return snapshot.data == true
                          ? Align(
                          alignment: Alignment.bottomCenter,
                          child: AwesomeFilterNameIndicator(state: state))
                          : Center(
                          child: AwesomeSensorTypeSelector(state: state));
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 20,
                  child: IconButton(
                    onPressed: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context)=>ScreenGallery()));
                    },
                    icon: Icon(Icons.filter,color: Colors.white,),)

                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          AwesomeBackground(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 700),
              curve: Curves.fastLinearToSlowEaseIn,
              child: StreamBuilder<bool>(
                stream: state.filterSelectorOpened$,
                builder: (_, snapshot) {
                  return snapshot.data == true
                      ? AwesomeFilterSelector(state: state)
                      : const SizedBox(
                    width: double.infinity,
                  );
                },
              ),
            ),
          ),
          AwesomeBackground(
            child: SafeArea(
              top: false,
              child: Column(
                children: [

                  const SizedBox(height: 12),
                  AwesomeBottomActions(state: state,
                      setPreview:setPreview,
                      onMediaTap: onMediaTap),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
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
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AwesomeFlashButton(state: state),
            IconButton(
              color: Colors.black26,
                onPressed: ()=> setSound(), icon: Icon(isSound?Icons.volume_up_outlined:Icons.volume_off_outlined,color: Colors.white,)),
            AwesomeAspectRatioButton(state: state),
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
  const AwesomeBottomActions({
  super.key,
  required this.state,
  required this.setPreview,
  this.onMediaTap, required ,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Spacer(),
        UtilCaptureButton(state: state,
            setPreview:setPreview
        ),
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
