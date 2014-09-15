part of parse;

class ParseObject implements Encodable {

  static const String ENPOINT = '/classes/${_className}/${_objectId}';
  static const String BATCH_ENDPOINT = '/batch/';

  String _className;
  String _objectId;

  Map _serverData;
  Map _dataAvailability;
  Map _operationSet;

  Map estimatedData;

  DateTime _createdAt;
  DateTime _updatedAt;

  bool _hasBeenFetched;

  static Map<String, Type> registeredSubclasses = new Map();

  ParseObject(this._className) {

    estimatedData = new Map();

    _serverData = new Map();
    _dataAvailability = new Map();
    _operationSet = new Map();

    _hasBeenFetched = true;
  }

  add(String key, Object value) {

    _performOperation(key, new AddOperation(value));
  }

  addAll(String key, List<dynamic> values) {

  }

  addUnique(String key, Object value) {

    _performOperation(key, new AddUniqueOperation(value));
  }

  addAllUnique(String key, List<dynamic> values) {

  }


  bool containsKey(String key) {

  }

  static create(String className) {

    ParseSubClass SubClass = ParseObject.registeredSubclasses[className];

    if(SubClass) {

      return SubClass.newParseClass(className);

    } else {

      return new ParseObject(className);
    }
  }

  static createWithoutData(String className, String objectId) {

  }

  Future<dynamic> destroy() {

    if(!_objectId) {
      return;
    }

    var sessionToken = null;
    var currentUser = ParseUser.currentUser;

    if(currentUser) {
      sessionToken = currentUser.getSessionToken();
    }

    var path = ENPOINT;

    return ParseClient.request(method: HttpMethod.DELETE, path: path);
  }

  Future<dynamic> destroyAll(List<dynamic> objects) {

    var completer = new Completer();

    var errors = [];
    var results = [];
    var promises = [];
    var count = objects.length;

    if(count) {
      var batchSize = 40;
      var processed = 0;
      var currentBatch = [];
      var currentCount = 0;

      while(processed < count) {
        currentCount++;
        currentBatch.add(objects.elementAt(processed++));

        if(currentCount == batchSize || processed == count) {
          promises.add(destoryBatch(currentBatch));
        }
      }

      currentBatch = [];
      currentCount = 0;
    }

    Future.wait(promises).then((result) {

      return completer.complete(result);

    }).catchError((error) {

      return completer.completeError(error);
    });

    return completer.future;
  }

  static Future<dynamic> destoryBatch(List objects) {

    var data = [];
    var errors = [];

    String path = "";

    objects.forEach((element) {
      data.add({'method': HttpMethod.DELETE, 'path': ENPOINT});

    });

    var sessionToken = null;
    var currentUser = ParseUser.currentUser;

    if(currentUser) {
      sessionToken = currentUser.sessionToken;
    }

    return ParseClient.request(method: HttpMethod.POST, path: BATCH_ENDPOINT, body: new Map.from({'request': data}));
  }

  delete(String key) {

    _performOperation(key, new DeleteOperation());
  }

  clear(String key) {

    estimatedData.forEach((String key) {

      delete(key);

    });
  }

  Future<dynamic> fetch() {

    var sessionToken = null;
    var currentUser = ParseUser.currentUser;

    if(currentUser) {

      sessionToken = currentUser.sessionToken;
    }

    ParseClient.request(path: ENPOINT).then((response) {

      _mergeAfterFetch(response);

      return this;
    });
  }

  static Future<dynamic> fetchAll(List<dynamic> objects) {

  }

  static Future<dynamic> fetchAllIfNeeded(List<dynamic> objects) {

  }

  _mergeAfterFetch([Object result, bool completeData = true]) {

    for(var key in result) {
      if(_operationSet[key]) {
        _operationSet.remove(key);
      }
    }

    _serverData = new Map();
    _dataAvailability = new Map();
    _mergeFromServer(result, completeData);
    _rebuildEstimatedData();
  }

  mergeAfterSave(List result) {

    _applyOperations(_operationSet, _serverData);
    _mergeFromServer(result);
    _operationSet = new Map();
    _rebuildEstimatedData();
  }

  _mergeFromServer([dynamic data, bool completeData = true]) {

    var decodedValue = null;
    var value = null;

    _hasBeenFetched = (_hasBeenFetched || completeData) ? true: false;
    _mergeMagicFields(data);

    for(var key in data) {

      value = data[key];

      if(key == '__type' && value == 'className') {
        continue;
      }

      decodedValue = ParseClient.decode(value);

      if(decodedValue is Object || decodedValue is Map) {

        if(decodedValue['__type']) {

          if(decodedValue['__type'] == 'Relation') {
            var className = decodedValue['className'];
            decodedValue = new ParseRelation(this, key, className);
          }
        }
      }

      if (key == 'ACL') {
        decodedValue = new ParseACL.fromJson(decodedValue);
      }

      _serverData[key] = decodedValue;
      _dataAvailability[key] = true;
    }

    if (!_updatedAt && _createdAt) {
      _updatedAt = _createdAt;
    }
  }

