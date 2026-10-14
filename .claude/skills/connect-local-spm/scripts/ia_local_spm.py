#!/usr/bin/env python3
"""
Point the IA SDK Flutter plugin's Swift packages (main plugin + every module) at a
local IA-SDK-Dev-iOS checkout instead of the released IA-SDK-iOS binaries, so the
example app builds the native SDK from source. LOCAL ONLY - never commit the result.

    python3 ia_local_spm.py apply /abs/path/to/IA-SDK-Dev-iOS
    python3 ia_local_spm.py restore       # undo the patch + Package.resolved + Flutter noise
    python3 ia_local_spm.py status
    python3 ia_local_spm.py clean-noise   # revert only Flutter's analysis_options.yaml edits

The plugin repo defaults to the repo this script lives in; pass --repo <path> to override.
Every patched line carries MARKER, so `restore` undoes exactly our edits (byte-exact) and
leaves other local changes in those files alone. `apply` is idempotent.
"""
import argparse, glob, os, re, subprocess, sys

MARKER = "// IA_LOCAL_SPM"
REMOTE_PKG = "IA-SDK-iOS"
LOCAL_PKG = "IASDK"  # `name:` in IA-SDK-Dev-iOS/Package.swift
RESOLVED = [
    "example/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved",
    "example/ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved",
]
# What `flutter pub get` / `flutter build` (3.47+) appends to every analysis_options.yaml.
FLUTTER_ANALYZER_BLOCK = "analyzer:\n  exclude:\n    - build/**\n    - android/**\n    - ios/**"
DEFAULT_REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", ".."))


def git(repo, *args):
    return subprocess.run(["git", "-C", repo, *args], capture_output=True, text=True)


def manifests(repo):
    files = [os.path.join(repo, "ios/appsdk_v2_flutter_plugin/Package.swift")]
    files += sorted(glob.glob(os.path.join(repo, "modules/*/ios/*/Package.swift")))
    return [f for f in files if os.path.isfile(f)]


def target_path_fix(text, manifest):
    """SPM looks for Sources/<target name>; add `path:` when the folder is named differently."""
    sources = os.path.join(os.path.dirname(manifest), "Sources")
    for name in re.findall(r'\.target\(\s*name:\s*"([^"]+)"', text):
        if os.path.isdir(os.path.join(sources, name)):
            continue
        dirs = [d for d in os.listdir(sources) if os.path.isdir(os.path.join(sources, d))]
        if len(dirs) != 1:
            sys.exit(f"Cannot guess the source folder for target {name} in {manifest}: {dirs}")
        text = re.sub(
            r'(\.target\(\s*name:\s*"%s",\s*dependencies:\s*\[.*?\n(\s*)\],\n)' % re.escape(name),
            lambda m: f'{m.group(1)}{m.group(2)}path: "Sources/{dirs[0]}", {MARKER}\n',
            text, count=1, flags=re.S)
    return text


def restore_text(t):
    t = re.sub(r'^\s*\.package\(name: "%s".*%s was:(.*)$' % (LOCAL_PKG, MARKER),
               lambda m: m.group(1), t, flags=re.M)
    t = re.sub(r'^(.*)package: "%s"(.*?) %s$' % (LOCAL_PKG, MARKER),
               r'\1package: "%s"\2' % REMOTE_PKG, t, flags=re.M)
    t = re.sub(r'^\s*path: "Sources/[^"]*", %s\n' % MARKER, '', t, flags=re.M)
    return t


def apply(repo, sdk):
    sdk = os.path.abspath(os.path.expanduser(sdk)).rstrip("/")
    sdk_manifest = os.path.join(sdk, "Package.swift")
    if not os.path.isfile(sdk_manifest):
        sys.exit(f"No Package.swift in {sdk}")
    if f'name: "{LOCAL_PKG}"' not in open(sdk_manifest).read():
        sys.exit(f'{sdk_manifest} is not the IA SDK package (expected name: "{LOCAL_PKG}")')
    for f in manifests(repo):
        t = restore_text(open(f).read())  # start clean, so re-applying with a new path works
        t, n = re.subn(
            r'^((\s*)\.package\(url:\s*"[^"]*%s"[^)]*\),?)$' % REMOTE_PKG,
            lambda m: f'{m.group(2)}.package(name: "{LOCAL_PKG}", path: "{sdk}"), {MARKER} was:{m.group(1)}',
            t, flags=re.M)
        if n != 1:
            sys.exit(f"Expected one {REMOTE_PKG} dependency in {f}, found {n}")
        t = re.sub(r'^(.*)package: "%s"(.*)$' % REMOTE_PKG,
                   lambda m: f'{m.group(1)}package: "{LOCAL_PKG}"{m.group(2)} {MARKER}',
                   t, flags=re.M)
        open(f, "w").write(target_path_fix(t, f))
        print("patched ", os.path.relpath(f, repo))


def clean_noise(repo):
    changed = git(repo, "diff", "--name-only").stdout.split()
    for rel in [p for p in changed if os.path.basename(p) == "analysis_options.yaml"]:
        head = git(repo, "show", f"HEAD:{rel}").stdout.rstrip("\n")
        now = open(os.path.join(repo, rel)).read().rstrip("\n")
        if now == f"{head}\n{FLUTTER_ANALYZER_BLOCK}":
            git(repo, "checkout", "--", rel)
            print("reverted", rel, "(Flutter analyzer.exclude noise)")
        else:
            print("kept    ", rel, "(has changes other than Flutter's analyzer block)")


def restore(repo):
    for f in manifests(repo):
        t = open(f).read()
        if MARKER in t:
            open(f, "w").write(restore_text(t))
            print("restored", os.path.relpath(f, repo))
    for rel in RESOLVED:
        if git(repo, "diff", "--quiet", "--", rel).returncode:
            git(repo, "checkout", "--", rel)
            print("restored", rel)
    clean_noise(repo)


def status(repo):
    for f in manifests(repo):
        m = re.search(r'\.package\(name: "%s", path: "([^"]+)"\)' % LOCAL_PKG, open(f).read())
        print(f'{"LOCAL " + m.group(1) if m else "remote (released binaries)":64} {os.path.relpath(f, repo)}')


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("command", choices=["apply", "restore", "status", "clean-noise"])
    p.add_argument("sdk", nargs="?", help="IA-SDK-Dev-iOS path (apply only)")
    p.add_argument("--repo", default=DEFAULT_REPO, help="IA-SDK-Flutter repo root")
    a = p.parse_args()
    repo = os.path.abspath(a.repo)
    if a.command == "apply":
        if not a.sdk:
            p.error("apply needs the IA-SDK-Dev-iOS path")
        apply(repo, a.sdk)
    else:
        {"restore": restore, "status": status, "clean-noise": clean_noise}[a.command](repo)
