import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_appp/domain/data/model/split_type.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_bloc.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_event.dart';
import 'package:my_appp/ui/splitwise/bloc/splitwise_state.dart';

/// Full page for adding a new expense
class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedUserId;
  SplitType _selectedSplitType = SplitType.equal;
  final Map<String, TextEditingController> _splitControllers = {};
  String? _validationError;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (final controller in _splitControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplitWiseBloc, SplitWiseState>(
      builder: (context, state) {
        if (state is! SplitWiseLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Initialize controllers for split values
        if (_splitControllers.isEmpty) {
          for (final user in state.users) {
            _splitControllers[user.id] = TextEditingController();
          }
          _selectedUserId = state.users.first.id;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Expense'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildDescriptionField(context),
                const SizedBox(height: 16),
                _buildAmountField(context),
                const SizedBox(height: 16),
                _buildPaidByDropdown(context, state),
                const SizedBox(height: 24),
                _buildSplitTypeSelector(context),
                const SizedBox(height: 20),
                _buildSplitInputs(context, state),
                if (_validationError != null) ...[
                  const SizedBox(height: 16),
                  _buildValidationError(context),
                ],
                const SizedBox(height: 24),
                _buildActionButtons(context, state),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'What was this expense for?',
        prefixIcon: Icon(Icons.description_outlined),
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

  Widget _buildAmountField(BuildContext context) {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Amount',
        hintText: '0.00',
        prefixIcon: Icon(Icons.currency_rupee),
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount greater than 0';
        }
        return null;
      },
    );
  }

  Widget _buildPaidByDropdown(BuildContext context, SplitWiseLoaded state) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      value: _selectedUserId,
      decoration: const InputDecoration(
        labelText: 'Paid By',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      items: state.users.map((user) {
        return DropdownMenuItem(
          value: user.id,
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: user.avatarColor,
                child: Text(
                  user.initials,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(user.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedUserId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select who paid';
        }
        return null;
      },
    );
  }

  Widget _buildSplitTypeSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Split Type',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<SplitType>(
          segments: [
            ButtonSegment(
              value: SplitType.equal,
              label: Text(SplitType.equal.displayName),
              icon: const Icon(Icons.people),
            ),
            ButtonSegment(
              value: SplitType.percentage,
              label: Text(SplitType.percentage.displayName),
              icon: const Icon(Icons.percent),
            ),
            ButtonSegment(
              value: SplitType.weightage,
              label: Text(SplitType.weightage.displayName),
              icon: const Icon(Icons.scale),
            ),
          ],
          selected: {_selectedSplitType},
          onSelectionChanged: (selected) {
            setState(() {
              _selectedSplitType = selected.first;
              _validationError = null;
              // Clear split controllers when switching types
              for (final controller in _splitControllers.values) {
                controller.clear();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildSplitInputs(BuildContext context, SplitWiseLoaded state) {
    final theme = Theme.of(context);

    if (_selectedSplitType == SplitType.equal) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      final perPerson = amount > 0 ? amount / state.users.length : 0;

      return Card(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Each person pays equally',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...state.users.map(
                (user) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: user.avatarColor,
                        child: Text(
                          user.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(user.name)),
                      Text(
                        '₹${perPerson.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedSplitType == SplitType.percentage
              ? 'Enter percentage for each person (must sum to 100%)'
              : 'Enter weight/ratio for each person',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...state.users.map((user) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: user.avatarColor,
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Text(
                    user.name,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _splitControllers[user.id],
                    decoration: InputDecoration(
                      hintText: _selectedSplitType == SplitType.percentage
                          ? '%'
                          : 'Weight',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      suffixText: _selectedSplitType == SplitType.percentage
                          ? '%'
                          : null,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildValidationError(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _validationError!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, SplitWiseLoaded state) {
    return FilledButton(
      onPressed: () => _handleSubmit(context, state),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
      ),
      child: const Text('Add Expense'),
    );
  }

  void _handleSubmit(BuildContext context, SplitWiseLoaded state) {
    setState(() {
      _validationError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text);
    final splitValues = <String, double>{};

    // Build split values based on split type
    if (_selectedSplitType == SplitType.equal) {
      // For equal split, assign equal weight to all users
      for (final user in state.users) {
        splitValues[user.id] = 1;
      }
    } else {
      // For percentage or weightage, get values from controllers
      for (final user in state.users) {
        final valueText = _splitControllers[user.id]?.text ?? '';
        final value = double.tryParse(valueText) ?? 0;

        if (value <= 0) {
          setState(() {
            _validationError =
                'All ${_selectedSplitType.displayName.toLowerCase()} '
                'values must be greater than 0';
          });
          return;
        }

        splitValues[user.id] = value;
      }

      // Validate percentage sums to 100
      if (_selectedSplitType == SplitType.percentage) {
        final total = splitValues.values.fold<double>(0, (sum, val) => sum + val);
        if ((total - 100).abs() > 0.01) {
          setState(() {
            _validationError =
                'Percentages must sum to 100%. '
                'Current sum: ${total.toStringAsFixed(1)}%';
          });
          return;
        }
      }
    }

    // Add the expense
    context.read<SplitWiseBloc>().add(
          AddExpense(
            description: _descriptionController.text.trim(),
            amount: amount,
            paidByUserId: _selectedUserId!,
            splitType: _selectedSplitType,
            splitValues: splitValues,
          ),
        );

    Navigator.of(context).pop();
  }
}
