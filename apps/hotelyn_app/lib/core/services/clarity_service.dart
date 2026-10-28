import 'package:hotelyn/core/services/clarity_api.dart';

class ClarityService {
  void setCurrentScreenName(String name) {
    Clarity.setCurrentScreenName(name);
  }
}
