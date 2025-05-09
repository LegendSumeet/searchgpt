part of 'search_gpt_cubit.dart';

@freezed
sealed class SearchGptState with _$SearchGptState {
  const factory SearchGptState.initial() = SearchInitial;

  const factory SearchGptState.setId({required String id}) = SetId;
  const factory SearchGptState.getDatabase({required AppDatabase database}) =
      GetDatabase;

  const factory SearchGptState.start() = Loading;

  const factory SearchGptState.startSearch() = Search;

  const factory SearchGptState.searchResult() = SearchResult;

  const factory SearchGptState.searchError({required String message}) =
      SearchError;

  const factory SearchGptState.searchInProgress({required String query}) =
      SearchInProgress;

  const factory SearchGptState.searchCompleted({required String id}) =
      SearchCompleted;

  const factory SearchGptState.searchCancelled({required String error}) =
      SearchCancelled;

  const factory SearchGptState.searchSuccess({required String id}) =
      SearchSuccess;

  const factory SearchGptState.aiLoading() = AiLoading;

  const factory SearchGptState.aiSuccess({required String id}) = AiSuccess;
}
