#!/usr/bin/env python3
"""
Version bump script for ckad-dojo.

Updates version in all relevant files, updates CHANGELOG, commits, and creates a git tag.

Usage:
    ./scripts/bump-version.py 1.7.0
    ./scripts/bump-version.py 1.7.0 --no-commit
    ./scripts/bump-version.py 1.7.0 --no-tag
"""

import argparse
import re
import subprocess
import sys
from datetime import date
from pathlib import Path

# Project root
PROJECT_ROOT = Path(__file__).parent.parent

# Files to update
FILES = {
    "pyproject.toml": r'version = "[^"]+"',
    "ckad_dojo.py": r'__version__ = "[^"]+"',
    "README.md": r"https://img\.shields\.io/badge/version-[^-]+-blue",
}


def get_current_version() -> str:
    """Get current version from pyproject.toml."""
    pyproject = PROJECT_ROOT / "pyproject.toml"
    content = pyproject.read_text()
    match = re.search(r'version = "([^"]+)"', content)
    if match:
        return match.group(1)
    raise ValueError("Could not find version in pyproject.toml")


def validate_version(version: str) -> bool:
    """Validate semantic version format."""
    pattern = r"^\d+\.\d+\.\d+(-[a-zA-Z0-9.]+)?$"
    return bool(re.match(pattern, version))


def update_file(filepath: Path, pattern: str, new_version: str) -> bool:
    """Update version in a file."""
    if not filepath.exists():
        print(f"  [WARN] File not found: {filepath}")
        return False

    content = filepath.read_text()

    # Build replacement based on file
    if filepath.name == "pyproject.toml":
        replacement = f'version = "{new_version}"'
    elif filepath.name == "ckad_dojo.py":
        replacement = f'__version__ = "{new_version}"'
    elif filepath.name == "README.md":
        replacement = f"https://img.shields.io/badge/version-{new_version}-blue"
    else:
        return False

    new_content, count = re.subn(pattern, replacement, content)

    if count == 0:
        print(f"  [WARN] Pattern not found in {filepath.name}")
        return False

    filepath.write_text(new_content)
    print(f"  [OK] Updated {filepath.name}")
    return True


def update_changelog(new_version: str) -> bool:
    """Update CHANGELOG.md - move Unreleased to new version."""
    changelog = PROJECT_ROOT / "CHANGELOG.md"
    if not changelog.exists():
        print("  [WARN] CHANGELOG.md not found")
        return False

    content = changelog.read_text()
    today = date.today().isoformat()

    # Check if version already exists
    if f"## [{new_version}]" in content:
        print(f"  [WARN] Version {new_version} already in CHANGELOG.md")
        return False

    # Check if Unreleased has content (non-empty subsections)
    unreleased_with_content = re.search(
        r"## \[Unreleased\]\n\n(### Added\n\n(?:- .+\n)*\n?)(### Changed\n\n(?:- .+\n)*\n?)(### Fixed\n\n(?:- .+\n)*\n?)(### Removed\n\n(?:- .+\n)*\n?)",
        content,
    )

    if unreleased_with_content:
        # There's content - create new version from Unreleased
        # Replace Unreleased header with new version header
        new_content = re.sub(
            r"## \[Unreleased\]",
            f"## [Unreleased]\n\n### Added\n\n### Changed\n\n### Fixed\n\n### Removed\n\n## [{new_version}] - {today}",
            content,
            count=1,
        )

        # Clean up the duplicated sections
        new_content = re.sub(
            r"(## \[Unreleased\])\n\n### Added\n\n### Changed\n\n### Fixed\n\n### Removed\n\n(## \[" + re.escape(new_version) + r"\] - " + today + r")\n\n### Added",
            r"\1\n\n### Added\n\n### Changed\n\n### Fixed\n\n### Removed\n\n\2\n\n### Added",
            new_content,
        )
    else:
        # Unreleased is empty - just add new version header
        new_content = content.replace(
            "## [Unreleased]",
            f"## [Unreleased]\n\n### Added\n\n### Changed\n\n### Fixed\n\n### Removed\n\n## [{new_version}] - {today}",
        )

    changelog.write_text(new_content)
    print(f"  [OK] Updated CHANGELOG.md with version {new_version}")
    return True


