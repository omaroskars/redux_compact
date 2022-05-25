import 'package:redux/redux.dart';

import 'models.dart';

class CompactReducer<St> {
  Reducer<St> createReducer() {
    return combineReducers<St>([
      TypedReducer<St, CompactAction>(_handleCompactAction),
    ]);
  }

  St _handleCompactAction(St state, CompactAction action) {
    final newState = action.reduce();
    if (newState != null) {
      return newState;
    } else {
      return state;
    }
  }
}
