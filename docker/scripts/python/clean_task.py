import time
import shutil
from datetime import datetime
from pathlib import Path
from backend_config_lib import Configuration
from logger import Logger
      
OUTPUT_PATH = Path("/output")
LOG_PATH = Path("/data/logs")

CFG = Configuration()
LOGGER = Logger("Cleanup Service")

__LOG_PREFIX= "[Cleanup Service]"

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

def __scan_output_directory(path):
    global CFG
    if not path.exists():
        print(f"(File Retention) Output path {path} does not exist. Skipping scan.")
        return
    amount = 0
    print(f"(File Retention) Scanning output directory for files older than {CFG.get_file_retention_age()}...")
    for outfile in path.iterdir():
        if outfile.is_file():
            retention_age = CFG.get_file_retention_age()
            cutoff_time = datetime.now() - retention_age
            if datetime.fromtimestamp(outfile.stat().st_mtime) < cutoff_time:
                print(f"(File Retention) Removing file: {outfile}")
                outfile.unlink()
        elif outfile.is_dir():
            __scan_output_directory(outfile)
    if amount > 0:
        print(f"(File Retention) Removed {amount} files older than {cutoff_time}.")

if __name__ == '__main__':
    __load_config()
    __startup_cleanup()
    while True:
        __load_config() # Make the configuration to be dynamic
        if CFG.is_file_retention_enabled and not CFG.is_cleanup_directory_enabled():
            __scan_output_directory(OUTPUT_PATH)
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