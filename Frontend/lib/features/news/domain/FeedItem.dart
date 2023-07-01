class FeedItem {
  final String? pageUrl;
  final String? content;
  final String? imageUrl;
  //final UserNews user;
  final int commentsCount;
  final int likesCount;
  final int retweetsCount;
  Set<String?>? tags;
  final String? title;
  final String? date;

  FeedItem(
      {this.pageUrl,
      this.content,
      this.imageUrl,
      this.commentsCount = 0,
      this.likesCount = 0,
      this.retweetsCount = 0,
      this.tags,
      this.title,
      this.date});

  Map<String, dynamic> toMap() {
    return {
      'pageUrl': pageUrl,
      'tags': tags?.join(','),
      'content': content,
      'title': title,
      'date': date,
      'imageUrl': imageUrl
    };
  }

  static FeedItem fromMap(Map<String, dynamic> map) {
    return FeedItem(
      pageUrl: map['pageUrl'],
      content: map['content'],
      imageUrl: map['imageUrl'],
      tags: (map['tags'] as String?)?.split(',').toSet(),
      title: map['title'],
      date: map['date'],
    );
  }
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
