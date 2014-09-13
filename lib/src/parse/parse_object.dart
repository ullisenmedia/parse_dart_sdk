part of parse;

class ParseObject extends ParseRemoteObject {

  static const String ENPOINT = '';

  String _className;
  String _objectId;

  ParseObject(): super(ENPOINT);
  ParseObject(this.className): super(ENPOINT);

  add(String key, Object value) {

  }

  addAll(String key, List<T> values) {

  }

  addAllUnique(String key, List<T> values) {

  }

  addUnique(String key, Object value) {

  }

  Boolean containsKey(String key) {

  }

  static create(String className) {

  }

  static createWithoutData(String className, String objectId) {

  }

  Future<T> delete() {

  }

  Future<T> deleteAll(List<T> objects) {

  }

  Future<T> fetch() {

  }

  static Future<T> fetchAll(List<T> objects) {

  }

  static Future<T> fetchAllIfNeeded(List<T> objects) {

  }

  Object get(String key) {

  }

  ParseACL getACL() {

  }

  ParseRelation getRelation(String key) {

  }

  Boolean has(String key) {

  }

  Boolean hasSameId(ParseObject other) {

  }

  increment({String key, Number amount}) {

  }

  Boolean isDirty({String key}) {

  }

  remove(String key) {

  }

  removeAll(String key, List<T> values) {

  }

  Future<T> save() {

  }

  Future<T> saveAll(List<T> objects) {

  }

  String get objectId => _objectId;
  String get className => _className;

}