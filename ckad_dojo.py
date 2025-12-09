#!/usr/bin/env python3
"""
CKAD-Dojo CLI - Centralized command-line interface for CKAD Exam Simulator.

This CLI unifies all exam operations (setup, exam, score, cleanup) into a single
entry point with both interactive menu and direct command-line access.
"""

import argparse
import os
import re
import shutil
import signal
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

__version__ = "1.1.0"

# =============================================================================
# Color Output Utilities (T004)
# =============================================================================

class Colors:
    """ANSI color codes for terminal output."""
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    YELLOW = "\033[1;33m"
    BLUE = "\033[0;34m"
    CYAN = "\033[0;36m"
    NC = "\033[0m"  # No Color
    BOLD = "\033[1m"


# Global flag for color output
_use_colors = True


def set_colors_enabled(enabled: bool) -> None:
    """Enable or disable colored output."""
    global _use_colors
    _use_colors = enabled


def color(text: str, color_code: str) -> str:
    """Apply color to text if colors are enabled."""
    if _use_colors:
        return f"{color_code}{text}{Colors.NC}"
    return text


def print_success(message: str) -> None:
    """Print success message in green."""
    print(f"  {color('[OK]', Colors.GREEN)} {message}")


def print_error(message: str) -> None:
    """Print error message in red."""
    print(f"  {color('[ERROR]', Colors.RED)} {message}", file=sys.stderr)


def print_warning(message: str) -> None:
    """Print warning message in yellow."""
    print(f"  {color('[WARN]', Colors.YELLOW)} {message}")


def print_info(message: str) -> None:
    """Print info message in blue."""
    print(f"  {color('[INFO]', Colors.BLUE)} {message}")


# =============================================================================
# Project Paths
# =============================================================================

def get_project_root() -> Path:
    """Get the project root directory."""
    return Path(__file__).parent.resolve()


def get_scripts_dir() -> Path:
    """Get the scripts directory."""
    return get_project_root() / "scripts"


def get_exams_dir() -> Path:
    """Get the exams directory."""
    return get_project_root() / "exams"


# =============================================================================
# ASCII Banner (T009)
# =============================================================================

BANNER = r"""
 ██████╗██╗  ██╗ █████╗ ██████╗        ██████╗  ██████╗      ██╗ ██████╗
██╔════╝██║ ██╔╝██╔══██╗██╔══██╗       ██╔══██╗██╔═══██╗     ██║██╔═══██╗
██║     █████╔╝ ███████║██║  ██║ ████╗ ██║  ██║██║   ██║     ██║██║   ██║
██║     ██╔═██╗ ██╔══██║██║  ██║ ╚═══╝ ██║  ██║██║   ██║██   ██║██║   ██║
╚██████╗██║  ██╗██║  ██║██████╔╝       ██████╔╝╚██████╔╝╚█████╔╝╚██████╔╝
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝        ╚═════╝  ╚═════╝  ╚════╝  ╚═════╝
"""


def show_banner() -> None:
    """Display the ASCII banner."""
    print(color(BANNER, Colors.CYAN))
    print(f"                    {color('CKAD Exam Simulator', Colors.GREEN)} - CLI v{__version__}")
    print()


def show_version() -> None:
    """Display version information with banner and CLI description."""
    show_banner()
    print(color("Description:", Colors.BOLD))
    print("  Unified CLI for CKAD (Certified Kubernetes Application Developer)")
    print("  exam simulation. Practice under realistic conditions with automated")
    print("  environment setup, real-time scoring, and a modern web interface.")
    print()
    print(color("Features:", Colors.BOLD))
    print("  - 4 exam simulations with 85+ questions")
    print("  - Automated Kubernetes environment setup")
    print("  - Real-time scoring with 400+ criteria")
    print("  - Web interface with 120-minute countdown timer")
    print("  - Interactive menu or direct CLI commands")
    print()
    print(color("Usage:", Colors.BOLD))
    print("  uv run ckad-dojo              # Interactive menu")
    print("  uv run ckad-dojo list         # List available exams")
    print("  uv run ckad-dojo exam start   # Start an exam")
    print("  uv run ckad-dojo --help       # Show all commands")
    print()


class VersionAction(argparse.Action):
    """Custom version action that displays banner and description."""

    def __init__(self, option_strings, dest=argparse.SUPPRESS, default=argparse.SUPPRESS, help="Show version and exit"):
        super().__init__(option_strings=option_strings, dest=dest, default=default, nargs=0, help=help)

    def __call__(self, parser, namespace, values, option_string=None):
        show_version()
        parser.exit()


