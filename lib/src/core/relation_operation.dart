part of parse;

class RelationOperation implements FieldOperation {

  String _targetClassName;
  List _relationsToAdd = [];
  List _relationsToRemove = [];

  RelationOperation(List objectsToAdd, List objectsToRemove) {

    _targetClassName = null;

    _relationsToAdd = new Collection(objectsToAdd.map(pointerToId)).distinct().toList();
    _relationsToRemove = new Collection(objectsToRemove.map(pointerToId)).distinct();

    if (_targetClassName == null) {
      throw new Exception('Cannot create a ParseRelationOperation with no objects.');
    }
  }

  dynamic pointerToId(dynamic object) {

    if (object is ParseObject) {

      if (object.objectId) {
        throw new Exception('You can\'t add an unsaved ParseObject to a relation.');
      }

      String objectClassName = object.className;

      if (!_targetClassName) {
        _targetClassName = objectClassName;
      }

      if (_targetClassName != objectClassName) {
        throw new Exception('All objects in a relation must be of the same class.');
      }

      return object.objectId;

    }

    return object;
  }

  dynamic idToPointer(dynamic id) {

    return new Map.from({
                            '__type': 'Pointer', 'className': _targetClassName, 'objectId': id
                        });
  }

  dynamic encode() {

    var addRelation = [];
    var removeRelation = [];

    if (_relationsToAdd.isNotEmpty) {

      addRelation.add({'__op': 'AddRelation', 'objects': ParseClient.encode(_relationsToAdd.map())});
    }

    if (_relationsToRemove.isNotEmpty) {

      removeRelation.add({'__op': 'RemoveRelation', 'objects': ParseClient.encode(_relationsToRemove.map())});
    }

    if(addRelation.isNotEmpty && removeRelation.isNotEmpty) {

      return new List.from({'__op': 'Batch',
                            'ops': [addRelation, removeRelation]});
    }

    return (addRelation.isEmpty) ? removeRelation : addRelation;

  }

  dynamic apply(dynamic oldValue, dynamic object, String key) {

  }

  FieldOperation mergeWithPrevious(dynamic previous) {

  }

  String get targetClassName => _targetClassName;
}