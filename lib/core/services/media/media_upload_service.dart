import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

import '../supabase_service.dart';
import 'media_config.dart';

/// Handles image compression (on native threads) and upload to Supabase Storage
class MediaUploadService {
  final SupabaseService _supabase;
  final _uuid = const Uuid();

  MediaUploadService(this._supabase);

  // ============================================
  // COMPRESSION (runs on native isolate via flutter_image_compress)
  // ============================================

  /// Compress image bytes with configurable quality and dimensions.
  /// flutter_image_compress runs natively on iOS/Android threads,
  /// keeping the main isolate free for UI.
  Future<Uint8List> compressImage(
    Uint8List bytes, {
    int quality = MediaConfig.defaultQuality,
    int maxWidth = MediaConfig.maxImageWidth,
    int maxHeight = MediaConfig.maxImageHeight,
  }) async {
    // Skip compression for small images
    if (bytes.length < MediaConfig.compressionThreshold) {
      return bytes;
    }

    final result = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: maxWidth,
      minHeight: maxHeight,
      quality: quality,
      format: CompressFormat.jpeg,
    );

    return Uint8List.fromList(result);
  }

  /// Compress image to profile size (512x512)
  Future<Uint8List> compressProfileImage(Uint8List bytes) async {
    return compressImage(
      bytes,
      quality: MediaConfig.defaultQuality,
      maxWidth: MediaConfig.profileImageSize,
      maxHeight: MediaConfig.profileImageSize,
    );
  }

  /// Compress image to thumbnail size (200x200)
  Future<Uint8List> compressThumbnail(Uint8List bytes) async {
    return compressImage(
      bytes,
      quality: MediaConfig.thumbnailQuality,
      maxWidth: MediaConfig.thumbnailSize,
      maxHeight: MediaConfig.thumbnailSize,
    );
  }

  // ============================================
  // UPLOAD
  // ============================================

  /// Upload single image to a bucket. Compresses by default.
  /// Returns the public URL of the uploaded image.
  Future<String> upload(
    Uint8List bytes, {
    required String bucket,
    String? folder,
    bool compress = true,
    int quality = MediaConfig.defaultQuality,
    int maxWidth = MediaConfig.maxImageWidth,
    int maxHeight = MediaConfig.maxImageHeight,
  }) async {
    // Compress if requested
    final data = compress
        ? await compressImage(
            bytes,
            quality: quality,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          )
        : bytes;

    // Generate unique path
    final fileName = _generateFileName(MediaConfig.defaultImageExtension);
    final path = folder != null ? '$folder/$fileName' : fileName;

    // Upload to Supabase
    return await _supabase.uploadFile(
      bucket: bucket,
      path: path,
      fileBytes: data,
      contentType: MediaConfig.defaultContentType,
    );
  }

  /// Upload multiple images in parallel. Returns list of public URLs.
  Future<List<String>> uploadMultiple(
    List<Uint8List> images, {
    required String bucket,
    String? folder,
    bool compress = true,
  }) async {
    final futures = images.map(
      (bytes) =>
          upload(bytes, bucket: bucket, folder: folder, compress: compress),
    );
    return await Future.wait(futures);
  }

  /// Delete an image from storage by its public URL.
  Future<void> delete(String publicUrl, {required String bucket}) async {
    // Extract path from public URL
    // URL format: https://.../storage/v1/object/public/bucket-name/path
    final uri = Uri.parse(publicUrl);
    final segments = uri.pathSegments;
    final bucketIndex = segments.indexOf(bucket);
    if (bucketIndex == -1 || bucketIndex >= segments.length - 1) return;

    final path = segments.sublist(bucketIndex + 1).join('/');
    await _supabase.deleteFile(bucket: bucket, path: path);
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Generate a unique filename: {userId}_{uuid}.jpg
  String _generateFileName(String extension) {
    final userId = _supabase.userId ?? 'anon';
    final id = _uuid.v4().replaceAll('-', '').substring(0, 12);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${userId}_${timestamp}_$id.$extension';
  }
}