# =============================================================================
# Exam Discovery (T005)
# =============================================================================

def discover_exams() -> List[str]:
    """Discover available exams in the exams/ directory."""
    exams_dir = get_exams_dir()
    if not exams_dir.exists():
        return []

    exams = []
    for item in sorted(exams_dir.iterdir()):
        if item.is_dir() and (item / "exam.conf").exists():
            exams.append(item.name)
    return exams


# =============================================================================
# Exam Config Parser (T006)
# =============================================================================

def parse_exam_config(exam_id: str) -> Optional[Dict[str, str]]:
    """Parse exam.conf file and return configuration as dictionary."""
    config_file = get_exams_dir() / exam_id / "exam.conf"
    if not config_file.exists():
        return None

    config = {}
    try:
        content = config_file.read_text()
        # Parse shell variable assignments
        for line in content.splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                # Handle simple KEY=value or KEY="value"
                match = re.match(r'^([A-Z_]+)=["\'"]?([^"\'"\n]*)["\'"]?', line)
                if match:
                    key, value = match.groups()
                    config[key] = value.strip('"\'')
    except Exception:
        return None

    return config


def get_exam_info(exam_id: str) -> Optional[Dict[str, str]]:
    """Get formatted exam information."""
    config = parse_exam_config(exam_id)
    if not config:
        return None

    return {
        "id": exam_id,
        "name": config.get("EXAM_NAME", exam_id),
        "questions": config.get("TOTAL_QUESTIONS", "?"),
        "points": config.get("TOTAL_POINTS", "?"),
        "duration": config.get("EXAM_DURATION", "120"),
        "passing": config.get("PASSING_PERCENTAGE", "66"),
    }


# =============================================================================
# Script Runner (T007)
# =============================================================================

def run_script(script_name: str, args: List[str] = None, capture: bool = False) -> Tuple[int, str, str]:
    """Run a bash script from the scripts directory."""
    script_path = get_scripts_dir() / script_name
    if not script_path.exists():
        return 1, "", f"Script not found: {script_path}"

    cmd = ["bash", str(script_path)]
    if args:
        cmd.extend(args)

    try:
        if capture:
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=get_project_root())
            return result.returncode, result.stdout, result.stderr
        else:
            result = subprocess.run(cmd, cwd=get_project_root())
            return result.returncode, "", ""
    except Exception as e:
        return 1, "", str(e)


# =============================================================================
# Prerequisite Checker (T008)
# =============================================================================

def check_command(cmd: str) -> bool:
    """Check if a command is available in PATH."""
    return shutil.which(cmd) is not None


def check_prerequisites(verbose: bool = True) -> bool:
    """Check all prerequisites are installed."""
    required = ["kubectl", "helm"]
    optional = ["docker", "podman"]

    all_ok = True

    for cmd in required:
        if check_command(cmd):
            if verbose:
                print_success(f"{cmd} is available")
        else:
            if verbose:
                print_error(f"{cmd} is NOT available (required)")
            all_ok = False

    # At least one container runtime
    has_container_runtime = False
    for cmd in optional:
        if check_command(cmd):
            has_container_runtime = True
            if verbose:
                print_success(f"{cmd} is available")
            break

    if not has_container_runtime and verbose:
        print_warning("No container runtime (docker/podman) found")

    return all_ok


def check_cluster_connectivity() -> bool:
    """Check if kubectl can connect to a cluster."""
    try:
        result = subprocess.run(
            ["kubectl", "cluster-info"],
            capture_output=True,
            text=True,
            timeout=10
        )
        return result.returncode == 0
    except Exception:
        return False


# =============================================================================
# Signal Handler (T010)
# =============================================================================

_cleanup_callback = None


def set_cleanup_callback(callback) -> None:
    """Set the cleanup callback for Ctrl+C handling."""
    global _cleanup_callback
    _cleanup_callback = callback


def signal_handler(signum, frame):
    """Handle Ctrl+C gracefully."""
    print()
    print_warning("Interrupted by user")

    if _cleanup_callback:
        response = input("Do you want to cleanup resources? (y/n): ").strip().lower()
        if response in ("y", "yes"):
            _cleanup_callback()

    sys.exit(130)


# =============================================================================
# Interactive Menu (T011-T017)
# =============================================================================

def show_menu() -> None:
    """Display the main menu."""
    print(color("=" * 50, Colors.CYAN))
    print(color("           CKAD-DOJO Main Menu", Colors.BOLD))
    print(color("=" * 50, Colors.CYAN))
    print()
    print("  1. Start Exam")
    print("  2. Score Exam")
    print("  3. Cleanup Environment")
    print("  4. List Exams")
    print("  5. View Exam Info")
    print("  6. Check Prerequisites")
    print()
    print("  q. Quit")
    print()


