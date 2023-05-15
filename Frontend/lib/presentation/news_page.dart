import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/presentation/news_box.dart';

class NewsFeedPage1 extends StatelessWidget {
  const NewsFeedPage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView.separated(
            itemCount: _feedItems.length,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemBuilder: (BuildContext context, int index) {
              final item = _feedItems[index];
              return CustomCard(
                  imageUrl: item.imageUrl,
                  tags: item.tags,
                  content: item.content);
              /* return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.content != null)
                            Text(
                              item.content!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          if (item.imageUrl != null)
                            Container(
                              height: 200,
                              margin: const EdgeInsets.only(top: 8.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(item.imageUrl!),
                                  )),
                            ),
                          // _ActionsRow(item: item)
                        ],
                      ),
                    ),
                  ],
                ),
              );*/
            },
          ),
        ),
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String url;
  const _AvatarImage(this.url, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: NetworkImage(url))),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final FeedItem item;
  const _ActionsRow({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.white, size: 18),
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.mode_comment_outlined),
            label: Text(
                item.commentsCount == 0 ? '' : item.commentsCount.toString()),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.repeat_rounded),
            label: Text(
                item.retweetsCount == 0 ? '' : item.retweetsCount.toString()),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
            label: Text(item.likesCount == 0 ? '' : item.likesCount.toString()),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.share_up),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}

class FeedItem {
  final String? content;
  final String? imageUrl;
  final UserNews user;
  final int commentsCount;
  final int likesCount;
  final int retweetsCount;
  List<String>? tags;

  FeedItem(
      {this.content,
      this.imageUrl,
      required this.user,
      this.commentsCount = 0,
      this.likesCount = 0,
      this.retweetsCount = 0,
      this.tags});
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

final List<UserNews> _users = [
  UserNews(
    "John Doe",
    "john_doe",
    "https://picsum.photos/id/1062/80/80",
  ),
  UserNews(
    "Jane Doe",
    "jane_doe",
    "https://picsum.photos/id/1066/80/80",
  ),
  UserNews(
    "Jack Doe",
    "jack_doe",
    "https://picsum.photos/id/1072/80/80",
  ),
  UserNews(
    "Jill Doe",
    "jill_doe",
    "https://picsum.photos/id/133/80/80",
  )
];

final List<FeedItem> _feedItems = [
  FeedItem(
      content:
          "A son asked his father (a programmer) why the sun rises in the east, and sets in the west. His response? It works, don’t touch!",
      user: _users[0],
      imageUrl: "https://picsum.photos/id/1000/960/540",
      likesCount: 100,
      commentsCount: 10,
      retweetsCount: 1,
      tags: ['Eventos']),
  FeedItem(
      user: _users[1],
      imageUrl: "https://picsum.photos/id/1001/960/540",
      likesCount: 10,
      commentsCount: 2,
      tags: ['Investigação']),
  FeedItem(
      user: _users[1],
      content:
          "Programming today is a race between software engineers striving to build bigger and better idiot-proof programs, and the Universe trying to produce bigger and better idiots. So far, the Universe is winning.",
      imageUrl: "https://picsum.photos/id/1002/960/540",
      likesCount: 500,
      commentsCount: 202,
      retweetsCount: 120,
      tags: ['Eventos']),
  FeedItem(
      user: _users[2],
      content: "Good morning!",
      imageUrl: "https://picsum.photos/id/1003/960/540",
      tags: ['Eventos']),
  FeedItem(
      user: _users[1],
      imageUrl: "https://picsum.photos/id/1004/960/540",
      tags: ['Eventos']),
  FeedItem(
      user: _users[3],
      imageUrl: "https://picsum.photos/id/1005/960/540",
      tags: ['Eventos']),
  FeedItem(
      user: _users[0],
      imageUrl: "https://picsum.photos/id/1006/960/540",
      tags: ['Eventos']),
];