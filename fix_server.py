import re
import os

with open('web/server.py', 'r') as f:
    content = f.read()

start_marker = "        elif current_question:"
end_marker = "        else:"
# Find where elif current_question: starts
start_idx = content.find(start_marker)
if start_idx != -1:
    end_idx = content.find(end_marker, start_idx)
    
    new_content = """        elif current_question:
            # Parse metadata from table (format: | **Key** | value |)
            # Only process as metadata if it's a key-value table row with **bold** key
            if line.startswith("|"):
                parts = [p.strip() for p in line.split("|")[1:-1]]
                # Skip separator rows (e.g. |---|---|, | :--- | :--- |, etc.)
                if re.match(r"^\\|[\\s\\-:|\\s]+\\|?\\s*$", line.strip()):
                    continue
                if len(parts) >= 2 and parts[0].startswith("**") and parts[0].endswith("**"):
                    key = parts[0].strip("*").lower()
                    value = parts[1]
                    if key == "points":
                        # Extract points from format like "7/113 (6%)"
                        points_match = re.match(r"(\\d+)", value)
                        if points_match:
                            current_question["points"] = int(points_match.group(1))
                    elif key == "namespace":
                        current_question["namespace"] = value.strip("`")
                    elif key == "resources":
                        current_question["resources"] = value
                    elif key in ("file to create", "files to create", "files"):
                        current_question["files"] = value
                    # Skip metadata rows from content
                    continue
                elif line.strip() in ("| | |", "|---|---|"):
                    continue
            # Add all other lines (including task tables) to content
            current_content.append(line)
"""
    # Replace the chunk
    content = content[:start_idx] + new_content + content[end_idx:]
    with open('web/server.py', 'w') as f:
        f.write(content)
