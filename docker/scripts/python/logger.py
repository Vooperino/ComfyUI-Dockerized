from datetime import datetime
from pathlib import Path

class Logger:
    def __init__(self, log_prefix):
        self.__log_prefix = log_prefix
        self.__log_path = Path(f"/data/logs/{log_prefix}")

    def getLogFile(self):
        if not self.__log_path.exists():
            self.__log_path.mkdir(parents=True, exist_ok=True)
        log_file_name = datetime.now().strftime("%Y-%m-%d") + ".log"
        return self.__log_path / log_file_name
    
    def log(self, message, save_to_file=False):
        if save_to_file:
            log_file = self.getLogFile()
            with open(log_file, 'a') as file:
                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                file.write(f"{timestamp} {self.__log_prefix} {message}\n")
        print(f"{timestamp} {self.__log_prefix} {message}")