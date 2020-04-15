import 'dart:async';

import 'package:redux/redux.dart';

typedef Dispatch<St> = void Function(CompactAction<St> action);

abstract class CompactAction<St> {
  Store<St> _store;
  RequestStatus _requestStatus;

  void setStore(Store store) => _store = (store as Store<St>);

  void setRequestStatus(RequestStatus status) => _requestStatus = status;

  Store<St> get store => _store;

  St get state => _store.state;

  RequestStatus get requestStatus => _requestStatus;

  Dispatch<St> get dispatch => _store.dispatch;

  void before() {}

  void after() {}

  St reduce();

  FutureOr<dynamic> request() {
    return null;
  }
}

class RequestStatus {
  final bool isLoading;
  final dynamic data;
  final dynamic error;

  bool get hasError => error != null;

  RequestStatus({this.isLoading = false, this.data, this.error});
}

abstract class BaseModel<T> {
  final Store store;

  BaseModel(this.store);

  BaseModel fromStore();

  T get state => store.state;

  Dispatch get dispatch => store.dispatch;
}
