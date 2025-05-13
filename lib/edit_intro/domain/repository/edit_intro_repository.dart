import 'package:image_picker/image_picker.dart';
import 'package:devlink_mobile_app/auth/domain/model/member.dart';
import '../../../core/result/result.dart';

abstract interface class EditIntroRepository {
  Future<Result<Member>> getCurrentProfile();

  Future<Result<Member>> updateProfile({
    required String nickname,
    String? intro,
  });

  Future<Result<Member>> updateProfileImage(XFile image);
}
