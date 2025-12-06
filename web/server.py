#!/usr/bin/env python3
"""
ckad-dojo - Web Server
Serves the exam interface and provides API endpoints
"""

import http.server
import json
import os
import re
import socketserver
import subprocess
import sys
import time
import urllib.parse
from pathlib import Path
from datetime import datetime, timedelta

# Configuration
PORT = 9090
HOST = "localhost"

# Paths
SCRIPT_DIR = Path(__file__).parent
PROJECT_DIR = SCRIPT_DIR.parent
EXAMS_DIR = PROJECT_DIR / "exams"

# Timer state (in-memory)
timer_state = {
    "start_time": None,
    "duration_minutes": 120,
    "exam_id": None,
    "exam_name": None,
    "running": False,
    "start_question": 1
}

# Question flags state (in-memory)
flagged_questions = set()

# Scripts directory
SCRIPTS_DIR = PROJECT_DIR / "scripts"


def run_scoring_script(exam_id: str = None) -> dict:
    """Run ckad-score.sh and parse the output"""
    script_path = SCRIPTS_DIR / "ckad-score.sh"

    if not script_path.exists():
        return {
            "success": False,
            "error": "Scoring script not found",
            "questions": [],
            "total_score": 0,
            "max_score": 0,
            "percentage": 0,
            "passed": False
        }

    try:
        cmd = [str(script_path)]
        if exam_id:
            cmd.extend(["-e", exam_id])

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=str(PROJECT_DIR),
            timeout=60
        )

        output = result.stdout
        questions = []
        total_score = 0
        max_score = 0

        # Parse question scores from output
        # Format: Q1       1/1          Namespaces
        question_pattern = r'^Q(\d+|P\d+)\s+(\d+)/(\d+)\s+(.+)$'

        for line in output.split('\n'):
            match = re.match(question_pattern, line.strip())
            if match:
                q_id = match.group(1)
                scored = int(match.group(2))
                possible = int(match.group(3))
                topic = match.group(4).strip()
                questions.append({
                    "id": q_id,
                    "score": scored,
                    "max_score": possible,
                    "topic": topic,
                    "passed": scored == possible
                })
                total_score += scored
                max_score += possible

        # Parse total score if available
        # Format: TOTAL SCORE: 87 / 113 (77%)
        total_pattern = r'TOTAL SCORE:\s*(\d+)\s*/\s*(\d+)\s*\((\d+)%\)'
        total_match = re.search(total_pattern, output)
        if total_match:
            total_score = int(total_match.group(1))
            max_score = int(total_match.group(2))
            percentage = int(total_match.group(3))
        else:
            percentage = int((total_score / max_score * 100) if max_score > 0 else 0)

        # Check pass/fail (66% threshold)
        passed = percentage >= 66

        return {
            "success": True,
            "questions": questions,
            "total_score": total_score,
            "max_score": max_score,
            "percentage": percentage,
            "passed": passed,
            "output": output
        }

    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "error": "Scoring script timed out",
            "questions": [],
            "total_score": 0,
            "max_score": 0,
            "percentage": 0,
            "passed": False
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "questions": [],
            "total_score": 0,
            "max_score": 0,
            "percentage": 0,
            "passed": False
        }


