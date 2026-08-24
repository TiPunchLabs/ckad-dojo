import os

def remove_lines(file_path, patterns):
    if not os.path.exists(file_path): return
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    with open(file_path, 'w') as f:
        skip = False
        for line in lines:
            if skip:
                if line.strip() == "EOF" or line.strip() == "EOF_FILE" or line.strip() == "":
                    skip = False
                continue
            
            should_skip = False
            for p in patterns:
                if p in line:
                    should_skip = True
                    break
            
            if should_skip:
                if "cat << 'EOF'" in line or "cat <<EOF" in line or "cat << 'EOF_FILE'" in line:
                    skip = True
                continue
            
            f.write(line)

base = '/mnt/c/Users/kanik/kubernetes/CKAD/ckad-dojo'

remove_lines(f"{base}/exams/ckad-simulation4/post-setup.sh", [
    '9/rollback-revision.txt',
    '5/my-app.tar'
])

remove_lines(f"{base}/exams/ckad-simulation10/post-setup.sh", [
    '13/rollout-history.txt',
    '15/root-cause.txt'
])

remove_lines(f"{base}/exams/ckad-simulation11/post-setup.sh", [
    '1/solar-app.tar',
    '10/pending-reason.txt',
    '11/sidecar-logs.txt',
    '12/crd-group.txt',
    '15/auth-check.txt',
    '20/dns-output.txt'
])
