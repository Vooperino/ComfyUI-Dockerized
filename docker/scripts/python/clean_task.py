import json
import time
import shutil
from datetime import datetime, timedelta
from pathlib import Path

class Configuration:
    def __init__(self):
        self.__config_file_path = "/data/config/backend_config.json"
        self.__json_config = {}

    def __validate_config_existance(self):
        if not self.__config_file_path.exists():
            print (f"Config file {self.__config_file_path} does not exist. Creating new!")
            default_config = {
                "output": {
                    "cleanup_on_startup": False,
                    "cleanup_directory" : {
                        "enabled" : False,
                        "interval" : "1d"
                    },
                    "file_retention": {
                        "enabled": True,
                        "file_age": "30d"
                    }
                }
            }
            with open(self.__config_file_path, 'w') as file:
                json.dump(default_config, file, indent=4)
            self.__update_permissions()

    def __update_permissions(self):
        if self.__config_file_path.exists():
            self.__config_file_path.chmod(0o777)
    
    def __convert_interval(self, interval_str):
        if interval_str.endswith('d'):
            days = int(interval_str[:-1])
            return timedelta(days=days)
        elif interval_str.endswith('h'):
            hours = int(interval_str[:-1])
            return timedelta(hours=hours)
        elif interval_str.endswith('m'):
            minutes = int(interval_str[:-1])
            return timedelta(minutes=minutes)
        elif interval_str.endswith('s'):
            seconds = int(interval_str[:-1])
            return timedelta(seconds=seconds)
        else:
            raise ValueError(f"Invalid interval format: {interval_str}")
    

    def __validate_config_values(self):
        if 'output' not in self.__json_config:
            self.__json_config['output'] = {}
        if 'cleanup_on_startup' not in self.__json_config['output']:
            self.__json_config['output']['cleanup_on_startup'] = False
        if 'file_retention' not in self.__json_config['output']:
            self.__json_config['output']['file_retention'] = {
                'enabled': True,
                'file_age': '30d'
            }
        if 'enabled' not in self.__json_config['output']['file_retention']:
            self.__json_config['output']['file_retention']['enabled'] = True
        if 'file_age' not in self.__json_config['output']['file_retention']:
            self.__json_config['output']['file_retention']['file_age'] = '30d'
        
        self.__update_permissions()
        with open(self.__config_file_path, 'w') as file:
            json.dump(self.__json_config, file, indent=4)
        
    def load_config(self):
        self.__validate_config_existance()
        if self.__json_config:
            self.__json_config = {}
        self.__update_permissions()
        with open(self.__config_file_path, 'r') as file:
            self.__json_config = json.load(file)
        self.__validate_config_values()

    def is_cleanup_on_startup(self):
        if 'output' not in self.__json_config:
            return False
        if 'cleanup_on_startup' not in self.__json_config['output']:
            return False
        return self.__json_config['output']['cleanup_on_startup']
    
    def is_cleanup_directory_enabled(self):
        if 'output' not in self.__json_config:
            return False
        if 'cleanup_directory' not in self.__json_config['output']:
            return False
        if 'enabled' not in self.__json_config['output']['cleanup_directory']:
            return False
        return self.__json_config['output']['cleanup_directory']['enabled']
    
    def get_cleanup_directory_interval(self):
        if 'output' not in self.__json_config:
            return self.__convert_interval("1d")
        if 'cleanup_directory' not in self.__json_config['output']:
            return self.__convert_interval("1d")
        if 'interval' not in self.__json_config['output']['cleanup_directory']:
            return self.__convert_interval("1d")
        return self.__convert_interval(self.__json_config['output']['cleanup_directory']['interval'])
    
    def is_file_retention_enabled(self):
        if 'output' not in self.__json_config:
            return True
        if 'file_retention' not in self.__json_config['output']:
            return True
        if 'enabled' not in self.__json_config['output']['file_retention']:
            return True
        return self.__json_config['output']['file_retention']['enabled']
    
    def get_file_retention_age(self):
        if 'output' not in self.__json_config:
            return self.__convert_interval("30d")
        if 'file_retention' not in self.__json_config['output']:
            return self.__convert_interval("30d")
        if 'file_age' not in self.__json_config['output']['file_retention']:
            return self.__convert_interval("30d")
        return self.__convert_interval(self.__json_config['output']['file_retention']['file_age'])
    
        
OUTPUT_PATH = Path("/output")
CFG = Configuration()  

def __load_config():
    global CFG
    if not CFG:
        CFG = Configuration()
    CFG.load_config()

def __startup_cleanup():
    global OUTPUT_PATH, CFG
    if CFG.is_cleanup_on_startup():
        print("Performing startup cleanup...")
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
            print(f"Checking for files older than {cutoff_time}...")
            for item in OUTPUT_PATH.iterdir():
                if item.is_file() and datetime.fromtimestamp(item.stat().st_mtime) < cutoff_time:
                    print(f"Removing file: {item}")
                    item.unlink()
        elif CFG.is_cleanup_directory_enabled() and not CFG.is_file_retention_enabled():
            cleanup_interval = CFG.get_cleanup_directory_interval()
            last_cleanup_time = datetime.now() - cleanup_interval
            print(f"Checking for directories to clean up older than {last_cleanup_time}...")
            for item in OUTPUT_PATH.iterdir():
                if item.is_file() or item.is_symlink():
                    item.unlink()
                elif item.is_dir():
                    shutil.rmtree(item)
            time.sleep(cleanup_interval.total_seconds())
        elif not CFG.is_file_retention_enabled() and not CFG.is_cleanup_directory_enabled():
            print("No cleanup tasks are enabled. Skipping cleanup.")
        else:
            print("(CONFLICT) Both file retention and directory cleanup are enabled. Skipping cleanup.")
        time.sleep(5)