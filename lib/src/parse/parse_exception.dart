part of parse;

class ParseException implements Exception {

  final String message;
  final int code;
  Exception previous;

  ParseException([this.message = "", this.code = 0, Exception previous = null]);

  String toString() {

    if(!message) return "ParseException";

    return "ParseException: $message $code";
  }
}