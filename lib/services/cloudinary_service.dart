import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dp4qtd5uz',        // cloud name
    'kqpnsjr7',       // upload preset
    cache: false,
  );

  Future<String> uploadAvatarBytes(
      Uint8List bytes,
      String filename,
      String userId,
      ) async {
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromBytesData(
        bytes,
        identifier: filename,
        folder: 'avatars',
        publicId: 'user_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );

    return response.secureUrl;
  }
}
