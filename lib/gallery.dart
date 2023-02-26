import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

class ScreenGallery extends StatefulWidget {
  const ScreenGallery({Key? key}) : super(key: key);

  @override
  State<ScreenGallery> createState() => _ScreenGalleryState();
}

class _ScreenGalleryState extends State<ScreenGallery> {

  List<Album> imageAlbums =[];
  bool boolIsLoading = true;
  List<Medium> _media =[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();


  }
  fetch()async {
    imageAlbums = await PhotoGallery.listAlbums(mediumType: MediumType.image);
    Album? album;
    imageAlbums.asMap().forEach((index,element) {

      if(element.name=="Pictures"){
        album = element;

      }
    });
    if(album==null){
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(
                    "아직 촬영된 사진이 없습니다.",style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    else{
      MediaPage mediaPage = await album!.listMedia();
      _media = mediaPage.items;
      // if(_media!=null){
      //   if(_media.isNotEmpty){
      //     _media.forEach((element) async {
      //       var a = await element.getThumbnail();
      //       Uint8List bytes = Uint8List.fromList(a);
      //       _thumbList.add(bytes);
      //       _thumbIdList.add(element.id);
      //       _thumbTypeList.add(element.mediumType);
      //       _thumbNameList.add(element.filename);
      //     });
      //     setState(() {
      //       boolIsLoading = false;
      //     });
      //   }
      // }
      setState(() {
        boolIsLoading = false;
      });



    }


  }

  @override
  Widget build(BuildContext context) {

    print(_media[0].filename);
    if(boolIsLoading){
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          children:
            _media.map((medium) => Stack(
              fit: StackFit.expand,
              alignment: Alignment.bottomCenter,
              children: [
                GestureDetector(
                  // onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => ViewerPage(medium))),
                  child: Container(
                    color: Colors.grey[300],
                    child: FadeInImage(
                      fit: BoxFit.cover,
                      placeholder: MemoryImage(kTransparentImage),
                      image: ThumbnailProvider(
                        mediumId: medium.id,
                        mediumType: medium.mediumType,
                        highQuality: true,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                  child: Text(medium.filename!),

                )
              ],
            )).toList()

        ),
      ),
    );
  }
}
