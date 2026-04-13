import 'package:equatable/equatable.dart';
import 'package:my_appp/domain/data/model/context_type.dart';
import 'package:my_appp/domain/data/model/filter_type.dart';

class FilterOptions extends Equatable {
  const FilterOptions({
    required this.filterType,
    this.selectedContext,
  });

  final FilterType filterType;
  final ContextType? selectedContext;

  @override
  List<Object?> get props => [filterType, selectedContext];

  FilterOptions copyWith({
    FilterType? filterType,
    ContextType? selectedContext,
  }) {
    return FilterOptions(
      filterType: filterType ?? this.filterType,
      selectedContext: selectedContext ?? this.selectedContext,
    );
  }
}
