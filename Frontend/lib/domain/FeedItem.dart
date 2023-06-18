class FeedItem {
  final String? pageUrl;
  final String? content;
  final String? imageUrl;
  //final UserNews user;
  final int commentsCount;
  final int likesCount;
  final int retweetsCount;
  List<String>? tags;
  final String? title;
  final String? date;

  FeedItem(
      {this.pageUrl,
      this.content,
      this.imageUrl,
      //required this.user,
      this.commentsCount = 0,
      this.likesCount = 0,
      this.retweetsCount = 0,
      this.tags,
      this.title,
      this.date});
}

class UserNews {
  final String fullName;
  final String imageUrl;
  final String userName;

  UserNews(
    this.fullName,
    this.userName,
    this.imageUrl,
  );
}
