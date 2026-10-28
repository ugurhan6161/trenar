import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';

class TrenarFirebase {
  const TrenarFirebase._();

  static const _projectId = 'bektassigorta-5c167';

  static Future<FirebaseApp> initialize() {
    if (Firebase.apps.isNotEmpty) return Future.value(Firebase.app());
    if (!kIsWeb) return Firebase.initializeApp();

    return Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: String.fromEnvironment(
          'FIREBASE_API_KEY',
          defaultValue: 'AIzaSyAsglemJ-_hi8XjK0DPfniYjDO-fjJX2qA',
        ),
        authDomain: String.fromEnvironment(
          'FIREBASE_AUTH_DOMAIN',
          defaultValue: 'bektassigorta-5c167.firebaseapp.com',
        ),
        projectId: String.fromEnvironment(
          'FIREBASE_PROJECT_ID',
          defaultValue: _projectId,
        ),
        storageBucket: String.fromEnvironment(
          'FIREBASE_STORAGE_BUCKET',
          defaultValue: 'bektassigorta-5c167.firebasestorage.app',
        ),
        messagingSenderId: String.fromEnvironment(
          'FIREBASE_MESSAGING_SENDER_ID',
          defaultValue: '256844008742',
        ),
        appId: String.fromEnvironment(
          'FIREBASE_APP_ID',
          defaultValue: '1:256844008742:web:422d7e825fd5b3d4f605e7',
        ),
        measurementId: String.fromEnvironment(
          'FIREBASE_MEASUREMENT_ID',
          defaultValue: 'G-77MVZHV5FJ',
        ),
      ),
    );
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;

  static Future<TrenarSiteContent> loadSiteContent() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('site_content')
        .doc('public')
        .get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return TrenarSiteContent.defaultContent;
    }
    return TrenarSiteContent.fromJson(data);
  }

  static Future<void> saveSiteContent(TrenarSiteContent content) {
    return FirebaseFirestore.instance
        .collection('site_content')
        .doc('public')
        .set(content.toJson());
  }

  static Future<bool> verifyAdminAccess(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('admin_users')
        .doc(uid)
        .get();
    return snapshot.data()?['enabled'] == true;
  }

  static Future<void> submitBookingRequest({
    required String name,
    required String phone,
    required String service,
    required String destination,
    required String travelDate,
    required int guests,
    String? email,
    String? notes,
    List<String> bookingOptions = const [],
  }) async {
    await FirebaseFirestore.instance.collection('reservation_requests').add({
      'name': name,
      'phone': phone,
      'service': service,
      'destination': destination,
      'travel_date': travelDate,
      'guests': guests,
      if (bookingOptions.isNotEmpty) 'booking_options': bookingOptions,
      if (email != null && email.isNotEmpty) 'email': email,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