  _mergeMagicFields(Map data) {

    if(data['objectId']) {
      _objectId = data['objectId'];
      data.remove('objectId');
    }

    if(data['createdAt']) {
      _createdAt = new DateTime(data['createdAt']);
      data.remove('createdAt');
    }

    if(data['updatedAt']) {
      _updatedAt = new DateTime(data['updatedAt']);
      data.remove('updatedAt');
    }

    if(data['ACL']) {
      var acl = new ParseACL.fromJson(data['ACL']);
      data.remove('ACL');
    }

  }

  _rebuildEstimatedData() {

    estimatedData = new Map();

    _serverData.forEach((dynamic key, dynamic value) {

      estimatedData[key] = value;
    });

    _applyOperations(_operationSet, estimatedData);

  }

  _applyOperations(Map operators, Map target) {

    var oldValue = null;
    var newValue = null;

    operators.forEach((String key, FieldOperation operation) {

      oldValue = (target[key]) ? target[key] : null;
      newValue = operation.apply(oldValue, this, key);

      if(newValue && !(newValue is List) && newValue != null && !(newValue is bool) &&
         !(newValue is int) && !(newValue is String) && !(newValue is double)) {


        target.remove(key);
        _dataAvailability.remove(key);

      } else {

        target[key] = newValue;
        _dataAvailability[key] = true;
      }
    });

  }

  set(String key, dynamic value) {

    if(!key) {
      throw new Exception('key may not be null.');
    }

    if (value is List) {
      throw new Exception('Must use setArray() or setAssociativeArray() for this value.');
    }

    _performOperation(key, new SetOperation(value));
  }

  Object get(String key) {

    if(!_isDataAvailable(key)) {
      throw new Exception('ParseObject has no data for this key. Call fetch() to get the data.');
    }

    if(estimatedData[key]) {
      return estimatedData[key];
    }

    return null;
  }

  set ACL(ParseACL acl) {

    _performOperation('ACL', new SetOperation(acl));
  }

  ParseACL get ACL {

    ParseACL acl = estimatedData['ACL'];

    if(!acl) {
      return null;
    }

    if(acl.isShared) {

      acl = new ParseACL();
    }

    return acl;
  }

  static registerSubClass() {

    if(this is ParseSubClass) {

      var parseClassName = (this as ParseSubClass).parseClassName;

      registeredSubclasses.putIfAbsent(parseClassName, (this as ParseSubClass).parseClass);
    }
  }


  ParseRelation getRelation(String key) {

    var relation = new ParseRelation(this, key);

    if(estimatedData[key]) {

      var object = estimatedData[key];

      if(object is ParseRelation) {
        relation.targetClassName = (object as ParseRelation).targetClassName;
      }
    }

    return relation;
  }

  bool has(String key) {

    return estimatedData.containsKey(key);
  }

  bool hasSameId(ParseObject other) {

  }

  bool isKeyDirty(String key) {

    return _operationSet.containsKey(key);
  }

  increment([String key, int amount = 1]) {

    _performOperation(key, new IncrementOperation(amount));
  }

  remove(String key, dynamic value) {

    if (!key) {
      throw new Exception('key may not be null.');
    }

    _performOperation(key, new RemoveOperation([value]));
  }

  removeAll(String key, List<dynamic> values) {

  }

  Future<dynamic> save() {

    if(!isDirty()) {
      return;
    }

    ParseObject._deepSave();
  }

  Future<dynamic> saveAll(List<dynamic> objects) {

  }

