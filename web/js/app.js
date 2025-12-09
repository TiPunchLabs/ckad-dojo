/**
 * CKAD Exam Simulator - Main Application
 */

// ============================================================================
// State
// ============================================================================

const state = {
    currentExam: null,
    examConfig: null,
    questions: [],
    currentQuestionIndex: 0,
    flaggedQuestions: new Set(),
    timerInterval: null,
    timeRemaining: 0,
    timerPaused: false,
    examStarted: false,
    examEnded: false,
    // Solutions state
    solutions: [],
    scoreResult: null,
    currentSolutionIndex: 0,
    viewingSolutions: false,
    // Terminal state
    terminalEnabled: true,
    terminalPort: 7681,
    terminalConnected: false,
    splitRatio: 0.5  // 50% split by default
};

// ============================================================================
// API Functions
// ============================================================================

const api = {
    async getExams() {
        const response = await fetch('/api/exams');
        return response.json();
    },

    async getExamConfig(examId) {
        const response = await fetch(`/api/exam/${examId}/config`);
        return response.json();
    },

    async getQuestions(examId) {
        const response = await fetch(`/api/exam/${examId}/questions`);
        return response.json();
    },

    async getTimerState() {
        const response = await fetch('/api/timer');
        return response.json();
    },

    async startTimer(examId) {
        const response = await fetch('/api/timer/start', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ exam_id: examId })
        });
        return response.json();
    },

    async toggleFlag(questionId) {
        const response = await fetch('/api/flag', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ question_id: questionId })
        });
        return response.json();
    },

    async getScore() {
        const response = await fetch('/api/score', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        return response.json();
    },

    async getSolutions(examId) {
        const response = await fetch(`/api/exam/${examId}/solutions`);
        return response.json();
    },

    async getSolution(examId, questionId) {
        const response = await fetch(`/api/exam/${examId}/solutions/${questionId}`);
        return response.json();
    },

    async getTerminalStatus() {
        const response = await fetch('/api/terminal/status');
        return response.json();
    },

    async togglePause() {
        const response = await fetch('/api/timer/pause', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        });
        return response.json();
    },

    async cleanup() {
        const response = await fetch('/api/cleanup', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        });
        return response.json();
    },

    async shutdown() {
        const response = await fetch('/api/shutdown', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        });
        return response.json();
    }
};

// ============================================================================
// DOM Elements
// ============================================================================

const elements = {
    // Screens
    examSelection: document.getElementById('exam-selection'),
    examInterface: document.getElementById('exam-interface'),

    // Exam selection
    examList: document.getElementById('exam-list'),

    // Header
    examTitle: document.getElementById('exam-title'),
    timer: document.getElementById('timer'),
    timerDisplay: document.getElementById('timer-display'),
    progressText: document.getElementById('progress-text'),

    // Navigation
    btnPrev: document.getElementById('btn-prev'),
    btnNext: document.getElementById('btn-next'),
    btnNextFooter: document.getElementById('btn-next-footer'),
    questionSelect: document.getElementById('question-select'),
    questionDots: document.getElementById('question-dots'),

    // Question content
    metaPoints: document.getElementById('meta-points'),
    metaNamespace: document.getElementById('meta-namespace'),
    metaResources: document.getElementById('meta-resources'),
    metaFiles: document.getElementById('meta-files'),
    questionContent: document.getElementById('question-content'),

    // Flag
    btnFlag: document.getElementById('btn-flag'),
    btnFlaggedList: document.getElementById('btn-flagged-list'),
    flaggedCount: document.getElementById('flagged-count'),

    // Theme
    themeToggle: document.getElementById('theme-toggle'),
    themeToggleSelection: document.getElementById('theme-toggle-selection'),

    // Back button
    btnBack: document.getElementById('btn-back'),

    // Modals
    timesUpModal: document.getElementById('times-up-modal'),
    btnCloseModal: document.getElementById('btn-close-modal'),
    flaggedModal: document.getElementById('flagged-modal'),
    flaggedList: document.getElementById('flagged-list'),
    btnCloseFlagged: document.getElementById('btn-close-flagged'),

    // Score modal
    scoreModal: document.getElementById('score-modal'),
    scoreResultIcon: document.getElementById('score-result-icon'),
    scoreResultTitle: document.getElementById('score-result-title'),
    scorePercentage: document.getElementById('score-percentage'),
    scorePoints: document.getElementById('score-points'),
    scoreStatus: document.getElementById('score-status'),
    scoreElapsed: document.getElementById('score-elapsed'),
    scoreQuestionsList: document.getElementById('score-questions-list'),
    btnCloseScore: document.getElementById('btn-close-score'),
    btnBackToSelection: document.getElementById('btn-back-to-selection'),
    btnStopExam: document.getElementById('btn-stop-exam'),
    btnViewSolutions: document.getElementById('btn-view-solutions'),

    // Solutions view
    solutionsView: document.getElementById('solutions-view'),
    solutionTitle: document.getElementById('solution-title'),
    solutionStatus: document.getElementById('solution-status'),
    solutionContent: document.getElementById('solution-content'),
    solutionNav: document.getElementById('solution-nav'),
    btnPrevSolution: document.getElementById('btn-prev-solution'),
    btnNextSolution: document.getElementById('btn-next-solution'),
    btnBackToScore: document.getElementById('btn-back-to-score'),
    solutionSelect: document.getElementById('solution-select'),

    // Confirm Modal
    confirmModal: document.getElementById('confirm-modal'),
    btnConfirmCancel: document.getElementById('btn-confirm-cancel'),
    btnConfirmStop: document.getElementById('btn-confirm-stop'),

    // Pause Button
    btnPause: document.getElementById('btn-pause'),

    // Terminal
    splitContainer: document.querySelector('.split-container'),
    questionPanel: document.getElementById('question-panel'),
    terminalPanel: document.getElementById('terminal-panel'),
    terminalFrame: document.getElementById('terminal-frame'),
    terminalError: document.getElementById('terminal-error'),
    terminalErrorMessage: document.getElementById('terminal-error-message'),
    splitDivider: document.getElementById('split-divider'),
    btnReconnect: document.getElementById('btn-reconnect')
};

