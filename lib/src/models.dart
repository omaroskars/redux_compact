import 'dart:async';

import 'package:redux/redux.dart';

typedef Dispatch<St> = void Function(ReduxAction<St> action);

abstract class ReduxAction<St> {
  Store<St> _store;

  void setStore(Store store) => _store = (store as Store<St>);

  Store<St> get store => _store;

  St get state => _store.state;

  Dispatch<St> get dispatch => _store.dispatch;

  void before() {}

  void after() {}

  St reduce(RequestStatus status);

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

class ReduceAction {
  final ReduxAction reduxAction;
  final RequestStatus status;

  ReduceAction(this.reduxAction, this.status);
}

abstract class BaseModel<T> {
  final Store store;

  BaseModel(this.store);

  BaseModel fromStore();

  T get state => store.state;

  Dispatch get dispatch => store.dispatch;
}
