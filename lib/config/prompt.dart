import 'dart:convert';

class PromptFamily {
  final Config config;

  PromptFamily(this.config);

  static String generateSearchQueriesPrompt({
    required String question,
    required String parentQuery,
    required String reportType,
    int maxIterations = 3,
    List<Map<String, dynamic>> context = const [],
  }) {
    final task =
        (reportType == ReportType.detailedReport.value ||
            reportType == ReportType.subtopicReport.value)
        ? "$parentQuery - $question"
        : question;

    final contextPrompt = context.isNotEmpty
        ? """
You are a seasoned research assistant tasked with generating search queries to find relevant information for the following task: "$task".
Context: ${jsonEncode(context)}

Use this context to inform and refine your search queries. The context provides real-time web information that can help you generate more specific and relevant queries. Consider any current events, recent developments, or specific details mentioned in the context that could enhance the search queries.
"""
        : "";

    final dynamicExample = List.generate(
      maxIterations,
      (i) => '"query ${i + 1}"',
    ).join(', ');
    final currentDate = DateTime.now().toUtc();

    return """Write $maxIterations google search queries to search online that form an objective opinion from the following task: "$task"

Assume the current date is ${currentDate.month} ${currentDate.day}, ${currentDate.year} if required.

$contextPrompt
You must respond with a list of strings in the following format: [$dynamicExample].
The response should contain ONLY the list.
""";
  }

  static String generateReportPrompt({
    required String question,
    required dynamic context,
    required String reportSource,
    String reportFormat = "apa",
    int totalWords = 1000,
    Tone? tone,
    String language = "english",
  }) {
    final referencePrompt = reportSource == ReportSource.web.value
        ? """
You MUST write all used source urls at the end of the report as references, and make sure to not add duplicated sources, but only one reference for each.
Every url should be hyperlinked: [url website](url)
Additionally, you MUST include hyperlinks to the relevant URLs wherever they are referenced in the report:

eg: Author, A. A. (Year, Month Date). Title of web page. Website Name. [url website](url)
"""
        : """
You MUST write all used source document names at the end of the report as references, and make sure to not add duplicated sources, but only one reference for each."
""";

    final tonePrompt = tone != null
        ? "Write the report in a ${tone.value} tone."
        : "";
    final today = DateTime.now();

    return """
Information: "$context"
---
Using the above information, answer the following query or task: "$question" in a detailed report --
The report should focus on the answer to the query, should be well structured, informative,
in-depth, and comprehensive, with facts and numbers if available and at least $totalWords words.
You should strive to write the report as long as you can using all relevant and necessary information provided.

Please follow all of the following guidelines in your report:
- You MUST determine your own concrete and valid opinion based on the given information. Do NOT defer to general and meaningless conclusions.
- You MUST write the report with markdown syntax and $reportFormat format.
- Use markdown tables when presenting structured data or comparisons to enhance readability.
- You MUST prioritize the relevance, reliability, and significance of the sources you use. Choose trusted sources over less reliable ones.
- You must also prioritize new articles over older articles if the source can be trusted.
- You MUST NOT include a table of contents. Start from the main report body directly.
- Use in-text citation references in $reportFormat format and make it with markdown hyperlink placed at the end of the sentence or paragraph that references them like this: ([in-text citation](url)).
- Don't forget to add a reference list at the end of the report in $reportFormat format and full url links without hyperlinks.
- $referencePrompt
- $tonePrompt

You MUST write the report in the following language: $language.
Please do your best, this is very important to my career.
Assume that the current date is ${today.year}-${today.month}-${today.day}.
""";
  }

