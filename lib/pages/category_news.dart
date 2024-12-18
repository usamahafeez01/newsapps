import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:newsapp/pages/progress_indicator.dart';
import 'package:newsapp/progress_indicator/purple_progress_indicator.dart';

import 'news_detail_page.dart';

class CategoryNews extends StatefulWidget {
  @override
  _CategoryNewsState createState() => _CategoryNewsState();
}

class _CategoryNewsState extends State<CategoryNews> {
  final List<String> categories = [
    'General',
    'Business',
    'Entertainment',
    'Health',
    'Science',
    'Sports',
    'Technology',
  ];
  String selectedCategory = 'General';
  List<dynamic> articles = [];
  bool isLoading = false;

  Future<void> fetchNewsByCategory(String category) async {
    setState(() {
      isLoading = true;
    });
    final apiKey = '15cd6057c2fe4b069110dba533b457b7'; // Replace with your API key
    final url = Uri.parse(
        'https://newsapi.org/v2/top-headlines?category=$category&country=us&apiKey=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          articles = data['articles'];
        });
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news by category: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNewsByCategory(selectedCategory);
  }

  // Method to limit words in a string
  String limitWords(String text, int wordLimit) {
    List<String> words = text.split(' ');
    if (words.length > wordLimit) {
      return words.take(wordLimit).join(' ') + '...';
    } else {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'News',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),

        ),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                    fetchNewsByCategory(category);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: selectedCategory == category
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category.toLowerCase(),
                        style: TextStyle(
                          color: selectedCategory == category
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: PurpleProgressIndicator())
                : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                DateTime publishedAt =
                DateTime.parse(article['publishedAt']);
                String formattedDate =
                DateFormat('MMMM dd, yyyy').format(publishedAt);

                // Get the source name and limit it to 3 words, adding "..." if there are more
String sourceName = article['source']['name'] ?? 'Unknown';
                sourceName = limitWords(sourceName, 3); // Apply word limit

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image with fixed size
                        article['urlToImage'] != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            article['urlToImage'],
                            height: 150, // Fixed height
                            width: 100, // Fixed width
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child,
                                loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                  child:
                                  BlueProgressIndicator(),
                                );
                              }
                            },
                          ),
                        )
                            : Container(
                          height: 150,
                          width: 100,
                          color: Colors.grey,
                          child: Icon(
                            Icons.article,
                            size: 50,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ), // Space between image and text
                        // Text section for title and source
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article['title'] ?? 'No Title',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black38,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 70),
                              Row(
                                children: [
                                  Text(
                                    sourceName, // Display limited source name with "..."
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 13,
                                  ),
                                  Flexible(
                                    child: Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