def parse_solutions_md(exam_id: str) -> list:
    """Parse solutions.md file and extract solutions"""
    solutions_file = EXAMS_DIR / exam_id / "solutions.md"

    if not solutions_file.exists():
        return []

    content = solutions_file.read_text(encoding="utf-8")
    solutions = []

    # Split by question headers (## Question N | Topic or ## Preview Question N | Topic)
    solution_pattern = r'^## (Question|Preview Question) (\d+|P\d+) \| (.+?)$'

    lines = content.split('\n')
    current_solution = None
    current_content = []

    for line in lines:
        match = re.match(solution_pattern, line)
        if match:
            # Save previous solution
            if current_solution:
                current_solution['content'] = '\n'.join(current_content).strip()
                solutions.append(current_solution)

            # Start new solution
            q_type = match.group(1)
            q_num = match.group(2)
            topic = match.group(3)

            # Normalize ID for preview questions
            if q_type == "Preview Question":
                q_id = f"P{q_num}" if not q_num.startswith('P') else q_num
            else:
                q_id = q_num

            current_solution = {
                'id': q_id,
                'number': int(q_num) if q_num.isdigit() else q_num,
                'topic': topic,
                'content': '',
                'is_preview': q_type == "Preview Question"
            }
            current_content = []
        elif current_solution:
            current_content.append(line)

    # Save last solution
    if current_solution:
        current_solution['content'] = '\n'.join(current_content).strip()
        solutions.append(current_solution)

    return solutions


def get_solution(exam_id: str, question_id: str) -> dict:
    """Get a specific solution by question ID"""
    solutions = parse_solutions_md(exam_id)
    for solution in solutions:
        if str(solution['id']) == str(question_id):
            return solution
    return None


def solutions_available(exam_id: str) -> bool:
    """Check if solutions file exists for an exam"""
    solutions_file = EXAMS_DIR / exam_id / "solutions.md"
    return solutions_file.exists()


def parse_questions_md(exam_id: str) -> list:
    """Parse questions.md file and extract questions"""
    questions_file = EXAMS_DIR / exam_id / "questions.md"

    if not questions_file.exists():
        return []

    content = questions_file.read_text(encoding="utf-8")
    questions = []

    # Split by question headers (## Question N | Topic)
    question_pattern = r'^## Question (\d+|P\d+) \| (.+?)$'

    # Find all question sections
    lines = content.split('\n')
    current_question = None
    current_content = []

    for line in lines:
        match = re.match(question_pattern, line)
        if match:
            # Save previous question
            if current_question:
                current_question['content'] = '\n'.join(current_content).strip()
                questions.append(current_question)

            # Start new question
            q_num = match.group(1)
            topic = match.group(2)
            current_question = {
                'id': q_num,
                'number': int(q_num) if q_num.isdigit() else q_num,
                'topic': topic,
                'content': '',
                'points': 0,
                'namespace': '',
                'resources': '',
                'files': ''
            }
            current_content = []
        elif current_question:
            # Parse metadata from table
            if line.startswith('| Points'):
                continue
            if line.startswith('|---'):
                continue
            if line.startswith('|') and not line.startswith('| Points'):
                parts = [p.strip() for p in line.split('|')[1:-1]]
                if len(parts) >= 4:
                    try:
                        current_question['points'] = int(parts[0])
                    except ValueError:
                        pass
                    current_question['namespace'] = parts[1]
                    current_question['resources'] = parts[2]
                    current_question['files'] = parts[3]
            else:
                current_content.append(line)

    # Save last question
    if current_question:
        current_question['content'] = '\n'.join(current_content).strip()
        questions.append(current_question)

    return questions


