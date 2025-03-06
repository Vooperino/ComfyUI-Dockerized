import shutil
import importlib.resources
import comfyui_frontend_package
from pathlib import Path

def copy_html_to_static(source_html_path: str):
    static_dir = importlib.resources.files(comfyui_frontend_package) / "static"
    Path(static_dir).mkdir(parents=True, exist_ok=True)
    source_path = Path(source_html_path)
    if not source_path.exists() or not source_path.is_file():
        print(f"Error: Source file '{source_html_path}' does not exist.")
        return
    destination_path = static_dir / source_path.name
    shutil.copy2(source_path, destination_path)
    print(f"Copied '{source_html_path}' to '{destination_path}'")

if __name__ == "__main__":
    source_file = "docker-up.html" 
    copy_html_to_static(source_file)
