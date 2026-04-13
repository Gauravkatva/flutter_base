import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_appp/core/utils/image_picker_helper.dart';
import 'package:my_appp/domain/models/government_body.dart';
import 'package:my_appp/domain/models/location_direction.dart';
import 'package:my_appp/domain/models/zone.dart';
import 'package:my_appp/presentation/issue_form/bloc/issue_form_bloc.dart';
import 'package:my_appp/presentation/issue_form/bloc/issue_form_event.dart';
import 'package:my_appp/presentation/issue_form/bloc/issue_form_state.dart';

/// Page for reporting a new civic issue.
class IssueFormPage extends StatelessWidget {
  const IssueFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Civic Issue'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _IssueFormView(),
        ),
      ),
    );
  }
}

class _IssueFormView extends StatefulWidget {
  _IssueFormView();

  @override
  State<_IssueFormView> createState() => _IssueFormViewState();
}

class _IssueFormViewState extends State<_IssueFormView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<IssueFormBloc, IssueFormState>(
      listener: (context, state) {
        if (state.status == FormStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Issue reported successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<IssueFormBloc>().add(const IssueFormReset());
          Navigator.of(context).pop();
        } else if (state.status == FormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to submit issue'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Help improve your community by reporting civic issues',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Reporter Name Field
            const _ReporterNameField(),
            const SizedBox(height: 16),

            // Government Body Dropdown
            const _GovernmentBodyDropdown(),
            const SizedBox(height: 16),

            // Address Field
            const _AddressField(),
            const SizedBox(height: 16),

            // Direction and Zone Row
            const Row(
              children: [
                Expanded(child: _DirectionDropdown()),
                SizedBox(width: 12),
                Expanded(child: _ZoneDropdown()),
              ],
            ),
            const SizedBox(height: 24),

            // Image Picker
            const _ImagePickerSection(),
            const SizedBox(height: 32),

            // Submit Button
            const _SubmitButton(),
          ],
        ),
      ),
    );
  }
}

class _ReporterNameField extends StatelessWidget {
  const _ReporterNameField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IssueFormBloc, IssueFormState>(
      buildWhen: (previous, current) =>
          previous.reporterName != current.reporterName,
      builder: (context, state) {
        return TextFormField(
          decoration: InputDecoration(
            labelText: 'Your Name',
            hintText: 'Enter your full name',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          onChanged: (value) {
            context.read<IssueFormBloc>().add(IssueFormNameChanged(value));
          },
          validator: (value) {
            if (value == null || value.trim().length < 2) {
              return 'Please enter your name (minimum 2 characters)';
            }
            return null;
          },
          style: const TextStyle(fontSize: 18),
        );
      },
    );
  }
}

class _GovernmentBodyDropdown extends StatelessWidget {
  const _GovernmentBodyDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IssueFormBloc, IssueFormState>(
      buildWhen: (previous, current) =>
          previous.governmentBody != current.governmentBody,
      builder: (context, state) {
        return DropdownButtonFormField<GovernmentBody>(
          value: state.governmentBody,
          decoration: InputDecoration(
            labelText: 'Responsible Department',
            hintText: 'Select government body',
            prefixIcon: const Icon(Icons.account_balance),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          items: GovernmentBody.values.map((body) {
            return DropdownMenuItem(
              value: body,
              child: Text(
                body.displayName,
                style: const TextStyle(fontSize: 18),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<IssueFormBloc>().add(IssueFormBodyChanged(value));
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a government body';
            }
            return null;
          },
          isExpanded: true,
        );
      },
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IssueFormBloc, IssueFormState>(
      buildWhen: (previous, current) => previous.address != current.address,
      builder: (context, state) {
        return TextFormField(
          decoration: InputDecoration(
            labelText: 'Issue Location Address',
            hintText: 'Enter the complete address',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.streetAddress,
          onChanged: (value) {
            context.read<IssueFormBloc>().add(IssueFormAddressChanged(value));
          },
          validator: (value) {
            if (value == null || value.trim().length < 10) {
              return 'Please enter a detailed address (minimum 10 characters)';
            }
            return null;
          },
          style: const TextStyle(fontSize: 18),
        );
      },
    );
  }
}

class _DirectionDropdown extends StatelessWidget {
  const _DirectionDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IssueFormBloc, IssueFormState>(
      buildWhen: (previous, current) => previous.direction != current.direction,
      builder: (context, state) {
        return DropdownButtonFormField<LocationDirection>(
          value: state.direction,
          decoration: InputDecoration(
            labelText: 'Direction',
            hintText: 'Select',
            prefixIcon: const Icon(Icons.explore_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          items: LocationDirection.values.map((direction) {
            return DropdownMenuItem(
              value: direction,
              child: Text(
                direction.displayName,
                style: const TextStyle(fontSize: 18),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              context
                  .read<IssueFormBloc>()
                  .add(IssueFormDirectionChanged(value));
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Required';
            }
            return null;
          },
          isExpanded: true,
        );
      },
    );
  }
}

class _ZoneDropdown extends StatelessWidget {
  const _ZoneDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IssueFormBloc, IssueFormState>(
      buildWhen: (previous, current) => previous.zone != current.zone,
      builder: (context, state) {
        return DropdownButtonFormField<Zone>(
          value: state.zone,
          decoration: InputDecoration(
            labelText: 'Zone',
            hintText: 'Select',
            prefixIcon: const Icon(Icons.map_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          items: Zone.values.map((zone) {
            return DropdownMenuItem(
              value: zone,
              child: Text(
                zone.displayName,
                style: const TextStyle(fontSize: 18),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<IssueFormBloc>().add(IssueFormZoneChanged(value));
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Required';
            }
            return null;
          },
          isExpanded: true,
        );
      },
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  const _ImagePickerSection();

  Future<void> _pickImage(BuildContext context) async {
    final imagePath = await ImagePickerHelper.pickImage();

    if (imagePath != null && context.mounted) {
      context.read<IssueFormBloc>().add(IssueFormImageChanged(imagePath));
    } else if (imagePath == null && context.mounted) {
      // User cancelled or error occurred
      // Optionally show a message
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IssueFormBloc, IssueFormState>(
      buildWhen: (previous, current) => previous.imagePath != current.imagePath,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: () => _pickImage(context),
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 24),
              label: Text(
                state.imagePath == null ? 'Add Photo (Optional)' : 'Change Photo',
                style: const TextStyle(fontSize: 18),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (state.imagePath != null) ...[
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(state.imagePath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton.filled(
                      onPressed: () {
                        context
                            .read<IssueFormBloc>()
                            .add(const IssueFormImageChanged(null));
                      },
                      icon: const Icon(Icons.close),
                      tooltip: 'Remove image',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IssueFormBloc, IssueFormState>(
      builder: (context, state) {
        final isLoading = state.status == FormStatus.submitting;

        return FilledButton(
          onPressed: isLoading
              ? null
              : () {
                  context.read<IssueFormBloc>().add(const IssueFormSubmitted());
                },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Submit Issue Report',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
        );
      },
    );
  }
}
