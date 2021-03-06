import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sd_base/sd_base.dart';

@immutable
class CommentModel {
  final String id;
  final String authorId;
  final String postId;
  final String message;
  final DateTime createdAt;
  final bool isOwner;

  CommentModel.fromJson({
    @required String id,
    Map<String, dynamic> data,
  })  : this.id = id,
        authorId = data[FirestoreKeys.authorIdFieldKey] ?? '',
        postId = data[FirestoreKeys.postIdFieldKey] ?? '',
        message = data[FirestoreKeys.messageFieldKey] ?? '',
        createdAt = data[FirestoreKeys.createdAtFieldKey] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                (data[FirestoreKeys.createdAtFieldKey] as Timestamp)
                    .millisecondsSinceEpoch,
              )
            : null,
        isOwner = data[FirestoreKeys.isOwnerFieldKey] ?? false;

  CommentModel.empty()
      : id = '',
        authorId = '',
        postId = '',
        message = '',
        createdAt = null,
        isOwner = false;

  @override
  String toString() {
    return 'CommentModel('
        'id: $id, '
        'authorId: $authorId, '
        'postId: $postId, '
        'message: $message, '
        'createdAt: $createdAt, '
        'isOwner: $isOwner, '
        ')';
  }
}
