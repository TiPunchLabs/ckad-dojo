"""Tests for scripts/bump-version.py module."""

import sys
from pathlib import Path
from unittest.mock import patch

import pytest

# Import the module from scripts directory
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))
import importlib

bump_version = importlib.import_module("bump-version")


class TestValidateVersion:
    """Tests for validate_version()."""

    def test_valid_semver(self):
        assert bump_version.validate_version("1.0.0") is True
        assert bump_version.validate_version("0.1.0") is True
        assert bump_version.validate_version("10.20.30") is True

    def test_valid_with_suffix(self):
        assert bump_version.validate_version("1.0.0-alpha") is True
        assert bump_version.validate_version("1.0.0-beta.1") is True
        assert bump_version.validate_version("2.0.0-rc1") is True

    def test_invalid_format(self):
        assert bump_version.validate_version("1.0") is False
        assert bump_version.validate_version("v1.0.0") is False
        assert bump_version.validate_version("abc") is False
        assert bump_version.validate_version("") is False

    def test_invalid_with_spaces(self):
        assert bump_version.validate_version("1.0.0 beta") is False


class TestGetCurrentVersion:
    """Tests for get_current_version()."""

    def test_reads_version(self, tmp_path: Path):
        pyproject = tmp_path / "pyproject.toml"
        pyproject.write_text('[project]\nversion = "1.7.0"\n')

        with patch.object(bump_version, "PROJECT_ROOT", tmp_path):
            version = bump_version.get_current_version()

        assert version == "1.7.0"

    def test_missing_version_raises(self, tmp_path: Path):
        pyproject = tmp_path / "pyproject.toml"
        pyproject.write_text("[project]\nname = 'test'\n")

        with (
            patch.object(bump_version, "PROJECT_ROOT", tmp_path),
            pytest.raises(ValueError, match="Could not find version"),
        ):
            bump_version.get_current_version()


class TestUpdateFile:
    """Tests for update_file()."""

    def test_updates_pyproject(self, tmp_path: Path):
        filepath = tmp_path / "pyproject.toml"
        filepath.write_text('version = "1.0.0"\n')

        result = bump_version.update_file(filepath, r'version = "[^"]+"', "2.0.0")

        assert result is True
        assert 'version = "2.0.0"' in filepath.read_text()

    def test_missing_file(self, tmp_path: Path):
        filepath = tmp_path / "nonexistent.toml"
        result = bump_version.update_file(filepath, r".*", "1.0.0")
        assert result is False

    def test_pattern_not_found(self, tmp_path: Path):
        filepath = tmp_path / "pyproject.toml"
        filepath.write_text("name = 'test'\n")

        result = bump_version.update_file(filepath, r'version = "[^"]+"', "1.0.0")
        assert result is False
