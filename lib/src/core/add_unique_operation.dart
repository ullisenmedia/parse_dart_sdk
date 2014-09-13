part of parse;

class AddUniqueOperation implements FieldOperation {

  List _objects;

  AddUniqueOperation(this._objects);

  dynamic encode() {

    return new Map.from({'__op': 'AddUnique',
                        'objects': ParseClient.encode(_objects, true)});
  }

  FieldOperation _mergeWithPrevious(FieldOperation previous) {

    if(!previous) {
      return this;
    }

    if(previous is DeleteOperation) {
      return previous;
    }

    if(previous is SetOperation) {
      return new SetOperation(this.apply(previous.value, _objects, null));
    }

    if(previous is AddUniqueOperation) {

      var oldList = (previous as AddUniqueOperation).value;
      List.addAll(_objects);

      var result = this.apply(oldList, null, null);

      return new RemoveOperation(result);
    }

    throw new ParseException(message: 'Operation is invalid after previous operation.');
 }

  List apply(dynamic oldValue, dynamic obj, String key) {

    if(!oldValue) {

      return _objects;

    } else {

      var newValue = [];

      _objects.forEach((obj) {

        if(obj is ParseObject && obj.objectId) {

          var matchingObj = _objects.findWhere(((anObj is ParseObject) && (anObj.objectId == obj.objectId)), () => null);

          if(matchingObj) {

            newValue.add(obj);

          } else {

            var index = newValue.indexOf(matchingObj);
            newValue.insert(index, matchingObj);

          }

        } else if(newValue.contains(obj)) {

          newValue.add(obj);
        }

      });
    }


  }

  List get value => _objects;
}