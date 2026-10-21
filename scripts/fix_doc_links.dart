// Fixes the generated docs pages made from markdown, the index page (README.md) and the topic pages (guides in `docs`,
// see `dartdoc_options.yaml`). dartdoc copies their relative links unchanged, so:
// - links to the guides are changed to their topic pages,
// - links to other files in the repository are changed to GitHub,
// - the first heading of each guide is removed, as the topic page already shows it.
//
// Usage, from the project directory, after `dart doc`:
//
// dart run scripts/fix_doc_links.dart [<docs directory, defaults to doc/api>]

import 'dart:io';

const _repositoryUrl = 'https://github.com/ihreapotheken/IA-SDK-Flutter';
const _branch = 'main';

final _markdownSection = RegExp(r'<section class="desc markdown">.*?</section>', dotAll: true);
final _firstHeading = RegExp(r'^(<section class="desc markdown">\s*)<h1[^>]*>.*?</h1>\s*', dotAll: true);
final _href = RegExp(r'href="([^"]*)"');

/// Fixes the pages in the docs directory given in [args].
void main(List<String> args) {
  final docsDir = args.isEmpty ? 'doc/api' : args.first;
  final topics = _readTopics(File('dartdoc_options.yaml'));
  var fixedLinks = 0;

  void fixPage(String pagePath, String sourceDir, String topicsPrefix, {required bool removeHeading}) {
    final page = File(pagePath);
    if (!page.existsSync()) {
      stderr.writeln('Missing page: $pagePath');
      return;
    }
    final html = page.readAsStringSync().replaceFirstMapped(_markdownSection, (section) {
      var markdown = section[0]!.replaceAllMapped(_href, (link) {
        final fixed = _fixLink(link[1]!, sourceDir, topics, topicsPrefix);
        if (fixed == link[1]) return link[0]!;
        fixedLinks++;
        return 'href="$fixed"';
      });
      if (removeHeading) markdown = markdown.replaceFirstMapped(_firstHeading, (heading) => heading[1]!);
      return markdown;
    });
    page.writeAsStringSync(html);
  }

  fixPage('$docsDir/index.html', '', 'topics/', removeHeading: false);
  topics.forEach((markdownPath, topic) {
    final sourceDir = markdownPath.contains('/') ? markdownPath.substring(0, markdownPath.lastIndexOf('/')) : '';
    fixPage('$docsDir/topics/$topic-topic.html', sourceDir, '', removeHeading: true);
  });
  stdout.writeln('Fixed $fixedLinks links in ${topics.length} topic pages and the index page.');
}

/// Returns the topic of each guide in `dartdoc_options.yaml`, keyed by the guide's path.
Map<String, String> _readTopics(File options) {
  final topic = RegExp(r'^    (\w+):\s*$');
  final markdown = RegExp(r'^      markdown:\s*(\S+)\s*$');
  final topics = <String, String>{};
  String? currentTopic;
  for (final line in options.readAsLinesSync()) {
    final topicMatch = topic.firstMatch(line);
    final markdownMatch = markdown.firstMatch(line);
    if (topicMatch != null) {
      currentTopic = topicMatch[1];
    } else if (markdownMatch != null && currentTopic != null) {
      topics[markdownMatch[1]!] = currentTopic;
    }
  }
  return topics;
}

/// Returns [href], from a markdown file in [sourceDir], as a link that works in the generated docs.
String _fixLink(String href, String sourceDir, Map<String, String> topics, String topicsPrefix) {
  if (href.isEmpty || href.startsWith('#') || href.startsWith('/') || href.contains(':')) return href;

  final fragmentIndex = href.indexOf('#');
  final path = fragmentIndex == -1 ? href : href.substring(0, fragmentIndex);
  final fragment = fragmentIndex == -1 ? '' : href.substring(fragmentIndex);
  final repositoryPath = Uri(path: sourceDir.isEmpty ? '/' : '/$sourceDir/').resolve(path).path.substring(1);

  final topic = topics[repositoryPath];
  if (topic != null) return '$topicsPrefix$topic-topic.html$fragment';

  return switch (FileSystemEntity.typeSync(repositoryPath)) {
    FileSystemEntityType.notFound => href,
    FileSystemEntityType.directory => '$_repositoryUrl/tree/$_branch/$repositoryPath$fragment',
    _ => '$_repositoryUrl/blob/$_branch/$repositoryPath$fragment',
  };
}
