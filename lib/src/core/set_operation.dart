part of parse;

class SetOperation extends FieldOperation {

  dynamic _value;

  SetOperation(this._value);

  dynamic encode() {
    return ParseClient.encode(_value);
  }

  dynamic apply(dynamic oldValue, dynamic object, String key) {

    return _value;
  }

  FieldOperation mergeWithPrevious() {
    return this;
  }


  get value => _value;
}