part of parse;

class ParseAggregationException extends ParseException {

  final List _errors;

  ParseAggregationException([String message, List errors = [], Exception previous = null ]): super(message, 600, previous) {

    _errors = errors;
  }

  get errors => _errors;
}