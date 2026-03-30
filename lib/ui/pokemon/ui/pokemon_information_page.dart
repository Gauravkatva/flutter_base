import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_appp/di/injection.dart';
import 'package:my_appp/ui/pokemon/pokemon_info/pokemon_info_bloc.dart';
import 'package:my_appp/utils/dio_client.dart';

class PokemonInformationPage extends StatelessWidget {
  const PokemonInformationPage({required this.url, super.key});

  static Route<void> route(String url) {
    return MaterialPageRoute<void>(
      builder: (_) => PokemonInformationPage(url: url),
    );
  }

  final String url;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PokemonInfoBloc(dio: getIt.get<DioClient>())
            ..add(LoadPokemonInfo(url: url)),
      child: const _PokemonInformationPageState(),
    );
  }
}

class _PokemonInformationPageState extends StatelessWidget {
  const _PokemonInformationPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon Information'),
      ),
      body: BlocBuilder<PokemonInfoBloc, PokemonInfoState>(
        builder: (context, state) {
          if (state is PokemonInfoLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is PokemonInfoLoaded) {
            return Column(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    state.information.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  state.information.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ],
            );
          } else if (state is PokemonInfoError) {
            return Center(
              child: Text(state.message),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
