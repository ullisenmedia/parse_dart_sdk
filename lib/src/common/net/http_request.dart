part of parse_common;

class HttpRequest {

  final Uri url;
  final String method;
  final Object body;
  final Map<String, String> headers;

  BaseClient _client;

  HttpRequest(this.method, this.url, BaseClient client, [this.body = null, Map<String, String> headers = null]) {

    _client = client;
  }

  @override
  Future<StreamedResponse> execute() {

    var future;

    switch (this.method) {

      case HttpMethod.POST:
        future = _client.post(this.url, this.headers, this.body);
        break;

      case HttpMethod.DELETE:
        future = _client.delete(this.url, this.headers);
        break;

      case HttpMethod.PUT:
        future = _client.put(this.url, this.headers, this.body);
        break;

      default:
        future = _client.get(this.url);
        break;

    }

    return future;
  }
}