// ============================================================================
// Theme Management
// ============================================================================

function initTheme() {
    const savedTheme = localStorage.getItem('ckad-theme') || 'dark';
    document.documentElement.setAttribute('data-theme', savedTheme);
    updateHljsTheme(savedTheme);
}

function toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('ckad-theme', newTheme);
    updateHljsTheme(newTheme);
}

function updateHljsTheme(theme) {
    const hljsLink = document.getElementById('hljs-theme');
    if (theme === 'light') {
        hljsLink.href = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css';
    } else {
        hljsLink.href = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css';
    }
}

// ============================================================================
// Terminal Management
// ============================================================================

async function initTerminal() {
    // Check URL params for terminal settings
    const urlParams = new URLSearchParams(window.location.search);

    // Check if terminal is disabled via URL param
    if (urlParams.get('terminal') === 'false') {
        state.terminalEnabled = false;
    }

    // Get custom terminal port if specified
    const portParam = urlParams.get('terminal_port');
    if (portParam) {
        state.terminalPort = parseInt(portParam, 10);
    }

    // Load saved split ratio from localStorage
    const savedRatio = localStorage.getItem('ckad-split-ratio');
    if (savedRatio) {
        state.splitRatio = parseFloat(savedRatio);
    }

    // Check terminal status via API
    if (state.terminalEnabled) {
        try {
            const status = await api.getTerminalStatus();
            if (!status.enabled) {
                console.log('Terminal disabled via --no-terminal flag');
                state.terminalEnabled = false;
            } else if (status.running) {
                state.terminalPort = status.port;
            } else {
                console.log('Terminal not running, disabling terminal panel');
                state.terminalEnabled = false;
            }
        } catch (error) {
            console.error('Failed to check terminal status:', error);
            // Continue with terminal enabled, will show error if it fails
        }
    }

    // Apply terminal state
    updateTerminalVisibility();

    // Setup split divider drag
    initSplitDivider();

    // Setup reconnect button handler
    if (elements.btnReconnect) {
        elements.btnReconnect.addEventListener('click', reconnectTerminal);
    }
}

function updateTerminalVisibility() {
    if (!elements.terminalPanel || !elements.splitDivider || !elements.splitContainer) {
        return;
    }

    if (state.terminalEnabled) {
        elements.terminalPanel.classList.remove('hidden');
        elements.splitDivider.classList.remove('hidden');
        elements.splitContainer.classList.remove('no-terminal');

        // Apply saved split ratio
        applySplitRatio(state.splitRatio);

        // Load terminal iframe
        loadTerminalFrame();
    } else {
        elements.terminalPanel.classList.add('hidden');
        elements.splitDivider.classList.add('hidden');
        elements.splitContainer.classList.add('no-terminal');
    }
}

function loadTerminalFrame() {
    if (!elements.terminalFrame) return;

    const terminalUrl = `http://localhost:${state.terminalPort}`;
    elements.terminalFrame.src = terminalUrl;

    // Monitor iframe load
    elements.terminalFrame.onload = () => {
        state.terminalConnected = true;
        hideTerminalError();
    };

    elements.terminalFrame.onerror = () => {
        state.terminalConnected = false;
        showTerminalError('Failed to connect to terminal');
    };
}

function showTerminalError(message) {
    if (!elements.terminalError || !elements.terminalErrorMessage) return;

    elements.terminalErrorMessage.textContent = message;
    elements.terminalError.classList.remove('hidden');
}

function hideTerminalError() {
    if (!elements.terminalError) return;
    elements.terminalError.classList.add('hidden');
}

function reconnectTerminal() {
    hideTerminalError();
    loadTerminalFrame();
}

