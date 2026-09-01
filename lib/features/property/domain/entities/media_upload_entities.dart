import 'package:equatable/equatable.dart';

enum UploadState {
  idle,
  selecting,
  uploading,
  success,
  failed,
  cancelled,
  retrying,
}

enum MediaCategory {
  image,
  video,
  document,
}

class UploadProgressEntity extends Equatable {
  final double progressPercent; // 0.0 to 100.0
  final int bytesUploaded;
  final int totalBytes;
  final UploadState state;
  final String? errorMessage;
  final String? uploadedPath;
  final String? publicUrl;

  const UploadProgressEntity({
    this.progressPercent = 0.0,
    this.bytesUploaded = 0,
    this.totalBytes = 0,
    this.state = UploadState.idle,
    this.errorMessage,
    this.uploadedPath,
    this.publicUrl,
  });

  UploadProgressEntity copyWith({
    double? progressPercent,
    int? bytesUploaded,
    int? totalBytes,
    UploadState? state,
    String? errorMessage,
    String? uploadedPath,
    String? publicUrl,
  }) {
    return UploadProgressEntity(
      progressPercent: progressPercent ?? this.progressPercent,
      bytesUploaded: bytesUploaded ?? this.bytesUploaded,
      totalBytes: totalBytes ?? this.totalBytes,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadedPath: uploadedPath ?? this.uploadedPath,
      publicUrl: publicUrl ?? this.publicUrl,
    );
  }

  @override
  List<Object?> get props => [
        progressPercent,
        bytesUploaded,
        totalBytes,
        state,
        errorMessage,
        uploadedPath,
        publicUrl,
      ];
}
