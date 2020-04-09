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

# OLD DOC

```dart
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux_compact/redux_compact.dart';

void main() {
  // Create an instance of ReduxCompact reducer and middleware
  final marduxReducer = Mardux.createReducer<int>();
  final marduxMiddleware = Mardux.createMiddleware<int>();

  // Create the store as recommended by Flutter Redux
  final store = new Store<int>(
    marduxReducer,
    initialState: 0,
    middleware: [
      marduxMiddleware,
    ],
  );

  runApp(MyApp(
    store: store,
    title: "Mardux demo",
  ));
}

// The StoreProvider should wrap your MaterialApp as recommended by
// by Flutter Redux
class MyApp extends StatelessWidget {
  final Store<int> store;
  final String title;

  const MyApp({Key key, this.store, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return new StoreProvider<int>(
      store: store,
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CounterWidget(),
      ),
    );
  }
}
```

### Syncrounus action

TODO: Write some introduction

```dart
class IncrementCountAction extends ReduxAction<int> {
  // The reduce method acts as a reducer for this action.
  // It takes the previous count and increments it when this action is dispatched
  @override
  int reduce(status) {
    return state + 1;
  }
}
```

### Base model

TODO: Write something about base model

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
    this.errorMsg,
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

```dart
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<int, _VM>(
      converter: (store) => _VM(store).fromStore(), // initialize the VM
      builder: (context, vm) => render(context, vm),
    );
  }

  Widget render(BuildContext context, _VM vm) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Mardux demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            Text(
              vm.count.toString(),
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => vm.dispatch(IncrementCountAction()),
        tooltip: "Increment",
        child: new Icon(Icons.add),
      ),
    );
  }
}
```

### Asyncrounus action

### Chaining

# Mardux

Mardux is a library thats help you write less and more maintainable code with redux.

<!-- You can think of Mardux as a "wrapper" on top of Redux to help you write less but more maintainable code. And did i mention that asyncrounus actions are like super easy?

Mardux awesomeness consist of

- convinent models
- efficient middleware
- and a single tiny reducer -->

## Why Mardux

**tl;dr**

- Easy setup
- Less boilerplate
- Simplifies Redux architecture
- Handles all states of asyncrounus actions
- Provides convinent models and utilities

We all know that redux is awesome. Everything is fast, simple and pure. You create your fancy little states, reducers and actions. But as your project grows Redux tends to get a bit cumbersome. Mapping actions to reducers to update a state, working on mininum 3 files at once, and not to mention the syntax to create a reducer that one remembers. Maintaining all of this repetitive code can indeed be quite tricky.
And thats only for maintaining syncrounus code.

Vanilla Redux lacks the tools to handle asyncrounus code efficiently. Generally, asyncrounus actions consists of three states: loading, error and success. To handle all of those states you are going to need an action for each state. That boilerplate just adds up doesn't it. If you are smart but also kinda lazy, like I am, you would create an action wrapper class that has a set of callback functions to handle each state.

```dart
/// Actions
class SearchAction {
  final String term;

  SearchAction(this.term);
}

class SearchLoadingAction {}

class SearchErrorAction {}

class SearchResultAction {
  final SearchResult result;

  SearchResultAction(this.result);
}
```

```dart
/// Reducer
final searchReducer = combineReducers<SearchState>([
  TypedReducer<SearchState, SearchLoadingAction>(_onLoad),
  TypedReducer<SearchState, SearchErrorAction>(_onError),
  TypedReducer<SearchState, SearchResultAction>(_onResult),
]);

SearchState _onLoad(SearchState state, SearchLoadingAction action) =>
    SearchLoading();

SearchState _onError(SearchState state, SearchErrorAction action) =>
    SearchError();

SearchState _onResult(SearchState state, SearchResultAction action) =>
    action.result.items.isEmpty
        ? SearchEmpty()
        : SearchPopulated(action.result);
```

Congrajulashioshons! You just solved the first problem that explains why this library exists.

With Mardux you only need a single state, reducer and a middleware. You set up your redux store with `Mardux.createReducer<St>()` and `Mardux.createMiddleware<St>()` and you are all set up.

Now for the grand finale. With the reducer and middleware setup you can dispatch a specific kind of action. A `ReduxAction`. This action takes the _Re-_ out of _-dux_ and _duces_ it. This action can be both syncrounous, asyncrounus and act as a reducer, all within a single class. It also provides several other helper function that might come in handy like chaining. To use this magic wand you create a class that extends `ReduxAction<St>` and implement a method called `reduce`. The reduce method acts as the "reducer", so within this method you manipulate the state.

To make an asyncrounus action, the `ReduxAction` provides a method called `request`. If the method is a Future, it will be handled as an asyncrounus action. The `reduce` method will await for the `request` and and will be passed a `RequestStatus` object as a parameter. Therefore the `reduce` knows whether the `request` is loading, has an error or succeeded with a response.

If you want to know more I recommend reading the [Getting started](##Getting-started) section or check out the [Examples](https://github.com/omaroskars/mardux/tree/master/example)

## Getting started

Mardux only dependency is [Redux](https://pub.dev/packages/redux). If you are using Flutter I recommend using [Flutter Redux](https://pub.dev/packages/flutter_redux) as well to easily consume a Redux Store.

### Setup

```dart
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mardux/mardux.dart';

// Create the store as recommended by Flutter Redux. Be sure to create an instance of
// Mardux reducer and middleware and pass it to the store.
void main() {

  final marduxReducer = Mardux.createReducer<int>();
  final marduxMiddleware = Mardux.createMiddleware<int>();

  final store = new Store<int>(
    marduxReducer,
    initialState: 0,
    middleware: [
      marduxMiddleware,
    ],
  );

  runApp(MyApp(
    store: store,
    title: "Mardux demo",
  ));
}
```

```dart
// The StoreProvider should wrap your MaterialApp as recommended by
// by Flutter Redux
class MyApp extends StatelessWidget {
  final Store<int> store;
  final String title;

  const MyApp({Key key, this.store, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return new StoreProvider<int>(
      store: store,
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CounterWidget(),
      ),
    );
  }
}
```

### Syncrounus action

TODO: Write some introduction

```dart
class IncrementCountAction extends ReduxAction<int> {
  // The reduce method acts as a reducer for this action.
  // It takes the previous count and increments it when this action is dispatched
  @override
  int reduce(status) {
    return state + 1;
  }
}
```

### Base model

TODO: Write something about base model

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
    this.errorMsg,
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

```dart
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<int, _VM>(
      converter: (store) => _VM(store).fromStore(), // initialize the VM
      builder: (context, vm) => render(context, vm),
    );
  }

  Widget render(BuildContext context, _VM vm) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Mardux demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            Text(
              vm.count.toString(),
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => vm.dispatch(IncrementCountAction()),
        tooltip: "Increment",
        child: new Icon(Icons.add),
      ),
    );
  }
}
```

### Asyncrounus action

### Chaining
