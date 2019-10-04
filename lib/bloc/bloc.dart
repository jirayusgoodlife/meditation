export 'timer_bloc.dart';
export 'timer_event.dart';
export 'timer_state.dart';

class Ticker {
  Stream<int> tick({int ticks}) {
    return Stream.periodic(Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
  }
}