///////////////////////////////////////////////////////////////////////////////
/// The AppState contains:
///   counter     : Counter for how many times the button is pressed
///   description : Description text from a server
///   isLoading   : Indicator for loading state
///   errorMsg    : An error message if an error occurs

class AppState {
  final int? counter;
  final String? description;
  final bool? isLoading;
  final String? errorMsg;

  AppState({
    this.counter,
    this.description,
    this.isLoading,
    this.errorMsg,
  });

  AppState copy({
    int? counter,
    String? description,
    bool? isLoading,
    dynamic? errorMsg,
  }) =>
      AppState(
        counter: counter ?? this.counter,
        description: description ?? this.description,
        isLoading: isLoading ?? false,
        errorMsg: errorMsg ?? null,
      );

  static AppState initialState() =>
      AppState(counter: 0, description: "", isLoading: false, errorMsg: null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          counter == other.counter &&
          description == other.description &&
          errorMsg == other.errorMsg &&
          isLoading == other.isLoading;

  @override
  int get hashCode => counter.hashCode ^ description.hashCode;
}
