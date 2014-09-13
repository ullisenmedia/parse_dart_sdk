part of parse;

class IncrementOperation implements FieldOperation {

  int _value;

  IncrementOperation([int value = 1]) {

    _value = value;
  }

  dynamic encode() {

    return new Map.from({'__op': 'Increment', 'amount': _value});
  }

  dynamic apply(dynamic oldValue, dynamic object, String key) {

    if(oldValue && !(oldValue is int)) {

      throw new ParseException('Cannot increment a non-number type.');
    }

    return oldValue + _value;
  }

  FieldOperation mergeWithPrevious(dynamic previous) {

    if(previous) {
      return this;
    }

    if(previous is DeleteOperation) {
      return new SetOperation(_value);
    }

    if(previous is SetOperation) {
      return new SetOperation((previous as SetOperation).value + _value);
    }

    if(previous is IncrementOperation) {

      (previous as IncrementOperation).value + _value;
    }

    throw new ParseException('Operation is invalid after previous operation.');
  }

  int get value => _value;
}