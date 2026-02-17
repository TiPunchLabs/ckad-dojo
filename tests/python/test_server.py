"""Tests for web/server.py module."""

import os
from pathlib import Path
from unittest.mock import patch

from web import server


class TestStripAnsiCodes:
    """Tests for strip_ansi_codes()."""

    def test_strips_color_codes(self):
        text = "\033[0;31mERROR\033[0m: something failed"
        assert server.strip_ansi_codes(text) == "ERROR: something failed"

    def test_plain_text_unchanged(self):
        assert server.strip_ansi_codes("hello world") == "hello world"

    def test_multiple_codes(self):
        text = "\033[1;33mWARN\033[0m and \033[0;32mOK\033[0m"
        assert server.strip_ansi_codes(text) == "WARN and OK"

    def test_empty_string(self):
        assert server.strip_ansi_codes("") == ""


class TestParseCriteriaFromOutput:
    """Tests for parse_criteria_from_output()."""

    def test_legacy_format_pass(self):
        output = (
            "Question 1 | Namespaces\n"
            "\u2713 Namespace neptune exists\n"
            "\u2713 Pod nginx is running\n"
            "2/2\n"
        )
        criteria = server.parse_criteria_from_output(output, "1")
        assert len(criteria) == 2
        assert criteria[0]["passed"] is True
        assert criteria[0]["description"] == "Namespace neptune exists"

    def test_legacy_format_fail(self):
        output = "Question 1 | Namespaces\n\u2717 Namespace neptune not found\n0/1\n"
        criteria = server.parse_criteria_from_output(output, "1")
        assert len(criteria) == 1
        assert criteria[0]["passed"] is False

    def test_legacy_format_mixed(self):
        output = "Question 2 | Pods\n\u2713 Pod exists\n\u2717 Image incorrect\n1/2\n"
        criteria = server.parse_criteria_from_output(output, "2")
        assert len(criteria) == 2
        assert criteria[0]["passed"] is True
        assert criteria[1]["passed"] is False

    def test_details_format(self):
        output = (
            "DETAILS:Namespace exists. Pod running. Image correct.\n"
            "DETAILS:Service created. Port incorrect.\n"
        )
        criteria = server.parse_criteria_from_output(output, "1")
        assert len(criteria) == 3
        assert criteria[0]["description"] == "Namespace exists"
        assert criteria[0]["passed"] is True

    def test_details_format_fail_keywords(self):
        output = "DETAILS:Pod not found. Image incorrect.\n"
        criteria = server.parse_criteria_from_output(output, "1")
        assert len(criteria) == 2
        assert criteria[0]["passed"] is False
        assert criteria[1]["passed"] is False

    def test_no_matching_question(self):
        output = "Question 1 | Namespaces\n\u2713 Namespace exists\n1/1\n"
        criteria = server.parse_criteria_from_output(output, "99")
        assert criteria == []


class TestLoadExamConfig:
    """Tests for load_exam_config()."""

    def test_valid_config(self, tmp_exam_dir: Path):
        with patch.object(server, "EXAMS_DIR", tmp_exam_dir / "exams"):
            config = server.load_exam_config("ckad-simulation1")

        assert config["exam_name"] == "CKAD Simulation 1"
        assert config["duration"] == 120
        assert config["total_questions"] == 21
        assert config["total_points"] == 112
        assert config["passing_percentage"] == 66
        assert config["allow_timer_pause"] is False

    def test_missing_config_uses_defaults(self, tmp_path: Path):
        with patch.object(server, "EXAMS_DIR", tmp_path / "exams"):
            config = server.load_exam_config("nonexistent")

        assert config["exam_name"] == "nonexistent"
        assert config["duration"] == 120

    def test_env_override_no_pause(self, tmp_exam_dir: Path):
        with (
            patch.object(server, "EXAMS_DIR", tmp_exam_dir / "exams"),
            patch.dict(os.environ, {"NO_PAUSE": "true"}),
        ):
            config = server.load_exam_config("ckad-simulation1")

        assert config["allow_timer_pause"] is False

    def test_env_override_no_hints(self, tmp_exam_dir: Path):
        with (
            patch.object(server, "EXAMS_DIR", tmp_exam_dir / "exams"),
            patch.dict(os.environ, {"NO_HINTS": "true"}),
        ):
            config = server.load_exam_config("ckad-simulation1")

        assert config["allow_hints"] is False