  static String curateSources({
    required String query,
    required dynamic sources,
    int maxResults = 10,
  }) {
    return """Your goal is to evaluate and curate the provided scraped content for the research task: "$query"
    while prioritizing the inclusion of relevant and high-quality information, especially sources containing statistics, numbers, or concrete data.

The final curated list will be used as context for creating a research report, so prioritize:
- Retaining as much original information as possible, with extra emphasis on sources featuring quantitative data or unique insights
- Including a wide range of perspectives and insights
- Filtering out only clearly irrelevant or unusable content

EVALUATION GUIDELINES:
1. Assess each source based on:
   - Relevance: Include sources directly or partially connected to the research query. Err on the side of inclusion.
   - Credibility: Favor authoritative sources but retain others unless clearly untrustworthy.
   - Currency: Prefer recent information unless older data is essential or valuable.
   - Objectivity: Retain sources with bias if they provide a unique or complementary perspective.
   - Quantitative Value: Give higher priority to sources with statistics, numbers, or other concrete data.
2. Source Selection:
   - Include as many relevant sources as possible, up to $maxResults, focusing on broad coverage and diversity.
   - Prioritize sources with statistics, numerical data, or verifiable facts.
   - Overlapping content is acceptable if it adds depth, especially when data is involved.
   - Exclude sources only if they are entirely irrelevant, severely outdated, or unusable due to poor content quality.
3. Content Retention:
   - DO NOT rewrite, summarize, or condense any source content.
   - Retain all usable information, cleaning up only clear garbage or formatting issues.
   - Keep marginally relevant or incomplete sources if they contain valuable data or insights.

SOURCES LIST TO EVALUATE:
${jsonEncode(sources)}

You MUST return your response in the EXACT sources JSON list format as the original sources.
The response MUST not contain any markdown format or additional text (like ```json), just the JSON list!
""";
  }

  static String generateResourceReportPrompt({
    required String question,
    required dynamic context,
    required String reportSource,
    String reportFormat = "apa",
    Tone? tone,
    int totalWords = 1000,
    String language = "english",
  }) {
    final referencePrompt = reportSource == ReportSource.web.value
        ? """
            You MUST include all relevant source urls.
            Every url should be hyperlinked: [url website](url)
            """
        : """
            You MUST write all used source document names at the end of the report as references, and make sure to not add duplicated sources, but only one reference for each."
        """;

    return '''
"""$context"""\n\nBased on the above information, generate a bibliography recommendation report for the following
    question or topic: "$question". The report should provide a detailed analysis of each recommended resource,
    explaining how each source can contribute to finding answers to the research question.
    Focus on the relevance, reliability, and significance of each source.
    Ensure that the report is well-structured, informative, in-depth, and follows Markdown syntax.
    Use markdown tables and other formatting features when appropriate to organize and present information clearly.
    Include relevant facts, figures, and numbers whenever available.
    The report should have a minimum length of $totalWords words.
    You MUST write the report in the following language: $language.
    You MUST include all relevant source urls.
    Every url should be hyperlinked: [url website](url)
    $referencePrompt
    ''';
  }

  static String generateCustomReportPrompt({
    required String queryPrompt,
    required dynamic context,
    required String reportSource,
    String reportFormat = "apa",
    Tone? tone,
    int totalWords = 1000,
    String language = "english",
  }) {
    return '"$context"\n\n$queryPrompt';
  }

  static String generateOutlineReportPrompt({
    required String question,
    required dynamic context,
    required String reportSource,
    String reportFormat = "apa",
    Tone? tone,
    int totalWords = 1000,
    String language = "english",
  }) {
    return '''
"""$context""" Using the above information, generate an outline for a research report in Markdown syntax
    for the following question or topic: "$question". The outline should provide a well-structured framework
    for the research report, including the main sections, subsections, and key points to be covered.
    The research report should be detailed, informative, in-depth, and a minimum of $totalWords words.
    Use appropriate Markdown syntax to format the outline and ensure readability.
    Consider using markdown tables and other formatting features where they would enhance the presentation of information.
    ''';
  }

