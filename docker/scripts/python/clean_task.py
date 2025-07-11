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

def __check_logging_retention(path):
    global CFG
    if CFG.is_logging_retention_enabled():
        log_amount = 0
        for log_file in path.iterdir():
            if log_file.is_dir():
                __check_logging_retention(log_file.path)
            elif log_file.is_file():
                log_retention_age = CFG.get_logging_retention_age()
                log_cutoff_time = datetime.now() - log_retention_age
                if datetime.fromtimestamp(log_file.stat().st_mtime) < log_cutoff_time:
                    LOGGER.log(f"(Logging Retention) Removing log file: {log_file}",True)
                    log_file.unlink()
                    log_amount += 1

        if log_amount > 0:
            LOGGER.log("Logging Retention) Removed {log_amount} log files older than {log_cutoff_time}.")
            
def __check_output_retention(path):
    global CFG, LOGGER
    if CFG.is_file_retention_enabled and not CFG.is_cleanup_directory_enabled():
        output_amount = 0
        for item in path.iterdir():
            if item.is_dir():
                __check_output_retention(item.path)
            elif item.is_file():
                retention_age = CFG.get_file_retention_age()
                cutoff_time = datetime.now() - retention_age
                print(f"{__LOG_PREFIX} (File Retention) Checking for files older than {cutoff_time}...")          
                for item in OUTPUT_PATH.iterdir():
                    if item.is_file() and datetime.fromtimestamp(item.stat().st_mtime) < cutoff_time:
                        LOGGER.log(f"(File Retention) Removing file: {item}",True)
                        item.unlink()
                        output_amount += 1
        if output_amount > 0:
            LOGGER.log(f"(File Retention) Removed {output_amount} files older than {cutoff_time}.",True)

if __name__ == '__main__':
    __load_config()
    __startup_cleanup()
    while True:
        __load_config() # Make the configuration to be dynamic
        __check_logging_retention(LOG_PATH)
        
        if CFG.is_file_retention_enabled and not CFG.is_cleanup_directory_enabled():
            retention_age = CFG.get_file_retention_age()
            cutoff_time = datetime.now() - retention_age
            print(f"{__LOG_PREFIX} (File Retention) Checking for files older than {cutoff_time}...")
            amount = 0            
            for item in OUTPUT_PATH.iterdir():
                if item.is_file() and datetime.fromtimestamp(item.stat().st_mtime) < cutoff_time:
                    print(f"{__LOG_PREFIX} (File Retention) Removing file: {item}")
                    item.unlink()
                    amount += 1
            if amount > 0:
                print(f"{__LOG_PREFIX} (File Retention) Removed {amount} files older than {cutoff_time}.")

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