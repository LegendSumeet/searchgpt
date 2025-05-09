import 'package:searchgpt/workflow/tavily.dart';

import '../client/dio_client.dart';

Future<SearchResults> searchWorkflow({required String query}) async {
  SearchResults searchResults = await Tavily(
    apiKey: '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',
    baseUrl: 'https://api.tavily.com',
    dioClient: DioClient(),
    searchDepth: 'basic',
    includeDomains: [],
    excludeDomains: [],
  ).search(query);
  return searchResults;
}
