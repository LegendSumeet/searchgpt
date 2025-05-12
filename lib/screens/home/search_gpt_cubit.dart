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
      final String formattedContent = buildGeminiPromptFromSearchResults(
        results,
        query,
      );
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: 'AIzaSyCweP152s9zgdEC5j82HMQaCvPRuvyXu0Q',
      );
      final content = [Content.text(formattedContent)];
      final response = await model.generateContent(content);

      // Safely extract the generated text
      final text = response.text ?? '';

      searchDao.updateFieldById(id: id, value: text, columnName: "gemini");
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
      final String formattedContent = buildGeminiPromptFromSearchResults(
        results,
        searchData.query,
      );
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: 'AIzaSyCweP152s9zgdEC5j82HMQaCvPRuvyXu0Q',
      );
      final content = [Content.text(formattedContent)];
      final response = await model.generateContent(content);

      // Safely extract the generated text
      final text = response.text ?? '';

      searchDao.updateFieldById(id: id, value: text, columnName: "gemini");
    } catch (error) {
      searchDao.updateFieldById(id: id, value: 1, columnName: "is_failed");
      emit(SearchGptState.searchError(message: error.toString()));
    }
  }
}

String buildGeminiPromptFromSearchResults(
  SearchResults results,
  String question, {
  String reportType = 'research',
  String reportFormat = 'apa',
  int totalWords = 1200,
  String? tone,
  String language = 'english',
  bool includeImages = false,
}) {
  final buffer = StringBuffer();

  // 0. System Instruction
  buffer.writeln("You are an expert academic researcher and writer.");

  // 1. Research Context Header
  buffer.writeln(_buildResearchHeader(results.query, question, reportType));

  // 2. Source Metadata Overview
  buffer.writeln(_buildSourceMetadataOverview(results.results));
  // 2. LLM Answer Insight Section (if available)
  if (results.answer.trim().isNotEmpty) {
    buffer.writeln(_buildLLMAnswerSection(results.answer));
  }
  // 3. Visual References (optional)
  if (includeImages && results.images.isNotEmpty) {
    buffer.writeln(_buildVisualReferencesSection(results.images));
  }

  // 4. Curated Source Content (+ answer injection)
  buffer.writeln(_buildCuratedSourcesSection(results.results, question));

  // 5. Research Task Specifications
  buffer.writeln(
    _buildResearchTaskSpecifications(
      question,
      results.results.length,
      reportType: reportType,
      reportFormat: reportFormat,
      totalWords: totalWords,
      tone: tone,
      language: language,
      hasImages: includeImages && results.images.isNotEmpty,
    ),
  );

  return buffer.toString();
}

String _buildLLMAnswerSection(String llmAnswer) {
  return """
## LLM Curated Insight

The following summary has been generated by a large language model based on the retrieved sources.
Treat this as a synthesized expert perspective to guide your writing:

> "$llmAnswer"

Use this insight to align your writing direction, but validate and cite specific sources where necessary.
""";
}

// ----------------------------------------------------------------------------
// Helper Functions
// ----------------------------------------------------------------------------

String _buildResearchHeader(String query, String question, String reportType) {
  final taskDescription =
      {
        'research': 'comprehensive research report',
        'detailed': 'in-depth analysis report',
        'subtopic': 'focused subtopic analysis',
        'resource': 'source evaluation report',
      }[reportType] ??
      'research report';

  return """
# Research Task Briefing

**Primary Objective**:
Produce a $taskDescription addressing:
"${reportType == 'subtopic' ? '$query - $question' : question}"

**Context**:
The following information comes from AI-curated and human-evaluated sources:
- Reviewed for credibility, depth, and accuracy
- Enriched with LLM-generated analysis for clarity
- Ordered by relevance to the research topic
""";
}

String _buildSourceMetadataOverview(List<SearchResultItem> results) {
  final scoreRange =
      results.any((r) => r.score != null)
          ? '(${results.where((r) => r.score != null).map((r) => r.score!).reduce(min).toStringAsFixed(2)}–'
              '${results.map((r) => r.score ?? 0).reduce(max).toStringAsFixed(2)} relevance range)'
          : '';

  final contentType =
      results.any((r) => r.content.contains(RegExp(r'\d')))
          ? 'quantitative data'
          : 'qualitative narratives';

  return """
## Source Inventory

- Available sources: ${results.length} $scoreRange
- Content includes: $contentType
- Some entries include LLM-generated answer summaries to help clarity
""";
}

