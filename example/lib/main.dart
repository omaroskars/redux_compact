import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:redux_compact/redux_compact.dart';

// One simple action: Increment
class IncrementCountAction extends ReduxAction<int> {
  // The reduce method acts as a reducer for this action.
  // It takes the previous count and increments it when this action is dispatched
  @override
  int reduce(status) {
    return state + 1;
  }
}

void main() {
  // Create an instance of ReduxCompact reducer and middleware
  // and initialize the redux store
  final compactReducer = ReduxCompact.createReducer<int>();
  final compactMiddleware = ReduxCompact.createMiddleware<int>();

  final store = new Store<int>(
    compactReducer,
    initialState: 0,
    middleware: [
      compactMiddleware,
    ],
  );

  runApp(MyApp(
    store: store,
    title: "Redux Compact Demo",
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

// By extending BaseModel the ViewModel
// gains access to the store, state and dispatch
class _VM extends BaseModel<int> {
  final int count;

  _VM(Store store, {this.count}) : super(store);

  @override
  BaseModel fromStore() {
    return _VM(store, count: state);
  }
}

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
        title: Text("ReduxCompact demo"),
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
