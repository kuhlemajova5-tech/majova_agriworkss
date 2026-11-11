import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class PhotoStorageService {
  PhotoStorageService._();

  static final PhotoStorageService instance =
  PhotoStorageService._();

  static const String _folderName =
      'pest_disease_photos';

  Future<Directory> _getPhotoDirectory() async {
    final Directory documentsDirectory =
    await getApplicationDocumentsDirectory();

    final Directory photoDirectory = Directory(
      path.join(
        documentsDirectory.path,
        _folderName,
      ),
    );

    if (!await photoDirectory.exists()) {
      await photoDirectory.create(
        recursive: true,
      );
    }

    return photoDirectory;
  }

  Future<String> savePhoto(
      String sourcePath,
      ) async {
    final File sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw Exception(
        'The selected photo could not be found.',
      );
    }

    final Directory photoDirectory =
    await _getPhotoDirectory();

    final String originalExtension =
    path.extension(sourcePath);

    final String extension =
    originalExtension.isEmpty
        ? '.jpg'
        : originalExtension;

    final String fileName =
        'pest_disease_'
        '${DateTime.now().microsecondsSinceEpoch}'
        '$extension';

    final String permanentPath = path.join(
      photoDirectory.path,
      fileName,
    );

    final File savedFile =
    await sourceFile.copy(
      permanentPath,
    );

    return savedFile.path;
  }

  Future<bool> photoExists(
      String? photoPath,
      ) async {
    if (photoPath == null ||
        photoPath.trim().isEmpty) {
      return false;
    }

    return File(photoPath).exists();
  }

  Future<void> deletePhoto(
      String? photoPath,
      ) async {
    if (photoPath == null ||
        photoPath.trim().isEmpty) {
      return;
    }

    final File photoFile = File(photoPath);

    if (await photoFile.exists()) {
      await photoFile.delete();
    }
  }

  Future<int> getStoredPhotoCount() async {
    final Directory photoDirectory =
    await _getPhotoDirectory();

    final List<FileSystemEntity> files =
    await photoDirectory.list().toList();

    return files.whereType<File>().length;
  }
}