  static String generateDeepResearchPrompt({
    required String question,
    required dynamic context,
    required String reportSource,
    String reportFormat = "apa",
    Tone? tone,
    int totalWords = 2000,
    String language = "english",
  }) {
    final referencePrompt = reportSource == ReportSource.web.value
        ? """
You MUST write all used source urls at the end of the report as references, and make sure to not add duplicated sources, but only one reference for each.
Every url should be hyperlinked: [url website](url)
Additionally, you MUST include hyperlinks to the relevant URLs wherever they are referenced in the report:

eg: Author, A. A. (Year, Month Date). Title of web page. Website Name. [url website](url)
"""
        : """
You MUST write all used source document names at the end of the report as references, and make sure to not add duplicated sources, but only one reference for each."
""";

    final tonePrompt = tone != null
        ? "Write the report in a ${tone.value} tone."
        : "";
    final currentDate = DateTime.now().toUtc();

    return """
Using the following hierarchically researched information and citations:

"$context"

Write a comprehensive research report answering the query: "$question"

The report should:
1. Synthesize information from multiple levels of research depth
2. Integrate findings from various research branches
3. Present a coherent narrative that builds from foundational to advanced insights
4. Maintain proper citation of sources throughout
5. Be well-structured with clear sections and subsections
6. Have a minimum length of $totalWords words
7. Follow $reportFormat format with markdown syntax
8. Use markdown tables, lists and other formatting features when presenting comparative data, statistics, or structured information

Additional requirements:
- Prioritize insights that emerged from deeper levels of research
- Highlight connections between different research branches
- Include relevant statistics, data, and concrete examples
- You MUST determine your own concrete and valid opinion based on the given information. Do NOT defer to general and meaningless conclusions.
- You MUST prioritize the relevance, reliability, and significance of the sources you use. Choose trusted sources over less reliable ones.
- You must also prioritize new articles over older articles if the source can be trusted.
- Use in-text citation references in $reportFormat format and make it with markdown hyperlink placed at the end of the sentence or paragraph that references them like this: ([in-text citation](url)).
- $tonePrompt
- Write in $language

$referencePrompt

Please write a thorough, well-researched report that synthesizes all the gathered information into a cohesive whole.
Assume the current date is ${currentDate.month} ${currentDate.day}, ${currentDate.year}.
""";
  }

  static String autoAgentInstructions() {
    return """
This task involves researching a given topic, regardless of its complexity or the availability of a definitive answer. The research is conducted by a specific server, defined by its type and role, with each server requiring distinct instructions.
Agent
The server is determined by the field of the topic and the specific name of the server that could be utilized to research the topic provided. Agents are categorized by their area of expertise, and each server type is associated with a corresponding emoji.

examples:
task: "should I invest in apple stocks?"
response:
{
    "server": "💰 Finance Agent",
    "agent_role_prompt: "You are a seasoned finance analyst AI assistant. Your primary goal is to compose comprehensive, astute, impartial, and methodically arranged financial reports based on provided data and trends."
}
task: "could reselling sneakers become profitable?"
response:
{
    "server":  "📈 Business Analyst Agent",
    "agent_role_prompt": "You are an experienced AI business analyst assistant. Your main objective is to produce comprehensive, insightful, impartial, and systematically structured business reports based on provided business data, market trends, and strategic analysis."
}
task: "what are the most interesting sites in Tel Aviv?"
response:
{
    "server":  "🌍 Travel Agent",
    "agent_role_prompt": "You are a world-travelled AI tour guide assistant. Your main purpose is to draft engaging, insightful, unbiased, and well-structured travel reports on given locations, including history, attractions, and cultural insights."
}
""";
  }

  static String generateSummaryPrompt(String query, dynamic data) {
    return '''
$data\n Using the above text, summarize it based on the following task or query: "$query".\n If the
    query cannot be answered using the text, YOU MUST summarize the text in short.\n Include all factual
    information such as numbers, stats, quotes, etc if available.
    ''';
  }