def select_exam(prompt: str = "Select an exam") -> Optional[str]:
    """Display exam selection menu and return selected exam ID."""
    exams = discover_exams()
    if not exams:
        print_error("No exams found in exams/ directory")
        return None

    print()
    print(f"{prompt}:")
    print()
    for i, exam in enumerate(exams, 1):
        info = get_exam_info(exam)
        if info:
            print(f"  {i}. {info['name']} ({info['questions']} questions, {info['points']} points)")
        else:
            print(f"  {i}. {exam}")
    print()
    print("  0. Cancel")
    print()

    while True:
        try:
            choice = input("Enter choice: ").strip()
            if choice == "0":
                return None
            idx = int(choice) - 1
            if 0 <= idx < len(exams):
                return exams[idx]
            print_error("Invalid selection")
        except ValueError:
            print_error("Please enter a number")


def menu_start_exam() -> None:
    """Handle 'Start Exam' menu option."""
    exam_id = select_exam("Select exam to start")
    if not exam_id:
        return

    print()
    print_info(f"Starting exam: {exam_id}")
    print()

    # Run setup first
    print_info("Setting up exam environment...")
    returncode, _, _ = run_script("ckad-setup.sh", ["-e", exam_id])
    if returncode != 0:
        print_error("Setup failed")
        return

    # Run exam
    print()
    print_info("Launching exam interface...")
    run_script("ckad-exam.sh", ["web", "-e", exam_id])


def menu_score_exam() -> None:
    """Handle 'Score Exam' menu option."""
    exam_id = select_exam("Select exam to score")
    if not exam_id:
        return

    print()
    print_info(f"Scoring exam: {exam_id}")
    print()
    run_script("ckad-score.sh", ["-e", exam_id])


def menu_cleanup() -> None:
    """Handle 'Cleanup' menu option."""
    exam_id = select_exam("Select exam to cleanup")
    if not exam_id:
        return

    print()
    print_info(f"Cleaning up: {exam_id}")
    print()
    run_script("ckad-cleanup.sh", ["-e", exam_id])


def menu_list_exams() -> None:
    """Handle 'List Exams' menu option."""
    print()
    cmd_list(None)


def menu_exam_info() -> None:
    """Handle 'View Exam Info' menu option."""
    exam_id = select_exam("Select exam to view info")
    if not exam_id:
        return

    print()
    # Create a simple namespace to pass exam_id
    class Args:
        exam = exam_id
    cmd_info(Args())


def menu_check_prereqs() -> None:
    """Handle 'Check Prerequisites' menu option."""
    print()
    print_info("Checking prerequisites...")
    print()
    check_prerequisites(verbose=True)

    print()
    print_info("Checking cluster connectivity...")
    if check_cluster_connectivity():
        print_success("Kubernetes cluster is accessible")
    else:
        print_error("Cannot connect to Kubernetes cluster")


def run_interactive_menu() -> None:
    """Run the interactive menu loop."""
    show_banner()

    while True:
        show_menu()
        choice = input("Enter choice: ").strip().lower()

        if choice == "1":
            menu_start_exam()
        elif choice == "2":
            menu_score_exam()
        elif choice == "3":
            menu_cleanup()
        elif choice == "4":
            menu_list_exams()
        elif choice == "5":
            menu_exam_info()
        elif choice == "6":
            menu_check_prereqs()
        elif choice in ("q", "quit", "exit"):
            print()
            print("Goodbye!")
            break
        else:
            print_error("Invalid choice")

        print()
        input("Press Enter to continue...")
        print()


# =============================================================================
# CLI Commands (T018-T030)
# =============================================================================

def cmd_exam_start(args) -> int:
    """Start an exam (setup + web interface)."""
    exam_id = args.exam
    if not exam_id:
        exam_id = select_exam("Select exam to start")
        if not exam_id:
            return 1

    # Validate exam exists
    if exam_id not in discover_exams():
        print_error(f"Exam not found: {exam_id}")
        return 1

    show_banner()
    print_info(f"Starting exam: {exam_id}")
    print()

    # Setup
    print_info("Setting up exam environment...")
    returncode, _, _ = run_script("ckad-setup.sh", ["-e", exam_id])
    if returncode != 0:
        print_error("Setup failed")
        return returncode

    # Start exam
    print()
    print_info("Launching exam interface...")
    returncode, _, _ = run_script("ckad-exam.sh", ["web", "-e", exam_id])
    return returncode