function applySplitRatio(ratio) {
    if (!elements.questionPanel || !elements.terminalPanel) return;

    // Clamp ratio between 0.2 and 0.8 (20% to 80%)
    ratio = Math.max(0.2, Math.min(0.8, ratio));
    state.splitRatio = ratio;

    elements.questionPanel.style.flex = `${ratio}`;
    elements.terminalPanel.style.flex = `${1 - ratio}`;
}

function saveSplitRatio() {
    localStorage.setItem('ckad-split-ratio', state.splitRatio.toString());
}

// Split divider drag handling
let isDragging = false;

function initSplitDivider() {
    if (!elements.splitDivider || !elements.splitContainer) return;

    elements.splitDivider.addEventListener('mousedown', startDrag);
    document.addEventListener('mousemove', onDrag);
    document.addEventListener('mouseup', stopDrag);

    // Touch support
    elements.splitDivider.addEventListener('touchstart', startDrag, { passive: false });
    document.addEventListener('touchmove', onDrag, { passive: false });
    document.addEventListener('touchend', stopDrag);
}

function startDrag(e) {
    if (!state.terminalEnabled) return;

    isDragging = true;
    elements.splitDivider.classList.add('dragging');
    document.body.style.cursor = 'col-resize';
    document.body.style.userSelect = 'none';

    e.preventDefault();
}

function onDrag(e) {
    if (!isDragging) return;

    const container = elements.splitContainer;
    const rect = container.getBoundingClientRect();

    // Get X position from mouse or touch
    const clientX = e.touches ? e.touches[0].clientX : e.clientX;

    // Calculate ratio
    const ratio = (clientX - rect.left) / rect.width;

    // Apply ratio with constraints
    applySplitRatio(ratio);

    e.preventDefault();
}

function stopDrag() {
    if (!isDragging) return;

    isDragging = false;
    elements.splitDivider.classList.remove('dragging');
    document.body.style.cursor = '';
    document.body.style.userSelect = '';

    // Save preference
    saveSplitRatio();
}

// ============================================================================
// Exam Selection
// ============================================================================

async function loadExamList() {
    try {
        const exams = await api.getExams();
        renderExamList(exams);
    } catch (error) {
        console.error('Failed to load exams:', error);
        elements.examList.innerHTML = '<p class="error">Failed to load exams. Please check the server.</p>';
    }
}

function renderExamList(exams) {
    elements.examList.innerHTML = exams.map(exam => `
        <div class="exam-card" data-exam-id="${exam.id}">
            <h3>${exam.name}</h3>
            <div class="exam-card-info">
                <span>&#9202; ${exam.duration} min</span>
                <span>&#9733; ${exam.points} pts</span>
                <span>&#9776; ${exam.questions} questions</span>
            </div>
        </div>
    `).join('');

    // Add click handlers
    document.querySelectorAll('.exam-card').forEach(card => {
        card.addEventListener('click', () => {
            const examId = card.dataset.examId;
            startExam(examId);
        });
    });
}

// ============================================================================
// Exam Start
// ============================================================================

async function startExam(examId) {
    try {
        // Load exam config and questions
        const [config, questions] = await Promise.all([
            api.getExamConfig(examId),
            api.getQuestions(examId)
        ]);

        state.currentExam = examId;
        state.examConfig = config;
        state.questions = questions;
        state.currentQuestionIndex = 0;
        state.flaggedQuestions.clear();
        state.examStarted = true;
        state.examEnded = false;

        // Start timer
        await api.startTimer(examId);

        // Switch to exam interface
        elements.examSelection.classList.add('hidden');
        elements.examInterface.classList.remove('hidden');

        // Set exam title
        elements.examTitle.textContent = config.exam_name;

        // Render question navigation
        renderQuestionSelect();
        renderQuestionDots();

        // Show first question
        showQuestion(0);

        // Start timer updates
        startTimerUpdates();

    } catch (error) {
        console.error('Failed to start exam:', error);
        alert('Failed to start exam. Please check the server.');
    }
}

// ============================================================================
// Timer
// ============================================================================

function startTimerUpdates() {
    // Clear any existing interval
    if (state.timerInterval) {
        clearInterval(state.timerInterval);
    }

    // Update immediately
    updateTimer();

    // Then update every second
    state.timerInterval = setInterval(updateTimer, 1000);
}

async function updateTimer() {
    try {
        const timerState = await api.getTimerState();
        state.timeRemaining = timerState.remaining_seconds;

        // Sync paused state from server
        if (timerState.paused !== state.timerPaused) {
            state.timerPaused = timerState.paused;
            updatePauseUI();
        }

        // Format time
        const minutes = Math.floor(state.timeRemaining / 60);
        const seconds = state.timeRemaining % 60;
        const timeStr = `${minutes}:${seconds.toString().padStart(2, '0')}`;
        elements.timerDisplay.textContent = timeStr;

        // Update timer color based on remaining time
        elements.timer.classList.remove('warning', 'danger');

        if (state.timeRemaining <= 60) {
            elements.timer.classList.add('danger');
        } else if (state.timeRemaining <= 5 * 60) {
            elements.timer.classList.add('danger');
        } else if (state.timeRemaining <= 15 * 60) {
            elements.timer.classList.add('warning');
        }

        // Check if time's up
        if (!timerState.running && state.examStarted && !state.examEnded && !timerState.paused) {
            endExam();
        }

    } catch (error) {
        console.error('Failed to update timer:', error);
    }
}

