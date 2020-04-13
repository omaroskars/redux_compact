# Redux Compact

Redux Compact is a library that aims to reduce the massive amount of boilerplate that follows maintaining a Flutter Redux application.

The library provides a set of middleware and a reducer that intercept a special kind of action called [Compact Action](#compact-action). The action has direct access to the state and can be both `sync-` and `asynchronous` and provides you the ability to chain actions. The action’s reducer is a method called `reduce` which allows you to make corresponding state changes within the action itself.

This approach eliminates the need to maintain separate files and folders for actions and reducers and to create and dispatch multiple actions to handle asynchronous state.

## Usage

_This documentation assumes you are already familiar with [Redux](https://pub.dev/packages/redux) and [Flutter Redux](https://pub.dev/packages/flutter_redux), their core concepts, setup and usage._

For a full overview visit the [examples](https://github.com/omaroskars/redux_compact/tree/master/example)

Create your store as recommended by Flutter Redux. Add Redux Compact middleware and reducer to the store.

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

In order to use Redux Compact you must `dispatch` an action that extends a `CompactAction`.

All compact actions must implement the `reduce` method which is the reducer for the action. The reduce method has direct access to instance variables, dispatch function and the store state. The method accepts a `RequestStatus` as parameter to keep track of asynchronous state.

**Keep in mind**

- Like normal reducers the reduce method always expects to return a state. If you do not wish to update the state, simply return `state`, returning `null` updates the state to null.

* Even though the reduce method has access to the dispatch function, **dispatching an action in a reducer is an antipattern**. If you wish to dispatch another action read the [chaining actions](#chaining-actions) section.

### Sync action

```dart
class IncrementCountAction extends CompactAction<AppState> {
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

_\*Note: The request status will always be `null` for synchronous actions_

### Async Action

To create an asynchronous action you simply need to implement the `request()` method as a `Future`. The middleware then `awaits` the request and calls the reduce method with a `RequestStatus`. As your request executes, the values of `RequestStatus` change, allowing you to make state changes accordingly.

The `RequestStatus` is an object that contains:

- **isLoading:** `true` if a request is in flight, `false` otherwise
- **error:** `dynamic` if an error occurs, `null` otherwise
- **data**: `dynamic` if the request is successful, `null` otherwise

```dart
class IncrementCountAction extends CompactAction<AppState> {
  final int incrementBy;

  IncrementCountAction(this.incrementBy);

  @override
  request() {
    // The request method has direct access to
    // instance variable and current state
    const count = state.counter + incrementBy;
    final url = "http://numbersapi.com/$count";

    // Return a future
    return http.read(url);
  }

  @override
  AppState reduce(RequestStatus status) {
    // If we are waiting for a response isLoading, will be true.
    if (status.isLoading) {
      return state.copy(isLoading: status.isLoading);
    }

    // hasError is a helper function that checks if error != null
    if (status.hasError) {
      return state.copy(
        errorMsg: error.message,
      );
    }

    // The request was successful
    return state.copy(
      counter: state.counter + 1,
      description: status.data,
    );
  }
}
```

### Chaining Actions

Compact Action provides two helper functions, `before` and `after`. Both of these methods have direct access to the `state`, `dispatch` function and `instance variables`. You can therefore call or dispatch, other functions or actions, before or after the current action runs.

- The `before` method **always** runs before the `reduce` method. If the action is `asynchronous` the `before` method runs before the request is made.

- The `after` method runs after the `reduce` method, or when an `asynchronous` request has **finished successfully**. If an error occurred in an asynchronous request the method will **not run**.

**Just remember the state:**

- Has **not changed** in the `before` method
- Has **changed** in the `after` method

```dart
class IncrementCountAction extends CompactAction<AppState> {
  final int incrementBy;

  IncrementCountAction(this.incrementBy);

  @override
  AppState reduce(RequestStatus status) {
    // The reducer only increments the count
    return state.copy(
      counter: state.counter + incrementBy,
    );
  }

  @override
  void before() {
    // Before the reducer runs we dispatch an action
    // that copies the current state.
    dispatch(SetPreviousDescAction());
  }

  @override
  void after() {
    // After the reduce method runs
    // We dispatch an action to fetch a description for the counter
    dispatch(FetchDescriptionAction(state.counter));
  }
}
```

## BaseModel

`BaseModel` is a convenient class to quickly create a `ViewModel` for the Redux `StoreConnector`. It has direct access to the `store state` and the `dispatch` function. You can therefore dispatch an action within the model or the widget.

`BaseModel` is not a mandatory class for Redux Compact. You can use basic `ViewModel` if you want, as long as you dispatch a `CompactAction`. If you would like to use a `BaseModel`, create a class that extends `BaseModel` and implement the `fromStore` method.

```dart
class _VM extends BaseModel<AppState> {
  final int count;

  _VM(Store store, { this.count }) : super(store);

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

Then initialize `BaseModel` with the `fromStore` method in the in the Widget's `StoreConnector`

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