String _buildVisualReferencesSection(List<SearchResultImage> images) {
  final buffer = StringBuffer("\n## Supplementary Visual Data\n");
  buffer.writeln("Found ${images.length} potentially relevant images:\n");

  for (var i = 0; i < images.length; i++) {
    final img = images[i];
    buffer.writeln("${i + 1}. **Visual Reference**: ${img.description}");
    buffer.writeln("   - Source URL: ${img.url}");
    if (img.numberOfResults != null) {
      buffer.writeln("   - Context matches: ${img.numberOfResults} findings");
    }
    buffer.writeln();
  }

  buffer.writeln(
    "Note: Visual references support textual evidence but do not replace it. "
    "Use for enhancement, not citation.",
  );

  return buffer.toString();
}

String _buildCuratedSourcesSection(
  List<SearchResultItem> results,
  String question,
) {
  final prioritizedSources = _prioritizeResearchSources(results, question);
  final buffer = StringBuffer("\n## Curated Source Content\n");

  for (var i = 0; i < prioritizedSources.length; i++) {
    final source = prioritizedSources[i];
    buffer.writeln("### Source ${i + 1}: ${source.title}");
    buffer.writeln("- **URL**: ${source.url}");
    buffer.writeln(
      "- **Excerpt**: ${_truncateWithContext(source.content, 250, question)}",
    );

    if (source.score != null) {
      buffer.writeln(
        "- **Relevance Score**: ${source.score!.toStringAsFixed(2)}/1.00",
      );
    }
    buffer.writeln();
  }

  return buffer.toString();
}

String _buildResearchTaskSpecifications(
  String question,
  int sourceCount, {
  required String reportType,
  required String reportFormat,
  required int totalWords,
  String? tone,
  required String language,
  required bool hasImages,
}) {
  final contentFocus =
      {
        'research': 'synthesizing findings from all sources',
        'detailed': 'conducting a multi-angle deep analysis',
        'subtopic': 'staying tightly focused on the selected theme',
        'resource': 'evaluating and comparing sources critically',
      }[reportType] ??
      'addressing the research topic';

  return """
## Research Execution Guidelines

**Task Focus**:
- Central question: "$question"
- Use only the $sourceCount provided textual sources${hasImages ? " and optional visual references" : ""}
- Word count: $totalWords words (±10%)
- Format: $reportFormat
- Language: $language
${tone != null ? "- Desired tone: $tone" : ''}

**Development Instructions**:
1. Emphasize $contentFocus.
2. Prioritize:
   - High-relevance sources
   - Recent and data-rich materials
   - LLM summaries (where helpful)
3. Handle contradictions by:
   - Noting inconsistencies
   - Comparing author credibility
   - Providing balanced conclusions

**Structure Guidelines**:
${_getStructureSpecifications(reportType, reportFormat)}

**Citation Style**:
- In-text: ([Author, Year])
- References: Full $reportFormat style
- Hyperlinks: [Title]
- Merge duplicates from the same source

**Quality & Ethics**:
- Validate facts via ≥2 sources
- Acknowledge authorial bias
- Write with scholarly rigor

**Example Usage**:
> According to [Smith, 2022], AI adoption in healthcare has grown 30% year-over-year...

## Gemini Self-Check

Before finalizing:
- ✅ Have you cited top 3 sources?
- ✅ Did you handle conflicting perspectives?
- ✅ Does the tone match "$tone"?
- ✅ Are all visual cues referenced appropriately?
""";
}

List<SearchResultItem> _prioritizeResearchSources(
  List<SearchResultItem> results,
  String question,
) {
  final scored =
      results.where((r) => r.score != null).toList()
        ..sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));

  final unscored = results.where((r) => r.score == null).toList();

  return [...scored, ...unscored].take(12).toList();
}

String _truncateWithContext(String content, int length, String question) {
  final lowerContent = content.toLowerCase();
  final lowerQuestion = question.toLowerCase();

  final questionIndex = lowerContent.indexOf(lowerQuestion);
  if (questionIndex != -1) {
    final start = max(0, questionIndex - 50);
    final end = min(content.length, questionIndex + lowerQuestion.length + 50);
    return '...${content.substring(start, end)}...';
  }

  return content.length <= length
      ? content
      : '${content.substring(0, length)}...';
}

String _getStructureSpecifications(String reportType, String reportFormat) {
  final baseStructure = """
- Introduction with clear thesis
- Body with logical sectioning
- Conclusion with summary and implications
""";

  final structures = {
    'detailed': """
- H2 + H3 nested sections
- Methodology outline (optional)
- Comparative table if relevant
- Data figures where appropriate
""",
    'subtopic': """
- No intro; start with subtopic directly
- H3-level headers only
- No formal conclusion
- Use inline cross-referencing
""",
    'resource': """
- Source-by-source evaluation
- Include comparison matrix (if suitable)
- Focus on utility, bias, and coverage
""",
  };

  return structures[reportType] ?? baseStructure;
}
