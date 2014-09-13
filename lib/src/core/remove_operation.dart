part of parse;

class RemoveOperation implements FieldOperation {

  List _objects;

  RemoveOperation(this._objects);

  dynamic encode() {

    return new Map.from({
                          '__op': 'Remove',
                          'objects': ParseClient.encode(_objects, true)
                        });
  }

  FileOperation mergeWithPrevious(dynamic previous) {

    if(!previous) {
      return this;
    }

    if(previous is DeleteOperation) {
      return previous;
    }

    if(previous is SetOperation) {
      return new SetOperation(this.apply(previous.value, _objects, null));
    }

    if(previous is RemoveOperation) {

      var oldList = (previous as RemoveOperation).value;
      List.addAll(_objects);

      return new RemoveOperation(oldList);
    }

    throw new ParseException(message: 'Operation is invalid after previous operation.');
  }

  List apply(List oldValue, List object, String key) {


    if(oldValue.isEmpty) {

      return [];

    } else {

      var newValue = [];

      oldValue.forEach((oldObject) {

        object.forEach((newObject) {

          if(oldObject is ParseObject) {

            if(newObject is ParseObject
               && !((oldObject as ParseObject).isDirty())
               && (oldObject as ParseObject).objectId == (newObject as ParseObject).objectId) {

              // found the object, won't add it.
            } else {

              newValue.add(oldObject);
            }

          } else {

            if(oldObject != newObject) {
              newValue.add(oldObject);
            }
          }

        });
      });

      return newValue;
    }
  }

  List get value => _objects;
}