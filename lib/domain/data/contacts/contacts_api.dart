import 'dart:convert';

import 'package:my_appp/domain/data/common/error_response.dart';
import 'package:my_appp/domain/data/common/response.dart';
import 'package:my_appp/domain/data/model/contacts.dart';
import 'package:my_appp/utils/dio_client.dart';

class ContactsApi {
  ContactsApi({required DioClient dioClient}) : _dioClient = dioClient;
  final DioClient _dioClient;

  final _apiUrl =
      'https://gist.githubusercontent.com/sahil-sukhwani/c7a812858643cc080a262ff4e799a018/raw/45ee3de1a354a09fd1f429acfe7238b556cc8296/contacts-remote.json';

  Future<Response<List<Contacts>>> fetchContacts() async {
    try {
      final response = await _dioClient.get(_apiUrl);
      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        final contacts =
            jsonDecode(data as String? ?? '{}')['contacts'] as List<dynamic>;
        return Response.success(
          contacts
              .map((item) => Contacts.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      } else {
        // try handle error
        return Response.error(ErrorResponse(message: response.data.toString()));
      }
    } catch (e) {
      // try handle error
      return Response.error(ErrorResponse(message: 'Failed to load data: $e'));
    }
  }
}
