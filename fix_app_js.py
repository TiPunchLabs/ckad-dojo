with open('web/js/app.js', 'r') as f:
    content = f.read()

# FIX 7
content = content.replace(
    "if (state.examEnded && !elements.scoreModal.classList.contains('hidden')) return;",
    "if (state.examEnded) return;"
)

# FIX 8
content = content.replace("    state.examEnded = false;\n", "")

with open('web/js/app.js', 'w') as f:
    f.write(content)
