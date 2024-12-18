import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For formatting the date
import 'package:newsapp/pages/progress_indicator.dart';
import 'package:newsapp/progress_indicator/purple_progress_indicator.dart';

import 'category_news.dart';
import 'news_detail_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Popup Menu Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedChannel = 'Select a News Channel';
  List<dynamic> headlines = [];
  bool isLoading = false;
  String selectedCategory = 'General';
  List<dynamic> articles = [];

  final List<String> categories = [
    'General',
    'Business',
    'Entertainment',
    'Health',
    'Science',
    'Sports',
    'Technology',
  ];

  // Method to get a random category
  Future<void> fetchRandomNews() async {
    setState(() {
      isLoading = true;
    });

    final apiKey =
        '15cd6057c2fe4b069110dba533b457b7'; // Replace with your API key
    List<String> randomCategories =
        getRandomCategories(3); // Fetch 3 random categories
    List<dynamic> combinedArticles = [];

    try {
      for (String category in randomCategories) {
        final url = Uri.parse(
            'https://newsapi.org/v2/top-headlines?category=$category&country=us&apiKey=$apiKey');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          combinedArticles.addAll(data['articles']);
        } else {
          throw Exception('Failed to load news for $category');
        }
      }
      setState(() {
        articles = combinedArticles;
      });
    } catch (e) {
      print('Error fetching random news: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> getRandomCategories(int count) {
    final random = Random();
    List<String> shuffledCategories = List.from(categories)..shuffle(random);
    return shuffledCategories.take(count).toList();
  }

  // Method to fetch headlines based on selected channel
  Future<void> fetchHeadlines(String channel) async {
    setState(() {
      isLoading = true;
    });
    final apiKey =
        '15cd6057c2fe4b069110dba533b457b7'; // Replace with your actual API key
    final url = Uri.parse(
        'https://newsapi.org/v2/top-headlines?sources=$channel&apiKey=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          headlines = data['articles'];
        });
      } else {
        throw Exception('Failed to load headlines');
      }
    } catch (e) {
      print('Error fetching headlines: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // You can fetch headlines for a default channel when the app starts
    fetchHeadlines('bbc-news'); // Default channel (BBC News)
    fetchRandomNews();
    setState(() {
      selectedChannel = 'bbc-news';
    });
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
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryNews()),
              );
            },
            icon: Icon(
              Icons.dataset_outlined,
              color: Colors.black,
              size: 35,
            )),
        title: Center(
            child: const Text(
          'News App',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String channel) {
              setState(() {
                selectedChannel = channel;
              });
              fetchHeadlines(channel);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'bbc-news',
                child: Text('BBC News'),
              ),
              const PopupMenuItem(
                value: 'espn-news',
                child: Text('ESPN News'),
              ),
              const PopupMenuItem(
                value: 'al-jazeera-english',
                child: Text('Al-Jazeera News'),
              ),
              const PopupMenuItem(
                value: 'cnn',
                child: Text('CNN News'),
              ),
              const PopupMenuItem(
                value: 'nbc-news',
                child: Text('NBC News'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: PurpleProgressIndicator())
          : headlines.isEmpty
              ? Center(
                  child: Text(
                    'Select a news channel to view headlines.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: headlines.map((article) {
                            // Format date to show it nicely
                            DateTime publishedAt =
                                DateTime.parse(article['publishedAt']);
                            String formattedDate =
                                DateFormat('MMMM-dd-yyyy').format(publishedAt);

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NewsDetailPage(article: article),
                                  ),
                                );
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width / 1.1,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Card(
                                    elevation: 3,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        article['urlToImage'] != null
                                            ? Image.network(
                                                article['urlToImage'],
                                                height: 150,
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                        .width,
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
                                              )
                                            : Container(
                                                height: 150,
                                                color: Colors.green,
                                                child: Icon(
                                                  Icons.article,
                                                  size: 50,
                                                  color: Colors.black,
                                                ),
                                              ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            article['title'] ?? 'No Title',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Channel name and date at the bottom
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 18.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Channel name - Blue color
                                              Text(
                                                selectedChannel
                                                    .replaceAll('-', ' ')
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight
                                                        .bold // Channel name color changed to blue
                                                    ),
                                              ),
                                              // Date - Black and Bold
                                              Text(
                                                formattedDate,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  // Bold text
                                                  color: Colors
                                                      .black, // Black color for date
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
                                    DateFormat('MMMM dd, yyyy')
                                        .format(publishedAt);

                                // Get the source name and limit it to 3 words, adding "..." if there are more
                                String sourceName =
                                    article['source']['name'] ?? 'Unknown';
                                sourceName = limitWords(
                                    sourceName, 3); // Apply word limit

                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Image with fixed size
                                        article['urlToImage'] != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  article['urlToImage'],
                                                  height: 150, // Fixed height
                                                  width: 100, // Fixed width
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                    sourceName,
                                                    // Display limited source name with "..."
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
