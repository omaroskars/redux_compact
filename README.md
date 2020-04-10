# Redux Compact

Redux Compact is a library that aims to reduce the massive amount of boilerplate that follows maintaining a Flutter Redux application.

`Compact middleware` intercepts all [Compact Actions](#compact-action) which can be both `sync-` and `asyncrounus`. The `Compact reducer` handles theese actions with a callback function called `reduce` which allows you to do corresponding state changes within the action.

With this approach you dont need to maintain seperate files and folders for actions and reducers and you dont need to create and dispatch multiple actions to handle asyncrounus state.

<!-- `Compact Action` has access to the Redux store and state and provides you with the ability to dispatch and chain actions. The `reduce` method receives a `request state` as a paramater which allows you to react to asyncrounus state changes. With this approach you dont need to maintain seperate files and folders for actions and reducers and you dont need to `create` and `dispatch` multiple actions to handle asyncrounus state. -->

 <!-- This allows you to stop writing the huge amount of boilerplate that follows when `creating`, `combining` and `mapping` reducers and `creating` and `dispatching` multiple actions for asyncrounus state. -->

<!-- When you dispatch a Compact Action the state change occurs in the action `reduce` method. With this approach you dont need to maintain seperate files and folders for actions and reducers, in fact the only reducer you need is the Comptact reducer. This allows you to stop writing the huge amount of boilerplate that follows when `creating`, `combining` and `mapping` reducers.

The Compact Action can be both sync and asyncrounus and provides you the ability to chain. When the action is asyncrounus the reduce method receives the request state as parameter allowing you make corresponding state changes. This reduces the amount of actions you need to maintain asyncrounus state changes. -->

<!-- - All actions are handled with a single reducer -->

<!-- Actions and reducers are the same instance class

- You don't seprate actions from reducers
- Compact reducer handles all actions

Actions can be both sync- and asyncrounus

- Hanlde sync and asyncrounus state changes
- Easy to chain actions -->

<!-- The ReduxCompactMiddleware intercepts a `ReduxAction` which has access to both the Redux store and state which allows you make **sync- or asyncrounus** state changes within a single class. -->

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

- instance variables,
- dispatch function
- store state.

_Keep in mind like normal reducers the `reduce` method will \*always update the state with the **return value**. If you do not wish to update the state, simply return `state`. Returning `null` will result in the state being null._

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

### Chaining Action

TODO:

## BaseModel

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
