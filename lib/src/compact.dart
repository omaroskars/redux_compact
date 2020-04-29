import 'package:redux/redux.dart';

import 'middleware.dart';
import 'models.dart';
import 'reducer.dart';

class ReduxCompact<St> {
  static Middleware<St> createMiddleware<St>({
    ErrorFn onError,
    ApiProvider<St> apiProvider,
  }) {
    return createCompactMiddleware(
      onError: onError,
      apiProvider: apiProvider,
    );
  }

  static Reducer<St> createReducer<St>() {
    return CompactReducer<St>().createReducer();
  }
}
