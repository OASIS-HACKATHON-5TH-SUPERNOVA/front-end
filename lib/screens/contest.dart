import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

// 크롤러 클래스 정의
class ContestScraper {
  final String baseUrl;
  List<Map<String, String?>> scrapedData = [];
  int totalPages = 1;

  ContestScraper(this.baseUrl);

  // 모든 페이지를 크롤링하는 함수
  Future<void> scrapeAll() async {
    await _getTotalPages(); // 마지막 페이지 번호를 먼저 가져옴
    for (int page = 1; page <= totalPages; page++) {
      await scrapePage(page); // 각 페이지를 크롤링
    }
  }

  // 특정 페이지를 크롤링하는 함수
  Future<void> scrapePage(int page) async {
    try {
      final url = '$baseUrl?page=$page'; // 각 페이지 URL 생성
      print('Requesting URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
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

  // 마지막 페이지 번호를 추출하는 함수
  Future<void> _getTotalPages() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        // 페이지 번호를 가진 모든 a 태그를 가져옴
        final pageElements = document.querySelectorAll('ul.flex > li > a[href^="/posts/contest?page="]');

        // 페이지 번호들을 리스트로 저장
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

        // 페이지 번호들 중 가장 큰 번호를 총 페이지 수로 설정
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

// Flutter 애플리케이션의 메인 함수
void main() {
  runApp(MyApp());
}

// Flutter 애플리케이션의 루트 위젯
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '공모전 웹 크롤러',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ContestScreen(),
    );
  }
}

// Flutter 애플리케이션의 메인 화면 위젯
class ContestScreen extends StatefulWidget {
  @override
  _ContestScreenState createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> {
  final ContestScraper _scraper = ContestScraper('https://www.allforyoung.com/posts/contest');
  List<Map<String, String?>> _posts = [];
  bool _isLoading = true; // 데이터를 로드 중인지 여부를 표시하는 플래그
  int _currentPage = 1; // 현재 페이지를 추적하는 변수

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _scraper.scrapeAll(); // 모든 페이지 크롤링
    setState(() {
      _posts = _scraper.scrapedData;
      _isLoading = false; // 데이터 로드 완료
    });
  }

  // 페이지 버튼을 가로로 스크롤할 수 있도록 생성하는 메소드
  Widget _buildPaginationButtons() {
    if (_scraper.totalPages <= 1) {
      return SizedBox.shrink(); // 페이지가 1페이지 이하인 경우 버튼을 표시하지 않음
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_scraper.totalPages, (index) {
            final pageNumber = index + 1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  if (pageNumber != _currentPage) {
                    setState(() {
                      _currentPage = pageNumber;
                      _loadPage(_currentPage); // 페이지를 새로 로드
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: _currentPage == pageNumber ? Colors.blue : Colors.grey,
                ),
                child: Text('$pageNumber'),
              ),
            );
          }),
        ),
      ),
    );
  }

  // 선택된 페이지를 새로 로드하는 메소드
  Future<void> _loadPage(int pageNumber) async {
    setState(() {
      _isLoading = true; // 데이터 로드 시작
    });

    // 현재 페이지 데이터를 새로 로드
    _posts.clear(); // 기존 데이터 삭제
    await _scraper.scrapePage(pageNumber); // 선택된 페이지 크롤링
    setState(() {
      _posts = _scraper.scrapedData;
      _isLoading = false; // 데이터 로드 완료
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('공모전'),
      ),
      body: Column(
        children: [
          _isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator())) // 데이터 로딩 중일 때 로딩 표시
              : Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return ListTile(
                  leading: post['imageUrl'] != null
                      ? Image.network(post['imageUrl']!)
                      : null,
                  title: Text(post['title'] ?? '제목 없음'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post['dday'] != null)
                        Text('공모 기한: ${post['dday']}'), // 공모 기한 추가
                    ],
                  ),
                );
              },
            ),
          ),
          _buildPaginationButtons(), // 페이지 버튼 추가
        ],
      ),
    );
  }
}