def git_commit(version: str) -> bool:
    """Create git commit for version bump."""
    try:
        # Stage files
        files_to_stage = ["pyproject.toml", "ckad_dojo.py", "README.md", "CHANGELOG.md"]
        for f in files_to_stage:
            filepath = PROJECT_ROOT / f
            if filepath.exists():
                subprocess.run(
                    ["git", "add", str(filepath)],
                    cwd=PROJECT_ROOT,
                    check=True,
                    capture_output=True,
                )

        # Commit
        commit_msg = f"chore: bump version to {version}"
        subprocess.run(
            ["git", "commit", "-m", commit_msg],
            cwd=PROJECT_ROOT,
            check=True,
            capture_output=True,
        )
        print(f"  [OK] Created commit: {commit_msg}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"  [ERROR] Git commit failed: {e.stderr.decode() if e.stderr else str(e)}")
        return False


def git_tag(version: str) -> bool:
    """Create git tag for version."""
    try:
        tag_name = f"v{version}"

        # Check if tag exists
        result = subprocess.run(
            ["git", "tag", "-l", tag_name],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
        )
        if tag_name in result.stdout:
            print(f"  [WARN] Tag {tag_name} already exists")
            return False

        # Create tag
        subprocess.run(
            ["git", "tag", "-a", tag_name, "-m", f"Release {version}"],
            cwd=PROJECT_ROOT,
            check=True,
            capture_output=True,
        )
        print(f"  [OK] Created tag: {tag_name}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"  [ERROR] Git tag failed: {e.stderr.decode() if e.stderr else str(e)}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Bump version in all project files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s 1.7.0                    # Full bump: update files, commit, tag
  %(prog)s 1.7.0 --no-commit        # Only update files
  %(prog)s 1.7.0 --no-tag           # Update files and commit, no tag
  %(prog)s --current                # Show current version
        """,
    )
    parser.add_argument("version", nargs="?", help="New version (e.g., 1.7.0)")
    parser.add_argument("--current", action="store_true", help="Show current version")
    parser.add_argument("--no-commit", action="store_true", help="Don't create git commit")
    parser.add_argument("--no-tag", action="store_true", help="Don't create git tag")
    parser.add_argument("--no-changelog", action="store_true", help="Don't update CHANGELOG.md")
    parser.add_argument("-y", "--yes", action="store_true", help="Skip confirmation")

    args = parser.parse_args()

    # Show current version
    if args.current:
        print(f"Current version: {get_current_version()}")
        return 0

    # Require version argument
    if not args.version:
        parser.print_help()
        return 1

    new_version = args.version

    # Validate version format
    if not validate_version(new_version):
        print(f"[ERROR] Invalid version format: {new_version}")
        print("        Expected: X.Y.Z or X.Y.Z-suffix")
        return 1

    current_version = get_current_version()
    print(f"\n{'=' * 50}")
    print(f"  Version Bump: {current_version} → {new_version}")
    print(f"{'=' * 50}\n")

    # Confirmation
    if not args.yes:
        print("This will:")
        print(f"  - Update version in: {', '.join(FILES.keys())}")
        if not args.no_changelog:
            print("  - Update CHANGELOG.md")
        if not args.no_commit:
            print("  - Create git commit")
        if not args.no_tag and not args.no_commit:
            print(f"  - Create git tag: v{new_version}")
        print()
        response = input("Proceed? (y/N): ").strip().lower()
        if response not in ("y", "yes"):
            print("Aborted.")
            return 1

    print("\n[1/4] Updating version files...")

    # Update version files
    success = True
    for filename, pattern in FILES.items():
        filepath = PROJECT_ROOT / filename
        if not update_file(filepath, pattern, new_version):
            success = False

    # Update CHANGELOG
    if not args.no_changelog:
        print("\n[2/4] Updating CHANGELOG...")
        if not update_changelog(new_version):
            print("  [SKIP] CHANGELOG update skipped")

    # Git commit
    if not args.no_commit:
        print("\n[3/4] Creating git commit...")
        if not git_commit(new_version):
            success = False

        # Git tag
        if not args.no_tag:
            print("\n[4/4] Creating git tag...")
            if not git_tag(new_version):
                success = False
    else:
        print("\n[3/4] Skipping git commit (--no-commit)")
        print("[4/4] Skipping git tag (--no-commit)")

    print(f"\n{'=' * 50}")
    if success:
        print(f"  Version bumped to {new_version}")
        if not args.no_commit and not args.no_tag:
            print(f"\n  To push: git push && git push origin v{new_version}")
    else:
        print("  Completed with warnings")
    print(f"{'=' * 50}\n")

    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
