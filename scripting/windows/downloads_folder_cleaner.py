import shutil
from pathlib import Path
from datetime import datetime
from plyer import notification


#  SET YOUR DOWNLOADS FOLDER HERE
downloads_dir = Path.home() / "Downloads"
# downloads_dir = Path(r"D:\Custom\Downloads")  #Uncomment this if using a custom path

#  Define file type mappings
extension_map = {
    "Images": [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".ico"],
    "PDFs": [".pdf"],
    "Documents": [".doc", ".docx", ".txt", ".odt", ".rtf", ".md"],
    "Spreadsheets": [".xls", ".xlsx", ".csv"],
    "Archives": [".zip", ".rar", ".7z", ".tar", ".gz"],
    "Installers": [".exe", ".msi"],
    "Videos": [".mp4", ".mkv", ".avi", ".mov"],
    "Music": [".mp3", ".wav", ".flac"],
    "Code": [".py", ".js", ".html", ".css", ".cpp", ".c", ".java", ".sh"],
    "Ebooks": [".epub"],
    "Torrents": [".torrent"]
}

#  Log setup
log_file = downloads_dir / "downloads_cleanup.log"


def log(message):
    timestamp = datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(f"{timestamp} {message}\n")


#  Add timestamp to avoid overwrites
def append_timestamp(path: Path) -> Path:
    timestamp = datetime.now().strftime("_%d%m%y-%H%M%S")
    return path.with_name(f"{path.stem}{timestamp}{path.suffix}")


#  Move files by extension
def move_files():
    moved_count = 0  # Counter for moved files
    if not downloads_dir.exists():
        log(f"ERROR: Downloads folder not found at {downloads_dir}")
        return moved_count

    for item in downloads_dir.iterdir():
        if item.is_file() and item.name != log_file.name:
            moved = False
            for folder_name, extensions in extension_map.items():
                if item.suffix.lower() in extensions:
                    target_folder = downloads_dir / folder_name
                    target_folder.mkdir(exist_ok=True)
                    destination = target_folder / item.name
                    if destination.exists():
                        destination = append_timestamp(destination)
                    shutil.move(str(item), destination)
                    log(f'Moved: "{item.name}" → "{destination.relative_to(downloads_dir)}"')
                    moved = True
                    moved_count += 1
                    break
            if not moved:
                other = downloads_dir / "Other"
                other.mkdir(exist_ok=True)
                destination = other / item.name
                if destination.exists():
                    destination = append_timestamp(destination)
                shutil.move(str(item), destination)
                log(f'Moved: "{item.name}" → "Other/{destination.name}"')
                moved_count += 1
    return moved_count


if __name__ == "__main__":
    total_moved = move_files()

    notification.notify(
        title="Downloads Cleaned ✅",
        message=f"{total_moved} files have been organized successfully.",
        timeout=5
    )
