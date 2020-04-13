import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:redux_compact/redux_compact.dart';

///////////////////////////////////////////////////////////////////////////////
/// Initialize the store as recommended by Flutter redux

void main() {
  // Create an instance of ReduxCompact reducer and middleware.
  // In this example the AppState is an integer representing a counter
  final compactReducer = ReduxCompact.createReducer<int>();
  final compactMiddleware = ReduxCompact.createMiddleware<int>();

  final store = new Store<int>(
    compactReducer, // <-- Add the reducer
    initialState: 0,
    middleware: [
      compactMiddleware, // <-- Add the middleware
    ],
  );

  runApp(MyApp(
    store: store,
    title: "Redux Compact",
  ));
}

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

///////////////////////////////////////////////////////////////////////////////
/// The action increments the counter by [incrementBy]
class IncrementCountAction extends CompactAction<int> {
  final int incrementBy;

  IncrementCountAction(this.incrementBy);

  @override
  int reduce(status) {
    // The reduce method has access to the store state
    // and instance variables
    return state + incrementBy;
  }
}

///////////////////////////////////////////////////////////////////////////////
/// BaseModel has direct access to the store, state and dispatch function
/// Its a convienent helper class to quickly create a ViewModel
class _VM extends BaseModel<int> {
  final int count;

  _VM(Store store, {this.count}) : super(store);

  @override
  BaseModel fromStore() {
    // You can access the store's state directly with state
    // or through store.state if you like
    final count = state;
    return _VM(store, count: count);
  }

  incrementCount() {
    // You can dispatch within the BaseModel
    // or within the Widget with vm.disptach(...)
    dispatch(IncrementCountAction(1));
  }
}

class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<int, _VM>(
      converter: (store) =>
          _VM(store).fromStore(), // <-- Initialize the BaseModel
      builder: (context, vm) => render(context, vm),
    );
  }

  Widget render(BuildContext context, _VM vm) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Redux Compact"),
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
        onPressed: () =>
            vm.incrementCount(), // <-- Dispatch through the BaseModel
        tooltip: "Increment",
        child: new Icon(Icons.add),
      ),
    );
  }
}
