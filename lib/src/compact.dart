import 'package:redux/redux.dart';

import 'middleware.dart';
import 'reducer.dart';

class ReduxCompact<St> {
  static Middleware<St> createMiddleware<St>({ErrorFn onError}) {
    return createCompactMiddleware(onError: onError);
  }

  static Reducer<St> createReducer<St>() {
    return CompactReducer<St>().createReducer();
  }
}
