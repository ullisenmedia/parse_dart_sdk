part of parse;

class ParseACL extends ParseObject {

  static const String ENDPOINT = '';

  ParseACL(): super(ENPOINT) {

  }

  ParseACL.fromJson(arg) {

  }

  get isShared => true;
}