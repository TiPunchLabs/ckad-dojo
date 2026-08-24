import os
import re

def remove_lines(file_path, patterns):
    if not os.path.exists(file_path): return
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    with open(file_path, 'w') as f:
        skip = False
        for line in lines:
            if skip:
                if line.strip() == "EOF" or line.strip() == "":
                    skip = False
                continue
            
            should_skip = False
            for p in patterns:
                if p in line:
                    should_skip = True
                    break
            
            if should_skip:
                if "cat << 'EOF'" in line or "cat <<EOF" in line:
                    skip = True
                continue
            
            f.write(line)

base = '/mnt/c/Users/kanik/kubernetes/CKAD/ckad-dojo'

# sim3
remove_lines(f"{base}/exams/ckad-simulation3/post-setup.sh", [
    'pod-spec-fields.txt',
    'nginx-config.txt',
    'pod-resources.txt',
    'top-cpu-pod.txt'
])

# sim1
remove_lines(f"{base}/exams/ckad-simulation1/post-setup.sh", [
    '2/fire-app.yaml',
    '7/password.txt',
    '20/running-pods.txt',
    '21/drain-command.sh'
])

# sim4, sim10, sim11 - maintainer mentioned check and clean.
# I need to find which files are only checked with `-f` in scoring.
