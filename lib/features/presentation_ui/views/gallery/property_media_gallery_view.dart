import 'package:flutter/material.dart';

class PropertyMediaGalleryView extends StatelessWidget {
  final List<String> mediaUrls;

  const PropertyMediaGalleryView({super.key, required this.mediaUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Property Media Gallery', style: TextStyle(color: Colors.white)),
      ),
      body: PageView.builder(
        itemCount: mediaUrls.length,
        itemBuilder: (context, index) {
          return Center(
            child: Image.network(
              mediaUrls[index],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image, size: 100, color: Colors.white38),
            ),
          );
        },
      ),
    );
  }
}
