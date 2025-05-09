import 'dart:convert';

String convertToJsonString(dynamic objectWithToJson) {
  return json.encode(objectWithToJson.toJson());
}
