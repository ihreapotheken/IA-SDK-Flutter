#!/usr/bin/env dart

// generate_licenses.dart
// Flutter equivalent of Android's .generate-licenses.gradle.kts
// and iOS's generate-licenses.swift
//
// Parses pubspec.lock to enumerate pub.dev dependencies,
// reads LICENSE files from the pub cache, and generates licenses.html.
//
// Usage: dart run licenses/generate_licenses.dart [path/to/pubspec.lock] [output/licenses.html]

import 'dart:io';

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

/// Keywords in package names to skip (internal SDK packages).
const _skipKeywords = ['ihreapotheken'];

/// Exact package name prefixes to skip.
const _skipPrefixes = ['ia_', 'appsdk_v2'];

/// Exact package names to skip (SDK internals).
const _skipPackages = {'sky_engine'};

/// Common license file names to look for in the pub cache.
const _licenseFileNames = [
  'LICENSE',
  'LICENSE.md',
  'LICENSE.txt',
  'LICENCE',
  'LICENCE.md',
  'LICENCE.txt',
  'license',
  'license.md',
  'license.txt',
];

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class _PackageInfo {
  final String name;
  final String version;
  final String source;
  final String? url;
  final String dependency;

  _PackageInfo({
    required this.name,
    required this.version,
    required this.source,
    this.url,
    required this.dependency,
  });
}

// ---------------------------------------------------------------------------
// Parse pubspec.lock
// ---------------------------------------------------------------------------

List<_PackageInfo> _parsePubspecLock(String content) {
  final packages = <_PackageInfo>[];
  final lines = content.split('\n');

  String? currentPackage;
  String? source;
  String? version;
  String? dependency;
  String? hostedName;
  String? url;

  void saveCurrentPackage() {
    if (currentPackage != null && source != null && version != null) {
      packages.add(_PackageInfo(
        name: hostedName ?? currentPackage,
        version: version,
        source: source,
        url: url,
        dependency: dependency ?? 'transitive',
      ));
    }
  }

  for (final line in lines) {
    // Package name (2-space indent, word followed by colon)
    final packageMatch = RegExp(r'^  (\S+):$').firstMatch(line);
    if (packageMatch != null) {
      saveCurrentPackage();
      currentPackage = packageMatch.group(1);
      source = null;
      version = null;
      dependency = null;
      hostedName = null;
      url = null;
      continue;
    }

    if (currentPackage == null) continue;

    // dependency (4-space indent)
    final depMatch = RegExp(r'^    dependency: "?(.+?)"?$').firstMatch(line);
    if (depMatch != null) {
      dependency = depMatch.group(1);
      continue;
    }

    // source (4-space indent)
    final srcMatch = RegExp(r'^    source: (\S+)').firstMatch(line);
    if (srcMatch != null) {
      source = srcMatch.group(1)?.trim();
      continue;
    }

    // version (4-space indent)
    final verMatch = RegExp(r'^    version: "(.+)"').firstMatch(line);
    if (verMatch != null) {
      version = verMatch.group(1);
      continue;
    }

    // description > name (6-space indent)
    final nameMatch = RegExp(r'^      name: (\S+)').firstMatch(line);
    if (nameMatch != null) {
      hostedName = nameMatch.group(1)?.trim();
      continue;
    }

    // description > url (6-space indent)
    final urlMatch = RegExp(r'^      url: "?(.+?)"?$').firstMatch(line);
    if (urlMatch != null) {
      url = urlMatch.group(1);
      continue;
    }
  }

  // Save the last package
  saveCurrentPackage();

  return packages;
}

// ---------------------------------------------------------------------------
// Pub Cache
// ---------------------------------------------------------------------------

String? _findPubCachePath() {
  // 1. PUB_CACHE env var
  final envCache = Platform.environment['PUB_CACHE'];
  if (envCache != null && Directory(envCache).existsSync()) return envCache;

  // 2. Default location
  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  if (home == null) return null;

  final defaultPath = '$home/.pub-cache';
  if (Directory(defaultPath).existsSync()) return defaultPath;

  return null;
}

