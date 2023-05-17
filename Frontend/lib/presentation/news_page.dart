import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/presentation/news_box.dart';
import '../domain/FeedItem.dart';
import '../domain/fetchNews.dart';

class NewsFeedPage1 extends StatefulWidget {
  const NewsFeedPage1({Key? key}) : super(key: key);

  @override
  _NewsFeedPage1State createState() => _NewsFeedPage1State();
}

class _NewsFeedPage1State extends State<NewsFeedPage1> {
  late Future<List<FeedItem>> _feedItemsFuture;

  @override
  void initState() {
    super.initState();
    _feedItemsFuture = fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: FutureBuilder<List<FeedItem>>(
            future: _feedItemsFuture,
            builder: (BuildContext context, AsyncSnapshot<List<FeedItem>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Show loading spinner while fetching data
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}'); // Show error if something goes wrong
              } else {
                final _feedItems = snapshot.data!;
                return ListView.separated(
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
                  },
                );
              }
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

class _ActionsRow extends StatelessWidget  {
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

/*[
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
];*/
