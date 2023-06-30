import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/widgets/news_box.dart';
import '../../domain/FeedItem.dart';
import '../../application/fetchNews.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter/foundation.dart' show kIsWeb;

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({Key? key}) : super(key: key);

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final ScrollController _scrollController = ScrollController();
  final List<FeedItem> _feedItems = [];
  List<String> _activeTags = [];
  List<FeedItem> _filteredFeedItems = [];
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _fetchedAllFromServer = false;
  int _newsPerPage = 12;
  bool web = false;

  @override
  void initState() {
    super.initState();
    _fetchNews();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            (kIsWeb
                ? _scrollController.position.maxScrollExtent - 600
                : _scrollController.position.maxScrollExtent - 200) &&
        !isFetched()) {
      _fetchNews();
    }
  }

  void _filterNews() {
    _filteredFeedItems = _feedItems
        .where((item) => _activeTags.every((tag) => item.tags!.contains(tag)))
        .toList();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_activeTags.contains(tag)) {
        _activeTags.remove(tag);
      } else {
        _activeTags.add(tag);
      }
      _filterNews();
      if (_filteredFeedItems.isEmpty && !_fetchedAllFromServer) _hasMore = true;
    });
  }

  Future<void> _fetchNews() async {
    List<dom.Element> newsItems = await getNewsItems(_page);
    int sizeBeforeFetch = _filteredFeedItems.length;

    for (int i = 0; i < _newsPerPage + 1; i++) {
      if (_isLoading || !_hasMore) {
        return;
      }

      try {
        if (mounted)
          setState(() {
            _isLoading = true;
          });

        FeedItem? feedItem = await fetchNews(newsItems, i);

        if (feedItem == null) {
          continue;
        }

        if (mounted)
          setState(() {
            if (!_feedItems.contains(feedItem)) _feedItems.add(feedItem);
            _filterNews();
          });
      } catch (e) {
        // Handle exception here if needed
      } finally {
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      }
    }
    if (mounted)
      setState(() {
        _page++;
      });

    int sizeAfterFetch = _filteredFeedItems.length;

    if ((sizeBeforeFetch == sizeAfterFetch && !isFetched()) ||
        _activeTags.isNotEmpty) _fetchNews();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return _buildMobileLayout();
    } else {
      return _buildWebLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              _buildColumn(),
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: _filteredFeedItems.length + (_hasMore ? 1 : 0),
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= _filteredFeedItems.length) {
                      return _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : SizedBox.shrink();
                    }
                    final item = _filteredFeedItems[index];
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _launchURL(item.pageUrl ?? ''),
                        // When a tag is clicked, call _toggleTag.
                        child: CustomCard(
                          imageUrl: item.imageUrl,
                          tags: item.tags,
                          content: item.content,
                          title: item.title,
                          date: item.date,
                          index: index,
                          onTagClick: _toggleTag,
                          isSingleCrossAxisCount: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    final width = MediaQuery.of(context).size.width;
    final maxItemWidth = 400.0;
    final crossAxisCount = (width / maxItemWidth).floor();
    final isSingleCrossAxisCount = crossAxisCount == 1;

    return Column(
      children: [
        _buildColumn(),
        if (isSingleCrossAxisCount) ...[
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              itemCount: _filteredFeedItems.length + (_hasMore ? 1 : 0),
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                if (index >= _filteredFeedItems.length) {
                  return _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SizedBox.shrink();
                }
                final item = _filteredFeedItems[index];
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _launchURL(item.pageUrl ?? ''),
                        // When a tag is clicked, call _toggleTag.
                        child: CustomCard(
                          imageUrl: item.imageUrl,
                          tags: item.tags,
                          content: item.content,
                          title: item.title,
                          date: item.date,
                          index: index,
                          onTagClick: _toggleTag,
                          isSingleCrossAxisCount: isSingleCrossAxisCount,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ] else
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: crossAxisCount * maxItemWidth),
                child: GridView.builder(
                  controller: _scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                    childAspectRatio: crossAxisCount > 1 ? 0.6 : 1.2,
                  ),
                  itemCount: _filteredFeedItems.length + (_hasMore ? 1 : 0),
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= _filteredFeedItems.length) {
                      return _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : SizedBox.shrink();
                    }
                    final item = _filteredFeedItems[index];
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
                          index: index,
                          onTagClick: _toggleTag,
                          isSingleCrossAxisCount: isSingleCrossAxisCount,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildColumn() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _activeTags
          .map((tag) => Chip(
                label: Text(tag),
                deleteIcon: Icon(Icons.close),
                onDeleted: () => _toggleTag(tag),
              ))
          .toList(),
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
