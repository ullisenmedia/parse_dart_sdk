part of parse;

class DeleteOperation implements FieldOperation {

  dynamic encode() {

    return new Map.from({'__op' : 'Delete'});
  }

  FileOperation mergeWithPrevious(dynamic previous) {

    return this;
  }

  apply(List oldValue, List object, String key) {

    return null;
  }
}
