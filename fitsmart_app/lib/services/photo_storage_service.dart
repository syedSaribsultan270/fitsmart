import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'analytics_service.dart';

/// Metadata returned after a successful upload.
class ProgressPhotoMeta {
  final String docId;
  final String storagePath;
  final DateTime date;
  final String? notes;
  final double? weightKg;

  const ProgressPhotoMeta({
    required this.docId,
    required this.storagePath,
    required this.date,
    this.notes,
    this.weightKg,
  });

  factory ProgressPhotoMeta.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return ProgressPhotoMeta(
      docId: doc.id,
      storagePath: d['storagePath'] as String,
      date: (d['date'] as Timestamp).toDate(),
      notes: d['notes'] as String?,
      weightKg: (d['weight_kg'] as num?)?.toDouble(),
    );
  }
}

/// Handles upload, download, list, and delete of progress photos.
///
/// Storage path: `users/{uid}/progress_photos/{date}_{timestamp}.jpg`
/// Firestore:    `users/{uid}/progress_photos/{docId}`
class PhotoStorageService {
  PhotoStorageService._();
  static final instance = PhotoStorageService._();

  static final _storage = FirebaseStorage.instance;
  static final _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Reference _storageRef(String path) => _storage.ref(path);

  CollectionReference get _photosCol =>
      _db.collection('users').doc(_uid).collection('progress_photos');

  // ── Upload ─────────────────────────────────────────────────────

  Future<ProgressPhotoMeta?> upload({
    required Uint8List bytes,
    required DateTime date,
    String? notes,
    double? weightKg,
  }) async {
    if (_uid.isEmpty) return null;
    try {
      // Compress to max 1200px wide, JPEG 85
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 1200,
        minHeight: 1200,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      final dateStr = date.toIso8601String().substring(0, 10);
      final ts = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'users/$_uid/progress_photos/${dateStr}_$ts.jpg';

      final ref = _storageRef(storagePath);
      await ref.putData(
        Uint8List.fromList(compressed),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final doc = await _photosCol.add({
        'storagePath': storagePath,
        'date': Timestamp.fromDate(date),
        'notes': notes,
        'weight_kg': weightKg,
        'createdAt': FieldValue.serverTimestamp(),
      });

      AnalyticsService.instance.track('progress_photo_uploaded',
          props: {'date': dateStr});

      return ProgressPhotoMeta(
        docId: doc.id,
        storagePath: storagePath,
        date: date,
        notes: notes,
        weightKg: weightKg,
      );
    } catch (e) {
      debugPrint('[PhotoStorage] upload failed: $e');
      return null;
    }
  }

  // ── List ───────────────────────────────────────────────────────

  Future<List<ProgressPhotoMeta>> list() async {
    if (_uid.isEmpty) return [];
    try {
      final snap = await _photosCol
          .orderBy('date', descending: true)
          .limit(50)
          .get();
      return snap.docs.map(ProgressPhotoMeta.fromDoc).toList();
    } catch (e) {
      debugPrint('[PhotoStorage] list failed: $e');
      return [];
    }
  }

  // ── Download URL ───────────────────────────────────────────────

  Future<String?> getDownloadUrl(String storagePath) async {
    try {
      return await _storageRef(storagePath).getDownloadURL();
    } catch (e) {
      debugPrint('[PhotoStorage] getDownloadUrl failed: $e');
      return null;
    }
  }

  // ── Delete ─────────────────────────────────────────────────────

  Future<void> delete(ProgressPhotoMeta meta) async {
    if (_uid.isEmpty) return;
    try {
      await _storageRef(meta.storagePath).delete();
      await _photosCol.doc(meta.docId).delete();
      AnalyticsService.instance.track('progress_photo_deleted');
    } catch (e) {
      debugPrint('[PhotoStorage] delete failed: $e');
    }
  }
}
