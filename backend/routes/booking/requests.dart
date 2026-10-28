import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `POST /booking/requests` sends a validated guest inquiry to Telegram.
/// Customer accounts and payment credentials are intentionally not collected.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final parsed = await _parseBookingRequest(context);
  if (parsed is Response) return parsed;
  final inquiry = parsed as BookingInquiry;
  try {
    await context.read<ReservationNotifier>().sendBookingRequest(inquiry);
    return Response.json(
      statusCode: HttpStatus.accepted,
      body: {'accepted': true},
      headers: const {HttpHeaders.cacheControlHeader: 'no-store'},
    );
  } on TelegramConfigurationException {
    stderr.writeln(
      'POST /booking/requests failed: Telegram is not configured.',
    );
    return Response.json(
      statusCode: HttpStatus.serviceUnavailable,
      body: {'error': 'booking_delivery_unavailable'},
    );
  } on TelegramDeliveryException {
    stderr.writeln(
      'POST /booking/requests failed: Telegram rejected delivery.',
    );
    return Response.json(
      statusCode: HttpStatus.badGateway,
      body: {'error': 'booking_delivery_failed'},
    );
  } on Object catch (error, stackTrace) {
    stderr.writeln('POST /booking/requests failed: $error\n$stackTrace');
    return internalError();
  }
}

Future<Object> _parseBookingRequest(RequestContext context) async {
  final body = await context.request.body();
  if (body.length > 10000) {
    return Response.json(
      statusCode: HttpStatus.requestEntityTooLarge,
      body: {'error': 'request_too_large'},
    );
  }

  final dynamic decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'invalid_json'},
    );
  }
  if (decoded is! Map<String, dynamic>) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'body_must_be_an_object'},
    );
  }

  final name = _requiredString(decoded, 'name', maxLength: 120);
  final phone = _requiredString(decoded, 'phone', maxLength: 40);
  final service = _requiredString(decoded, 'service', maxLength: 120);
  final destination = _requiredString(decoded, 'destination', maxLength: 160);
  final travelDate = _requiredString(decoded, 'travel_date', maxLength: 10);
  final guests = decoded['guests'];
  if (name == null ||
      phone == null ||
      service == null ||
      destination == null ||
      travelDate == null ||
      guests is! int ||
      guests < 1 ||
      guests > 50 ||
      !_isDate(travelDate) ||
      !RegExp(r'^[+()0-9\s.-]{7,40}$').hasMatch(phone)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'invalid_booking_request'},
    );
  }

  final email = _optionalString(decoded, 'email', maxLength: 254);
  final notes = _optionalString(decoded, 'notes', maxLength: 1000);
  final bookingOptions = _optionalStringList(
    decoded,
    'booking_options',
    maxItems: 20,
    maxLength: 120,
  );
  if (email == null && decoded['email'] != null ||
      notes == null && decoded['notes'] != null ||
      bookingOptions == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'invalid_booking_request'},
    );
  }
  if (email != null && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'invalid_booking_request'},
    );
  }

  return BookingInquiry(
    name: _singleLine(name),
    phone: _singleLine(phone),
    service: _singleLine(service),
    destination: _singleLine(destination),
    travelDate: travelDate,
    guests: guests,
    bookingOptions: bookingOptions.map(_singleLine).toList(),
    email: email == null ? null : _singleLine(email),
    notes: notes?.trim(),
  );
}

List<String>? _optionalStringList(
  Map<String, dynamic> body,
  String key, {
  required int maxItems,
  required int maxLength,
}) {
  final value = body[key];
  if (value == null) return const [];
  if (value is! List || value.length > maxItems) return null;
  final items = <String>[];
  for (final item in value) {
    if (item is! String || item.trim().isEmpty || item.length > maxLength) {
      return null;
    }
    items.add(item.trim());
  }
  return items;
}

String? _requiredString(
  Map<String, dynamic> body,
  String key, {
  required int maxLength,
}) {
  final value = body[key];
  if (value is! String || value.trim().isEmpty || value.length > maxLength) {
    return null;
  }
  return value.trim();
}

String? _optionalString(
  Map<String, dynamic> body,
  String key, {
  required int maxLength,
}) {
  final value = body[key];
  if (value == null) return null;
  if (value is! String || value.length > maxLength) return null;
  return value.trim();
}

bool _isDate(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return false;
  final parsed = DateTime.tryParse(value);
  return parsed != null && parsed.toIso8601String().startsWith(value);
}

String _singleLine(String value) => value.replaceAll(RegExp(r'[\r\n]+'), ' ');
