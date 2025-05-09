// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:searchgpt/database/dao/index.dart';
import 'package:searchgpt/database/db/db.dart';
import 'package:searchgpt/workflow/tavily.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'search_gpt_cubit.dart';

class ChatScreenPage extends StatelessWidget {
  final AppDatabase db;
  const ChatScreenPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchGptCubit(),
      child: Builder(
        builder:
            (context) => Scaffold(
              floatingActionButton: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    context.watch<SearchGptCubit>().state is SearchInitial ==
                            false
                        ? FloatingActionButton(
                          key: const ValueKey('fab'),
                          onPressed: () {
                            context.read<SearchGptCubit>().setInitial();
                          },
                          child: const Icon(Icons.auto_awesome),
                        )
                        : null,
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              drawer: Drawer(
                child: SafeArea(
                  child: StreamBuilder<List<SearchDatas>>(
                    stream: SearchDao(db).watchAllSearchData(),
                    builder: (context, snapshot) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _buildDrawerContent(context, snapshot),
                      );
                    },
                  ),
                ),
              ),
              appBar: AppBar(
                centerTitle: true,
                title: buildTitle(context, db),
                elevation: 0,
              ),
              body: SafeArea(child: ChatBody(db: db)),
            ),
      ),
    );
  }

  Widget buildTitle(BuildContext context, AppDatabase db) {
    final state = context.read<SearchGptCubit>().state;

    if (state is! SearchInitial) {
      return const Text('SearchGPT');
    } else if (state is SetId) {
      return SearchTitleWidget(
        id: (state as dynamic).id,
        searchDao: SearchDao(db),
      );
    } else {
      return const Text('SearchGPT'); // Default fallback
    }
  }

  Widget _buildDrawerContent(
    BuildContext context,
    AsyncSnapshot<List<SearchDatas>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const _ShimmerList(key: ValueKey('shimmer'));
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(
        key: const ValueKey('empty'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No recent searches found.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return _SearchList(
      key: ValueKey('list-${snapshot.data!.length}'),
      data: snapshot.data!,
      db: db,
    );
  }
}

class _SearchList extends StatelessWidget {
  final List<SearchDatas> data;
  final AppDatabase db;

  const _SearchList({required this.data, required this.db, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final search = data[index];
        return AnimatedListItem(
          index: index,
          child: ListTile(
            key: ValueKey(search.id), // Important for animations
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 0.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text(
              search.query,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            onTap: () {
              context.read<SearchGptCubit>().setID(search.id);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}

class AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;

  const AnimatedListItem({required this.index, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100).clamp(0, 500)),
      curve: Curves.easeOutQuint,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0.0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          index: index,
          child: const ListTile(
            leading: CircleAvatar(backgroundColor: Colors.grey),
            title: SizedBox(
              height: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
            subtitle: SizedBox(
              height: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ChatBody extends StatefulWidget {
  final AppDatabase db;
  const ChatBody({super.key, required this.db});

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  String _currentQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchGptCubit, SearchGptState>(
      listener: (context, state) {
        if (state is AiSuccess || state is SearchSuccess) {}
      },
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<SearchGptCubit, SearchGptState>(
              builder: (context, state) {
                return CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          if (state is SearchInitial)
                            _buildWelcomeMessage(context),
                        ]),
                      ),
                    ),
                    if (state is SetId) ...[
                      _buildAiResponseSection(state.id),
                      _buildSearchResultsSection(state.id),
                    ],
                    const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                  ],
                );
              },
            ),
          ),
          BlocBuilder<SearchGptCubit, SearchGptState>(
            builder: (context, state) {
              if (state is SearchInitial) {
                return _buildInputArea(context);
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'How can I help you today?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Ask anything or search for information across the web. I can help with research, analysis, and more.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSuggestionChip(context, "Best productivity tips"),
              _buildSuggestionChip(context, "Explain quantum computing"),
              _buildSuggestionChip(context, "Latest AI trends 2024"),
              _buildSuggestionChip(context, "How to learn Flutter fast"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _controller.text = text;
        _focusNode.requestFocus();
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      shape: StadiumBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
    );
  }

  SliverList _buildSearchResultsSection(String id) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SearchResultsWidget(id: id, dao: SearchDao(widget.db)),
        ),
      ]),
    );
  }

  SliverList _buildAiResponseSection(String id) {
    return SliverList(
      delegate: SliverChildListDelegate([
        AIResultsWidget(id: id, dao: SearchDao(widget.db)),
      ]),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return BlocBuilder<SearchGptCubit, SearchGptState>(
      builder: (context, state) {
        final isProcessing = state is SearchInProgress || state is AiLoading;
        final hasText = _controller.text.isNotEmpty;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.08),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 150,
                  ), // Prevent field from growing too tall
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextFormField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      hintText: 'Type your message...',
                      hintStyle: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: Theme.of(context).hintColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    maxLines: null, // Allows growing with content
                    minLines: 1,
                    autofocus: true,
                    onChanged: (value) => _currentQuery = value,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted:
                        hasText && !isProcessing
                            ? (_) => _handleSubmit(context, _controller.text)
                            : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Submit button with nice animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder:
                    (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                child: FloatingActionButton.small(
                  elevation: 0,
                  highlightElevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  child: Icon(
                    Icons.send_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                  onPressed: () => _handleSubmit(context, _controller.text),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSubmit(BuildContext context, String query) {
    if (query.trim().isNotEmpty) {
      _currentQuery = query;
      context.read<SearchGptCubit>().search(query);
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }
}

class SearchResultsWidget extends StatelessWidget {
  final String id;
  final SearchDao dao;

  const SearchResultsWidget({super.key, required this.id, required this.dao});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SearchDatas?>(
      stream: dao.watchSearchData(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return _buildLoadingShimmer(context);
        }

        final data = snapshot.data!;
        if (data.search == null) {
          return const NoResultsWidget();
        }

        try {
          final jsonMap = json.decode(data.search!);
          final SearchResults results = SearchResults.fromJson(jsonMap);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (results.images.isNotEmpty) ...[
                _buildSectionHeader(context, "Related Images"),
                _buildImagesSection(context, results),
              ],
              if (results.results.isNotEmpty) ...[
                _buildSectionHeader(context, "Search Results"),
                _buildSearchResults(context, results),
              ],
            ],
          );
        } catch (e) {
          return _buildLoadingShimmer(context);
        }
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withOpacity(0.6),
      highlightColor: Theme.of(context).colorScheme.surface,
      period: const Duration(
        milliseconds: 1500,
      ), // Slower, more elegant animation
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar placeholder
            Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),

            // AI response placeholder with typing indicator effect
            Container(
              height: 20,
              width: 120,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Content placeholders with different widths to simulate text
            ...List.generate(
              8,
              (index) => Container(
                height:
                    index % 3 == 0
                        ? 16
                        : 12, // Vary height to simulate different text
                width:
                    index % 2 == 0
                        ? MediaQuery.of(context).size.width * 0.7
                        : MediaQuery.of(context).size.width * 0.5,
                margin: EdgeInsets.only(
                  bottom: 8,
                  left: index % 3 == 0 ? 0 : 24.0, // Indent some lines
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Suggested questions/topics section
            Container(
              height: 20,
              width: 180,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                4,
                (index) => Container(
                  width: 120 + (index * 40).toDouble(),
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchResults results) {
    return Column(
      children:
          results.results
              .map(
                (result) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ResultCard(result: result),
                ),
              )
              .toList(),
    );
  }

  Widget _buildImagesSection(BuildContext context, SearchResults results) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: results.images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final image = results.images[index];
          return ImageCard(image: image);
        },
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final SearchResultItem result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _launchUrl(result.url),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // URL and favicon
              Row(
                children: [
                  // Favicon placeholder
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      result.url
                          .replaceAll('https://', '')
                          .replaceAll('http://', '')
                          .replaceAll('www.', '')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Domain
                  Expanded(
                    child: Text(
                      Uri.parse(result.url).host.replaceFirst('www.', ''),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                result.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Content snippet
              Text(
                result.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

class ImageCard extends StatelessWidget {
  final SearchResultImage image;

  const ImageCard({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 200,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _launchUrl(image.url),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with shimmer loading
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Image.network(
                      image.url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return ShimmerLoading(
                          isLoading: true,
                          child: Container(color: colorScheme.surface),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
              // Image info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  image.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

class AIResultsWidget extends StatelessWidget {
  final String id;
  final SearchDao dao;

  const AIResultsWidget({super.key, required this.id, required this.dao});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SearchDatas?>(
      stream: dao.watchSearchData(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return _buildLoadingShimmer(context);
        }
        final data = snapshot.data!;
        if (data.gemini == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GptMarkdown(
                  data.gemini!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withOpacity(0.6),
      highlightColor: Theme.of(context).colorScheme.surface,
      period: const Duration(milliseconds: 1800), // Smooth, report-like loading
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report header section
            Container(
              height: 28,
              width: 200,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            _buildSectionShimmer(context, titleWidth: 120),
            _buildParagraphShimmer(context, lineCount: 3),

            const SizedBox(height: 32),

            _buildSectionShimmer(context, titleWidth: 140),
            _buildBulletPointShimmer(context),

            const SizedBox(height: 32),

            Container(
              height: 180,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // Conclusion section
            _buildSectionShimmer(context, titleWidth: 100),
            _buildParagraphShimmer(context, lineCount: 4, lastLineWidth: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionShimmer(
    BuildContext context, {
    required double titleWidth,
  }) {
    return Container(
      height: 24,
      width: titleWidth,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildParagraphShimmer(
    BuildContext context, {
    int lineCount = 2,
    double lastLineWidth = 0.7,
  }) {
    return Column(
      children: List.generate(
        lineCount,
        (index) => Container(
          height: 12,
          width:
              MediaQuery.of(context).size.width *
              (index == lineCount - 1 ? lastLineWidth : 0.9),
          margin: EdgeInsets.only(bottom: index == lineCount - 1 ? 0 : 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPointShimmer(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 8,
                width: 8,
                margin: const EdgeInsets.only(top: 4, right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    if (index % 2 == 0)
                      Container(
                        height: 12,
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorWidget({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No search results',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search query',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoResultsWidget extends StatelessWidget {
  const NoResultsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your search didn\'t match any documents',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }
}

class SearchTitleWidget extends StatelessWidget {
  final String id;
  final SearchDao searchDao; // Assuming you have a SearchDao instance

  const SearchTitleWidget({Key? key, required this.id, required this.searchDao})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: searchDao.getSearchDataTitleById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Text('No title found');
        } else {
          return Text(
            snapshot.data!,
            style: Theme.of(context).textTheme.headlineMedium,
          );
        }
      },
    );
  }
}
