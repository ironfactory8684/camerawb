import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';


class ListPhotoViews extends StatefulWidget {
  ListPhotoViews(
      {required this.photoDatList,
        required this.index,});

  List photoDatList;
  int index;

  @override
  _ListPhotoViewsState createState() => _ListPhotoViewsState();
}

class _ListPhotoViewsState extends State<ListPhotoViews> {
  ScrollController photoController = ScrollController();
  GlobalKey<ScrollSnapListState> sslKey = GlobalKey();
  late String nickName;

  late String date;
  bool isMe = false;
  double defaultItemHeight = 30;
  late Size viewportSize;
  bool isLoading = true;
  // late String photoData;
  bool isAPScrolling = false;
  int currentSelectedAPIndex = -1;
  int secondsInterval = 1;
  int _focusedIndex = 0;
  PageController pageController = PageController();
  bool isExpanded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // photoData = widget.photoDatList[widget.index];

    _focusedIndex = widget.index;
    fetch();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  fetch() async {
    setState(() {
      isLoading =false;
    });

  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CupertinoActivityIndicator()));
    }

    viewportSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isExpanded?null:AppBar(backgroundColor: Colors.black,iconTheme: IconThemeData(color: Colors.white),),
      bottomSheet: isExpanded?null:Container(
        color: Colors.black,
        height: 50,
        width: viewportSize.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                ],
              ),
              Text(
                '${_focusedIndex + 1}/${widget.photoDatList.length.toString()}',
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height,
              ),
              child:
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: _buildItem,
                itemCount: widget.photoDatList.length,
                pageController: pageController,
                onPageChanged: onPageChanged,
                scrollDirection: Axis.horizontal,
              ),
            ),
            // if(!isExpanded)   WdgtHeaderWithChild(
            //     str_title: photoData['USER_NICK'],
            //     child: Text(
            //       dateText,
            //       style: HDTextStyles.HaedolWhiteN.copyWith(fontSize: 12),
            //     ),
            //     backColor: Colors.black,
            //     textColor: Colors.white),
            if (widget.photoDatList.length > 1&&!isExpanded)
              Positioned(
                bottom: 70,
                child: Container(
                  height: 60,
                  width: viewportSize.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: ScrollSnapList(
                          onItemFocus: _onItemFocus,
                          listController: photoController,
                          itemSize: 50,
                          key: sslKey,
                          itemBuilder: (ctx, idx) {
                            return GestureDetector(
                              onTap: () {
                                if (sslKey.currentState != null) {
                                  sslKey.currentState!.focusToItem(idx);
                                  // photoData = widget.photoDatList[idx];
                                }
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    border: idx == _focusedIndex
                                        ? Border.all(
                                        color: Colors.red, width: 3)
                                        : Border()),
                                child: Image.network(
                                      widget.photoDatList[idx],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                          itemCount: widget.photoDatList.length,
                          dynamicItemSize: false,
                          // dynamicSizeEquation: customEquation, //optional
                        ),
                      ),
                    ],
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    widget.photoDatList[index];
    return  PhotoViewGalleryPageOptions(
      onTapDown: (ctx, tap,value){
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      imageProvider: PhotoProvider(mediumId: widget.photoDatList[index].id),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
      maxScale: PhotoViewComputedScale.covered * 4.1,
      // heroAttributes: PhotoViewHeroAttributes(tag: item.id),
    );
  }

  void onPageChanged(int index) {

    setState(() {
      _focusedIndex = index;
      // photoData = widget.photoDatList[index];
    });
  }

  void _onItemFocus(int index) {
    pageController.animateToPage(index, duration: Duration(milliseconds: 200), curve:Curves.easeOut);
    setState(() {
      _focusedIndex = index;
      // photoData = widget.photoDatList[index];
    });
  }
}
