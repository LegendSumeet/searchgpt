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

      print(text);

      searchDao.updateFieldById(id: id, value: text, columnName: "gemini");
    } catch (error) {
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

  // 1. Research Context Header
  buffer.writeln(_buildResearchHeader(results.query, question, reportType));

  // 2. Source Metadata Overview
  buffer.writeln(_buildSourceMetadataOverview(results.results));

  // 3. Visual References (if available)
  if (includeImages && results.images.isNotEmpty) {
    buffer.writeln(_buildVisualReferencesSection(results.images));
  }

  // 4. Curated Source Content
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

// Helper Methods ==============================================================

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
The following information comes from carefully vetted sources that have been:
- Evaluated for relevance to the research topic
- Assessed for credibility and objectivity
- Prioritized based on content quality
""";
}

String _buildSourceMetadataOverview(List<SearchResultItem> results) {
  final scoreRange =
      results.any((r) => r.score != null)
          ? '(${results.where((r) => r.score != null).map((r) => r.score!).reduce(min).toStringAsFixed(2)}-'
              '${results.map((r) => r.score ?? 0).reduce(max).toStringAsFixed(2)} relevance range)'
          : '';

  return """
## Source Inventory
- Available textual sources: ${results.length} $scoreRange
- Content includes: ${results.any((r) => r.content.contains(RegExp(r'\d'))) ? 'quantitative data' : 'qualitative analysis'}
- Best matches highlighted at the top of the source list
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
      buffer.writeln(
        "   - Context matches: ${img.numberOfResults} related findings",
      );
    }
    buffer.writeln();
  }

  buffer.writeln(
    "Note: Visual references should only support textual evidence, not replace it. "
    "Use them to enhance understanding but rely on textual sources for citations.",
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
    buffer.writeln("- **Source Location**: ${source.url}");
    buffer.writeln(
      "- **Content Excerpt**: ${_truncateWithContext(source.content, 250, question)}",
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
        'research': 'synthesizing information across all sources',
        'detailed': 'conducting multi-perspective analysis',
        'subtopic': 'maintaining tight focus on assigned aspect',
        'resource': 'evaluating source utility and reliability',
      }[reportType] ??
      'addressing the research question';

  return """
## Research Execution Guidelines

**Core Deliverable Requirements**:
- Primary focus: "$question"
- Source constraints: Strictly use provided ${sourceCount} text sources${hasImages ? ' + visual references' : ''}
- Length target: $totalWords words (±10%)
- Formatting: $reportFormat style
- Language: $language
${tone != null ? '- Tone: $tone' : ''}

**Content Development**:
1. Focus on $contentFocus
2. Prioritize sources with:
   - Highest relevance scores
   - Quantitative/statistical data
   - Most recent publication dates
3. Handle contradictions by:
   - Noting discrepancies
   - Comparing source reliability
   - Providing balanced perspective

**Structural Requirements**:
${_getStructureSpecifications(reportType, reportFormat)}

**Citation Protocol**:
- In-text citations: ([Author, Year])
- Reference list: Full $reportFormat entries
- URL formatting: [Source Title]
- Deduplication: Combine references to same source

**Quality Assurance**:
- Fact verification: Cross-check between ≥2 sources
- Bias mitigation: Note potential biases in sources
- Professional standards: Academic rigor required
- End-use reminder: Critical decision-making dependency

**Pro Tip**: Start by identifying the 3-5 most relevant sources to build your core argument, then supplement with supporting evidence.
""";
}

// Utility Methods =============================================================

List<SearchResultItem> _prioritizeResearchSources(
  List<SearchResultItem> results,
  String question,
) {
  // Score-based sorting (descending)
  final scored =
      results.where((r) => r.score != null).toList()
        ..sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));

  // Unscored sources (appended)
  final unscored = results.where((r) => r.score == null).toList();

  return [...scored, ...unscored].take(12).toList(); // Optimal balance
}

String _truncateWithContext(String content, int length, String question) {
  final lowerContent = content.toLowerCase();
  final lowerQuestion = question.toLowerCase();

  // Try to find question-related context
  final questionIndex = lowerContent.indexOf(lowerQuestion);
  if (questionIndex != -1) {
    final start = max(0, questionIndex - 50);
    final end = min(content.length, questionIndex + lowerQuestion.length + 50);
    return '...${content.substring(start, end)}...';
  }

  // Fallback to simple truncation
  return content.length <= length
      ? content
      : '${content.substring(0, length)}...';
}

String _getStructureSpecifications(String reportType, String reportFormat) {
  final baseStructure = """
- Standard academic structure
- Introduction with clear thesis
- Body with logical progression
- Conclusion summarizing findings
""";

  final specialStructures = {
    'detailed': """
- Hierarchical organization (H2 > H3 > H4)
- Comparative analysis sections
- Methodology appendix
- Data visualization where helpful
""",
    'subtopic': """
- Direct content start (no intro)
- H3-level headers only
- No conclusion section
- Cross-reference markers
""",
    'resource': """
- Source evaluation framework
- Utility comparison matrix
- Reliability assessment
- Coverage analysis
""",
  };

  return specialStructures[reportType] ?? baseStructure;
}
