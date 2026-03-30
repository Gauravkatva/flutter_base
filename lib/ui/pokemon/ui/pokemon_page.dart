import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_appp/di/injection.dart';
import 'package:my_appp/domain/data/pokemon/pokemon_api.dart';
import 'package:my_appp/ui/pokemon/bloc/pokemon_bloc.dart';
import 'package:my_appp/ui/pokemon/ui/pokemon_list_item.dart';

/// Pokemon list page
class PokemonListPage extends StatelessWidget {
  const PokemonListPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const PokemonListPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PokemonBloc(pokemonApi: getIt.get<PokemonApi>())
            ..add(const LoadPokemonList()),
      child: const PokemonListView(),
    );
  }
}

/// Pokemon list view
class PokemonListView extends StatefulWidget {
  const PokemonListView({super.key});

  @override
  State<PokemonListView> createState() => _PokemonListViewState();
}

class _PokemonListViewState extends State<PokemonListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PokemonBloc>().add(const LoadMorePokemon());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PokemonBloc>().add(const RefreshPokemonList());
            },
          ),
        ],
      ),
      body: BlocConsumer<PokemonBloc, PokemonState>(
        listener: (context, state) {
          if (state is PokemonLoaded && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    if (state.pokemons.isEmpty) {
                      context.read<PokemonBloc>().add(const LoadPokemonList());
                    } else {
                      context.read<PokemonBloc>().add(const LoadMorePokemon());
                    }
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            PokemonInitial() => const SizedBox.shrink(),
            PokemonLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            PokemonLoaded()
                when state.pokemons.isEmpty && state.errorMessage != null =>
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PokemonBloc>().add(
                          const LoadPokemonList(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            PokemonLoaded() => RefreshIndicator(
              onRefresh: () async {
                context.read<PokemonBloc>().add(const RefreshPokemonList());
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.hasMore
                    ? state.pokemons.length + 1
                    : state.pokemons.length,
                itemBuilder: (context, index) {
                  if (index >= state.pokemons.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final pokemon = state.pokemons[index];
                  return PokemonListItem(pokemon: pokemon);
                },
              ),
            ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
