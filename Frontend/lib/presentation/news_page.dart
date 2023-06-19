import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/widgets/news_box.dart';
import '../domain/FeedItem.dart';
import '../application/fetchNews.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({Key? key}) : super(key: key);

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final ScrollController _scrollController = ScrollController();
  final List<FeedItem> _feedItems = [];
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMore();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 1200) {
      _fetchMore();
    }
  }

  Future<void> _fetchMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
    });
    List<FeedItem> newFeedItems = await fetchNews(_page);
    setState(() {
      _isLoading = false;
      if (newFeedItems.isEmpty) {
        _hasMore = false;
      } else {
        _feedItems.addAll(newFeedItems);
        _page++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView.separated(
            controller: _scrollController,
            itemCount: (_feedItems.length - 1) + (_hasMore ? 1 : 0),
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemBuilder: (BuildContext context, int index) {
              if (index >= _feedItems.length) {
                return _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox.shrink();
              }
              final item = _feedItems[index];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _launchURL(item.pageUrl ?? ''),
                  child: CustomCard(
                    imageUrl: item.imageUrl,
                    tags: item.tags,
                    content: item.content,
                    title: item.title,
                    date: item.date,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Future<void> _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    // can't launch url, there is some error
    throw "Could not launch $url";
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
