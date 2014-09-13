part of parse;

class ParseRemoteObject {

  String _endpoint;

  ParseRemoteObject(this.endpoint);

  Future<StreamedResponse> _create({Map<String, String> queryParams, Object data}) {

    return _request(method: HttpMethod.POST,
                    path: _endpoint,
                    queryParams: queryParams,
                    body: data);
  }

  Future<StreamedResponse> _read({Map<String, String> queryParams, Object data}) {

    return _request(method: HttpMethod.GET,
                    path: _endpoint,
                    queryParams: queryParams,
                    body: data);
  }


  Future<StreamedResponse> _update({Map<String, String> queryParams, Object data}) {

    return _request(method: HttpMethod.PUT,
                    path: _endpoint,
                    queryParams: queryParams,
                    body: data);
  }

  Future<StreamedResponse> _delete({Map<String, String> queryParams, Object data}) {

    return _request(method: HttpMethod.DELETE,
                    path: _endpoint,
                    queryParams: queryParams,
                    body: data);
  }

  Future<StreamedResponse> _request({String method: HttpMethod.GET,
                                    String path: '',
                                    Map<String, String> queryParams: null,
                                    Object body: null}) {


    ParseClient.request(method: method,
                    path: path,
                    queryParameters: queryParams,
                    body: body);
  }

}