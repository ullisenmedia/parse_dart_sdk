part of parse;

abstract class FieldOperation extends Encodable {

  dynamic apply(dynamic oldValue, dynamic object, String key);
  FieldOperation mergeWithPrevious(dynamic previous);
}