function updatePauseUI() {
    if (elements.btnPause) {
        elements.btnPause.classList.toggle('paused', state.timerPaused);
        elements.btnPause.title = state.timerPaused ? 'Resume timer' : 'Pause timer';
        // Toggle pause/resume icons
        const pauseIcon = elements.btnPause.querySelector('.pause-icon');
        const resumeIcon = elements.btnPause.querySelector('.resume-icon');
        if (pauseIcon && resumeIcon) {
            pauseIcon.classList.toggle('hidden', state.timerPaused);
            resumeIcon.classList.toggle('hidden', !state.timerPaused);
        }
    }
    if (elements.timer) {
        elements.timer.classList.toggle('paused', state.timerPaused);
    }
}

function endExam() {
    state.examEnded = true;
    if (state.timerInterval) {
        clearInterval(state.timerInterval);
    }
    elements.timesUpModal.classList.remove('hidden');
}

// ============================================================================
// Stop Exam and Scoring
// ============================================================================

// Show confirm modal
function showConfirmModal() {
    elements.confirmModal.classList.remove('hidden');
}

// Hide confirm modal
function hideConfirmModal() {
    elements.confirmModal.classList.add('hidden');
}

// Handle confirm stop
async function confirmStopExam() {
    hideConfirmModal();
    await executeStopExam();
}

async function stopExam() {
    // Show custom confirm modal instead of browser confirm
    showConfirmModal();
}

async function executeStopExam() {
    // Stop timer
    state.examEnded = true;
    if (state.timerInterval) {
        clearInterval(state.timerInterval);
    }

    // Show modal with loading state
    elements.scoreModal.classList.remove('hidden');
    elements.scoreResultIcon.textContent = '⏳';
    elements.scoreResultTitle.textContent = 'Calculating Score...';
    elements.scoreStatus.textContent = 'Please wait...';
    elements.scoreStatus.className = 'score-status';
    elements.scorePercentage.textContent = '--';
    elements.scorePoints.textContent = '-- / --';
    elements.scoreElapsed.textContent = '--:--';
    elements.scoreQuestionsList.innerHTML = '<div class="loading">Scoring in progress...</div>';

    try {
        const result = await api.getScore();

        if (result.success) {
            // Save score result for solutions view
            state.scoreResult = result;

            // Update percentage with animation
            elements.scorePercentage.textContent = result.percentage;
            elements.scorePoints.textContent = `${result.total_score} / ${result.max_score}`;

            // Update elapsed time
            if (result.elapsed_formatted) {
                elements.scoreElapsed.textContent = result.elapsed_formatted;
            }

            // Update status and icon based on pass/fail
            if (result.passed) {
                elements.scoreResultIcon.textContent = '🎉';
                elements.scoreResultTitle.textContent = 'Congratulations!';
                elements.scoreStatus.textContent = 'PASSED';
                elements.scoreStatus.className = 'score-status passed';
            } else {
                elements.scoreResultIcon.textContent = '📚';
                elements.scoreResultTitle.textContent = 'Keep Practicing!';
                elements.scoreStatus.textContent = 'NOT PASSED';
                elements.scoreStatus.className = 'score-status failed';
            }

            // Show/hide View Solutions button
            if (elements.btnViewSolutions) {
                if (result.solutions_available) {
                    elements.btnViewSolutions.classList.remove('hidden');
                } else {
                    elements.btnViewSolutions.classList.add('hidden');
                }
            }

            // Render question scores
            renderQuestionScores(result.questions);

        } else {
            elements.scoreResultIcon.textContent = '❌';
            elements.scoreResultTitle.textContent = 'Scoring Error';
            elements.scoreStatus.textContent = result.error || 'Failed to calculate score';
            elements.scoreStatus.className = 'score-status failed';
            elements.scoreQuestionsList.innerHTML = `
                <div class="score-error">
                    <p>Could not calculate score.</p>
                    <p>Run <code>./scripts/ckad-score.sh</code> manually in your terminal.</p>
                </div>
            `;
        }

    } catch (error) {
        console.error('Failed to get score:', error);
        elements.scoreResultIcon.textContent = '❌';
        elements.scoreResultTitle.textContent = 'Error';
        elements.scoreStatus.textContent = 'Failed to connect to server';
        elements.scoreStatus.className = 'score-status failed';
    }
}

