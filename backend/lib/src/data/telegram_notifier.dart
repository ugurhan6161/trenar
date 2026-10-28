import 'dart:async';
import 'dart:convert';
import 'dart:io';

class BookingInquiry {
  const BookingInquiry({
    required this.name,
    required this.phone,
    required this.service,
    required this.destination,
    required this.travelDate,
    required this.guests,
    this.bookingOptions = const [],
    this.email,
    this.notes,
  });

  final String name;
  final String phone;
  final String service;
  final String destination;
  final String travelDate;
  final int guests;
  final List<String> bookingOptions;
  final String? email;
  final String? notes;
}

// A contract keeps request delivery replaceable in route tests and deployment.
// ignore: one_member_abstracts
abstract interface class ReservationNotifier {
  Future<void> sendBookingRequest(BookingInquiry request);
}

class TelegramConfigurationException implements Exception {
  const TelegramConfigurationException();
}

class TelegramDeliveryException implements Exception {
  const TelegramDeliveryException();
}

/// Sends guest inquiries from the trusted backend; bot credentials never reach
/// the customer app or the public content endpoint.
class TelegramReservationNotifier implements ReservationNotifier {
  TelegramReservationNotifier({
    required this.botToken,
    required this.chatId,
    HttpClient? httpClient,
    this.timeout = const Duration(seconds: 10),
  }) : _httpClient = httpClient ?? HttpClient();

  final String? botToken;
  final String? chatId;
  final HttpClient _httpClient;
  final Duration timeout;

  @override
  Future<void> sendBookingRequest(BookingInquiry request) async {
    final token = botToken;
    final destination = chatId;
    if (token == null ||
        token.isEmpty ||
        destination == null ||
        destination.isEmpty) {
      throw const TelegramConfigurationException();
    }

    final telegramRequest = await _httpClient
        .postUrl(Uri.https('api.telegram.org', '/bot$token/sendMessage'))
        .timeout(timeout);
    telegramRequest.headers.contentType = ContentType.json;
    telegramRequest.write(
      jsonEncode({
        'chat_id': destination,
        'text': _formatMessage(request),
        'disable_web_page_preview': true,
      }),
    );

    final response = await telegramRequest.close().timeout(timeout);
    final responseBody = await utf8.decoder
        .bind(response)
        .join()
        .timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const TelegramDeliveryException();
    }

    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic> || decoded['ok'] != true) {
      throw const TelegramDeliveryException();
    }
  }

  String _formatMessage(BookingInquiry request) {
    final lines = <String>[
      'New TRENAR VIP booking request',
      'Name: ${request.name}',
      'Phone: ${request.phone}',
      if (request.email != null) 'Email: ${request.email}',
      'Service: ${request.service}',
      'Destination: ${request.destination}',
      'Travel date: ${request.travelDate}',
      'Guests: ${request.guests}',
      if (request.bookingOptions.isNotEmpty)
        'Additional requests: ${request.bookingOptions.join(', ')}',
      if (request.notes != null && request.notes!.isNotEmpty)
        'Notes: ${request.notes}',
    ];
    return lines.join('\n');
  }
}
