"""Tests for ckad_dojo.py CLI module."""

from pathlib import Path
from unittest.mock import patch

import ckad_dojo


class TestColor:
    """Tests for color output utilities."""

    def test_color_enabled(self):
        ckad_dojo.set_colors_enabled(True)
        result = ckad_dojo.color("hello", ckad_dojo.Colors.RED)
        assert result == "\033[0;31mhello\033[0m"

    def test_color_disabled(self):
        ckad_dojo.set_colors_enabled(False)
        result = ckad_dojo.color("hello", ckad_dojo.Colors.RED)
        assert result == "hello"

    def teardown_method(self):
        ckad_dojo.set_colors_enabled(True)


class TestNormalizeExamId:
    """Tests for normalize_exam_id()."""

    def test_digit_shortcut(self):
        assert ckad_dojo.normalize_exam_id("1") == "ckad-simulation1"
        assert ckad_dojo.normalize_exam_id("5") == "ckad-simulation5"

    def test_full_id_unchanged(self):
        assert ckad_dojo.normalize_exam_id("ckad-simulation1") == "ckad-simulation1"

    def test_non_digit_unchanged(self):
        assert ckad_dojo.normalize_exam_id("custom-exam") == "custom-exam"

    def test_empty_string(self):
        assert ckad_dojo.normalize_exam_id("") == ""


class TestParseExamConfig:
    """Tests for parse_exam_config()."""

    def test_valid_config(self, tmp_exam_dir: Path):
        with patch.object(ckad_dojo, "get_exams_dir", return_value=tmp_exam_dir / "exams"):
            config = ckad_dojo.parse_exam_config("ckad-simulation1")

        assert config is not None
        assert config["EXAM_NAME"] == "CKAD Simulation 1"
        assert config["EXAM_DURATION"] == "120"
        assert config["TOTAL_QUESTIONS"] == "21"
        assert config["TOTAL_POINTS"] == "112"

    def test_nonexistent_exam(self, tmp_exam_dir: Path):
        with patch.object(ckad_dojo, "get_exams_dir", return_value=tmp_exam_dir / "exams"):
            config = ckad_dojo.parse_exam_config("nonexistent")

        assert config is None

    def test_config_with_quotes(self, tmp_path: Path):
        exam_dir = tmp_path / "exams" / "test-exam"
        exam_dir.mkdir(parents=True)
        (exam_dir / "exam.conf").write_text('EXAM_NAME="My Exam"\nTOTAL_QUESTIONS=10\n')

        with patch.object(ckad_dojo, "get_exams_dir", return_value=tmp_path / "exams"):
            config = ckad_dojo.parse_exam_config("test-exam")

        assert config is not None
        assert config["EXAM_NAME"] == "My Exam"


class TestGetExamInfo:
    """Tests for get_exam_info()."""

    def test_valid_exam(self, tmp_exam_dir: Path):
        with patch.object(ckad_dojo, "get_exams_dir", return_value=tmp_exam_dir / "exams"):
            info = ckad_dojo.get_exam_info("ckad-simulation1")

        assert info is not None
        assert info["id"] == "ckad-simulation1"
        assert info["name"] == "CKAD Simulation 1"
        assert info["dojo_name"] == "Suzaku"
        assert info["questions"] == "21"
        assert info["points"] == "112"
        assert info["duration"] == "120"
        assert info["passing"] == "66"

    def test_nonexistent_exam(self, tmp_exam_dir: Path):
        with patch.object(ckad_dojo, "get_exams_dir", return_value=tmp_exam_dir / "exams"):
            info = ckad_dojo.get_exam_info("nonexistent")

        assert info is None


class TestDiscoverExams:
    """Tests for discover_exams()."""

    def test_discovers_exams(self, tmp_exam_dir: Path):
        # Add a second exam
        exam2 = tmp_exam_dir / "exams" / "ckad-simulation2"
        exam2.mkdir()
        (exam2 / "exam.conf").write_text('EXAM_NAME="Sim 2"\n')

        with patch.object(ckad_dojo, "get_exams_dir", return_value=tmp_exam_dir / "exams"):
            exams = ckad_dojo.discover_exams()

        assert exams == ["ckad-simulation1", "ckad-simulation2"]

    def test_skips_dirs_without_config(self, tmp_exam_dir: Path):
        # Add a directory without exam.conf
        (tmp_exam_dir / "exams" / "not-an-exam").mkdir()

        with patch.object(ckad_dojo, "get_exams_dir", return_value=tmp_exam_dir / "exams"):
            exams = ckad_dojo.discover_exams()

        assert "not-an-exam" not in exams

    def test_empty_exams_dir(self, tmp_path: Path):
        exams_dir = tmp_path / "exams"
        exams_dir.mkdir()

        with patch.object(ckad_dojo, "get_exams_dir", return_value=exams_dir):
            exams = ckad_dojo.discover_exams()

        assert exams == []

    def test_missing_exams_dir(self, tmp_path: Path):
        with patch.object(ckad_dojo, "get_exams_dir", return_value=tmp_path / "nonexistent"):
            exams = ckad_dojo.discover_exams()

        assert exams == []


class TestCheckCommand:
    """Tests for check_command()."""

    def test_existing_command(self):
        assert ckad_dojo.check_command("python3") is True

    def test_nonexistent_command(self):
        assert ckad_dojo.check_command("nonexistent_command_xyz") is False


class TestCreateParser:
    """Tests for create_parser()."""

    def test_parser_creation(self):
        parser = ckad_dojo.create_parser()
        assert parser.prog == "ckad-dojo"

    def test_parse_list_command(self):
        parser = ckad_dojo.create_parser()
        args = parser.parse_args(["list"])
        assert args.command == "list"

    def test_parse_exam_start(self):
        parser = ckad_dojo.create_parser()
        args = parser.parse_args(["exam", "start", "-e", "ckad-simulation1"])
        assert args.command == "exam"
        assert args.exam_action == "start"
        assert args.exam == "ckad-simulation1"

    def test_parse_score(self):
        parser = ckad_dojo.create_parser()
        args = parser.parse_args(["score", "-e", "ckad-simulation2"])
        assert args.command == "score"
        assert args.exam == "ckad-simulation2"

    def test_parse_no_color(self):
        parser = ckad_dojo.create_parser()
        args = parser.parse_args(["--no-color", "list"])
        assert args.no_color is True

    def test_parse_completion(self):
        parser = ckad_dojo.create_parser()
        args = parser.parse_args(["completion", "bash"])
        assert args.command == "completion"
        assert args.shell == "bash"