def cmd_exam_stop(args) -> int:
    """Stop current exam session."""
    print_info("Stopping exam session...")
    # The web interface handles its own cleanup when closed
    print_warning("Use Ctrl+C in the exam window or click 'Stop Exam' in the interface")
    return 0


def cmd_setup(args) -> int:
    """Setup exam environment only (no exam launch)."""
    exam_id = args.exam
    if not exam_id:
        exam_id = select_exam("Select exam to setup")
        if not exam_id:
            return 1

    if exam_id not in discover_exams():
        print_error(f"Exam not found: {exam_id}")
        return 1

    show_banner()
    print_info(f"Setting up exam: {exam_id}")
    print()

    returncode, _, _ = run_script("ckad-setup.sh", ["-e", exam_id])

    if returncode == 0:
        print()
        print_success("Setup complete!")
        print()
        print("Next steps:")
        print(f"  - Start exam: uv run ckad-dojo exam start -e {exam_id}")
        print(f"  - Or use kubectl directly to practice")

    return returncode


def cmd_score(args) -> int:
    """Score exam answers."""
    exam_id = args.exam
    if not exam_id:
        exam_id = select_exam("Select exam to score")
        if not exam_id:
            return 1

    if exam_id not in discover_exams():
        print_error(f"Exam not found: {exam_id}")
        return 1

    show_banner()
    print_info(f"Scoring exam: {exam_id}")
    print()

    returncode, _, _ = run_script("ckad-score.sh", ["-e", exam_id])
    return returncode


def cmd_cleanup(args) -> int:
    """Cleanup exam resources."""
    exam_id = args.exam
    if not exam_id:
        exam_id = select_exam("Select exam to cleanup")
        if not exam_id:
            return 1

    if exam_id not in discover_exams():
        print_error(f"Exam not found: {exam_id}")
        return 1

    show_banner()
    print_info(f"Cleaning up exam: {exam_id}")
    print()

    returncode, _, _ = run_script("ckad-cleanup.sh", ["-e", exam_id])
    return returncode


def cmd_list(args) -> int:
    """List available exams."""
    exams = discover_exams()

    if not exams:
        print_error("No exams found in exams/ directory")
        return 1

    # Table header
    print()
    print(f"{'Exam ID':<25} {'Name':<30} {'Questions':<10} {'Points':<8} {'Duration'}")
    print("-" * 90)

    for exam_id in exams:
        info = get_exam_info(exam_id)
        if info:
            print(f"{info['id']:<25} {info['name']:<30} {info['questions']:<10} {info['points']:<8} {info['duration']} min")
        else:
            print(f"{exam_id:<25} {'(config error)':<30}")

    print()
    return 0


def cmd_info(args) -> int:
    """Show detailed exam information."""
    exam_id = args.exam
    if not exam_id:
        exam_id = select_exam("Select exam to view info")
        if not exam_id:
            return 1

    config = parse_exam_config(exam_id)
    if not config:
        print_error(f"Cannot read config for exam: {exam_id}")
        return 1

    print()
    print(color(f"Exam: {config.get('EXAM_NAME', exam_id)}", Colors.BOLD))
    print("=" * 50)
    print()
    print(f"  ID:               {exam_id}")
    print(f"  Version:          {config.get('EXAM_VERSION', 'N/A')}")
    print(f"  Questions:        {config.get('TOTAL_QUESTIONS', 'N/A')}")
    print(f"  Preview Questions: {config.get('PREVIEW_QUESTIONS', 'N/A')}")
    print(f"  Total Points:     {config.get('TOTAL_POINTS', 'N/A')}")
    print(f"  Passing Score:    {config.get('PASSING_PERCENTAGE', '66')}%")
    print(f"  Duration:         {config.get('EXAM_DURATION', '120')} minutes")
    print()

    return 0


def cmd_status(args) -> int:
    """Show exam environment status."""
    exam_id = args.exam

    print()
    print(color("Exam Environment Status", Colors.BOLD))
    print("=" * 50)
    print()

    # Check cluster
    print_info("Checking cluster connectivity...")
    if check_cluster_connectivity():
        print_success("Kubernetes cluster is accessible")
    else:
        print_error("Cannot connect to Kubernetes cluster")
        return 1

    # Check namespaces for specific exam or all
    if exam_id:
        exams_to_check = [exam_id] if exam_id in discover_exams() else []
    else:
        exams_to_check = discover_exams()

    print()
    for eid in exams_to_check:
        config = parse_exam_config(eid)
        if not config:
            continue

        # Try to detect if namespaces exist
        try:
            result = subprocess.run(
                ["kubectl", "get", "namespaces", "-o", "name"],
                capture_output=True,
                text=True,
                timeout=10
            )
            existing_ns = set(result.stdout.strip().split("\n"))
            existing_ns = {ns.replace("namespace/", "") for ns in existing_ns}

            # Check first namespace from exam config
            exam_name = config.get("EXAM_NAME", eid)
            # Simple heuristic: check if common namespace exists
            has_resources = any(
                ns in existing_ns
                for ns in ["neptune", "saturn", "andromeda", "olympus", "athena"]
            )

            status = color("SETUP", Colors.GREEN) if has_resources else color("NOT SETUP", Colors.YELLOW)
            print(f"  {exam_name}: {status}")

        except Exception:
            print(f"  {eid}: {color('UNKNOWN', Colors.YELLOW)}")

    print()
    return 0


