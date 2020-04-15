import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:redux_compact/redux_compact.dart';
import 'package:redux_compact/src/middleware.dart';

void main() {
  final compactReducer = ReduxCompact.createReducer<String>();
  final compactMiddeware = createCompactMiddleware<String>();

  group("redux action", () {
    test("should not intercept normal redux action", () {
      final store = Store<String>(
        compactReducer,
        initialState: "",
        middleware: [compactMiddeware],
      );

      store.dispatch(ReduxAction());

      expect(store.state, "");
    });
  });

  group("compact action", () {
    test("should set the store", () {
      final store = Store<String>(
        compactReducer,
        initialState: "",
        middleware: [compactMiddeware],
      );

      final action = MockCompactAction();

      store.dispatch(action);

      verify(action.setStore(store)).called(1);
    });

    test("should call before and after", () {
      final store = Store<String>(
        compactReducer,
        initialState: "",
        middleware: [compactMiddeware],
      );

      final action = MockCompactAction();

      store.dispatch(action);

      verify(action.before()).called(1);
      verify(action.after()).called(1);
    });

    test("should change the state", () {
      final store = Store<String>(
        compactReducer,
        initialState: "",
        middleware: [compactMiddeware],
      );

      store.dispatch(SyncAction());

      expect(store.state, "1");
    });
  });

  group("async compact action", () {
    test("should reduce when loading", () async {
      final store = Store<String>(
        compactReducer,
        initialState: "",
        middleware: [
          compactMiddleware,
        ],
      );
      final action = AsyncAction();

      store.dispatch(action);
      expect(store.state, "loading");
    });

    test("should reduce when response is received", () async {
      final store = Store<String>(
        compactReducer,
        initialState: "",
        middleware: [
          compactMiddleware,
        ],
      );
      final action = AsyncAction();

      await expectLater(store.dispatch(action), completes);
      expect(store.state, "response");
    });

    test("should reduce when error occurs", () async {
      final store = Store<String>(
        compactReducer,
        initialState: "",
        middleware: [
          compactMiddleware,
        ],
      );

      final action = AsyncErrorAction();

      await expectLater(store.dispatch(action), completes);

      expect(store.state, "error");
    });
  });
}

class ReduxAction {}

class MockCompactAction extends Mock implements CompactAction {}

class SyncAction extends CompactAction {
  @override
  reduce() {
    return "1";
  }
}

class AsyncAction extends CompactAction {
  request() {
    return Future<String>.value('response');
  }

  @override
  reduce() {
    if (requestStatus.isLoading) {
      return "loading";
    }

    if (requestStatus.hasError) {
      return "error";
    }

    return requestStatus.data;
  }
}

class AsyncErrorAction extends CompactAction {
  request() {
    return Future<String>.error('error');
  }

  @override
  reduce() {
    if (requestStatus.isLoading) {
      return "loading";
    }

    if (requestStatus.hasError) {
      return requestStatus.error;
    }

    return requestStatus.data;
  }
}
