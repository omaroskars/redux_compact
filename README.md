# Redux Compact

Reduces boilerplate and helps you write more maintanable code with redux.

## Getting started

Redux compact only dependency is [Redux](https://pub.dev/packages/redux). If you are using Flutter I recommend using [Flutter Redux](https://pub.dev/packages/flutter_redux) as well to easily consume a Redux Store.

For complete example check out the [examples](https://github.com/omaroskars/redux_compact/tree/master/example).

## Store

Follow the setup guide for [Flutter Redux](https://pub.dev/packages/flutter_redux). Create an instance of Redux compact **reducer** and **middleware** and pass it to the store.

```dart
final compactReducer = ReduxCompact.createReducer<int>();
final compactMiddleware = ReduxCompact.createMiddleware<int>();

final store = new Store<int>(
  compactReducer
  initialState: 0,
  middleware: [
    compactMiddleware,
  ],
);
```

## ReduxAction

In order to use Redux Compact you must dispatch an action that extends `ReduxAction`.

**Public methods**

_Required:_

- **`T reduce(RequestStatus):`** Acts as the reducer for the action so all state manipulation will occur here. The RequestStatus holds information about status of an async operation: ie `bool isLoading, dynamic error and dynamic data`.

_Optional:_

- **`FutureOr<dynamic> request():`:** Makes the action asyncrounus. Must be implemented as a Future. The reduce method will receive the request status in order to act accordingly.

- **`void before():`** Helper method for chaining. Will be called before each dispatched action.

- **`void after():`** Helper method for chaining. Will be called after each dispatched action.

**All methods have direct access to:**

- The store state
- The Action instance variables
- The dispatch method, so that other actions may be dispatched

#### Sync action

```dart
class IncrementCountAction extends ReduxAction<int> {
  @override
  int reduce(status) {
    return state + 1;
  }
}
```

#### Async Action

```dart
class IncrementCountAction extends ReduxAction<AppState> {
  @override
  request() {
    final url = "http://numbersapi.com/${state.counter + 1}";
    final res = http.read(url);

    return res;
  }

  @override
  AppState reduce(RequestStatus status) {
    // Handle loading state
    if (status.isLoading) {
      return state.copy(isLoading: status.isLoading);
    }

    // Update the error message if an error occurs
    if (status.hasError) {
      return state.copy(
        errorMsg: "Error occured",
      );
    }

    // Update the state with incremented counter
    // and a description from the server
    return state.copy(
      counter: state.counter + 1,
      description: status.data,
    );
  }
}
```

#### Chaining Action

```dart
class SomeAction extends ReduxAction<String> {
  final String message;

  ShowMessageAction(this.message);

  @override
  int reduce(status) {
    return state + 1;
  }

  @override
  void before() {
    dispatch(BeforeAction())
  }

  @override
  void after() {
    dispatch(SomeOtherAction());
  }
}
```

### BaseModel

TODO

```dart
class _VM extends BaseModel<AppState> {
  final int count;
  final String desc;
  final bool isLoading;
  final String errorMsg;

  _VM(
    Store store, {
    this.count,
    this.desc,
    this.isLoading,
    this.errorMsg
  }) : super(store);

  @override
  BaseModel fromStore() {
    return _VM(store,
        count: state.counter,
        desc: state.description,
        isLoading: state.isLoading,
        errorMsg: state.errorMsg);
  }
}
```
