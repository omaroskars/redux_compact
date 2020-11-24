import 'package:redux/redux.dart';

import 'models.dart';

typedef ErrorFn = void Function(
    dynamic error, void Function(dynamic action) dispatch);

Middleware<St> createCompactMiddleware<St>({ErrorFn onError}) {
  return (Store<St> store, dynamic action, NextDispatcher next) =>
      compactMiddleware(
        store,
        action,
        next,
        onError: onError,
      );
}

CompactAction isCompactAction(dynamic action) {
  if (action is CompactAction) return action;
  return null;
}

dynamic compactMiddleware<St>(
  Store<St> store,
  dynamic action,
  NextDispatcher next, {
  ErrorFn onError,
}) async {
  final compactAction = isCompactAction(action);

  if (compactAction == null) {
    return next(action);
  }

  compactAction.setStore(store);

  compactAction.before();

  try {
    final request = compactAction.makeRequest();
    if (request is Future) {
      compactAction.setRequestStatus(RequestStatus(loading: true));
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

    if (onError != null) {
      onError(e, store.dispatch);
    }
    return;
  }

  next(compactAction);
  compactAction.after();
}
