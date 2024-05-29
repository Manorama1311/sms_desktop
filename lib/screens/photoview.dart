import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:sms/utils/constants.dart' as contants;
import 'package:sms/utils/constants.dart';

class PhotoViewPage extends StatelessWidget {
  final List photos;
  final int index;

  const PhotoViewPage({
    Key? key,
    required this.photos,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        titleSpacing: 0,

      ),
      body: Container(
        color: Colors.white,
        child: PhotoViewGallery.builder(
          itemCount: photos.length,
          builder: (context, index) => PhotoViewGalleryPageOptions.customChild(
            child: CachedNetworkImage(
              imageUrl: localurlLogin + photos[index]["url"],
              placeholder: (context, url) => Container(
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.red.shade400,
              ),
            ),
            minScale: PhotoViewComputedScale.covered,
            heroAttributes: PhotoViewHeroAttributes(tag:localurlLogin + photos[index]["url"]),
          ),
          pageController: PageController(initialPage: index),
          enableRotation: false,
        ),
      ),
    );
  }
}