  static Future<dynamic> _deepSave(Map target) {

    var completer = new Completer();

    var sessionToken = null;
    var currentUser = ParseUser.currentUser;

    if(currentUser) {
      sessionToken = currentUser.sessionToken;
    }

    ParseObject._findUnsavedChildren(target, (List unsavedChildren, List unsavedFiles) {

      unsavedFiles.forEach((ParseFile file) {

        file.save();
      });

      var remaining = new Collection(unsavedChildren).distinct().toList();
      var len = remaining.length;

      while(len > 0) {

        var batchCount = 0;
        var batch = [];
        var newRemaining = [];

        for(var object in remaining) {

          batchCount = batch.length;

          if(batchCount > 40) {

            newRemaining.add(object);
            continue;
          }

          if(object.canBeSerialized()) {
            batch.add(object);
          } else {
            newRemaining.add(object);
          }

        }

        remaining = newRemaining;

        if(batch.length == 0) {
          throw new Exception("Tried to save a batch with a cycle.");
        }

        var json = null;
        var oid = null;
        var path = "";
        var method = HttpMethod.POST;
        var requests = [];

        batch.forEach((ParseObject object) {

          json = object.getSavedJson();
          method = HttpMethod.POST;
          oid = object.objectId;

          if(oid) {
            path = '/classes/$oid';
            method = HttpMethod.PUT;
          }

          requests.add({'method': method, 'path': path, 'body': json});
        });

        if(requests.length == 1) {

          var req = requests.elementAt(1);
          var promise = ParseClient.request(method: req['method'],
                                           path: req['path'],
                                           body: JSON.encode(req['body']));

          promise
          .then((result) {

            batch[0].mergeAfterSave(result);
            completer.complete(batch[0]);

          })
          .catchError((error) {

            completer.completeError(error);
          });


        } else {

          var promise = ParseClient.request(method: HttpMethod.POST,
                                           path: '/batch',
                                           body: JSON.encode({'request': requests}));

          promise
          .then((List results) {

            var errorCollection = [];

            for(var i = 0; i < batch.length; i++) {

              var obj = batch[i];
              var result = results[i];

              if(result['success']) {

                obj.mergeAfterSave(result['success']);

              } else if(result['error']) {

                var error = result['error']['error'];
                var code = result['error']['code'] || -1;

                errorCollection.add({'error': error,
                                     'code': code,
                                     'object': obj});
              } else {

                errorCollection.add({'error': 'Unknown error in batch save.',
                                     'code': 1,
                                     'object': obj});
              }
            }

            if(errorCollection.isNotEmpty) {

              completer.completeError(new ParseAggregationException('Errors during batch save.', errorCollection));
            }

          })
          .catchError((error) {

            completer.completeError(new ParseAggregationException('Errors during batch save.', [error]));

          });

        }
      }
    });

    return completer.future;
  }

  static _findUnsavedChildren(ParseObject object, Function mapFunction) {

    var unsavedChildren = new List();
    var unsavedFiles = new List();

    _traverse(true, object, (obj) {

      if(obj is ParseObject) {
        if((obj as ParseObject).isDirty()) {

          unsavedChildren.add(obj);

        } else if(obj is ParseFile) {

          if(!obj.url) {

            unsavedFiles.add(obj);
          }
        }
      }
    });

    mapFunction(unsavedChildren, unsavedFiles);
  }

  _performOperation(String key, FieldOperation operation) {

    var oldValue = null;

    if(estimatedData.containsKey(key)) {
      oldValue = estimatedData[key];
    }

    var newValue = operation.apply(oldValue, this, key);

    if(!newValue) {

      estimatedData[key] = newValue;

    } else if(estimatedData[key]) {

      estimatedData.remove(key);
    }

    if(estimatedData[key]) {

      var oldOperations = _operationSet[key];
      var newOperations = operation.mergeWithPrevious(oldOperations);

      _operationSet[key] = newOperations;

    } else {

      _operationSet[key] = operation;
    }

    _dataAvailability[key] = true;
  }

  bool _isDataAvailable(String key) {

    return _hasBeenFetched || _dataAvailability[key] != null;
  }

  bool _hasDirtyChildren() {

    var result = false;

    _traverse(true, estimatedData, (dynamic object) {

      if(object is ParseObject) {

        if((object as ParseObject).isDirty()) {
          result = true;
        }

      }
    });

    return result;
  }

  static dynamic _traverse([bool deep, dynamic object, Function mapFunction, List seen = new List()]) {

    if(object is ParseObject) {

      if(seen.contains(object)) {
        return;
      }

      seen.add(object);

      if(deep) {
        _traverse(deep, object.estimatedData, mapFunction, seen);
      }

      return mapFunction(object);
    }

    if(object is ParseRelation || object is ParseFile) {

      return mapFunction(object);
    }

    if(object is List) {

      var len = (object as List).length;

      for(var i = 0; i < len; i++) {

        var value = (object as List).elementAt(i);

        _traverse(deep, value.estimateData, mapFunction, seen);

      }

      return mapFunction(object);
    }

    return mapFunction(object);
  }

  bool isDirty([bool considerChildren = true]) {

    return (_operationSet.isNotEmpty || _objectId == null) ||
           (considerChildren && _hasDirtyChildren());
  }

  dynamic getSavedJson() {
    return ParseClient.encode(_operationSet, true);
  }

  String get objectId => _objectId;
  String get className => _className;
  DateTime get updateAt => _updatedAt;
  Datatime get createdAt => _createdAt;

}