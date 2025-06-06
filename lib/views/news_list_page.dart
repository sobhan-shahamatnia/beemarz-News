import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controllers/news_controller.dart';

class NewsListPage extends StatelessWidget {
  final NewsController newsController = Get.put(NewsController());

  NewsListPage({Key? key}) : super(key: key);

  /// Pre-cache images for all news items.
  Future<void> _precacheImages(BuildContext context, List<dynamic> newsList) async {
    for (var newsItem in newsList) {
      final imageUrl = newsItem['image'] ?? '';
      if (imageUrl.isNotEmpty) {
        try {
          await precacheImage(CachedNetworkImageProvider(imageUrl), context);
        } catch (e) {
          debugPrint("Failed to precache image: $imageUrl");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trigger fetching news when the widget builds.
    newsController.fetchNews();

    return Scaffold(
      appBar: AppBar(
        title: Directionality(
          textDirection: TextDirection.ltr,
          child: const Text(
            'BeeMarz',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Obx(() {
        if (newsController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          );
        } else if (newsController.errorMessage.isNotEmpty) {
          return Center(child: Text(newsController.errorMessage.value));
        } else if (newsController.newsList.isEmpty) {
          return const Center(child: Text('اخباری موجود نیست.'));
        } else {
          return FutureBuilder(
            future: _precacheImages(context, newsController.newsList),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  itemCount: newsController.newsList.length,
                  itemBuilder: (context, index) {
                    final newsItem = newsController.newsList[index];
                    return NewsCard(newsItem: newsItem);
                  },
                );
              }
            },
          );
        }
      }),
    );
  }
}

class NewsCard extends StatefulWidget {
  final Map<String, dynamic> newsItem;

  const NewsCard({Key? key, required this.newsItem}) : super(key: key);

  @override
  _NewsCardState createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool isTranslated = false; // Controls whether to show both titles.

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.newsItem['image'] ?? '';
    final originalTitle = widget.newsItem['title'] ?? 'عنوان موجود نیست';
    final translatedTitle = widget.newsItem['translated_title'] ?? 'ترجمه موجود نیست';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      // Outer Container instead of Card.
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // You can adjust background color if desired
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Large image at the top.
            imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 200, // Make this bigger to display a larger image
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 200,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image_not_supported, size: 80),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image, size: 80),
                  ),

            // Title section.
            Padding(
              padding: const EdgeInsets.all(16),
              child: isTranslated
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          originalTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.left,
                          textDirection: TextDirection.ltr,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          translatedTitle,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    )
                  : Text(
                      originalTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.left,
                      textDirection: TextDirection.ltr,
                    ),
            ),

            // Row for the icons.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Read More icon.
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      final url = widget.newsItem['url'] ?? '';
                      if (url.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsWebViewPage(url: url),
                          ),
                        );
                      }
                    },
                  ),
                  // Translate icon.
                  IconButton(
                    icon: Icon(
                      Icons.translate,
                      color: isTranslated ? Colors.blue : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        isTranslated = !isTranslated;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class NewsWebViewPage extends StatefulWidget {
  final String url;

  const NewsWebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  _NewsWebViewPageState createState() => _NewsWebViewPageState();
}

class _NewsWebViewPageState extends State<NewsWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بازگشت'),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