function renderQuestionScores(questions) {
    if (!questions || questions.length === 0) {
        elements.scoreQuestionsList.innerHTML = '<div class="score-error">No scoring data available</div>';
        return;
    }

    elements.scoreQuestionsList.innerHTML = questions.map(q => `
        <div class="score-question-item ${q.passed ? 'passed' : 'failed'}">
            <span class="score-q-id">Q${q.id}</span>
            <span class="score-q-topic">${q.topic}</span>
            <span class="score-q-points">${q.score}/${q.max_score}</span>
            <span class="score-q-status">${q.passed ? '✓' : '✗'}</span>
        </div>
    `).join('');
}

// ============================================================================
// Pause Timer
// ============================================================================

async function togglePause() {
    try {
        const result = await api.togglePause();

        if (!result.error) {
            state.timerPaused = result.paused;

            // Update UI
            if (elements.btnPause) {
                elements.btnPause.classList.toggle('paused', state.timerPaused);
                // Toggle pause/resume icons
                const pauseIcon = elements.btnPause.querySelector('.pause-icon');
                const resumeIcon = elements.btnPause.querySelector('.resume-icon');
                if (pauseIcon && resumeIcon) {
                    pauseIcon.classList.toggle('hidden', state.timerPaused);
                    resumeIcon.classList.toggle('hidden', !state.timerPaused);
                }
            }
            if (elements.timer) {
                elements.timer.classList.toggle('paused', state.timerPaused);
            }

            // Update button title
            if (elements.btnPause) {
                elements.btnPause.title = state.timerPaused ? 'Resume timer' : 'Pause timer';
            }
        }
    } catch (error) {
        console.error('Failed to toggle pause:', error);
    }
}

// ============================================================================
// Cleanup and Shutdown
// ============================================================================

async function cleanupAndGoBack() {
    // Show cleanup loader in score modal
    const scoreContainer = elements.scoreModal.querySelector('.modal-content');
    const originalContent = scoreContainer.innerHTML;

    scoreContainer.innerHTML = `
        <div class="cleanup-loader">
            <div class="spinner"></div>
            <div class="cleanup-message">Cleaning up exam resources...</div>
            <div class="cleanup-status">Please wait</div>
        </div>
    `;

    const statusEl = scoreContainer.querySelector('.cleanup-status');
    const messageEl = scoreContainer.querySelector('.cleanup-message');

    try {
        // Call cleanup endpoint
        statusEl.textContent = 'Running ckad-cleanup.sh...';
        const result = await api.cleanup();

        if (result.success) {
            messageEl.textContent = 'Cleanup complete!';
            statusEl.textContent = 'Returning to exam selection...';

            // Short delay to show message
            await new Promise(resolve => setTimeout(resolve, 800));

            // Hide modal and go back to selection
            elements.scoreModal.classList.add('hidden');
            backToSelection();
        } else {
            // Restore original content on error
            scoreContainer.innerHTML = originalContent;
            const statusElement = scoreContainer.querySelector('.score-status');
            if (statusElement) {
                statusElement.textContent = 'Cleanup failed: ' + (result.error || 'Unknown error');
                statusElement.className = 'score-status failed';
            }
        }
    } catch (error) {
        console.error('Cleanup failed:', error);
        // Restore original content on error
        scoreContainer.innerHTML = originalContent;
        const statusElement = scoreContainer.querySelector('.score-status');
        if (statusElement) {
            statusElement.textContent = 'Failed to cleanup';
            statusElement.className = 'score-status failed';
        }
    }
}

async function closeExamAndCleanup() {
    // Hide score details and show cleanup loader
    const scoreContainer = elements.scoreModal.querySelector('.modal-content');
    const originalContent = scoreContainer.innerHTML;

    scoreContainer.innerHTML = `
        <div class="cleanup-loader">
            <div class="spinner"></div>
            <div class="cleanup-message">Cleaning up exam resources...</div>
            <div class="cleanup-status">Please wait</div>
        </div>
    `;

    const statusEl = scoreContainer.querySelector('.cleanup-status');
    const messageEl = scoreContainer.querySelector('.cleanup-message');

    try {
        // Call cleanup endpoint
        statusEl.textContent = 'Running ckad-cleanup.sh...';
        const result = await api.cleanup();

        if (result.success) {
            messageEl.textContent = 'Cleanup complete!';
            statusEl.textContent = 'Shutting down server...';

            // Short delay to show message
            await new Promise(resolve => setTimeout(resolve, 800));

            // Call shutdown endpoint
            try {
                await api.shutdown();
            } catch (e) {
                // Expected - server stops so request may fail
            }

            // Show final message
            elements.scoreModal.classList.add('hidden');
            document.body.innerHTML = `
                <div style="display: flex; align-items: center; justify-content: center; height: 100vh; background: var(--bg-primary); color: var(--text-primary); font-family: system-ui;">
                    <div style="text-align: center;">
                        <h1 style="margin-bottom: 1rem;">Exam Ended</h1>
                        <p style="color: var(--text-secondary);">You can close this browser tab.</p>
                    </div>
                </div>
            `;
        } else {
            // Restore original content on error
            scoreContainer.innerHTML = originalContent;
            elements.scoreStatus.textContent = 'Cleanup failed: ' + (result.error || 'Unknown error');
            elements.scoreStatus.className = 'score-status failed';
        }
    } catch (error) {
        console.error('Cleanup failed:', error);
        // Restore original content on error
        scoreContainer.innerHTML = originalContent;
        elements.scoreStatus.textContent = 'Failed to cleanup';
        elements.scoreStatus.className = 'score-status failed';
    }
}

