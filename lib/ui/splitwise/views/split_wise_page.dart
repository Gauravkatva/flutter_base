import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_appp/ui/splitwise/bloc/splitwise_bloc.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_event.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_state.dart';
import 'package:my_appp/ui/splitwise/views/add_expense_page.dart';
import 'package:my_appp/ui/splitwise/views/widgets/balances_tab.dart';
import 'package:my_appp/ui/splitwise/views/widgets/expenses_tab.dart';
import 'package:my_appp/ui/splitwise/views/widgets/settlements_tab.dart';

/// Main SplitWise page with Material 3 design
class SplitWisePage extends StatelessWidget {
  const SplitWisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplitWiseBloc()..add(const InitializeSplitWise()),
      child: const SplitWiseView(),
    );
  }
}

class SplitWiseView extends StatefulWidget {
  const SplitWiseView({super.key});

  @override
  State<SplitWiseView> createState() => _SplitWiseViewState();
}

class _SplitWiseViewState extends State<SplitWiseView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddExpenseSheet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (pageContext) => BlocProvider.value(
          value: context.read<SplitWiseBloc>(),
          child: const AddExpensePage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<SplitWiseBloc, SplitWiseState>(
      listener: (context, state) {
        // Show error messages
        if (state is SplitWiseLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('SplitWise'),
            centerTitle: false,
            elevation: 0,
            actions: [
              if (state is SplitWiseLoaded && state.expenses.isNotEmpty)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'clear') {
                      _showClearConfirmation(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Clear all expenses'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.receipt_long),
                  text: 'Expenses',
                ),
                Tab(
                  icon: Icon(Icons.account_balance_wallet),
                  text: 'Balances',
                ),
                Tab(
                  icon: Icon(Icons.payment),
                  text: 'Settlements',
                ),
              ],
            ),
          ),
          body: _buildBody(state),
          floatingActionButton: state is SplitWiseLoaded
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddExpenseSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(SplitWiseState state) {
    if (state is SplitWiseInitial || state is SplitWiseLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is SplitWiseError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    if (state is SplitWiseLoaded) {
      return TabBarView(
        controller: _tabController,
        children: const [
          ExpensesTab(),
          BalancesTab(),
          SettlementsTab(),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Expenses?'),
        content: const Text(
          'This will delete all expenses and reset all balances. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<SplitWiseBloc>().add(const ClearAllExpenses());
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
