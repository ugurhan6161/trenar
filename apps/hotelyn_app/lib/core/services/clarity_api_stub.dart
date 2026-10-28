import 'package:flutter/widgets.dart';

class Clarity {
  static void setCurrentScreenName(String name) {}

  static void setCustomTag(String key, String value) {}

  static void setCustomUserId(String userId) {}
}

class ClarityMask extends StatelessWidget {
  const ClarityMask({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class ClarityUnmask extends StatelessWidget {
  const ClarityUnmask({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
