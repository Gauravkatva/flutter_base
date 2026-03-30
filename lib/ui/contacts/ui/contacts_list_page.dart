import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_appp/di/injection.dart';
import 'package:my_appp/domain/data/contacts/contacts_api.dart';
import 'package:my_appp/ui/contacts/bloc/contacts_list_bloc.dart';

class ContactsListPage extends StatelessWidget {
  const ContactsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContactsListBloc(
        contactsApi: getIt.get<ContactsApi>(),
      )..add(LoadRemoteContacts()),
      child: const _ContactsListPageView(),
    );
  }
}

class _ContactsListPageView extends StatefulWidget {
  const _ContactsListPageView();

  @override
  State<_ContactsListPageView> createState() => __ContactsListPageViewState();
}

class __ContactsListPageViewState extends State<_ContactsListPageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: BlocBuilder<ContactsListBloc, ContactsListState>(
        builder: (context, state) {
          if (state is ContactsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ContactsErrorState) {
            return Center(
              child: Text(state.errorMessage),
            );
          } else if (state is ContactsLoadedState) {
            return ListView.builder(
              itemCount: state.contacts.length,
              itemBuilder: (context, index) {
                final item = state.contacts[index];
                return Card(
                  color: item.conflict
                      ? Colors.redAccent.withOpacity(0.5)
                      : Colors.transparent,
                  child: Column(
                    children: [Text(item.name ?? '')],
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('Something went wrong!'),
            );
          }
        },
      ),
    );
  }
}
