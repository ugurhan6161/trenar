import 'package:hotelyn_server/hotelyn_server.dart';

class FakeReservationNotifier implements ReservationNotifier {
  BookingInquiry? request;
  Exception? failure;

  @override
  Future<void> sendBookingRequest(BookingInquiry request) async {
    if (failure != null) throw failure!;
    this.request = request;
  }
}
