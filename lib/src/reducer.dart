import 'package:redux/redux.dart';

import 'models.dart';

class CompactReducer<St> {
  Reducer<St> createReducer() {
    return combineReducers<St>([
      TypedReducer<St, ReduceAction>(_handleReduceAction),
    ]);
  }

  St _handleReduceAction(St state, ReduceAction action) {
    return action.action.reduce(action.status);
  }
}
