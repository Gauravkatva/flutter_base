part of 'contacts_list_bloc.dart';

sealed class ContactsListState extends Equatable {
  const ContactsListState();

  @override
  List<Object> get props => [];
}

final class ContactsListInitial extends ContactsListState {}

final class ContactsLoading extends ContactsListState {}

final class ContactsLoadedState extends ContactsListState {
  const ContactsLoadedState({required this.contacts});
  final List<Contacts> contacts;
}

final class ContactsErrorState extends ContactsListState {
  const ContactsErrorState({required this.errorMessage});
  final String errorMessage;
}
