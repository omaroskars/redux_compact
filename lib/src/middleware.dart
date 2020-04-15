import 'package:redux/redux.dart';

import 'models.dart';

typedef ErrorFn = Function(dynamic error);

Middleware<St> createCompactMiddleware<St>({Function onError}) {
  return (Store<St> store, dynamic action, NextDispatcher next) =>
      compactMiddleware(store, action, next, onError: onError);
}

CompactAction isCompactAction(dynamic action) {
  if (action is CompactAction) return action;
  return null;
}

dynamic compactMiddleware<St>(
  Store<St> store,
  dynamic action,
  NextDispatcher next, {
  Function onError,
}) async {
  final compactAction = isCompactAction(action);

  if (compactAction == null) {
    return next(action);
  }

  compactAction.setStore(store);
  compactAction.before();

  try {
    final request = compactAction.request();
    if (request is Future) {
      compactAction.setRequestStatus(RequestStatus(isLoading: true));
      next(compactAction);

      final res = await request;
      compactAction.setRequestStatus(RequestStatus(data: res));
      next(compactAction);

      compactAction.after();
      return;
    }
  } catch (e) {
    compactAction.setRequestStatus(RequestStatus(error: e));
    next(action);

    if (onError is ErrorFn) {
      onError(e);
    }
    return;
  }

  next(compactAction);
  compactAction.after();
}
