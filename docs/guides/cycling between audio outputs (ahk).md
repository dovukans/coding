 ##### <a href="/README.md">← Back to home page</a>

 # Cycling Between Audio Outputs - AutoHotKey Script

 In this guide we will create an AHK script that cycles between two audio sources (headset and speakers) with a single click. For convenience, we will place this button in the systray.

 ## 1. Prerequisites

 Install nircmd, which can be found here:
```
 https://www.nirsoft.net/utils/nircmd.html
 ```

 And then install autohotkey v2, which can be found here:
 ```
 https://www.autohotkey.com/
  ```

After installation process, we can get started.

## 2. About NirCmd

NirCmd is a portable app, this means there is no installation at all so you need to manually copy it somewhere after unzipping it.


## 3. Renaming Audio Devices

If you have a monitor with speakers or any other device capable of outputting sound, Windows may label them all as "Speaker" which may lead to confusion. To prevent this, we should rename our audio devices.

- Press Win+R and open mmsys.cpl,

- Above the "Change Icon" button you can see the device name, simply rename these for both of your headset and speakers. I renamed my devices as "Nari" and "X530".

![pic2](/docs/guides/img%20sources/img02.png)

## 4. AutoHotKey Script

Here is our ahk script. Go to NirCmd directory and create a text file there. Then copy these inside and rename your file with your desired name and .ahk extension.
 ```
#Requires AutoHotkey v2.0
#SingleInstance Force

A_IconHidden := false
Persistent
TraySetIcon(A_ScriptDir "\audio.ico")
Tray := A_TrayMenu
Tray.Delete()
Tray.Add("🔄 Switch Audio", ToggleAudio)
Tray.Add("🚪 Exit", (*) => ExitApp())

current := ""

ToggleAudio(*) {
    global current
    target := (current = "Nari") ? "X530" : "Nari"
    RunSwitch(target)
    current := target
}

RunSwitch(deviceName) {
    nircmd := "nircmd.exe" ; or full path if needed
    cmd := '"' nircmd '" setdefaultsounddevice "' deviceName '" 1'
    RunWait(cmd, , "Hide")
    TrayTip("Audio switched to: " deviceName, "", "Iconi")
}

myGui := Gui()
myGui.Opt("+ToolWindow +AlwaysOnTop -Caption")
myGui.Show("Hide")

OnMessage(0x404, TrayClick)

TrayClick(wParam, lParam, msg, hwnd) {
    if (lParam = 0x201) {
        ToggleAudio()
    }
}

Return
 ```






I named my script as AudioSwitcher, your folder should look like this:

![pic1](/docs/guides/img%20sources/img01.png)




> [!TIP]
> You can change the systray icon of this app, copy .ico file into the same folder and rename it as audio.ico
 You can use .png or other image files as well, but you need to convert them to ico first. You can use online ico converter tools for converting your files.


 > After running the script you should be able to see the icon in your systray. 

 ![pic5](/docs/guides/img%20sources/img05.PNG)

> Simply left click once to change output device.


 ![pic4](/docs/guides/img%20sources/img04.PNG)

 ![pic3](/docs/guides/img%20sources/img03.PNG)

## 5. Automatic Start Up

We can configure this script to start after logging on.

- Press Win+R and type shell:startup
- In the opened folder, right-click → New → Shortcut
- In the location field, enter:
 ```
"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" "D:\nircmd\AudioSwitcher.ahk"
 ```
 - Change the shortcut name of your liking, press finish.

 Now our icon should appear in the system tray whenever we log on to pc.

 ## Supported Platforms
 Tested on:
 - Windows 11 24H2
 - AutoHotKey v2 (ver 2.0.19)
 - NirCmd  (ver 2.87)