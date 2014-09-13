part of parse;

class ParseClient {

  static const String API_VERSION = '1';
  static const String BASE_API_URL = 'https://api.parse.com';

  static final ParseClient _singleton;

  final String _applicationId;
  final String _clientKey;
  final String _apiVersion;
  final HttpClient _apiClient;
  final Map<String, String> _apiHeaders;

  factory ParseClient() {

    return _singleton;
  }

  ParseClient.initialize(BaseClient client, String applicationId, String clientKey, {String apiVersion: API_VERSION}) {

    if (_singleton) {

      return _singleton;

    } else {

      var apiClient = new HttpClient(BASE_API_URL, null, apiVersion, client);

      _singleton = new ParseClient._internal(apiClient, applicationId, clientKey, apiVersion);

      return _singleton;
    }

  }

  static dynamic encode(dynamic value, Boolean allowParseObjects) {

    if (value is ParseObject) {

      if (!allowParseObjects) {
        throw new Exception('ParseObjects not allowed here.');
      }

      return value.toPointer(); // TODO: Where is this stored
    }

    if (value is Encodable) {
      return value.encode();
    }

    if(value is List) {

      return encodeArray(value, allowPaseObjects);
    }

    if(value is DateTime) {
      return { "__type": "Date", "iso": JSON.encode(value) };
    }

    if(value is Object) {

      var output = {};

      for(var key in value) {
        output[key] = ParseClient.encode(value[key], allowParseObjects);
      }
    }

    if(value is Map) {

      var output = {};

      (value as Map).forEach((key, value){
        output[key] = ParseClient.encode(value, allowParseObjects);
      });

      return output;
    }

    if(value is RegExp) {
      return (value as RegExp).pattern;
    }

    return value;
  }

  static dynamic decode(dynamic data) {

    var isBaseType = (data is Object) || (data is Map);

    if(!isBaseType) {
      return data;
    }

    if(data is List) {

      var output = new List();

      (data as List).forEach((element) {
        output.add(ParseClient.decode(element));
      });

      return output;
    }

    if((data is ParseObject)) { // TODO: ParseFile
      return data;
    }

    String type = data._type;
    String className = data.className;

    if(type == 'Pointer' && className) {
      var pointer = ParseObject.create(className);
      // TODO: pointer._finishFetch();

      return pointer;
    }

    if(type == 'Object' && className) {
      var object = ParseObject.create(className);
      return object;
    }

    if(type == 'Date') {
      return new DateTime(data['iso']);
    }

    if (type == 'ACL') {
      if(data is ParseACLrse) {
        return data;
      }

      return new ParseACL(data);
    }

    if(type == 'Relation') { // TODO: This may not work
      return data;
    }

    var output = {};

    for(var key in data) {
      output[key] = PaseClient.decode(data[key]);
    }
    return output;

//    if ($typeString === 'GeoPoint') {
//      return new ParseGeoPoint($data['latitude'], $data['longitude']);
//    }

//    if (value.__type === "File") {
//      var file = new Parse.File(value.name);
//      file._url = value.url;
//      return file;
//    }

  }

  static List encodeArray(List values, allowParseObjects) {

    var output = new List();

    values.forEach((element) {
      output.add(ParseClient.encode(element, allowParseObjects));
    });

    return output;
  }

  Future<StreamedResponse> request({String method: HttpMethod.GET, String path: '', Map<String, String> queryParams: null, Object body: null}) {

    var httpRequest = _apiClient.buildHttpRequest(method: method, path: path, queryParameters: queryParams, body: body,
                                                  headers: _apiHeaders);

    return httpRequest.execute();
  }


  ParseClient._internal(this._apiClient, this._applicationId, this._clientKey, this._apiVersion) {

    _apiHeaders = new Map.from({
                                   'X-Parse-Application-Id': _applicationId, 'X-Parse-REST-API-Key': _apiClient, 'Content-Type': 'application/json'
                               });
  }
}