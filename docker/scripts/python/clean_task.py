import time
import shutil
from datetime import datetime
from pathlib import Path
from backend_config_lib import Configuration
      
OUTPUT_PATH = Path("/output")
CFG = Configuration()

__LOG_PREFIX= "[Cleanup Service] "

def __load_config():
    global CFG
    if not CFG:
        CFG = Configuration()
    CFG.load_config()

def __startup_cleanup():
    global OUTPUT_PATH, CFG
    if CFG.is_cleanup_on_startup():
        print("[Cleanup Service] Performing startup cleanup...")
        for item in OUTPUT_PATH.iterdir():
            if item.is_file() or item.is_symlink():
                item.unlink()
            elif item.is_dir():
                shutil.rmtree(item)


if __name__ == '__main__':
    __load_config()
    __startup_cleanup()
    while True:
        __load_config() # Make the configuration to be dynamic 
        if CFG.is_file_retention_enabled and not CFG.is_cleanup_directory_enabled():
            retention_age = CFG.get_file_retention_age()
            cutoff_time = datetime.now() - retention_age
            print(f"{__LOG_PREFIX} (File Retention) Checking for files older than {cutoff_time}...")
            for item in OUTPUT_PATH.iterdir():
                if item.is_file() and datetime.fromtimestamp(item.stat().st_mtime) < cutoff_time:
                    print(f"{__LOG_PREFIX} (File Retention) Removing file: {item}")
                    item.unlink()
        elif CFG.is_cleanup_directory_enabled() and not CFG.is_file_retention_enabled():
            cleanup_interval = CFG.get_cleanup_directory_interval()
            last_cleanup_time = datetime.now() - cleanup_interval
            print(f"{__LOG_PREFIX}  Checking for directories to clean up older than {last_cleanup_time}...")
            for item in OUTPUT_PATH.iterdir():
                if item.is_file() or item.is_symlink():
                    item.unlink()
                elif item.is_dir():
                    shutil.rmtree(item)
            time.sleep(cleanup_interval.total_seconds())
        elif not CFG.is_file_retention_enabled() and not CFG.is_cleanup_directory_enabled():
            print(f"{__LOG_PREFIX} No cleanup tasks are enabled. Skipping cleanup.")
        else:
            print(f"{__LOG_PREFIX} (CONFLICT) Both file retention and directory cleanup are enabled. Skipping cleanup.")
        time.sleep(10)