part of parse;

class AddOperation implements FieldOperation {

  List _objects;

  AddOperation(List objects) {

    if (objects && objects.isNotEmpty) {
      throw new ParseException("AddOperation requires an array.");
    }

    _objects = objects;
  }
}