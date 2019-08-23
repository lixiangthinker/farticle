import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
//  test("artivle_model test", () {
//
//
//
//    expect(decoded, equals(null));
//  });
//
//  test("String.trim() removes surrounding whitespace", () {
//    var string = "  foo ";
//    expect(string.trim(), equals("foo"));
//  });
   testParseJson();
}

void testParseJson() async {
  var client = http.Client();
  final response =
      await client.get('https://jsonplaceholder.typicode.com/photos');
  var decoded = json.decode(response.body);
  print(decoded);
}