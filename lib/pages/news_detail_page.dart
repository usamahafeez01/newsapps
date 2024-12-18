import 'package:flutter/material.dart';
class NewsDetailPage extends StatelessWidget {
  final dynamic article;

  NewsDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("News App")),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            article['urlToImage'] != null
                ? Image.network(article['urlToImage'])
                : SizedBox.shrink(),
            SizedBox(height: 10),
            Text(
              article['title'] ?? 'No Title',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(article['content'] ?? 'No Content'),
          ],
        ),
      ),
    );
  }
}
