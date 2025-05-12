// Enum for request types
import 'package:searchgpt/client/dio_client.dart';

enum TavilyRequestType { search, extract }

// Model for search results
class SearchResults {
  final List<SearchResultImage> images;
  final List<SearchResultItem> results;
  final int? numberOfResults;
  final String query;
  final String answer;

  SearchResults({
    required this.images,
    required this.results,
    required this.query,
    this.numberOfResults,
    required this.answer,
  });

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    return SearchResults(
      answer: json['answer'] ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((item) => SearchResultImage.fromJson(item))
              .toList() ??
          [],
      results:
          (json['results'] as List<dynamic>?)
              ?.map((item) => SearchResultItem.fromJson(item))
              .toList() ??
          [],
      numberOfResults: json['number_of_results'],
      query: json['query'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'images': images.map((e) => e.toJson()).toList(),
      'results': results.map((e) => e.toJson()).toList(),
      'number_of_results': numberOfResults,
      'query': query,
    };
  }
}

// Model for image search result
class SearchResultImage {
  final String url;
  final String description;
  final int? numberOfResults;

  SearchResultImage({
    required this.url,
    required this.description,
    this.numberOfResults,
  });

  factory SearchResultImage.fromJson(Map<String, dynamic> json) {
    return SearchResultImage(
      url: json['url'] ?? '',
      description: json['description'] ?? 'No description available',
      numberOfResults: json['number_of_results'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'description': description,
      'number_of_results': numberOfResults,
    };
  }
}

// Model for regular search result item
class SearchResultItem {
  final String title;
  final String url;
  final String content;
  final double? score;

  SearchResultItem({
    required this.title,
    required this.url,
    required this.content,
    this.score,
  });

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      content: json['content'] ?? '',
      score: (json['score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'url': url, 'content': content, 'score': score};
  }
}

class Tavily {
  final String apiKey;
  final String baseUrl;
  final DioClient dioClient;
  final String searchDepth;
  final List<String> includeDomains;
  final List<String> excludeDomains;

  Tavily({
    required this.apiKey,
    required this.baseUrl,
    required this.dioClient,
    required this.searchDepth,
    required this.includeDomains,
    required this.excludeDomains,
  });

  Future<SearchResults> search(String query) async {
    final response = await dioClient.post(
      '$baseUrl/search',
      headers: {'Content-Type': 'application/json'},
      data: {
        'api_key': apiKey,
        'query': query,
        'topic': 'general',
        'max_results': 5,
        'search_depth': searchDepth,
        'include_images': true,
        'include_image_descriptions': true,
        'include_answer': 'advanced',
        'include_domains': includeDomains,
        'exclude_domains': excludeDomains,
        'time_range': 'day',
      },
    );
    return SearchResults.fromJson(response);
  }

  Future<SearchResults> extract(String url) async {
    final response = await dioClient.get(
      '$baseUrl/extract',
      queryParams: {'url': url},
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    return SearchResults.fromJson(response);
  }
}
