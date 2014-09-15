part of parse;

class ParseUser extends ParseObject implements ParseSubClass {

  static const String ENDPOINT = '';

  static String parseClassName = '_User';

  ParseUser(): super(ENPOINT) {

  }


  dynamic getSessionToken() {

    return null;
  }

  dynamic get sessionToken {

    return null;
  }

  static ParseUser get currentUser {

    return null;
  }

  static Type newParseClass([className = null]) {

    return new ParseUser();
  }

  static Type get parseClass => ParseUser;
}