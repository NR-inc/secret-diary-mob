import 'package:common_ui/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sddomain/export/domain.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:ssecretdiary/feature/widgets/base_state.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;

  PostDetailsScreen({
    @required this.postId,
  });

  @override
  State<StatefulWidget> createState() => _PostDetailsState();
}

class _PostDetailsState extends BaseState<PostDetailsScreen> {
  final PostsBloc _postsBloc = Injector.getInjector().get<PostsBloc>();
  final CommentsBloc _commentsBloc = Injector.getInjector().get<CommentsBloc>();
  final LikesBloc _likesBloc = Injector.getInjector().get<LikesBloc>();

  final _isOwnerValueNotifier = ValueNotifier(false);
  final _addCommentTextController = TextEditingController();

  @override
  void initState() {
    _postsBloc.errorStream.handleError(handleError);
    _postsBloc.getPost(postId: widget.postId).then(
      (postModel) {
        _isOwnerValueNotifier.value = postModel.isOwner;
      },
    );
    _likesBloc.getLikes(postId: widget.postId);
    _likesBloc.isPostLiked(postId: widget.postId);
    _commentsBloc.loadComments(postId: widget.postId);
    _commentsBloc.getCountOfComments(postId: widget.postId);
    super.initState();
  }

  @override
  void dispose() {
    _postsBloc.dispose();
    _commentsBloc.dispose();
    _likesBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Post Details'),
          actions: [
            ValueListenableBuilder(
              valueListenable: _isOwnerValueNotifier,
              builder: (context, value, child) {
                return value
                    ? IconButton(
                        icon: SvgPicture.asset(
                          SdAssets.deleteIcon,
                          color: SdColors.whiteColor,
                          package: commonUiPackage,
                          height: Dimens.unit2,
                          width: Dimens.unit2,
                        ),
                        onPressed: () async {
                          show2OptionsDialog(
                              context: context,
                              title: 'Delete your post',
                              description: 'Are you sure?',
                              option1ButtonName: 'Delete',
                              option2ButtonName: 'Cancel',
                              option1ButtonCallback: () async {
                                Navigator.pop(context);
                                //todo review
                                await _postsBloc.removePostById(widget.postId);
                                showToast(message: 'The post has been removed');
                                Future.delayed(Duration(seconds: 1)).then(
                                  (value) {
                                    Navigator.pop(context);
                                  },
                                );
                              });
                        },
                      )
                    : Container();
              },
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: StreamBuilder(
            stream: _postsBloc.loadingProgressStream,
            builder: (
              BuildContext context,
              AsyncSnapshot<bool> loadingProgress,
            ) {
              return Stack(children: <Widget>[
                _content,
                showLoader(
                  show: loadingProgress.hasData && loadingProgress.data,
                )
              ]);
            },
          ),
        ));
  }

  Widget get _content => Center(
        child: Container(
          child: StreamBuilder(
            stream: _postsBloc.postDetailsStream,
            builder: (BuildContext context, AsyncSnapshot<PostModel> result) {
              final postModel = result.data;
              if (postModel != null) {
                return Column(
                  children: [
                    SizedBox(height: Dimens.unit),
                    Text(postModel.title),
                    SizedBox(height: Dimens.unit),
                    Text(postModel.description),
                    SizedBox(height: Dimens.unit),
                    divider(),
                    SizedBox(height: Dimens.unit),
                    _likesCounterWidget(),
                    SizedBox(height: Dimens.unit2),
                    _commentsCounterWidget(),
                    SizedBox(height: Dimens.unit),
                    divider(),
                    SizedBox(height: Dimens.unit5),
                    _addCommentWidget(),
                    _commentsListWidget(),
                  ],
                );
              } else {
                return Text('No data for the post');
              }
            },
          ),
        ),
      );

  Widget _addCommentWidget() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(
          top: Dimens.unit,
          bottom: Dimens.unit,
        ),
        child: Row(children: [
          Expanded(
              child: inputField(
            inputFieldKey: Key('add_comment_field'),
            controller: _addCommentTextController,
            hint: 'Add your comment',
          )),
          GestureDetector(
            onTap: () => _addCommentAction(_addCommentTextController.text),
            child: Container(
              height: Dimens.unit3,
              width: Dimens.unit3,
              child: Center(
                child: SvgPicture.asset(
                  SdAssets.sendIcon,
                  color: SdColors.secondaryColor,
                  package: commonUiPackage,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _likesCounterWidget() => StreamBuilder(
      stream: _likesBloc.isPostLikedStream,
      builder: (context, AsyncSnapshot<bool> result) {
        final isUserLiked = result?.data ?? false;
        return GestureDetector(
            onTap: () => _likeAction(!isUserLiked),
            child: Row(children: [
              SvgPicture.asset(
                SdAssets.likeIcon,
                color: isUserLiked ? SdColors.primaryColor : SdColors.greyColor,
                package: commonUiPackage,
                height: Dimens.unit2,
                width: Dimens.unit2,
              ),
              SizedBox(width: Dimens.unit),
              StreamBuilder(
                initialData: <LikeModel>[],
                stream: _likesBloc.likesStream,
                builder: (
                  context,
                  AsyncSnapshot<List<LikeModel>> snapshot,
                ) {
                  final likes = snapshot.data;
                  return Text('${likes?.length ?? 0}');
                },
              )
            ]));
      });

  Widget _commentsCounterWidget() => StreamBuilder(
      stream: _commentsBloc.countOfCommentsStream,
      builder: (context, AsyncSnapshot<int> result) {
        return Row(children: [
          SvgPicture.asset(
            SdAssets.commentIcon,
            package: commonUiPackage,
            height: Dimens.unit2,
            width: Dimens.unit2,
          ),
          SizedBox(
            width: Dimens.unit,
          ),
          Text('${result.data ?? 0}')
        ]);
      });

  Widget _commentsListWidget() => Expanded(
          child: StreamBuilder(
        stream: _commentsBloc.commentsStream,
        builder: (context, AsyncSnapshot<List<CommentModel>> snapshot) {
          final comments = snapshot.data ?? [];
          return Container(
            child: NotificationListener(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    _commentsBloc.loadComments(postId: widget.postId);
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _commentItem(comments[index]);
                  },
                )),
          );
        },
      ));

  Widget _commentItem(CommentModel commentModel) {
    return GestureDetector(
      child: Container(
        child: Column(
          children: [
            Card(
              child: Padding(
                  padding: EdgeInsets.all(Dimens.unit),
                  child: Text(commentModel.message)),
            ),
          ],
        ),
      ),
      onLongPress: () {
        show2OptionsDialog(
          context: context,
          title: 'Delete comment',
          description: 'Are you sure you want to delete your comment?',
          option1ButtonName: 'Delete',
          option1ButtonCallback: () {
            _commentsBloc.removeComment(commentId: commentModel.id);
            Navigator.of(context).pop();
          },
          option2ButtonName: 'Cancel',
        );
      },
    );
  }

  void _addCommentAction(String message) {
    _addCommentTextController.clear();
    _commentsBloc.addComment(
      message: message,
      postId: widget.postId,
    );
  }

  void _likeAction(bool isUserLiked) {
    if (isUserLiked) {
      _likesBloc.addLike(postId: widget.postId);
    } else {
      _likesBloc.removeLike(postId: widget.postId);
    }
  }
}
