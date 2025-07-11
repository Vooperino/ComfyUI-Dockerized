import json
from datetime import timedelta
from pathlib import Path

class Configuration:
    def __init__(self):
        self.__config_file_path = "/data/config/backend_config.json"
        self.__json_config = {}
    
    def __get_config_file(self):
        return Path(self.__config_file_path)

    def __validate_config_existance(self):
        if not self.__get_config_file().exists():
            print (f"(CONFIG) Config file {self.__config_file_path} does not exist. Creating new!")
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
                    },
                    "logging_retention": {
                        "enabled": True,
                        "file_age": "30d"
                    }
                }
            }
            with open(self.__config_file_path, 'w') as file:
                json.dump(default_config, file, indent=4)
            self.__update_permissions()

    def __update_permissions(self):
        if self.__get_config_file().exists():
            self.__get_config_file().chmod(0o777)
    
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
        
        if 'logging_retention' not in self.__json_config['output']:
            self.__json_config['output']['logging_retention'] = {
                'enabled': True,
                'file_age': '30d'
            }
        
        if 'enabled' not in self.__json_config['output']['logging_retention']:
            self.__json_config['output']['logging_retention']['enabled'] = True
        if 'file_age' not in self.__json_config['output']['logging_retention']:
            self.__json_config['output']['logging_retention']['file_age'] = '30d'
        
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
    
    def is_logging_retention_enabled(self):
        if 'output' not in self.__json_config:
            return True
        if 'logging_retention' not in self.__json_config['output']:
            return True
        if 'enabled' not in self.__json_config['output']['logging_retention']:
            return True
        return self.__json_config['output']['logging_retention']['enabled']
    
    def get_logging_retention_age(self):
        if 'output' not in self.__json_config:
            return self.__convert_interval("30d")
        if 'logging_retention' not in self.__json_config['output']:
            return self.__convert_interval("30d")
        if 'file_age' not in self.__json_config['output']['logging_retention']:
            return self.__convert_interval("30d")
        return self.__convert_interval(self.__json_config['output']['logging_retention']['file_age'])