// ============================================================================
// Solutions View
// ============================================================================

async function showSolutions() {
    if (!state.currentExam) return;

    try {
        // Fetch solutions
        const result = await api.getSolutions(state.currentExam);

        if (!result.available || !result.solutions || result.solutions.length === 0) {
            alert('Solutions are not available for this exam yet.');
            return;
        }

        state.solutions = result.solutions;
        state.currentSolutionIndex = 0;
        state.viewingSolutions = true;

        // Hide score modal, show solutions view
        elements.scoreModal.classList.add('hidden');
        elements.solutionsView.classList.remove('hidden');

        // Render solution select dropdown
        renderSolutionSelect();

        // Show first solution
        showSolution(0);

    } catch (error) {
        console.error('Failed to load solutions:', error);
        alert('Failed to load solutions. Please try again.');
    }
}

function renderSolutionSelect() {
    if (!elements.solutionSelect) return;

    elements.solutionSelect.innerHTML = state.solutions.map((s, index) => {
        const scoreInfo = state.scoreResult?.questions?.find(q => String(q.id) === String(s.id));
        const status = scoreInfo ? (scoreInfo.passed ? '✓' : '✗') : '';
        return `<option value="${index}">${status} Q${s.id} | ${s.topic}</option>`;
    }).join('');
}

function showSolution(index) {
    if (index < 0 || index >= state.solutions.length) return;

    state.currentSolutionIndex = index;
    const solution = state.solutions[index];

    // Update select
    if (elements.solutionSelect) {
        elements.solutionSelect.value = index;
    }

    // Update title
    if (elements.solutionTitle) {
        elements.solutionTitle.textContent = `Question ${solution.id} | ${solution.topic}`;
    }

    // Update status (pass/fail)
    if (elements.solutionStatus && state.scoreResult) {
        const scoreInfo = state.scoreResult.questions?.find(q => String(q.id) === String(solution.id));
        if (scoreInfo) {
            elements.solutionStatus.textContent = scoreInfo.passed ? 'PASSED' : 'FAILED';
            elements.solutionStatus.className = `solution-status ${scoreInfo.passed ? 'passed' : 'failed'}`;
        } else {
            elements.solutionStatus.textContent = '';
            elements.solutionStatus.className = 'solution-status';
        }
    }

    // Render solution content with markdown
    if (elements.solutionContent) {
        elements.solutionContent.innerHTML = marked.parse(solution.content || '');

        // Highlight code blocks
        elements.solutionContent.querySelectorAll('pre code').forEach(block => {
            hljs.highlightElement(block);
        });
    }

    // Update navigation buttons
    if (elements.btnPrevSolution) {
        elements.btnPrevSolution.disabled = index === 0;
    }
    if (elements.btnNextSolution) {
        elements.btnNextSolution.disabled = index === state.solutions.length - 1;
    }
}

function nextSolution() {
    showSolution(state.currentSolutionIndex + 1);
}

function prevSolution() {
    showSolution(state.currentSolutionIndex - 1);
}

function backToScore() {
    state.viewingSolutions = false;
    elements.solutionsView.classList.add('hidden');
    elements.scoreModal.classList.remove('hidden');
}

// ============================================================================
// Question Navigation
// ============================================================================

function renderQuestionSelect() {
    elements.questionSelect.innerHTML = state.questions.map((q, index) => `
        <option value="${index}">Question ${q.id} | ${q.topic}</option>
    `).join('');
}

function renderQuestionDots() {
    elements.questionDots.innerHTML = state.questions.map((q, index) => `
        <div class="question-dot${index === state.currentQuestionIndex ? ' current' : ''}${state.flaggedQuestions.has(q.id) ? ' flagged' : ''}"
             data-index="${index}"
             title="Question ${q.id}">
            ${q.id}
        </div>
    `).join('');

    // Add click handlers
    document.querySelectorAll('.question-dot').forEach(dot => {
        dot.addEventListener('click', () => {
            showQuestion(parseInt(dot.dataset.index));
        });
    });
}

