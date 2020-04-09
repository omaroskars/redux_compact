# Redux Compact

Redux Compact is a library that aims to reduce the massive amount of boilerplate that follows maintaining a Flutter Redux application.

## Usage

_This documentation assumes you are already familiar with_

- [Redux](https://pub.dev/packages/redux) and its core concepts
- [Flutter Redux](https://pub.dev/packages/flutter_redux) setup and usage

For a full overview checkout the [Examples](https://github.com/omaroskars/redux_compact/tree/master/example)

### Store

```dart
final compactReducer = ReduxCompact.createReducer<AppState>();
final compactMiddleware = ReduxCompact.createMiddleware<AppState>();

var state = AppState.initalState();

final store = new Store<AppState>(
  compactReducer, // <-- Use ReduxCompact reducer
  initialState: state,
  middleware: [
    compactMiddleware, // <-- Use ReduxCompact middleware
  ],
);
```

### Action

```dart
class IncrementCountAction extends ReduxAction<AppState> {
  final int incrementBy;

  IncrementCountAction(this.incrementBy);

  @override
  int reduce(status) {
    // The reduce method acts as the reducer for this action
    // It has direct access to the store state
    return state.count + incrementBy;
  }
}
```

## ReduxAction

All methods have direct access to:

- The store state
- The action instance variables
- The dispatch method, so that other actions may be dispatched

_Required:_

- **`reduce(RequestStatus):`** Acts as the reducer for the action so all state manipulation will occur here. The RequestStatus holds information about status of an async operation: ie `bool isLoading, dynamic error and dynamic data`.

_Optional:_

- **`request():`:** Makes the action asyncrounus. Must be implemented as a Future. The reduce method will receive the request status in order to act accordingly.

- **`before():`** Helper method for chaining. Will be called before each dispatched action.

- **`after():`** Helper method for chaining. Will be called after each dispatched action.

### Sync action

```dart
class IncrementCountAction extends ReduxAction<int> {
  @override
  int reduce(status) {
    return state + 1;
  }
}
```

### Async Action

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

### Chaining Action

TODO:

### BaseModel

BaseModel has direct access to the store state and dispatch method.

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