class TestParseSolutionsMd:
    """Tests for parse_solutions_md()."""

    def test_parses_solutions(self, tmp_exam_with_questions: Path):
        with patch.object(server, "EXAMS_DIR", tmp_exam_with_questions / "exams"):
            solutions = server.parse_solutions_md("ckad-simulation1")

        assert len(solutions) == 2
        assert solutions[0]["id"] == "1"
        assert solutions[0]["topic"] == "Namespaces"
        assert "kubectl create namespace" in str(solutions[0]["content"])

    def test_nonexistent_file(self, tmp_path: Path):
        with patch.object(server, "EXAMS_DIR", tmp_path / "exams"):
            solutions = server.parse_solutions_md("nonexistent")

        assert solutions == []


class TestGetSolution:
    """Tests for get_solution()."""

    def test_existing_solution(self, tmp_exam_with_questions: Path):
        with patch.object(server, "EXAMS_DIR", tmp_exam_with_questions / "exams"):
            solution = server.get_solution("ckad-simulation1", "1")

        assert solution is not None
        assert solution["topic"] == "Namespaces"

    def test_nonexistent_solution(self, tmp_exam_with_questions: Path):
        with patch.object(server, "EXAMS_DIR", tmp_exam_with_questions / "exams"):
            solution = server.get_solution("ckad-simulation1", "99")

        assert solution is None


class TestParseQuestionsMd:
    """Tests for parse_questions_md()."""

    def test_parses_questions(self, tmp_exam_with_questions: Path):
        with patch.object(server, "EXAMS_DIR", tmp_exam_with_questions / "exams"):
            questions = server.parse_questions_md("ckad-simulation1")

        assert len(questions) == 2
        assert questions[0]["id"] == "1"
        assert questions[0]["topic"] == "Namespaces"
        assert questions[0]["points"] == 5
        assert questions[0]["namespace"] == "neptune"

    def test_second_question(self, tmp_exam_with_questions: Path):
        with patch.object(server, "EXAMS_DIR", tmp_exam_with_questions / "exams"):
            questions = server.parse_questions_md("ckad-simulation1")

        assert questions[1]["id"] == "2"
        assert questions[1]["topic"] == "Pods"
        assert questions[1]["points"] == 3

    def test_nonexistent_file(self, tmp_path: Path):
        with patch.object(server, "EXAMS_DIR", tmp_path / "exams"):
            questions = server.parse_questions_md("nonexistent")

        assert questions == []


class TestSolutionsAvailable:
    """Tests for solutions_available()."""

    def test_available(self, tmp_exam_with_questions: Path):
        with patch.object(server, "EXAMS_DIR", tmp_exam_with_questions / "exams"):
            assert server.solutions_available("ckad-simulation1") is True

    def test_not_available(self, tmp_path: Path):
        with patch.object(server, "EXAMS_DIR", tmp_path / "exams"):
            assert server.solutions_available("nonexistent") is False


class TestListExams:
    """Tests for list_exams()."""

    def test_lists_exams(self, tmp_exam_dir: Path):
        with patch.object(server, "EXAMS_DIR", tmp_exam_dir / "exams"):
            exams = server.list_exams()

        assert len(exams) == 1
        assert exams[0]["id"] == "ckad-simulation1"
        assert exams[0]["name"] == "CKAD Simulation 1"
        assert exams[0]["duration"] == 120

    def test_empty_dir(self, tmp_path: Path):
        exams_dir = tmp_path / "exams"
        exams_dir.mkdir()
        with patch.object(server, "EXAMS_DIR", exams_dir):
            exams = server.list_exams()

        assert exams == []
