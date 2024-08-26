import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

// WebScraper 클래스를 main_activity.dart에 통합
class WebScraper {
  final String baseUrl;
  int pageCount = 1; // 기본 페이지 수는 1로 설정
  List<Map<String, String?>> scrapedData = [];

  WebScraper(this.baseUrl);

  Future<void> scrape(int page) async {
    try {
      final url = '$baseUrl?page=$page';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final postElements = document.querySelectorAll('a[href^="/posts/"]');

        scrapedData = []; // 새 페이지 로드 시 데이터 초기화
        for (var postElement in postElements) {
          final link = postElement.attributes['href'];
          final titleElement = postElement.querySelector('.line-clamp-2');
          final title = titleElement?.text.trim();
          final imageElement = postElement.querySelector('img');
          final imageUrl = imageElement?.attributes['src'];

          if (link != null && title != null) {
            scrapedData.add({
              'title': title,
              'imageUrl': imageUrl,
              //'link': 'https://www.allforyoung.com$link', // 링크를 사용하려면 이 줄을 복구
            });
          }
        }
      } else {
        print('페이지 $page 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('크롤링 중 오류 발생: $e');
    }
  }
}

// main 함수와 MyApp 클래스는 그대로 유지
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '대외활동_웹 크롤러',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebScraperScreen(),
    );
  }
}

// WebScraperScreen 클래스는 activity.dart와 main_activity.dart가 통합된 결과물
class WebScraperScreen extends StatefulWidget {
  @override
  _WebScraperScreenState createState() => _WebScraperScreenState();
}

class _WebScraperScreenState extends State<WebScraperScreen> {
  final WebScraper _scraper = WebScraper('https://www.allforyoung.com/posts/activity');
  List<Map<String, String?>> _posts = [];
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _loadPage(_currentPage);
  }

  Future<void> _loadPage(int page) async {
    await _scraper.scrape(page);
    setState(() {
      _posts = _scraper.scrapedData;
      _totalPages = 22; // Set to the maximum number of pages
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('대외활동'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return ListTile(
                  leading: post['imageUrl'] != null
                      ? Image.network(post['imageUrl']!)
                      : null,
                  title: Text(post['title'] ?? '제목 없음'),
                  subtitle: post['link'] != null
                      ? Text('링크: ${post['link']}')
                      : null,
                );
              },
            ),
          ),
          if (_totalPages > 1) // Only show pagination if there are multiple pages
            Container(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_totalPages, (index) {
                    final pageNumber = index + 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (pageNumber != _currentPage) {
                            setState(() {
                              _currentPage = pageNumber;
                              _loadPage(_currentPage);
                            });
                          }
                        },
                        child: Text('$pageNumber'),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
