import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_appp/domain/constants/local_contacts.dart';
import 'package:my_appp/domain/data/contacts/contacts_api.dart';
import 'package:my_appp/domain/data/model/contacts.dart';

part 'contacts_list_event.dart';
part 'contacts_list_state.dart';

class ContactsListBloc extends Bloc<ContactsListEvent, ContactsListState> {
  ContactsListBloc({
    required ContactsApi contactsApi,
  }) : _contactsApi = contactsApi,
       super(ContactsListInitial()) {
    on<LoadLocalContacts>(_loadLocalContacts);
    on<LoadRemoteContacts>(_loadRemoteContacts);
    on<MergeContacts>(_mergeContacts);
  }

  final ContactsApi _contactsApi;

  FutureOr<void> _loadLocalContacts(
    LoadLocalContacts event,
    Emitter<ContactsListState> emit,
  ) {}

  FutureOr<void> _loadRemoteContacts(
    LoadRemoteContacts event,
    Emitter<ContactsListState> emit,
  ) async {
    emit(ContactsLoading());
    final response = await _contactsApi.fetchContacts();
    if (response.isSuccess) {
      final _remoteContacts = response.data ?? [];
      final _localContacts =
          localContacts['contacts']
              ?.map((e) => Contacts.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      add(MergeContacts(local: _localContacts, remote: _remoteContacts));
    } else {
      emit(
        ContactsErrorState(
          errorMessage: response.error?.message ?? 'Failed to load data!',
        ),
      );
    }
  }

  FutureOr<void> _mergeContacts(
    MergeContacts event,
    Emitter<ContactsListState> emit,
  ) {
    // they share a phone number after removing non digit char
    // they share an emaiol case-sensitive means -> a@gmail.com is differnet from A@gmail.com
    // they have the same name trimmed and case in-senstivie a and A are same
    final merged = <Contacts>[];
    final processed = Set<Contacts>();
    final local = event.local;
    final remote = event.remote;
    for (final localItem in local) {
      if (processed.contains(localItem)) {
        continue;
      }
      for (final remoteItem in remote) {
        if (processed.contains(remoteItem)) {
          continue;
        }
        final lPhones =
            localItem.phones?.map(_replaceSpecialChars).toList() ?? [];
        final rPhones =
            remoteItem.phones?.map(_replaceSpecialChars).toList() ?? [];

        final lEmails = localItem.emails ?? [];
        final rEmails = remoteItem.emails ?? [];

        final lName = localItem.name?.trim().toLowerCase();
        final rName = localItem.name?.trim().toLowerCase();

        if (lPhones.any(rPhones.contains) ||
            lEmails.any(rEmails.contains) ||
            lName == rName) {
          // merge
          final mergedItem = merge(localItem, remoteItem);
          // local.remove(localItem);
          // remote.remove(remoteItem);
          processed
            ..add(localItem)
            ..add(remoteItem);
          merged.add(mergedItem);
        }
      }
    }
    emit(ContactsLoadedState(contacts: merged));
  }

  Contacts merge(Contacts local, Contacts remote) {
    final lPhones = local.phones?.map(_replaceSpecialChars).toList() ?? [];
    final rPhones = remote.phones?.map(_replaceSpecialChars).toList() ?? [];
    final phones = Set<String>()
      ..addAll(lPhones)
      ..addAll(rPhones);
    return Contacts(
      id: remote.id ?? local.id,
      conflict: true,
      emails: [...remote.emails ?? [], ...local.emails ?? []],
      phones: phones.toList(),
      name: findLatestContact(local, remote)?.name,
      lastModifiedDate: findLatestContact(
        remote,
        local,
      )?.lastModifiedDate,
    );
  }

  Contacts? findLatestContact(Contacts? c1, Contacts? c2) {
    final date1 = c1?.lastModifiedDate;
    final date2 = c2?.lastModifiedDate;
    if (date1 == null && date2 == null) {
      return null;
    }
    if (date1 == null && date2 != null) {
      return c2;
    }
    if (date1 != null && date2 == null) {
      return c1;
    }
    if ((date1?.millisecondsSinceEpoch ?? 0) <
        (date2?.millisecondsSinceEpoch ?? 0)) {
      return c2;
    } else {
      return c1;
    }
  }

  String _replaceSpecialChars(String item) {
    return item.replaceAll('+', '').replaceAll('-', '');
  }
}
