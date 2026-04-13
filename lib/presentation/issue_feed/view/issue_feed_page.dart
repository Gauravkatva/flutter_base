import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_appp/domain/repositories/issue_repository.dart';
import 'package:my_appp/presentation/issue_feed/bloc/issue_feed_bloc.dart';
import 'package:my_appp/presentation/issue_feed/bloc/issue_feed_event.dart';
import 'package:my_appp/presentation/issue_feed/bloc/issue_feed_state.dart';
import 'package:my_appp/presentation/issue_feed/view/widgets/empty_feed_widget.dart';
import 'package:my_appp/presentation/issue_feed/view/widgets/issue_card.dart';
import 'package:my_appp/presentation/issue_form/bloc/issue_form_bloc.dart';
import 'package:my_appp/presentation/issue_form/view/issue_form_page.dart';

/// Main feed page displaying all reported civic issues.
class IssueFeedPage extends StatelessWidget {
  const IssueFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Issues'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<IssueFeedBloc>().add(const IssueFeedLoaded());
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: const SafeArea(
        child: _IssueFeedView(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final repository = context.read<IssueRepository>();
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => IssueFormBloc(
                  issueRepository: repository,
                ),
                child: IssueFormPage(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'Report Issue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _IssueFeedView extends StatefulWidget {
  const _IssueFeedView();

  @override
  State<_IssueFeedView> createState() => _IssueFeedViewState();
}

class _IssueFeedViewState extends State<_IssueFeedView> {
  @override
  void initState() {
    super.initState();
    // Load issues when the page first loads
    context.read<IssueFeedBloc>().add(const IssueFeedLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IssueFeedBloc, IssueFeedState>(
      builder: (context, state) {
        // Loading state
        if (state.status == FeedStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error state
        if (state.status == FeedStatus.error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                    state.errorMessage ?? 'Something went wrong',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<IssueFeedBloc>().add(const IssueFeedLoaded());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (state.isEmpty) {
          return const EmptyFeedWidget();
        }

        // Success state with data
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.issues.length,
          itemBuilder: (context, index) {
            final issue = state.issues[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: IssueCard(issue: issue),
            );
          },
        );
      },
    );
  }
}