# =============================================================================
# Argument Parser (T018, T031-T033)
# =============================================================================

def create_parser() -> argparse.ArgumentParser:
    """Create the argument parser with all subcommands."""
    parser = argparse.ArgumentParser(
        prog="ckad-dojo",
        description="CKAD Exam Simulator - Centralized CLI for exam management",
        epilog="Run without arguments for interactive menu mode.",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument(
        "--version", "-V",
        action=VersionAction
    )

    parser.add_argument(
        "--no-color",
        action="store_true",
        help="Disable colored output"
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # exam command with subcommands
    exam_parser = subparsers.add_parser(
        "exam",
        help="Exam operations (start, stop)",
        description="Start or stop exam sessions"
    )
    exam_subparsers = exam_parser.add_subparsers(dest="exam_action", help="Exam actions")

    exam_start = exam_subparsers.add_parser("start", help="Start an exam session")
    exam_start.add_argument("-e", "--exam", help="Exam ID (e.g., ckad-simulation1)")

    exam_stop = exam_subparsers.add_parser("stop", help="Stop current exam session")

    # setup command
    setup_parser = subparsers.add_parser(
        "setup",
        help="Setup exam environment",
        description="Setup exam environment without starting the interface"
    )
    setup_parser.add_argument("-e", "--exam", help="Exam ID (e.g., ckad-simulation1)")

    # score command
    score_parser = subparsers.add_parser(
        "score",
        help="Score exam answers",
        description="Calculate and display exam score"
    )
    score_parser.add_argument("-e", "--exam", help="Exam ID (e.g., ckad-simulation1)")

    # cleanup command
    cleanup_parser = subparsers.add_parser(
        "cleanup",
        help="Cleanup exam resources",
        description="Remove all exam resources from the cluster"
    )
    cleanup_parser.add_argument("-e", "--exam", help="Exam ID (e.g., ckad-simulation1)")

    # list command
    subparsers.add_parser(
        "list",
        help="List available exams",
        description="Show all available exams with details"
    )

    # info command
    info_parser = subparsers.add_parser(
        "info",
        help="Show exam details",
        description="Display detailed information about an exam"
    )
    info_parser.add_argument("-e", "--exam", help="Exam ID (e.g., ckad-simulation1)")

    # status command
    status_parser = subparsers.add_parser(
        "status",
        help="Show environment status",
        description="Check cluster connectivity and exam resource status"
    )
    status_parser.add_argument("-e", "--exam", help="Exam ID to check (optional)")

    return parser


# =============================================================================
# Main Entry Point
# =============================================================================

def main() -> int:
    """Main entry point for the CLI."""
    # Setup signal handler
    signal.signal(signal.SIGINT, signal_handler)

    parser = create_parser()
    args = parser.parse_args()

    # Handle --no-color
    if args.no_color:
        set_colors_enabled(False)

    # Check for exams directory
    if not get_exams_dir().exists():
        print_error(f"Exams directory not found: {get_exams_dir()}")
        print_error("Make sure you're running from the ckad-dojo project root")
        return 1

    # Route to appropriate handler
    if args.command is None:
        # No command = interactive menu
        run_interactive_menu()
        return 0

    if args.command == "exam":
        if args.exam_action == "start":
            return cmd_exam_start(args)
        elif args.exam_action == "stop":
            return cmd_exam_stop(args)
        else:
            parser.parse_args(["exam", "--help"])
            return 1

    elif args.command == "setup":
        return cmd_setup(args)

    elif args.command == "score":
        return cmd_score(args)

    elif args.command == "cleanup":
        return cmd_cleanup(args)

    elif args.command == "list":
        return cmd_list(args)

    elif args.command == "info":
        return cmd_info(args)

    elif args.command == "status":
        return cmd_status(args)

    return 0


if __name__ == "__main__":
    sys.exit(main())