function showQuestion(index) {
    if (index < 0 || index >= state.questions.length) return;
    if (state.examEnded) return;

    state.currentQuestionIndex = index;
    const question = state.questions[index];

    // Update select
    elements.questionSelect.value = index;

    // Update metadata
    elements.metaPoints.textContent = question.points || '-';
    elements.metaNamespace.textContent = question.namespace || '-';
    elements.metaResources.textContent = question.resources || '-';
    elements.metaFiles.textContent = question.files || '-';

    // Render question content with markdown
    const content = question.content || '';
    elements.questionContent.innerHTML = marked.parse(content);

    // Highlight code blocks
    elements.questionContent.querySelectorAll('pre code').forEach(block => {
        hljs.highlightElement(block);
    });

    // Update navigation buttons
    elements.btnPrev.disabled = index === 0;
    elements.btnNext.disabled = index === state.questions.length - 1;
    elements.btnNextFooter.disabled = index === state.questions.length - 1;

    // Update dots
    document.querySelectorAll('.question-dot').forEach((dot, i) => {
        dot.classList.toggle('current', i === index);
    });

    // Update flag button
    updateFlagButton();

    // Update progress
    updateProgress();
}

function nextQuestion() {
    showQuestion(state.currentQuestionIndex + 1);
}

function prevQuestion() {
    showQuestion(state.currentQuestionIndex - 1);
}

function updateProgress() {
    const visited = state.currentQuestionIndex + 1;
    const total = state.questions.length;
    elements.progressText.textContent = `${visited} / ${total}`;
}

// ============================================================================
// Flagging
// ============================================================================

async function toggleFlag() {
    const question = state.questions[state.currentQuestionIndex];
    if (!question) return;

    try {
        const result = await api.toggleFlag(question.id);

        if (result.flagged) {
            state.flaggedQuestions.add(question.id);
        } else {
            state.flaggedQuestions.delete(question.id);
        }

        updateFlagButton();
        updateFlaggedCount();
        renderQuestionDots();

    } catch (error) {
        console.error('Failed to toggle flag:', error);
    }
}

function updateFlagButton() {
    const question = state.questions[state.currentQuestionIndex];
    const isFlagged = question && state.flaggedQuestions.has(question.id);
    elements.btnFlag.classList.toggle('flagged', isFlagged);
}

function updateFlaggedCount() {
    const count = state.flaggedQuestions.size;
    elements.flaggedCount.textContent = count > 0 ? count : '';
}

function showFlaggedList() {
    const flaggedItems = state.questions.filter(q => state.flaggedQuestions.has(q.id));

    if (flaggedItems.length === 0) {
        elements.flaggedList.innerHTML = '<div class="flagged-item-empty">No flagged questions</div>';
    } else {
        elements.flaggedList.innerHTML = flaggedItems.map(q => {
            const index = state.questions.findIndex(question => question.id === q.id);
            return `
                <div class="flagged-item" data-index="${index}">
                    <span>Question ${q.id} | ${q.topic}</span>
                    <span>${q.points} pts</span>
                </div>
            `;
        }).join('');

        // Add click handlers
        document.querySelectorAll('.flagged-item').forEach(item => {
            item.addEventListener('click', () => {
                const index = parseInt(item.dataset.index);
                elements.flaggedModal.classList.add('hidden');
                showQuestion(index);
            });
        });
    }

    elements.flaggedModal.classList.remove('hidden');
}

// ============================================================================
// Back to Selection
// ============================================================================

