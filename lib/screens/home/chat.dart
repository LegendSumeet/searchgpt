// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:intl/intl.dart';
import 'package:searchgpt/database/dao/index.dart';
import 'package:searchgpt/database/db/db.dart';
import 'package:searchgpt/workflow/tavily.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'search_gpt_cubit.dart';

class ChatScreenPage extends StatefulWidget {
  final AppDatabase db;
  const ChatScreenPage({super.key, required this.db});

  @override
  State<ChatScreenPage> createState() => _ChatScreenPageState();
}

class _ChatScreenPageState extends State<ChatScreenPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
              drawer: DrawerWidget(db: widget.db),
              appBar: AppBar(
                centerTitle: false,
                title: buildTitle(context, widget.db),
                elevation: 0,
              ),
              body: SafeArea(child: ChatBody(db: widget.db)),
            ),
      ),
    );
  }

  Widget buildTitle(BuildContext context, AppDatabase db) {
    final state = context.read<SearchGptCubit>().state;

    if (state is SetId) {
      return SearchTitleWidget(
        id: (state as dynamic).id,
        searchDao: SearchDao(db),
      );
    } else {
      return const Text('SearchGPT');
    }
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
  String currentQuery = '';

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
                      _buildSearchResultsSection(state.id),
                      _buildAiResponseSection(state.id),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated greeting text with subtle scale effect
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.95, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Text(
              'How can I help you today?',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: colorScheme.onSurface.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Decorative divider
          Container(
            width: 48,
            height: 3,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Improved description text with better spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text:
                        'Ask anything or search for information across the web. ',
                  ),
                  TextSpan(
                    text: 'I can help with research, analysis, and more.',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverList _buildSearchResultsSection(String id) {
    return SliverList(
      delegate: SliverChildListDelegate([
        SearchResultsWidget(id: id, dao: SearchDao(widget.db)),
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
                    onChanged: (value) => currentQuery = value,
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
      currentQuery = query;
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
            snapshot.data?.search == null ||
            snapshot.data?.search == "" && snapshot.data?.isFailed == false) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 0,
              margin: const EdgeInsets.all(
                8,
              ), // Add some margin for better spacing
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GptMarkdown(
                      followLinkColor: true,
                      "Searching...",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "This may take a moment",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        if (data.isFailed) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We couldn’t complete your search.\nPlease check your connection or try again.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    onPressed: () {
                      context.read<SearchGptCubit>().retry(data.id);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (data.search == null) {
          return const NoResultsWidget();
        }

        try {
          final jsonMap = json.decode(
            data.search ?? '{}',
          ); // Added null check operator
          final SearchResults results = SearchResults.fromJson(jsonMap);

          return Skeletonizer(
            enabled: false,
            child: Column(
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
            ),
          );
        } catch (e) {
          // Handle JSON parsing errors
          debugPrint('Error parsing search data: $e');
          return const Skeletonizer(enabled: true, child: SizedBox());
        }
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 0, 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchResults results) {
    return SizedBox(
      height: 200,
      child: CarouselView(
        onTap: (index) async {
          await launchUrlWeb(results.results[index].url);
        },
        padding: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        scrollDirection: Axis.horizontal,
        itemExtent: 267,
        children:
            results.results
                .map((result) => ResultCard(result: result))
                .toList(),
      ),
    );
  }

  Widget _buildImagesSection(BuildContext context, SearchResults results) {
    return SizedBox(
      height: 200,
      child: CarouselView(
        onTap: (index) async {
          await launchUrlWeb(results.images[index].url);
        },
        padding: EdgeInsets.all(4),
        scrollDirection: Axis.horizontal,
        itemExtent: 280,
        children:
            results.images.map((image) => ImageCard(image: image)).toList(),
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

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> launchUrlWeb(String url) async {
  final uri = Uri.parse(url);

  // Check if URL is valid and can be launched
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://$url';
  }

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Opens in browser
        webOnlyWindowName: '_blank', // For web apps
      );
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    debugPrint('Error launching URL: $e');
  }
}

class ImageCard extends StatelessWidget {
  final SearchResultImage image;

  const ImageCard({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        color: colorScheme.surfaceContainerHighest,
        child: Image.network(
          image.url,
          fit: BoxFit.cover,
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
            snapshot.data == null ||
            snapshot.data?.gemini == "" && snapshot.data?.isFailed == false) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Generating summary...",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              height: 1.4,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "We're processing your content",
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
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
        final data = snapshot.data!;
        if (data.isFailed == true) {
          return const SizedBox.shrink();
        }
        if (data.gemini == null) {
          return const SizedBox.shrink();
        }

        return Skeletonizer(
          enabled:
              snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data?.gemini == "",
          child: Card(
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
                onLinkTab: (url, text) async {
                  await launchUrlWeb(url);
                },
                followLinkColor: true,
                data.gemini ?? '',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
            ),
          ),
        );
      },
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
  final SearchDao searchDao;

  const SearchTitleWidget({Key? key, required this.id, required this.searchDao})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: searchDao.getSearchDataTitleById(id),
      builder: (context, snapshot) {
        // Handle different states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Skeletonizer(
            enabled: true,
            child: Text(
              'Loading...', // Placeholder text
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Error loading title',
            style: Theme.of(context).textTheme.headlineMedium,
          );
        }

        final title = snapshot.data ?? 'SearchGPT'; // Fallback for null data

        return Skeletonizer(
          enabled: false, // Disable skeleton when we have data
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        );
      },
    );
  }
}

class DrawerWidget extends StatefulWidget {
  final AppDatabase db;

  const DrawerWidget({Key? key, required this.db}) : super(key: key);

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Drawer(
      child: SafeArea(
        child: StreamBuilder<List<SearchDatas>>(
          stream: SearchDao(widget.db).watchAllSearchData(),
          builder: (context, snapshot) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildDrawerContent(context, snapshot, widget.db),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Widget _buildDrawerContent(
  BuildContext context,
  AsyncSnapshot<List<SearchDatas>> snapshot,
  AppDatabase db,
) {
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

  // Group data by date
  final groupedData = _groupByDate(snapshot.data!);

  return _SearchList(
    key: ValueKey('list-${snapshot.data!.length}'),
    groupedData: groupedData,
    db: db,
  );
}

Map<DateTime, List<SearchDatas>> _groupByDate(List<SearchDatas> data) {
  final Map<DateTime, List<SearchDatas>> groupedData = {};

  for (final item in data) {
    // Assuming createdAt is a timestamp in seconds (like 1234723224)
    final date = DateTime.fromMillisecondsSinceEpoch(
      item.createdAt.millisecondsSinceEpoch,
    );
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (!groupedData.containsKey(dateOnly)) {
      groupedData[dateOnly] = [];
    }
    groupedData[dateOnly]!.add(item);
  }

  // Sort by date (newest first)
  final sortedKeys = groupedData.keys.toList()..sort((a, b) => b.compareTo(a));

  final sortedMap = Map.fromEntries(
    sortedKeys.map((key) => MapEntry(key, groupedData[key]!)),
  );

  return sortedMap;
}

class _SearchList extends StatelessWidget {
  final Map<DateTime, List<SearchDatas>> groupedData;
  final AppDatabase db;

  const _SearchList({required this.groupedData, required this.db, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children:
          groupedData.entries.map((entry) {
            final date = entry.key;
            final items = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    _formatDate(date),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...items
                    .map(
                      (search) => AnimatedListItem(
                        index: items.indexOf(search),
                        child: ListTile(
                          key: ValueKey(search.id),
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
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          onTap: () {
                            context.read<SearchGptCubit>().setID(search.id);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    )
                    .toList(),
                const Divider(height: 16.0),
              ],
            );
          }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }
}

class AIResponseLoading extends StatefulWidget {
  const AIResponseLoading({super.key});

  @override
  State<AIResponseLoading> createState() => _AIResponseLoadingState();
}

class _AIResponseLoadingState extends State<AIResponseLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _animation,
            child: const Icon(Icons.auto_awesome, size: 50),
          ),
          const SizedBox(height: 16),
          const Text("AI Response Loading...", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            minHeight: 2,
          ),
        ],
      ),
    );
  }
}
