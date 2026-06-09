import 'package:equatable/equatable.dart';

abstract class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object> get props => [];
}

class FetchEarnings extends EarningsEvent {
  final String period;

  const FetchEarnings(this.period);

  @override
  List<Object> get props => [period];
}
