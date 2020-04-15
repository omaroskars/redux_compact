import 'package:redux/redux.dart';

import 'models.dart';

class CompactReducer<St> {
  Reducer<St> createReducer() {
    return combineReducers<St>([
      TypedReducer<St, CompactAction>(_handleCompactAction),
    ]);
  }

  St _handleCompactAction(St state, CompactAction action) {
    return action.reduce();
  }
}
