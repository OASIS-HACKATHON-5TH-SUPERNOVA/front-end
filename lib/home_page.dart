import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../screens/main_page.dart';
import '../screens/login.dart'; // 로그인 페이지 파일을 가져옵니다.
import '../screens/activity.dart';
import '../screens/contest.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '호적메이트',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HohomeScreen(),
      debugShowCheckedModeBanner: false, // 디버그 배너 비활성화
    );
  }
}

// ActivityScraper 클래스 정의
class ActivityScraper {
  final String baseUrl;
  List<Map<String, String?>> scrapedData = [];

  ActivityScraper(this.baseUrl);

  Future<void> scrapeTop5() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final postElements = document.querySelectorAll('a[href^="/posts/"]').take(5); // 상위 5개만 가져옴

        for (var postElement in postElements) {
          final link = postElement.attributes['href'];
          final titleElement = postElement.querySelector('.line-clamp-2');
          final title = titleElement?.text.trim();
          final imageElement = postElement.querySelector('img');
          final imageUrl = imageElement?.attributes['src'];
          final ddayElement = postElement.querySelector('div > div > div');
          final dday = ddayElement?.text.trim();

          if (link != null && title != null) {
            scrapedData.add({
              'title': title,
              'imageUrl': imageUrl,
              'dday': dday,
            });
          }
        }
      } else {
        print('페이지 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('크롤링 중 오류 발생: $e');
    }
  }
}

// ContestScraper 클래스 정의
class ContestScraper {
  final String baseUrl;
  List<Map<String, String?>> scrapedData = [];
  int totalPages = 1;

  ContestScraper(this.baseUrl);

  Future<void> scrapeAll() async {
    await _getTotalPages(); // 마지막 페이지 번호를 먼저 가져옴
    for (int page = 1; page <= totalPages; page++) {
      await scrapePage(page); // 각 페이지를 크롤링
    }
  }

  Future<void> scrapePage(int page) async {
    try {
      final url = '$baseUrl?page=$page'; // 각 페이지 URL 생성
      print('Requesting URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final postElements = document.querySelectorAll('a[href^="/posts/"]');

        for (var postElement in postElements) {
          final link = postElement.attributes['href'];
          final titleElement = postElement.querySelector('.line-clamp-2');
          final title = titleElement?.text.trim();
          final imageElement = postElement.querySelector('img');
          final imageUrl = imageElement?.attributes['src'];
          final ddayElement = postElement.querySelector('div > div > div');
          final dday = ddayElement?.text.trim();

          if (link != null && title != null) {
            scrapedData.add({
              'title': title,
              'imageUrl': imageUrl,
              'dday': dday,
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

  Future<void> _getTotalPages() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        final pageElements = document.querySelectorAll(
          'ul.flex > li > a[href^="/posts/contest?page="]',
        );

        List<int> pageNumbers = [];

        for (var element in pageElements) {
          final href = element.attributes['href'];
          final regex = RegExp(r'page=(\d+)');
          final match = regex.firstMatch(href ?? '');

          if (match != null) {
            final pageNumber = int.parse(match.group(1) ?? '1');
            pageNumbers.add(pageNumber);
          }
        }

        if (pageNumbers.isNotEmpty) {
          totalPages = pageNumbers.reduce((a, b) => a > b ? a : b);
          print('총 페이지 수: $totalPages');
        }
      } else {
        print('페이지 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('총 페이지 수 추출 중 오류 발생: $e');
    }
  }
}

// Flutter 애플리케이션의 홈 화면 위젯
class HohomeScreen extends StatefulWidget {
  @override
  _HohomeScreenState createState() => _HohomeScreenState();
}

class _HohomeScreenState extends State<HohomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ActivityScraper _activityScraper = ActivityScraper('https://www.allforyoung.com/posts/activity');
  final ContestScraper _contestScraper = ContestScraper('https://www.allforyoung.com/posts/contest');
  List<Map<String, String?>> _posts = [];
  bool _isLoading = true;

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(), // 임시 페이지 콘텐츠
    CareerPage(), // 커리어 작성 페이지로 이동
    CareerEditPage(), // 임시 페이지 콘텐츠
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) { // "커리어 작성" 버튼
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CareerPage()), // CareerPage로 이동
      );
    } else if (index == 2) { // "커리어 수정" 버튼
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CareerEditPage()), // CareerEditPage로 이동
      );

    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTop5Posts();
  }

  Future<void> _fetchTop5Posts() async {
    await _activityScraper.scrapeTop5(); // 상위 5개 포스팅을 크롤링
    setState(() {
      _posts = _activityScraper.scrapedData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('호적메이트'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                '프로필',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.emoji_events),
              title: Text('대외활동'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WebScraperScreen()), // 대외활동 화면으로 이동
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.card_giftcard),
              title: Text('공모전'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContestScreen()), // 공모전 화면으로 이동
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.school),
              title: Text('강연/교육 게시판'),
              onTap: () {
                // 강연/교육 게시판 화면으로 이동
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('팀원 모집'),
              onTap: () {
                // 팀원 모집 화면으로 이동
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('진로/고민 게시판'),
              onTap: () {
                // 진로/고민 게시판 화면으로 이동
              },

            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator()) // 로딩 중 표시
                : Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // 가로 스크롤 설정
                child: Row(
                  children: _posts.map((post) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        elevation: 5,
                        child: Container(
                          width: 300, // 카드의 너비 설정
                          height: 450, // 카드의 높이 설정
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (post['imageUrl'] != null)
                                Image.network(
                                  post['imageUrl']!,
                                  height: 250, // 이미지 높이 설정
                                  width: 300, // 이미지 너비 설정
                                  fit: BoxFit.cover,
                                ),
                              SizedBox(height: 8.0),
                              Text(
                                post['title'] ?? '제목 없음',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8.0),
                              Text(post['dday'] ?? ''),
                              SizedBox(height: 8.0),
                              ElevatedButton(
                                onPressed: () {
                                  // '더 보기' 버튼 눌렀을 때 동작 추가
                                },
                                child: Text('더 보기'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: '커리어 작성',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: '커리어 수정',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
