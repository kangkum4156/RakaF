import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rokafirst/data/product_data.dart';

class NoticeDetailScreen extends StatelessWidget {
  final String title;
  final String text;
  final String image;
  final String time;

  const NoticeDetailScreen({
    super.key,
    required this.title,
    required this.text,
    required this.image,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime;
    try {
      DateTime dateTime = DateTime.parse(time);
      formattedTime = DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      formattedTime = time;
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (image != 'null' && image.isNotEmpty)
                Image.network(
                  servertoken + image,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        "이미지를 불러올 수 없습니다",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  },
                )
              else
                const Center(
                  child: Text(
                    "Image not found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                text,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              Text(
                formattedTime,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
