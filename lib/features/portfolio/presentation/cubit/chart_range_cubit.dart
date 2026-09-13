import 'package:flutter_bloc/flutter_bloc.dart';

enum ChartRange { d1, d3, d5, d7, d10 }

extension ChartRangeX on ChartRange {
  int get days => switch (this) {
        ChartRange.d1 => 1,
        ChartRange.d3 => 3,
        ChartRange.d5 => 5,
        ChartRange.d7 => 7,
        ChartRange.d10 => 10,
      };

  String get label => switch (this) {
        ChartRange.d1 => '1D',
        ChartRange.d3 => '3D',
        ChartRange.d5 => '5D',
        ChartRange.d7 => '7D',
        ChartRange.d10 => '10D',
      };
}

class ChartRangeCubit extends Cubit<ChartRange> {
  ChartRangeCubit() : super(ChartRange.d7);

  void select(ChartRange range) => emit(range);
}
