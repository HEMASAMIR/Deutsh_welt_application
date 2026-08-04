part of 'videos_cubit.dart';

abstract class VideosState extends Equatable {
  const VideosState();

  @override
  List<Object?> get props => [];
}

class VideosInitial extends VideosState {
  const VideosInitial();
}

class VideosLoading extends VideosState {
  const VideosLoading();
}

class VideosLoaded extends VideosState {
  final LevelVideosResponse data;

  const VideosLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class VideosAccessDenied extends VideosState {
  const VideosAccessDenied();
}

class VideosError extends VideosState {
  final String message;
  final bool isNoInternet;

  const VideosError(this.message, {this.isNoInternet = false});

  @override
  List<Object?> get props => [message, isNoInternet];
}

/// Emitted while a course file (PDF) is being downloaded.
class FileDownloading extends VideosState {
  final int fileId;
  const FileDownloading(this.fileId);
  @override
  List<Object?> get props => [fileId];
}

/// Emitted if course file download fails.
class FileDownloadError extends VideosState {
  final String message;
  const FileDownloadError(this.message);
  @override
  List<Object?> get props => [message];
}