  static String prettyPrintDocs(List<Document> docs, [int? topN]) {
    return docs
        .take(topN ?? docs.length)
        .map(
          (d) =>
              "Source: ${d.metadata['source']}\n"
              "Title: ${d.metadata['title']}\n"
              "Content: ${d.pageContent}\n",
        )
        .join("\n");
  }

  static String joinLocalWebDocuments(String docsContext, String webContext) {
    return "Context from local documents: $docsContext\n\nContext from web sources: $webContext";
  }

  // DETAILED REPORT PROMPTS
  static String generateSubtopicsPrompt() {
    return """
Provided the main topic:

{task}

and research data:

{data}

- Construct a list of subtopics which indicate the headers of a report document to be generated on the task.
- These are a possible list of subtopics : {subtopics}.
- There should NOT be any duplicate subtopics.
- Limit the number of subtopics to a maximum of {max_subtopics}
- Finally order the subtopics by their tasks, in a relevant and meaningful order which is presentable in a detailed report

"IMPORTANT!":
- Every subtopic MUST be relevant to the main topic and provided research data ONLY!

{format_instructions}
""";
  }

  static String generateSubtopicReportPrompt({
    required String currentSubtopic,
    required List<String> existingHeaders,
    required List<String> relevantWrittenContents,
    required String mainTopic,
    required dynamic context,
    String reportFormat = "apa",
    int maxSubsections = 5,
    int totalWords = 800,
    Tone tone = Tone.objective,
    String language = "english",
  }) {
    final currentDate = DateTime.now().toUtc();
    return """
Context:
"$context"

Main Topic and Subtopic:
Using the latest information available, construct a detailed report on the subtopic: $currentSubtopic under the main topic: $mainTopic.
You must limit the number of subsections to a maximum of $maxSubsections.

Content Focus:
- The report should focus on answering the question, be well-structured, informative, in-depth, and include facts and numbers if available.
- Use markdown syntax and follow the ${reportFormat.toUpperCase()} format.
- When presenting data, comparisons, or structured information, use markdown tables to enhance readability.

IMPORTANT:Content and Sections Uniqueness:
- This part of the instructions is crucial to ensure the content is unique and does not overlap with existing reports.
- Carefully review the existing headers and existing written contents provided below before writing any new subsections.
- Prevent any content that is already covered in the existing written contents.
- Do not use any of the existing headers as the new subsection headers.
- Do not repeat any information already covered in the existing written contents or closely related variations to avoid duplicates.
- If you have nested subsections, ensure they are unique and not covered in the existing written contents.
- Ensure that your content is entirely new and does not overlap with any information already covered in the previous subtopic reports.

"Existing Subtopic Reports":
- Existing subtopic reports and their section headers:

    ${existingHeaders.join('\n')}

- Existing written contents from previous subtopic reports:

    ${relevantWrittenContents.join('\n')}

"Structure and Formatting":
- As this sub-report will be part of a larger report, include only the main body divided into suitable subtopics without any introduction or conclusion section.

- You MUST include markdown hyperlinks to relevant source URLs wherever referenced in the report, for example:

    ### Section Header

    This is a sample text ([in-text citation](url)).

- Use H2 for the main subtopic header (##) and H3 for subsections (###).
- Use smaller Markdown headers (e.g., H2 or H3) for content structure, avoiding the largest header (H1) as it will be used for the larger report's heading.
- Organize your content into distinct sections that complement but do not overlap with existing reports.
- When adding similar or identical subsections to your report, you should clearly indicate the differences between and the new content and the existing written content from previous subtopic reports. For example:

    ### New header (similar to existing header)

    While the previous section discussed [topic A], this section will explore [topic B]."

"Date":
Assume the current date is ${currentDate.month} ${currentDate.day}, ${currentDate.year} if required.

"IMPORTANT!":
- You MUST write the report in the following language: $language.
- The focus MUST be on the main topic! You MUST Leave out any information un-related to it!
- Must NOT have any introduction, conclusion, summary or reference section.
- You MUST use in-text citation references in ${reportFormat.toUpperCase()} format and make it with markdown hyperlink placed at the end of the sentence or paragraph that references them like this: ([in-text citation](url)).
- You MUST mention the difference between the existing content and the new content in the report if you are adding the similar or same subsections wherever necessary.
- The report should have a minimum length of $totalWords words.
- Use an ${tone.value} tone throughout the report.

Do NOT add a conclusion section.
""";
  }