def load_exam_config(exam_id: str) -> dict:
    """Load exam configuration from exam.conf"""
    config_file = EXAMS_DIR / exam_id / "exam.conf"
    config = {
        "exam_name": exam_id,
        "exam_id": exam_id,
        "duration": 120,
        "warning_time": 15,
        "total_questions": 22,
        "total_points": 113,
        "passing_percentage": 66
    }

    if config_file.exists():
        content = config_file.read_text()
        # Parse bash-style config
        for line in content.split('\n'):
            line = line.strip()
            if line.startswith('#') or '=' not in line:
                continue
            key, value = line.split('=', 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")

            if key == "EXAM_NAME":
                config["exam_name"] = value
            elif key == "EXAM_DURATION":
                config["duration"] = int(value)
            elif key == "EXAM_WARNING_TIME":
                config["warning_time"] = int(value)
            elif key == "TOTAL_QUESTIONS":
                config["total_questions"] = int(value)
            elif key == "TOTAL_POINTS":
                config["total_points"] = int(value)
            elif key == "PASSING_PERCENTAGE":
                config["passing_percentage"] = int(value)

    return config


def list_exams() -> list:
    """List all available exams"""
    exams = []
    if EXAMS_DIR.exists():
        for exam_dir in EXAMS_DIR.iterdir():
            if exam_dir.is_dir() and (exam_dir / "exam.conf").exists():
                config = load_exam_config(exam_dir.name)
                exams.append({
                    "id": exam_dir.name,
                    "name": config["exam_name"],
                    "duration": config["duration"],
                    "questions": config["total_questions"],
                    "points": config["total_points"]
                })
    return exams


class ExamHandler(http.server.SimpleHTTPRequestHandler):
    """Custom HTTP handler for exam interface"""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(SCRIPT_DIR), **kwargs)

    def do_GET(self):
        """Handle GET requests"""
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        # API endpoints
        if path == "/api/exams":
            self.send_json(list_exams())
        elif path.startswith("/api/exam/") and path.endswith("/questions"):
            exam_id = path.split("/")[3]
            questions = parse_questions_md(exam_id)
            self.send_json(questions)
        elif path.startswith("/api/exam/") and path.endswith("/config"):
            exam_id = path.split("/")[3]
            config = load_exam_config(exam_id)
            self.send_json(config)
        elif path == "/api/timer":
            self.send_json(self.get_timer_state())
        elif path == "/api/flags":
            self.send_json(list(flagged_questions))
        elif path == "/api/terminal/status":
            # Check if terminal is disabled via environment
            no_terminal = os.environ.get("NO_TERMINAL", "false").lower() == "true"

            if no_terminal:
                self.send_json({
                    "enabled": False,
                    "running": False,
                    "port": 0,
                    "url": None
                })
            else:
                # Check if ttyd is running
                ttyd_port = int(os.environ.get("TTYD_PORT", "7681"))
                ttyd_running = self.check_ttyd_status(ttyd_port)
                self.send_json({
                    "enabled": True,
                    "running": ttyd_running,
                    "port": ttyd_port,
                    "url": f"http://localhost:{ttyd_port}"
                })
        elif path.startswith("/api/exam/") and "/solutions" in path:
            parts = path.split("/")
            exam_id = parts[3]
            if path.endswith("/solutions"):
                # Get all solutions for exam
                solutions = parse_solutions_md(exam_id)
                self.send_json({
                    "available": len(solutions) > 0,
                    "solutions": solutions
                })
            elif len(parts) >= 6:
                # Get specific solution: /api/exam/{id}/solutions/{question_id}
                question_id = parts[5]
                solution = get_solution(exam_id, question_id)
                if solution:
                    self.send_json(solution)
                else:
                    self.send_json({"error": "Solution not found", "available": False})
        else:
            # Serve static files
            if path == "/":
                self.path = "/index.html"
            super().do_GET()

    def do_POST(self):
        """Handle POST requests"""
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8') if content_length > 0 else '{}'

        try:
            data = json.loads(body) if body else {}
        except json.JSONDecodeError:
            data = {}

        if path == "/api/timer/start":
            exam_id = data.get("exam_id", "ckad-simulation1")
            config = load_exam_config(exam_id)
            timer_state["start_time"] = time.time()
            timer_state["duration_minutes"] = config["duration"]
            timer_state["exam_id"] = exam_id
            timer_state["exam_name"] = config["exam_name"]
            timer_state["running"] = True
            flagged_questions.clear()
            self.send_json({"status": "started", "timer": self.get_timer_state()})

        elif path == "/api/timer/stop":
            timer_state["running"] = False
            self.send_json({"status": "stopped"})

        elif path == "/api/flag":
            question_id = data.get("question_id")
            if question_id:
                if question_id in flagged_questions:
                    flagged_questions.remove(question_id)
                    self.send_json({"flagged": False})
                else:
                    flagged_questions.add(question_id)
                    self.send_json({"flagged": True})
            else:
                self.send_error(400, "Missing question_id")

        elif path == "/api/score":
            # Stop the timer
            timer_state["running"] = False

            # Run the scoring script
            exam_id = timer_state.get("exam_id") or data.get("exam_id")
            score_result = run_scoring_script(exam_id)

            # Add timer info to result
            if timer_state["start_time"]:
                elapsed = time.time() - timer_state["start_time"]
                score_result["elapsed_seconds"] = int(elapsed)
                score_result["elapsed_formatted"] = f"{int(elapsed // 60)}:{int(elapsed % 60):02d}"

            # Add solutions availability
            score_result["solutions_available"] = solutions_available(exam_id) if exam_id else False
            score_result["exam_id"] = exam_id

            self.send_json(score_result)

        else:
            self.send_error(404, "Not found")

    def get_timer_state(self) -> dict:
        """Get current timer state"""
        if not timer_state["running"] or timer_state["start_time"] is None:
            return {
                "running": False,
                "remaining_seconds": 0,
                "elapsed_seconds": 0,
                "total_seconds": timer_state["duration_minutes"] * 60,
                "exam_id": timer_state["exam_id"],
                "exam_name": timer_state["exam_name"],
                "start_question": timer_state.get("start_question", 1)
            }

        elapsed = time.time() - timer_state["start_time"]
        total = timer_state["duration_minutes"] * 60
        remaining = max(0, total - elapsed)

        if remaining <= 0:
            timer_state["running"] = False

        return {
            "running": timer_state["running"],
            "remaining_seconds": int(remaining),
            "elapsed_seconds": int(elapsed),
            "total_seconds": total,
            "exam_id": timer_state["exam_id"],
            "exam_name": timer_state["exam_name"],
            "start_question": timer_state.get("start_question", 1)
        }

    def check_ttyd_status(self, port: int) -> bool:
        """Check if ttyd is running on the specified port"""
        import socket
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1)
            result = sock.connect_ex(('localhost', port))
            sock.close()
            return result == 0
        except Exception:
            return False

    def send_json(self, data):
        """Send JSON response"""
        response = json.dumps(data, ensure_ascii=False)
        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Content-Length", len(response.encode('utf-8')))
        self.end_headers()
        self.wfile.write(response.encode('utf-8'))

    def log_message(self, format, *args):
        """Suppress default logging"""
        pass


