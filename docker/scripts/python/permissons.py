from pathlib import Path
import time

TARGETS_PATHS = ["/data/models","/output","/data/logs"]

if __name__ == '__main__':
    while True:
        for target_path in TARGETS_PATHS:
            path = Path(target_path)
            if path.exists():
                print(f"[Permissions] Setting permissions for {target_path} to 777")
                path.chmod(0o777)
            else:
                print(f"[Permissions] Path {target_path} does not exist, skipping permission change.")
        time.sleep(10)  # Check every 10 seconds