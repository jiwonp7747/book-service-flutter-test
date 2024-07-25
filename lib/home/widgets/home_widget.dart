import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final _formKey = GlobalKey<FormState>();
  String bookSummary="";
  TextEditingController titleController = TextEditingController();
  bool isLoading=false;

  // 서버에서 책 요약을 가져오는 함수
  Future<void> fetchBookSummary(String title) async {

    setState(() {
      isLoading=true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.14:8080/flask'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'bookName': title,
          'description':"description"
        }),
      );
      // 요청 받기
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData['bookName']);
        setState(() {
          bookSummary = responseData['content']; // 서버로부터 받은 요약 데이터
        });
        print("200 ok: $bookSummary");
      } else {
        // 서버 오류 응답 처리
        setState(() {
          bookSummary = "Error: Could not fetch summary";
        });
      }

    } catch (e) {
      setState(() {
        bookSummary = "Error: $e";
      });
    }finally{
      setState(() {
        isLoading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "책 내용 요약 서비스",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "책 제목",
                  hintText: "책 제목을 입력하세요",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "필수 항목 입니다.";
                  }
                  return null;
                },
      
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(color: Colors.grey),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "책 설명",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    if(isLoading)
                      Center(child: CircularProgressIndicator())
                    else
                      Text(bookSummary),
                  ],
                ),
              ),
              ElevatedButton(onPressed: () {fetchBookSummary(titleController.text);},
                  child: Text("button")),
            ],
          ),
        ),
      ),
    );
  }
}
