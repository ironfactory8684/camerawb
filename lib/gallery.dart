import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

import 'list_photo_views.dart';

class ScreenGallery extends StatefulWidget {
  const ScreenGallery({Key? key}) : super(key: key);

  @override
  State<ScreenGallery> createState() => _ScreenGalleryState();
}

class _ScreenGalleryState extends State<ScreenGallery> {

  List<Album> imageAlbums =[];
  bool boolIsLoading = true;
  bool isGrid = true;
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

    if(boolIsLoading){
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            setState(() {
              isGrid = !isGrid;
            });
          }, icon: Icon(isGrid?Icons.menu:Icons.grid_view))
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
          isGrid?
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 2.0,
            crossAxisSpacing: 2.0,
            children: _media.map((medium) => GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) =>
                        ListPhotoViews(
                          photoDatList: [medium], index: 0,)));
              },
              child: Column(
                children: [
                  SizedBox(
                      height: 80,
                      child:  Container(
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
                      ),),
                  Text(medium.filename!,maxLines: 1,)
                ],
              ))).toList(),
          ):
          ListView.builder(itemBuilder: (ctx,idx){
            return ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) =>
                        ListPhotoViews(
                          photoDatList: [_media[idx]], index: 0,)));
              },
              leading:Container(
                height: 80,
                child: FadeInImage(
                  fit: BoxFit.cover,
                  placeholder: MemoryImage(kTransparentImage),
                  image: ThumbnailProvider(
                    mediumId: _media[idx].id,
                    mediumType: _media[idx].mediumType,
                    highQuality: true,
                  ),
                ),
              ),
              title: Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.bottomCenter,
                child: Text(_media[idx].filename!),
              ),
            );
          },itemCount: _media.length,),
        ),
      ),
    );
  }
}
