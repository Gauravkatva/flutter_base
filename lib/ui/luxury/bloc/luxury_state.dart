part of 'luxury_bloc.dart';

class LuxuryState extends Equatable {
  const LuxuryState({
    this.localPriceList = const [],
    this.streamingPriceList = const [],
    this.isLoading = false,
  });

  // Data loaded from local bid_data.json
  final List<LuxuryModel> localPriceList;

  // Data streamed from luxury API
  final List<LuxuryModel> streamingPriceList;

  final bool isLoading;

  // Combined list for display (local + streaming)
  List<LuxuryModel> get allPrices => [...localPriceList, ...streamingPriceList];

  // Chart data - streamingPriceList already maintains only 10 items
  List<LuxuryModel> get chartData => streamingPriceList;

  LuxuryState copyWith({
    List<LuxuryModel>? localPriceList,
    List<LuxuryModel>? streamingPriceList,
    bool? isLoading,
  }) {
    return LuxuryState(
      localPriceList: localPriceList ?? this.localPriceList,
      streamingPriceList: streamingPriceList ?? this.streamingPriceList,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [localPriceList, streamingPriceList, isLoading];
}
