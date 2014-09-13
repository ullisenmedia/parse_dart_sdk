part of parse;

class ParseException extends Exception {

  ParseException({String message, Number code: 0, Exception previous}) : super(message, code, previous);
}