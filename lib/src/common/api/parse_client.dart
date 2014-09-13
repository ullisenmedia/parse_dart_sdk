part of parse_common;

class ParseClient {

  static const String API_VERSION = '1';
  static const String BASE_API_URL = 'https://api.parse.com';

  static final ParseClient _singleton;

  final String _applicationId;
  final String _clientKey;
  final String _apiVersion;
  final BaseAPIClient _apiClient;
  final Map<String, String> _apiHeaders;

  factory ParseClient() {

    return _singleton;
  }

  ParseClient.initialize(BaseClient client,
                         String applicationId,
                         String clientKey,
                         {String apiVersion: API_VERSION}) {

    if (_singleton) {

      return _singleton;

    } else {

      var apiClient = new BaseAPIClient(BASE_API_URL, null, apiVersion, client);

      _singleton = new ParseClient._internal(apiClient, applicationId, clientKey, apiVersion);

      return _singleton;
    }

  }

  Future<StreamedResponse> api({String method: HttpMethod.GET,
                               String path: '',
                               Map<String, String> queryParams: null,
                               Object body: null}) {

    var httpRequest = _apiClient.buildHttpRequest(method: method,
                                                  path: path,
                                                  queryParameters: queryParams,
                                                  body: body,
                                                  headers: _apiHeaders);

    return httpRequest.execute();
  }


  ParseClient._internal(this._apiClient, this._applicationId, this._clientKey, this._apiVersion) {

    _apiHeaders = new Map.from({
                          'X-Parse-Application-Id': _applicationId,
                          'X-Parse-REST-API-Key': _apiClient,
                          'Content-Type': 'application/json'
                          });
  }
}