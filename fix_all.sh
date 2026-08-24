#!/bin/bash
set -e
cd /mnt/c/Users/kanik/kubernetes/CKAD/ckad-dojo/

# FIX 2: Normalize question headers in new exams (13-20)
for i in $(seq 13 20); do
  q="exams/ckad-simulation${i}/questions.md"
  s="exams/ckad-simulation${i}/solutions.md"
  if [ -f "$q" ]; then
    sed -i -E 's/^### Question ([0-9]+): (.+)$/## Question \1 | \2/' "$q"
    sed -i -E 's/^### Question ([0-9]+)$/## Question \1 | Kubernetes Practice/' "$q"
    sed -i -E 's/^## Question ([0-9]+)$/## Question \1 | Kubernetes Practice/' "$q"
  fi
  if [ -f "$s" ]; then
    sed -i -E 's/^### Question ([0-9]+): (.+)$/## Question \1 | \2/' "$s"
    sed -i -E 's/^### Question ([0-9]+)$/## Question \1 | Kubernetes Practice/' "$s"
    sed -i -E 's/^## Question ([0-9]+)$/## Question \1 | Kubernetes Practice/' "$s"
  fi
done

# FIX 4: Fix sim17 TOTAL_POINTS
sed -i 's/TOTAL_POINTS=116/TOTAL_POINTS=119/' exams/ckad-simulation17/exam.conf

# FIX 6: Fix ckad-exam.sh help text
sed -i 's/Terminal port (default: 7681)/Terminal port (default: 7682)/' scripts/ckad-exam.sh

# FIX 7 & 8: Revert app.js changes
sed -i "if (state.examEnded && !elements.scoreModal.classList.contains('hidden')) return;/if (state.examEnded) return;/" web/js/app.js || true

# Wait I should use python to replace exact strings for safety. Let's do python script.
