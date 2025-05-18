import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:searchgpt/config/config.dart';
import 'package:searchgpt/database/dao/index.dart';
import 'package:searchgpt/database/db/db.dart';
import 'package:searchgpt/workflow/tavily.dart';
import 'package:searchgpt/workflow/workflow.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
// import 'dart:convert';
// import 'dart:typed_data';

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

  void search(String query) async {
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
      // final String formattedContent = buildGeminiPromptFromSearchResults(
      //   results,
      //   query,
      // );
      // final model = GenerativeModel(
      //   model: 'gemini-1.5-pro',
      //   apiKey: 'AIzaSyCIHrD0b9A3NI6O5aNYQ1pLhaksq9MWxCg',
      // );
      // final content = [Content.text(formattedContent)];
      // final response = await model.generateContent(content);

      // // Safely extract the generated text
      // final text = response.text ?? '';

      searchDao.updateFieldById(
        id: id,
        value: results.answer,
        columnName: "gemini",
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
      // final String formattedContent = buildGeminiPromptFromSearchResults(
      //   results,
      //   searchData.query,
      // );
      // final model = GenerativeModel(
      //   model: 'gemini-2.0-flash',
      //   apiKey: 'AIzaSyCweP152s9zgdEC5j82HMQaCvPRuvyXu0Q',
      // );
      // final content = [Content.text(formattedContent)];
      // final response = await model.generateContent(content);

      // // Safely extract the generated text
      // final text = response.text ?? '';

      searchDao.updateFieldById(
        id: id,
        value: results.answer,
        columnName: "gemini",
      );
    } catch (error) {
      searchDao.updateFieldById(id: id, value: 1, columnName: "is_failed");
      emit(SearchGptState.searchError(message: error.toString()));
    }
  }
}