function backToSelection() {
    if (state.examStarted && !state.examEnded) {
        if (!confirm('Are you sure you want to leave the exam? Your progress will be lost.')) {
            return;
        }
    }

    // Stop timer
    if (state.timerInterval) {
        clearInterval(state.timerInterval);
    }

    // Reset state
    state.examStarted = false;
    state.examEnded = false;

    // Switch screens
    elements.examInterface.classList.add('hidden');
    elements.examSelection.classList.remove('hidden');
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

function handleKeyboard(event) {
    // Handle Escape for confirm modal
    if (event.key === 'Escape') {
        if (elements.confirmModal && !elements.confirmModal.classList.contains('hidden')) {
            hideConfirmModal();
            return;
        }
    }

    // Don't handle if modal is open
    if (!elements.timesUpModal.classList.contains('hidden') ||
        !elements.flaggedModal.classList.contains('hidden') ||
        (elements.confirmModal && !elements.confirmModal.classList.contains('hidden'))) {
        return;
    }

    // Don't handle if exam interface is not visible
    if (elements.examInterface.classList.contains('hidden')) {
        return;
    }

    switch (event.key) {
        case 'ArrowLeft':
            prevQuestion();
            break;
        case 'ArrowRight':
            nextQuestion();
            break;
        case 'f':
        case 'F':
            if (!event.ctrlKey && !event.metaKey) {
                toggleFlag();
            }
            break;
    }
}

// ============================================================================
// Event Listeners
// ============================================================================

function initEventListeners() {
    // Theme toggles
    elements.themeToggle.addEventListener('click', toggleTheme);
    elements.themeToggleSelection.addEventListener('click', toggleTheme);

    // Navigation
    elements.btnPrev.addEventListener('click', prevQuestion);
    elements.btnNext.addEventListener('click', nextQuestion);
    elements.btnNextFooter.addEventListener('click', nextQuestion);
    elements.questionSelect.addEventListener('change', (e) => {
        showQuestion(parseInt(e.target.value));
    });

    // Flag
    elements.btnFlag.addEventListener('click', toggleFlag);
    elements.btnFlaggedList.addEventListener('click', showFlaggedList);
    elements.btnCloseFlagged.addEventListener('click', () => {
        elements.flaggedModal.classList.add('hidden');
    });

    // Back button
    elements.btnBack.addEventListener('click', backToSelection);

    // Modal close - when time's up, calculate score
    elements.btnCloseModal.addEventListener('click', async () => {
        elements.timesUpModal.classList.add('hidden');
        await executeStopExam();
    });

    // Stop exam button
    elements.btnStopExam.addEventListener('click', stopExam);

    // Confirm modal buttons
    if (elements.btnConfirmCancel) {
        elements.btnConfirmCancel.addEventListener('click', hideConfirmModal);
    }
    if (elements.btnConfirmStop) {
        elements.btnConfirmStop.addEventListener('click', confirmStopExam);
    }

    // Pause button
    if (elements.btnPause) {
        elements.btnPause.addEventListener('click', togglePause);
    }

    // Score modal buttons
    elements.btnCloseScore.addEventListener('click', closeExamAndCleanup);
    elements.btnBackToSelection.addEventListener('click', cleanupAndGoBack);

    // View Solutions button
    if (elements.btnViewSolutions) {
        elements.btnViewSolutions.addEventListener('click', showSolutions);
    }

    // Solutions navigation
    if (elements.btnPrevSolution) {
        elements.btnPrevSolution.addEventListener('click', prevSolution);
    }
    if (elements.btnNextSolution) {
        elements.btnNextSolution.addEventListener('click', nextSolution);
    }
    if (elements.btnBackToScore) {
        elements.btnBackToScore.addEventListener('click', backToScore);
    }
    if (elements.solutionSelect) {
        elements.solutionSelect.addEventListener('change', (e) => {
            showSolution(parseInt(e.target.value));
        });
    }

    // Close solutions view on backdrop click
    if (elements.solutionsView) {
        elements.solutionsView.addEventListener('click', (e) => {
            if (e.target === elements.solutionsView) {
                backToScore();
            }
        });
    }

    // Keyboard
    document.addEventListener('keydown', handleKeyboard);

    // Close modal on backdrop click
    elements.timesUpModal.addEventListener('click', (e) => {
        if (e.target === elements.timesUpModal) {
            elements.timesUpModal.classList.add('hidden');
        }
    });
    elements.flaggedModal.addEventListener('click', (e) => {
        if (e.target === elements.flaggedModal) {
            elements.flaggedModal.classList.add('hidden');
        }
    });
    elements.scoreModal.addEventListener('click', (e) => {
        if (e.target === elements.scoreModal) {
            elements.scoreModal.classList.add('hidden');
        }
    });

    // Confirm modal backdrop click
    if (elements.confirmModal) {
        elements.confirmModal.addEventListener('click', (e) => {
            if (e.target === elements.confirmModal) {
                hideConfirmModal();
            }
        });
    }
}

// ============================================================================
// Check for auto-start (timer already running)
// ============================================================================

async function checkExistingSession() {
    try {
        const timerState = await api.getTimerState();

        if (timerState.running && timerState.exam_id) {
            // Resume existing session, starting at the specified question
            const startQuestion = timerState.start_question || 1;
            await resumeExam(timerState.exam_id, startQuestion);
        }
    } catch (error) {
        console.error('Failed to check existing session:', error);
    }
}

async function resumeExam(examId, startQuestion = 1) {
    try {
        const [config, questions] = await Promise.all([
            api.getExamConfig(examId),
            api.getQuestions(examId)
        ]);

        state.currentExam = examId;
        state.examConfig = config;
        state.questions = questions;
        state.currentQuestionIndex = 0;
        state.flaggedQuestions.clear();
        state.examStarted = true;
        state.examEnded = false;

        // Fetch flagged questions from server
        try {
            const flags = await fetch('/api/flags').then(r => r.json());
            flags.forEach(f => state.flaggedQuestions.add(f));
        } catch (e) {
            // Ignore
        }

        // Switch to exam interface
        elements.examSelection.classList.add('hidden');
        elements.examInterface.classList.remove('hidden');

        elements.examTitle.textContent = config.exam_name;
        renderQuestionSelect();
        renderQuestionDots();

        // Navigate to start question (convert from 1-based to 0-based index)
        const startIndex = Math.max(0, Math.min(startQuestion - 1, questions.length - 1));
        showQuestion(startIndex);

        updateFlaggedCount();
        startTimerUpdates();

    } catch (error) {
        console.error('Failed to resume exam:', error);
    }
}

// ============================================================================
// Initialize
// ============================================================================

async function init() {
    initTheme();
    await initTerminal();
    initEventListeners();

    // Check for existing session first
    await checkExistingSession();

    // If no existing session, load exam list
    if (!state.examStarted) {
        await loadExamList();
    }
}

// Start the app
document.addEventListener('DOMContentLoaded', init);
