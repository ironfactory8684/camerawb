// import 'dart:typed_data';
//
// import 'package:camerawesome/camerawesome_plugin.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:hand_signature/signature.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:camerawb/controller.dart';
//
// import '../db_helper.dart';
// import 'image_item.dart';
//
// class ImageEditor extends StatefulWidget {
//   final Uint8List image;
//   final double aspectRatio;
//   final Controller controller;
//   const ImageEditor({Key? key, required this.image, required this.aspectRatio, required this.controller}) : super(key: key);
//
//   @override
//   State<ImageEditor> createState() => _ImageEditorState();
// }
//
// class _ImageEditorState extends State<ImageEditor> {
//
//   ImageItem image = ImageItem();
//
//   Color pickerColor = Colors.white;
//   Color currentColor = Colors.white;
//
//   final control = HandSignatureControl(
//     threshold: 3.0,
//     smoothRatio: 0.65,
//     velocityRange: 2.0,
//   );
//
//   List<CubicPath> undoList = [];
//   bool skipNextEvent = false;
//
//   List<Color> colorList = [
//     Colors.black,
//     Colors.white,
//     Colors.blue,
//     Colors.green,
//     Colors.pink,
//     Colors.purple,
//     Colors.brown,
//     Colors.indigo,
//     Colors.indigo,
//   ];
//
//   void changeColor(Color color) {
//     currentColor = color;
//     setState(() {});
//   }
//   static ThemeData theme = ThemeData(
//     scaffoldBackgroundColor: Colors.black,
//     backgroundColor: Colors.black,
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.black87,
//       iconTheme: IconThemeData(color: Colors.white),
//       systemOverlayStyle: SystemUiOverlayStyle.light,
//       toolbarTextStyle: TextStyle(color: Colors.white),
//       titleTextStyle: TextStyle(color: Colors.white),
//     ),
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       backgroundColor: Colors.black,
//     ),
//     iconTheme: const IconThemeData(
//       color: Colors.white,
//     ),
//     textTheme: const TextTheme(
//       bodyMedium: TextStyle(color: Colors.white),
//     ),
//   );
//
//   @override
//   void initState() {
//     image.load(widget.image);
//     control.addListener(() {
//       if (control.hasActivePath) return;
//
//       if (skipNextEvent) {
//         skipNextEvent = false;
//         return;
//       }
//
//       undoList = [];
//       setState(() {});
//     });
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Theme(
//       data: theme,
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.clear),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//             Padding(
//               padding: const EdgeInsets.all(19.0),
//               child: Text('파일명 : ${DateTime.now().toString().substring(0, 10).replaceAll("-", "")}_${widget.controller.count}.jpg',style: TextStyle(color: Colors.white),),
//             ),
//             const Spacer(),
//             IconButton(
//               icon: Icon(
//                 Icons.undo,
//                 color: control.paths.isNotEmpty ? Colors.white : Colors.white.withAlpha(80),
//               ),
//               onPressed: () {
//                 if (control.paths.isEmpty) return;
//                 skipNextEvent = true;
//                 undoList.add(control.paths.last);
//                 control.stepBack();
//                 setState(() {});
//               },
//             ),
//             IconButton(
//               icon: Icon(
//                 Icons.redo,
//                 color: undoList.isNotEmpty ? Colors.white : Colors.white.withAlpha(80),
//               ),
//               onPressed: () {
//                 if (undoList.isEmpty) return;
//
//                 control.paths.add(undoList.removeLast());
//                 setState(() {});
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.check),
//               onPressed: () async {
//                 if (control.paths.isEmpty) return Navigator.pop(context);
//
//                 var data = await control.toImage(color: currentColor);
//                 var imageName = '${DateTime.now().toString().substring(0, 10).replaceAll("-", "")}_${widget.controller.count}';
//                 await ImageGallerySaver.saveImage(
//                     data!.buffer.asUint8List(),
//                     quality: 100,
//                     name: imageName,
//                     isReturnImagePathOfIOS: true
//
//                 );
//                 widget.controller.increment(imageName);
//                 return Navigator.pop(context, true);
//               },
//             ),
//           ],
//         ),
//         body: ClipPath(
//     clipper: CenterCropClipper(
//     aspectRatio: widget.aspectRatio,
//     isWidthLarger: MediaQuery.of(context).size.width>MediaQuery.of(context).size.height-100,
//     ),
//         child: Container(
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           decoration: BoxDecoration(
//             color: currentColor == Colors.black ? Colors.white : Colors.black,
//             image: DecorationImage(
//               image: Image.memory(widget.image).image,
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: HandSignature(
//             control: control,
//             color: currentColor,
//             width: 1.0,
//             maxWidth: 10.0,
//             type: SignatureDrawType.shape,
//           ),
//         ),),
//
//
//         bottomNavigationBar: SafeArea(
//           child: Container(
//             height: 80,
//             decoration: const BoxDecoration(
//               boxShadow: [
//                 BoxShadow(blurRadius: 2),
//               ],
//             ),
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: <Widget>[
//                 ColorButton(
//                   color: Colors.yellow,
//                   onTap: (color) {
//                     showModalBottomSheet(
//                       shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.only(
//                           topRight: Radius.circular(10),
//                           topLeft: Radius.circular(10),
//                         ),
//                       ),
//                       context: context,
//                       builder: (context) {
//                         return Container(
//                           color: Colors.black87,
//                           padding: const EdgeInsets.all(20),
//                           child: SingleChildScrollView(
//                             child: Container(
//                               padding: const EdgeInsets.only(top: 16),
//                               child: HueRingPicker(
//                                 pickerColor: pickerColor,
//                                 onColorChanged: changeColor,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//                 for (int i = 0; i < colorList.length; i++)
//                   ColorButton(
//                     color: colorList[i],
//                     onTap: (color) => changeColor(color),
//                     isSelected: colorList[i] == currentColor,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class ColorButton extends StatelessWidget {
//   final Color color;
//   final Function onTap;
//   final bool isSelected;
//
//   const ColorButton({
//     Key? key,
//     required this.color,
//     required this.onTap,
//     this.isSelected = false,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         onTap(color);
//       },
//       child: Container(
//         height: 34,
//         width: 34,
//         margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 23),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: isSelected ? Colors.white : Colors.white54,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//       ),
//
//     );
//   }
// }
