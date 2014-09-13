part of parse;

class HttpClient {

  final Uri baseUrl;
  final String key;
  final String version;

  Uri _url;
  BaseClient _client;

  HttpClient(this.baseUrl, this.key, this.version, BaseClient client, [int port = 0]) {

    _client = client;
    _url = Uri.parse('${baseUrl}:${port}/${version}/');
  }

  @override
  HttpRequest buildHttpRequest({String method: 'GET',
                               String path: '',
                               Map<String, String>
                               queryParameters: null,
                               Object body: null,
                               Map<String, String> headers: null}) {

    var requestParams = new Map.from(queryParameters);

    var requestURL = this.buildRequestURL(path, requestParams, this.url.port);

    return new HttpRequest(method, requestURL, _client, body, headers);
  }

  @override
  Uri buildRequestURL(String path, Map<String, String> params, [port = 0]) {

    var requestPath = '${_url.path}${path}';
    var requestUrl = new Uri(scheme: _url.scheme, host: _url.host, port: _url.port, path: requestPath, queryParameters: params);

    return requestUrl;
  }

  Uri get url =>_url;
}