String? _loadLicenseFromCache(
  String pubCache,
  String name,
  String version,
) {
  final packageDir = Directory('$pubCache/hosted/pub.dev/$name-$version');
  if (!packageDir.existsSync()) return null;

  for (final filename in _licenseFileNames) {
    final file = File('${packageDir.path}/$filename');
    if (file.existsSync()) return file.readAsStringSync();
  }

  return null;
}

// ---------------------------------------------------------------------------
// HTML Helpers
// ---------------------------------------------------------------------------

String _escapeHtml(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

// ---------------------------------------------------------------------------
// Skip Logic
// ---------------------------------------------------------------------------

bool _shouldSkip(String name) {
  if (_skipPackages.contains(name)) return true;
  if (_skipPrefixes.any((p) => name.startsWith(p))) return true;
  if (_skipKeywords.any((kw) => name.contains(kw))) return true;
  return false;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main(List<String> args) {
  final scriptDir =
      File(Platform.script.toFilePath()).parent.path;

  // -- Resolve paths --

  final pubspecLockPath = args.isNotEmpty
      ? args[0]
      : '$scriptDir/../example/pubspec.lock';

  final outputPath =
      args.length > 1 ? args[1] : '$scriptDir/licenses.html';

  // -- Validate --

  final lockFile = File(pubspecLockPath);
  if (!lockFile.existsSync()) {
    stderr.writeln('Error: pubspec.lock not found at $pubspecLockPath');
    exit(1);
  }

  // -- Find pub cache --

  final pubCache = _findPubCachePath() ??
      (throw StateError('Pub cache not found. '
          'Run "flutter pub get" in the example app first.'));
  // -- Parse --

  final packages = _parsePubspecLock(lockFile.readAsStringSync());
  final hosted = packages
      .where((p) => p.source == 'hosted' && !_shouldSkip(p.name))
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  // -- Build entries --

  final entries = <String>[];
  final missing = <String>[];

  for (final pkg in hosted) {
    String? licenseText;

    // 1. Try pub cache
    licenseText = _loadLicenseFromCache(pubCache, pkg.name, pkg.version);

    // 2. Not found
    if (licenseText == null) {
      missing.add(pkg.name);

      final escaped = _escapeHtml(
        'License not found for: ${pkg.name}\n'
        'Please run "flutter pub get" in the example app to populate '
        'the pub cache.',
      );

      entries.add('''    <li>
        <strong>${_escapeHtml(pkg.name)} (${_escapeHtml(pkg.version)})</strong>
        <br><small>https://pub.dev/packages/${_escapeHtml(pkg.name)}</small>
        <pre>$escaped</pre>
    </li>''');
      continue;
    }

    final escaped = _escapeHtml(licenseText);
    final pubUrl = 'https://pub.dev/packages/${pkg.name}';

    entries.add('''    <li>
        <strong>${_escapeHtml(pkg.name)} (${_escapeHtml(pkg.version)})</strong>
        <br><small>${_escapeHtml(pubUrl)}</small>
        <pre>$escaped</pre>
    </li>''');
  }

  // -- Write HTML --

  final html = '''<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Open Source Licenses</title>
</head>
<body>
<h1>Open Source Licenses</h1>
<p>Third-party libraries used by IASDK for Flutter.</p>
<h2>Pub Dependencies</h2>
<ul>
${entries.join('\n')}
</ul>
</body>
</html>
''';

  File(outputPath).writeAsStringSync(html);

  // -- Summary --

  print('Generated: $outputPath');
  print('Pub dependencies: ${entries.length}');

  if (missing.isNotEmpty) {
    print('');
    print('Warning: ${missing.length} package(s) with missing LICENSE:');
    for (final pkg in missing) {
      print('  - $pkg');
    }
    print('Run "flutter pub get" in the example app to populate the pub cache.');
  }
}
