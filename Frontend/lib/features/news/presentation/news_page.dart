import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unilink2023/data/cache_factory_provider.dart';
import 'package:unilink2023/widgets/news_box.dart';
import '../domain/FeedItem.dart';
import '../../../application/fetchNews.dart';
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
  List<FeedItem> _feedItems = [];
  List<String> _activeTags = [];
  List<FeedItem> _filteredFeedItems = [];
  int _page = 0;
  bool _isLoading = false;
  int _newsPerPage = 12;
  bool web = false;
  int newsCounter = 0;
  bool _hasNoMoreNews = false;

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

  bool isFetched() {
    return _hasNoMoreNews;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            (kIsWeb
                ? _scrollController.position.maxScrollExtent - 600
                : _scrollController.position.maxScrollExtent - 200) &&
        !isFetched()) {
      _fetchNews();
    } else if (isFetched()) {
      setState(() {
        _isLoading = false;
      });
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
    });
  }

  Future<void> _fetchNews() async {
    print(isFetched());
    if (isFetched()) return;
    int currentPageInCache =
        int.parse(await cacheFactory.get('settings', 'currentPage'));
    int currentNewsInCache =
        int.parse(await cacheFactory.get('settings', 'currentNews'));
    List<FeedItem> itemsInCache =
        await cacheFactory.get('news', '') as List<FeedItem>;

    if (itemsInCache.isNotEmpty && currentPageInCache > _page) {
      if (mounted) {
        setState(() {
          _page = currentPageInCache;
          _feedItems = itemsInCache;
          _filterNews();
        });
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      List<dom.Element> newsItems = await getNewsItems(_page);

      if ((_page != 0 &&
              itemsInCache[0].title ==
                  newsItems[1]
                      .querySelector('.views-field-title .field-content a')!
                      .text) ||
          newsItems.length != _newsPerPage + 1) {
        _hasNoMoreNews = true;
        return;
      }

      int start = currentNewsInCache != 0 ? currentNewsInCache : 0;

      for (int i = start; i < _newsPerPage + 1; i++) {
        FeedItem? feedItem = await fetchNews(newsItems, i);
        if (feedItem != null) {
          if (mounted) {
            setState(() {
              if (!_filteredFeedItems
                  .any((item) => item.title == feedItem.title)) {
                _feedItems.add(feedItem);
                _filterNews();
                cacheFactory.setNews(feedItem);
                cacheFactory.set('currentNews', i.toString());
              }
            });
          }
        }
      }

      currentNewsInCache =
          int.parse(await cacheFactory.get('settings', 'currentNews'));

      if (mounted) {
        setState(() {
          if (currentNewsInCache == 12 && !isFetched()) {
            _page++;
            cacheFactory.set('currentPage', _page.toString());
            cacheFactory.set('currentNews', "0");
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    if (_activeTags.isNotEmpty && !isFetched()) _fetchNews();
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
                  itemCount: _filteredFeedItems.length + (!isFetched() ? 1 : 0),
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
              itemCount: _filteredFeedItems.length + (!isFetched() ? 1 : 0),
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
                  itemCount: _filteredFeedItems.length + (!isFetched() ? 1 : 0),
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
