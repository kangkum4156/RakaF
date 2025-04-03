import 'package:flutter/material.dart';
import 'package:rokafirst/data/product_data.dart'; // selectedNotices를 가져오기
import 'package:rokafirst/body/notice/noticedetail.dart'; // 공지 상세 화면
import 'package:intl/intl.dart';

class NoticeBody extends StatelessWidget {
  const NoticeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: selectedNotices.isEmpty
          ? const Center(
        child: Text('공지사항이 없습니다.'),
      )
          : ListView.builder(
        itemCount: selectedNotices.length,
        itemBuilder: (context, index) {
          var notice = selectedNotices[index];
          return NoticeCard(
            index: index,
            title: notice['name'] ?? '공지 ${index + 1}',
            time: notice['time'] ?? '',
            text: notice['text'] ?? '',
            image: notice['image'] ?? '',
          );
        },
      ),
    );
  }
}

class NoticeCard extends StatelessWidget {
  final int index;
  final String title;
  final String time;
  final String text;
  final String image;

  const NoticeCard({
    super.key,
    required this.index,
    required this.title,
    required this.time,
    required this.text,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = '';
    try {
      DateTime dateTime = DateTime.parse(time);
      formattedTime = DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      formattedTime = time;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoticeDetailScreen(
              title: title,
              time: time,
              text: text,
              image: image,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formattedTime,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),

            ],
          ),
        ),
      ),
    );
  }
}
