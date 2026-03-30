part of 'luxury_bloc.dart';

sealed class LuxuryEvent extends Equatable {
  const LuxuryEvent();

  @override
  List<Object> get props => [];
}

class LoadLuxuryPricing extends LuxuryEvent {}

class LoadLocalPricing extends LuxuryEvent {}
