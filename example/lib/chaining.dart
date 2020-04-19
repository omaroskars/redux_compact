import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;
import 'package:redux_compact/redux_compact.dart';

///////////////////////////////////////////////////////////////////////////////
/// Setup a basic Redux state for the app
/// The AppState contains:
///   counter     : Counter for how many times the button is pressed
///   description : Description text from a server
///   isLoading   : Indicator for loading state
///   errorMsg    : An error message if an error occurs
///   prevDesc    : The previous description

class AppState {
  final int counter;
  final String description;
  final bool isLoading;
  final String errorMsg;

  final String prevDesc;

  AppState({
    this.counter,
    this.description,
    this.isLoading,
    this.errorMsg,
    this.prevDesc,
  });

  AppState copy({
    int counter,
    String description,
    bool isLoading,
    dynamic errorMsg,
    String prevDesc,
  }) =>
      AppState(
        counter: counter ?? this.counter,
        description: description ?? this.description,
        isLoading: isLoading ?? false,
        errorMsg: errorMsg ?? null,
        prevDesc: prevDesc ?? this.prevDesc,
      );

  static AppState initialState() => AppState(
      counter: 0,
      description: "",
      isLoading: false,
      errorMsg: null,
      prevDesc: null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          counter == other.counter &&
          description == other.description &&
          errorMsg == other.errorMsg &&
          isLoading == other.isLoading &&
          prevDesc == other.prevDesc;

  @override
  int get hashCode =>
      counter.hashCode ^ description.hashCode ^ prevDesc.hashCode;
}

///////////////////////////////////////////////////////////////////////////////
/// Setup the redux store as is recommended by flutter_redux.

void main() {
  // Create an instance of Redux Compact reducer and middleware
  // and initialize the redux store

  final compactReducer = ReduxCompact.createReducer<AppState>();
  final compactMiddleware = ReduxCompact.createMiddleware<AppState>();

  final store = new Store<AppState>(
    compactReducer,
    initialState: AppState.initialState(),
    middleware: [
      compactMiddleware,
    ],
  );

  runApp(MyApp(
    store: store,
    title: "Redux compact demo",
  ));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;
  final String title;

  const MyApp({Key key, this.store, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StoreProvider<AppState>(
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
/// Helper class known as a ViewModel.
/// The view model has direct access to the store's state for convenience.
/// You can therefore use the state directly or access it through the store.state if you like

class _VM extends BaseModel<AppState> {
  final int count;
  final String desc;
  final bool isLoading;
  final String errorMsg;
  final String prevDesc;

  _VM(
    Store store, {
    this.count,
    this.desc,
    this.isLoading,
    this.errorMsg,
    this.prevDesc,
  }) : super(store);

  @override
  BaseModel fromStore() {
    return _VM(
      store,
      count: state.counter,
      desc: state.description,
      isLoading: state.isLoading,
      errorMsg: state.errorMsg,
      prevDesc: state.prevDesc,
    );
  }

  incrementCount() {
    dispatch(IncrementCountAction(1));
  }
}

class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _VM>(
      converter: (store) => _VM(store).fromStore(),
      builder: (context, vm) => Scaffold(
        appBar: AppBar(title: Text("Async demo")),
        body: Center(
          child: buildBody(context, vm),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => vm.incrementCount(),
          tooltip: "Increment",
          child: new Icon(Icons.add),
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context, _VM vm) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          vm.count.toString(),
          style: Theme.of(context).textTheme.display1,
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: vm.isLoading
              ? CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                )
              : Text(
                  vm.desc,
                  textAlign: TextAlign.center,
                ),
        ),
        SizedBox(
          height: 20,
        ),
        buildPrev(context, vm),
      ],
    );
  }

  Widget buildPrev(BuildContext context, _VM vm) {
    return vm.prevDesc != null
        ? Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Previous: ${vm.prevDesc}",
              textAlign: TextAlign.center,
            ),
          )
        : Container();
  }
}

///////////////////////////////////////////////////////////////////////////////
/// Before the reduce method is run it dispatches: [ShowDescriptionCountAction]
/// Then it Increments the count by incrementBy.
/// Finally it dispatches: [FetchDescriptionAction]
class IncrementCountAction extends CompactAction<AppState> {
  final int incrementBy;

  IncrementCountAction(this.incrementBy);

  @override
  AppState reduce() {
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

/// Updates the precDesc state with the current description state
class SetPreviousDescAction extends CompactAction<AppState> {
  @override
  AppState reduce() {
    return state.copy(
      prevDesc: state.description,
    );
  }
}

/// This action makes an asynchronous request to the numbers api.
/// Updates the state when its loading,
/// When it gets a response it updates the description with the response
class FetchDescriptionAction extends CompactAction<AppState> {
  final int count;

  FetchDescriptionAction(this.count);

  @override
  Future makeRequest() {
    final url = "http://numbersapi.com/${count}";
    final res = http.read(url);

    return res;
  }

  AppState reduce() {
    // Handle loading state
    if (request.loading) {
      return state.copy(isLoading: request.loading);
    }

    // Update the error message if an error occurs
    if (request.hasError) {
      return state.copy(
        errorMsg: "Error occured",
      );
    }

    // Parse response from the server
    final description = request.data;

    // Update the state with incremented counter
    // and a description from the server
    return state.copy(
      description: description,
    );
  }
}