def main():
    """Start the web server"""
    global PORT

    # Check for port argument
    if len(sys.argv) > 1:
        try:
            PORT = int(sys.argv[1])
        except ValueError:
            pass

    # Check for exam_id argument to auto-start timer
    exam_id = None
    if len(sys.argv) > 2:
        exam_id = sys.argv[2]

    # Check for start_question argument
    start_question = 1
    if len(sys.argv) > 3:
        try:
            start_question = int(sys.argv[3])
        except ValueError:
            start_question = 1

    # Allow port reuse to avoid "Address already in use" after restart
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer((HOST, PORT), ExamHandler) as httpd:
        print(f"\n{'='*60}")
        print(f"  ckad-dojo - CKAD Exam Simulator")
        print(f"{'='*60}")
        print(f"\n  Server running at: http://{HOST}:{PORT}")
        print(f"  Press Ctrl+C to stop\n")

        if exam_id:
            config = load_exam_config(exam_id)
            timer_state["start_time"] = time.time()
            timer_state["duration_minutes"] = config["duration"]
            timer_state["exam_id"] = exam_id
            timer_state["exam_name"] = config["exam_name"]
            timer_state["running"] = True
            timer_state["start_question"] = start_question
            print(f"  Exam started: {config['exam_name']}")
            print(f"  Duration: {config['duration']} minutes")
            print(f"  Starting at question: {start_question}\n")

        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n  Server stopped.\n")


if __name__ == "__main__":
    main()
