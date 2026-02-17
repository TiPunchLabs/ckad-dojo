"""Shared fixtures for Python tests."""

from pathlib import Path

import pytest


@pytest.fixture
def tmp_exam_dir(tmp_path: Path) -> Path:
    """Create a temporary exam directory with a valid exam.conf."""
    exam_dir = tmp_path / "exams" / "ckad-simulation1"
    exam_dir.mkdir(parents=True)

    exam_conf = exam_dir / "exam.conf"
    exam_conf.write_text(
        'EXAM_NAME="CKAD Simulation 1"\n'
        'EXAM_ID="ckad-simulation1"\n'
        "EXAM_DURATION=120\n"
        "TOTAL_QUESTIONS=21\n"
        "PREVIEW_QUESTIONS=1\n"
        "TOTAL_POINTS=112\n"
        "PASSING_PERCENTAGE=66\n"
        'DOJO_NAME="Suzaku"\n'
        'DOJO_EMOJI="\U0001f525"\n'
        'EXAM_VERSION="1.0"\n'
        "ALLOW_TIMER_PAUSE=false\n"
    )

    return tmp_path


@pytest.fixture
def tmp_exam_with_questions(tmp_exam_dir: Path) -> Path:
    """Create a temporary exam directory with questions.md and solutions.md."""
    exam_dir = tmp_exam_dir / "exams" / "ckad-simulation1"

    questions_md = exam_dir / "questions.md"
    questions_md.write_text(
        "# CKAD Simulation 1\n\n"
        "## Question 1 | Namespaces\n\n"
        "| | |\n|---|---|\n"
        "| **Points** | 5/112 (4%) |\n"
        "| **Namespace** | `neptune` |\n\n"
        "Create a namespace called `neptune`.\n\n"
        "## Question 2 | Pods\n\n"
        "| | |\n|---|---|\n"
        "| **Points** | 3/112 (2%) |\n"
        "| **Namespace** | `default` |\n\n"
        "Create a pod called `nginx` with image `nginx:1.21`.\n"
    )

    solutions_md = exam_dir / "solutions.md"
    solutions_md.write_text(
        "# Solutions\n\n"
        "## Question 1 | Namespaces\n\n"
        "```bash\nkubectl create namespace neptune\n```\n\n"
        "## Question 2 | Pods\n\n"
        "```bash\nkubectl run nginx --image=nginx:1.21\n```\n"
    )

    return tmp_exam_dir
