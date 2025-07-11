from pathlib import Path

TARGETS_PATHS = ["/data/models","/output"]

if __name__ == '__main__':
    for target_path in TARGETS_PATHS:
        path = Path(target_path)
        if path.exists():
            print(f"[Permissions] Setting permissions for {target_path} to 777")
            path.chmod(0o777)
        else:
            print(f"[Permissions] Path {target_path} does not exist, skipping permission change.")