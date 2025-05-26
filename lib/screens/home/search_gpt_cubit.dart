import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:searchgpt/config/config.dart';
import 'package:searchgpt/config/prompt.dart';
import 'package:searchgpt/database/dao/index.dart';
import 'package:searchgpt/database/db/db.dart';
import 'package:searchgpt/workflow/workflow.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:uuid/uuid.dart';
part 'search_gpt_cubit.freezed.dart';
part 'search_gpt_state.dart';

class SearchGptCubit extends Cubit<SearchGptState> {
  SearchGptCubit() : super(const SearchGptState.initial());

  void setInitial() {
    emit(SearchGptState.initial());
  }

  void setID(String id) {
    emit(SearchGptState.setId(id: id));
  }

  void search(String query, String lang) async {
    var uuid = Uuid();
    AppDatabase db = await AppDatabase.instance;
    SearchDao searchDao = db.searchDao;

    final id = uuid.v4();
    searchDao.insertSearchData(
      SearchDatas(
        id: id,
        query: query,
        token: 123456789,
        search: "",
        gemini: "",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFailed: false,
        isPinned: false,
        isDeleted: false,
        isStarred: false,
        isArchived: false,
        isFavorite: false,
      ),
    );
    emit(SearchGptState.setId(id: id));
    try {
      final results = await searchWorkflow(query: query);
      searchDao.updateFieldById(
        id: id,
        value: convertToJsonString(results),
        columnName: "search",
      );
      debugPrint('Search results ${convertToJsonString(results)}');
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: 'AIzaSyCIHrD0b9A3NI6O5aNYQ1pLhaksq9MWxCg',
      );

      ///TITLE GENERATION
      final titlePrompt = PromptFamily.generateReportIntroduction(
        question: query,
        researchSummary: results.answer,
        language: lang,
      );

      final content = [Content.text(titlePrompt)];
      final response = await model.generateContent(content);
      final reportTitle = response.text ?? '';

      searchDao.updateFieldById(
        id: id,
        value: reportTitle,
        columnName: "gemini",
      );
      final readableContext = results.results
          .map(
            (e) =>
                '''
      Title: ${e.title}
      URL: ${e.url}
      Content: ${e.content}
      Score: ${e.score?.toStringAsFixed(2) ?? 'N/A'}
      ''',
          )
          .join('\n\n');
      final readableContextSource = results.results
          .map(
            (e) =>
                '''
          Title: ${e.title}
          URL: ${e.url}
          Score: ${e.score?.toStringAsFixed(2) ?? 'N/A'}
          ''',
          )
          .join('\n\n');

      ///REPORT GENERATION
      final reportPrompt = PromptFamily.generateReportPrompt(
        question: query,
        context: readableContext,
        reportSource: readableContextSource,
        language: lang,
      );
      debugPrint(reportPrompt);
      final reportContentContent = [Content.text(reportPrompt)];
      final reportContentResponse = await model.generateContent(
        reportContentContent,
      );
      final reportContent = reportContentResponse.text ?? '';

      searchDao.updateFieldById(
        id: id,
        value: reportContent,
        columnName: "report",
      );
    } catch (error) {
      searchDao.updateFieldById(id: id, value: 1, columnName: "is_failed");
      emit(SearchGptState.searchError(message: error.toString()));
    }
  }

  void retry(String id) async {
    AppDatabase db = await AppDatabase.instance;
    SearchDao searchDao = db.searchDao;
    SearchDatas? searchData = await searchDao.getSearchDataById(id);
    if (searchData == null) {
      emit(SearchGptState.searchError(message: "Search data not found"));
      return;
    }
    emit(SearchGptState.setId(id: id));
    try {
      searchDao.updateFieldById(id: id, value: 0, columnName: "is_failed");
      final results = await searchWorkflow(query: searchData.query);
      searchDao.updateFieldById(
        id: id,
        value: convertToJsonString(results),
        columnName: "search",
      );

      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: 'AIzaSyCIHrD0b9A3NI6O5aNYQ1pLhaksq9MWxCg',
      );

      ///TITLE GENERATION
      final titlePrompt = PromptFamily.generateReportIntroduction(
        question: searchData.query,
        researchSummary: results.answer,
      );

      final content = [Content.text(titlePrompt)];
      final response = await model.generateContent(content);
      final reportTitle = response.text ?? '';

      searchDao.updateFieldById(
        id: id,
        value: reportTitle,
        columnName: "gemini",
      );
      final readableContext = results.results
          .map(
            (e) =>
                '''
      Title: ${e.title}
      URL: ${e.url}
      Content: ${e.content}
      Score: ${e.score?.toStringAsFixed(2) ?? 'N/A'}
      ''',
          )
          .join('\n\n');
      final readableContextSource = results.results
          .map(
            (e) =>
                '''
          Title: ${e.title}
          URL: ${e.url}
          Score: ${e.score?.toStringAsFixed(2) ?? 'N/A'}
          ''',
          )
          .join('\n\n');

      ///REPORT GENERATION
      final reportPrompt = PromptFamily.generateReportPrompt(
        question: searchData.query,
        context: readableContext,
        reportSource: readableContextSource,
      );
      debugPrint(reportPrompt);
      final reportContentContent = [Content.text(reportPrompt)];
      final reportContentResponse = await model.generateContent(
        reportContentContent,
      );
      final reportContent = reportContentResponse.text ?? '';

      searchDao.updateFieldById(
        id: id,
        value: reportContent,
        columnName: "report",
      );
    } catch (error) {
      searchDao.updateFieldById(id: id, value: 1, columnName: "is_failed");
      emit(SearchGptState.searchError(message: error.toString()));
    }
  }
}
