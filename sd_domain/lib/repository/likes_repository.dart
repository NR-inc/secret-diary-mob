import 'package:flutter/cupertino.dart';
import 'package:sddomain/export/domain.dart';

abstract class LikesRepository {
  Future<LikeModel> addLike({
    @required String userId,
    @required String postId,
  });

  Future<bool> removeLike({
    @required String userId,
    @required String postId,
  });

  Future<List<LikeModel>> getLikes({
    @required String postId,
  });

  Future<bool> removeLikes({
    @required String postId,
  });
}
