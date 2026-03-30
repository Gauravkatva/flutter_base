part of 'contacts_list_bloc.dart';

sealed class ContactsListEvent extends Equatable {
  const ContactsListEvent();

  @override
  List<Object> get props => [];
}

class LoadLocalContacts extends ContactsListEvent {}

class LoadRemoteContacts extends ContactsListEvent {}

class MergeContacts extends ContactsListEvent {
  const MergeContacts({required this.local, required this.remote});

  final List<Contacts> remote;
  final List<Contacts> local;
}