  static String generateDraftTitlesPrompt({
    required String currentSubtopic,
    required String mainTopic,
    required dynamic context,
    int maxSubsections = 5,
  }) {
    return """
"Context":
"$context"

"Main Topic and Subtopic":
Using the latest information available, construct a draft section title headers for a detailed report on the subtopic: $currentSubtopic under the main topic: $mainTopic.

"Task":
1. Create a list of draft section title headers for the subtopic report.
2. Each header should be concise and relevant to the subtopic.
3. The header should't be too high level, but detailed enough to cover the main aspects of the subtopic.
4. Use markdown syntax for the headers, using H3 (###) as H1 and H2 will be used for the larger report's heading.
5. Ensure the headers cover main aspects of the subtopic.

"Structure and Formatting":
Provide the draft headers in a list format using markdown syntax, for example:

### Header 1
### Header 2
### Header 3

"IMPORTANT!":
- The focus MUST be on the main topic! You MUST Leave out any information un-related to it!
- Must NOT have any introduction, conclusion, summary or reference section.
- Focus solely on creating headers, not content.
""";
  }

  static String generateReportIntroduction({
    required String question,
    String researchSummary = "",
    String language = "english",
    String reportFormat = "apa",
  }) {
    final currentDate = DateTime.now().toUtc();
    return """$researchSummary\n
Using the above latest information, Prepare a detailed report introduction on the topic -- $question.
- The introduction should be succinct, well-structured, informative with markdown syntax.
- As this introduction will be part of a larger report, do NOT include any other sections, which are generally present in a report.
- The introduction should be preceded by an H1 heading with a suitable topic for the entire report.
Assume that the current date is ${currentDate.month} ${currentDate.day}, ${currentDate.year} if required.
- The output must be in $language language.
""";
  }

  static String generateReportConclusion({
    required String query,
    required String reportContent,
    String language = "english",
    String reportFormat = "apa",
  }) {
    return """
Based on the research report below and research task, please write a concise conclusion that summarizes the main findings and their implications:

Research task: $query

Research Report: $reportContent

Your conclusion should:
1. Recap the main points of the research
2. Highlight the most important findings
3. Discuss any implications or next steps
4. Be approximately 2-3 paragraphs long

If there is no "## Conclusion" section title written at the end of the report, please add it to the top of your conclusion.
You must use in-text citation references in ${reportFormat.toUpperCase()} format and make it with markdown hyperlink placed at the end of the sentence or paragraph that references them like this: ([in-text citation](url)).

IMPORTANT: The entire conclusion MUST be written in $language language.

Write the conclusion:
""";
  }
}

class Config {
  // Your Config class implementation
}

class ReportType {
  static const detailedReport = _DetailedReport();
  static const subtopicReport = _SubtopicReport();

  const ReportType._();
}

class _DetailedReport {
  final String value = "detailed_report";
  const _DetailedReport();
}

class _SubtopicReport {
  final String value = "subtopic_report";
  const _SubtopicReport();
}

class ReportSource {
  static const web = _Web();
  static const documents = _Documents();

  const ReportSource._();
}

class _Web {
  final String value = "web";
  const _Web();
}

class _Documents {
  final String value = "documents";
  const _Documents();
}

class Tone {
  static const objective = _Objective();

  final String value;
  const Tone._(this.value);
}

class _Objective extends Tone {
  const _Objective() : super._("objective");
}

class Document {
  final Map<String, dynamic> metadata;
  final String pageContent;

  Document({required this.metadata, required this.pageContent});
}
