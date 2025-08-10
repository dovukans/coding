##### <a href="/README.md">← Back to home page</a>

#  Downloads Folder Cleaner
This Python script moves files scattered across the Downloads folder into separate folders based on their extensions. If a folder does not exist, it creates one. The script then shows a toast notification after moving the files.

![pic6](/docs/guides/img%20sources/img06.png)



>📄 **Index**
> - [downloads_folder_cleaner.py](../../scripting/windows/downloads_folder_cleaner.py) – Main script
> - [README.md](./downloads_folder_cleaner.md)  – You're here


## 1- Requirements
 - Pyhton 3
 - A very messy Downloads folder

 ## 2- How to Use

 - Save the python script to your computer.
 - You can simply run it whenever you want.

 ## 3- Setting Up Windows Task Scheduler

 Alternatively, we can set up Windows Task Scheduler to run this script at specific times, so we don’t have to run it manually each time.

- Open **Windows Task Scheduler**.
- Right-click **Task Scheduler Library**, then select **Create Basic Task**.
- Enter a name for your task and click Next.
- Select Daily if you want the script to run each day or choose another schedule if you prefer.
- In the Action step, select **Start a Program**.
- In the Program/script field, enter the path to your **pythonw.exe**.
- In the Add arguments field, enter **the full path to your script**. It should look like the image below.

 ![pic7](/docs/guides/img%20sources/img07.png)

- Press Next and Finish.

![pic8](/docs/guides/img%20sources/img08.png)

> [!IMPORTANT]
> Note: Even if you have installed reqiured libraries in your development environment, the script will fail unless they’re installed in the same Python environment that Windows will use to run the task (the python.exe or pythonw.exe specified in Task Scheduler). You’ll need to install: plyer, datetime, and pathlib. 

> Run: 

> ``` pip install plyer datetime pathlib ```

> Make sure you run this pip command from the Python installation path that Task Scheduler will use.


## ✅ Done

Our script runs daily at 12:20, moving files to their corresponding folders and then showing a toast notification. You can customize the folder-to-extension mappings in the script’s **extension_map** section.

