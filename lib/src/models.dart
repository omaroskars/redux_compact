import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';

typedef Dispatch<St> = void Function(CompactAction<St> action);

abstract class CompactAction<St> {
  /// The redux store
  Store<St> _store;
  RequestStatus _requestStatus;
  ApiProvider _client;

  /// Setter for the action store
  void setStore(Store store) => _store = (store as Store<St>);

  void setRequestStatus(RequestStatus status) => _requestStatus = status;

  void setApiProvider(ApiProvider provider) => _client = provider;

  Store<St> get store => _store;

  St get state => _store.state;

  ApiProvider get client => _client;

  Dispatch<St> get dispatch => _store.dispatch;

  /// Status of a request.
  ///
  /// `isLoading`: Indicates if a request is loading
  ///
  /// `data`: The response from the request
  ///
  /// `error`: The error if it occurs
  RequestStatus get request => _requestStatus;

  /// The action reducer
  St reduce();

  /// Creates an asynchronous action
  FutureOr<dynamic> makeRequest() {
    return null;
  }

  /// Runs before `reduce()`.
  void before() {}

  /// Runs after `reduce()`.
  void after() {}
}

class RequestStatus {
  final bool loading;
  final dynamic data;
  final dynamic error;

  bool get hasError => error != null;

  RequestStatus({this.loading = false, this.data, this.error});
}

abstract class BaseModel<T> {
  final Store store;

  BaseModel(this.store);

  BaseModel fromStore();

  T get state => store.state;

  Dispatch get dispatch => store.dispatch;
}

abstract class ApiProvider<St> {
  String baseUrl;
  String authUrl;

  Store<St> _store;

  ApiProvider(this.baseUrl, {this.authUrl});

  void setStore(Store store) => _store = (store as Store<St>);
  Store<St> get store => _store;
  St get state => _store.state;

  Future<dynamic> request({
    @required String url,
    @required String method,
    Map<String, dynamic> query,
    Map<String, dynamic> headers,
    dynamic body,
    ProviderType providerType,
  });
}

enum ProviderType { base, auth }
