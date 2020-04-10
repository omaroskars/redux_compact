# Redux Compact

Redux Compact is a library that aims to reduce the massive amount of boilerplate that follows maintaining a Flutter Redux application.

`Compact middleware` intercepts all [Compact Actions](#compact-action) which can be both `sync-` and `asyncrounus`. The `Compact reducer` handles theese actions with a callback function called `reduce` which allows you to do corresponding state changes within the action itself.

With this approach you dont need to:

- Maintain seperate files and folders for actions and reducers
- Create and dispatch multiple actions to handle asyncrounus state.

## Usage

For a full overview visit the [examples](https://github.com/omaroskars/redux_compact/tree/master/example)

This documentation assumes you are already familiar with

- [Redux](https://pub.dev/packages/redux) and its core concepts
- [Flutter Redux](https://pub.dev/packages/flutter_redux) setup and usage

You should setup your app and store as recommended by [Flutter Redux](https://pub.dev/packages/flutter_redux).

In order to use Redux Compact you must add add the `compactMiddlware` to the store and use the `compactReducer` to maintain some state.

In this exmaple the `compactReducer` is the root reducer for `AppState`.

```dart
final compactReducer = ReduxCompact.createReducer<AppState>();
final compactMiddleware = ReduxCompact.createMiddleware<AppState>();

final store = new Store<AppState>(
  compactReducer, // <-- Add compactReducer
  initialState: AppState.initialState(),
  middleware: [
    compactMiddleware, // <-- Add compactMiddleware
  ],
);
```

Then `dispatch` an action that extends `CompactAction`

```dart
// When this action is dispatched the reduce method will
// update state counter by incrementedBy
class IncrementCountAction extends CompactAction<AppState> {
  final int incrementBy;

  IncrementCountAction(this.incrementBy);

  @override
  int reduce(status) {
    return state.copy(
      counter: incrementBy
    );
  }
}
```

## Compact Action

In order to use Redux Compact you must `dispatch` an action that extends a **`CompactAction`**.

All actions must implement the **`reduce`** method which acts as reducer for the action.
The reduce method receives a `RequestStatus` as parameter to keep track of asyncrounus state and has direct access to:

- instance variables
- dispatch function
- the store state

_Keep in mind like normal reducers the `reduce` method will always update the state with the **return value**. If you do not wish to update the state, simply return `state`. Returning `null` will result with the state being null._

### Sync action

```dart
class IncrementCountAction extends ReduxAction<AppState> {
  final int incrementBy;

  IncrementCountAction(this.incrementBy);

  @override
  int reduce(status) {
    return state.copy(
      counter: state.counter + incrementBy,
    );
  }
}
```

_\*Note: The request status will always be `null` for syncrounus actions_

### Async Action

To create an asyncrounus action you simply need to implement the **`request()`** method as a `Future`. The middleware then `awaits` the request and calls the `reduce` method with updated `RequestStatus` parameter.

The **`RequestStatus`** is an object that consist of three variables and one getter:

- `bool isLoading:` True when wating for a response, false otherwise
- `dynamic error:` If the request results in error, this variable will hold the error object.
- `dynamic data:` If the request is successfull, this will be the resonse
- `bool hasError`: Simple getter which checks if the status error is null or not.

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

### Chaining Actions

Compact Action provides two helper functions in which you can use to chain some functionalities:

- `void before:` Runs before the reduce method
- `void after:` Runs after the reduce method

These methods have direct access to the state, dispatch function and the class instance variables. You can therefore call or dispatch, other functions or actions, before or after the current action runs. These methods can be really helpfull with more complicated functionalities that are dependant on each other.

**Just remember that the state changes:**

- **Have not taken** place in the `before` method
- **Have taken place** in the `after` method

```dart

class IncrementCountAction extends CompactAction<AppState> {
  final int incrementBy;

  IncrementCountAction(this.incrementBy);

  @override
  AppState reduce(RequestStatus status) {
    return state.copy(
      counter: state.counter + incrementBy,
    );
  }

  @override
  void before() {
    dispatch(SetPreviousDescAction());
  }

  @override
  void after() {
    dispatch(FetchDescriptionAction(state.counter));
  }
}
```

## BaseModel

_Base Model is not mandatory for ReduxCompact to function, it is a convenient helper class to quickly create a `ViewModel` for the `Redux StoreConnector`._

Base model has direct access to:

- the store state
- dispatch method.

If you would like to use a `BaseModel`, create a class that extends `BaseModel` and implement the `fromStore` method.

```dart
class _VM extends BaseModel<AppState> {
  final int count;

  _VM(
    Store store, { this.count }) : super(store);

  @override
  AppState fromStore() {
    return _VM(store, count: state.counter);
  }

  // You can dispatch an action from the VM
  // or call vm.dispatch(...) from the widget
  void incrementCount() {
    dispatch(IncrementCountAction(state.counter + 1));
  }
}
```

Then create an instance of view model the in the Widget's `StoreConnector`

```dart
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _VM>(
      converter: (store) => _VM(store).fromStore(), // <-- Initialize the VM
      builder: (context, vm) => Container(...),
    );
  }
```
