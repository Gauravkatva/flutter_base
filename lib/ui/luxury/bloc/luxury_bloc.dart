import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:my_appp/domain/data/luxury/luxury_api.dart';
import 'package:my_appp/domain/data/model/luxury_model.dart';

part 'luxury_event.dart';
part 'luxury_state.dart';

class LuxuryBloc extends Bloc<LuxuryEvent, LuxuryState> {
  LuxuryBloc(this._luxuryApi) : super(const LuxuryState()) {
    on<LoadLuxuryPricing>(_loadLuxuryPricing);
    on<LoadLocalPricing>(_loadLocalPricing);
  }
  final LuxuryApi _luxuryApi;

  FutureOr<void> _loadLuxuryPricing(
    LoadLuxuryPricing event,
    Emitter<LuxuryState> emit,
  ) async {
    // Process each item in real-time as it streams
    await for (final data in _luxuryApi.getLuxuryItems()) {
      // Parse in isolate to avoid UI blocking
      final receivePort = ReceivePort();
      await Isolate.spawn(
        _parseSingleItemIsolate,
        [receivePort.sendPort, data],
      );

      final item = await receivePort.first as LuxuryModel;
      receivePort.close();

      // Maintain only 10 items - O(1) operations
      final updatedList = List<LuxuryModel>.from(state.streamingPriceList);

      if (updatedList.length >= 10) {
        updatedList.removeAt(0); // removeFirst - O(1)
      }
      updatedList.add(item); // addLast - O(1)

      emit(state.copyWith(streamingPriceList: updatedList));
    }
  }

  FutureOr<void> _loadLocalPricing(
    LoadLocalPricing event,
    Emitter<LuxuryState> emit,
  ) async {
    // ●​ The Constraint: You must parse this data and format it for the chart
    // using Dart Isolates
    // (Isolate.run or compute). If the UI drops a single frame or the loading
    // spinner stutters
    // during this parse, the test is failed.
    emit(state.copyWith(isLoading: true));

    const jsonPath = 'assets/bid_data.json';
    final data = await rootBundle.loadString(jsonPath);

    final receivePort = ReceivePort();

    // Spawn the isolate with a top-level function
    await Isolate.spawn(
      _parseDataIsolate,
      [receivePort.sendPort, data],
    );

    try {
      // Await the first message so the Bloc handler doesn't complete
      // prematurely
      final message = await receivePort.first;
      if (message is List<LuxuryModel>) {
        emit(
          state.copyWith(localPriceList: message, isLoading: false),
        );
        add(LoadLuxuryPricing());
      }
    } finally {
      receivePort.close();
    }
  }
}

// Top-level function for Isolate.spawn - parses entire JSON file
void _parseDataIsolate(List<dynamic> args) {
  final sendPort = args[0] as SendPort;
  final data = args[1] as String;

  final jsonList = jsonDecode(data) as List<dynamic>;
  final priceList = jsonList
      .map((e) => LuxuryModel.fromJson(e as Map<String, dynamic>))
      .toList();

  sendPort.send(priceList);
}

// Top-level function for Isolate.spawn - parses a single streaming item
void _parseSingleItemIsolate(List<dynamic> args) {
  final sendPort = args[0] as SendPort;
  final data = args[1] as Map<String, dynamic>;

  final item = LuxuryModel.fromJson(data);

  sendPort.send(item);
}
