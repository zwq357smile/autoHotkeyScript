[简体中文](README_zh-CN.md) | **English**

# AutoHotkey Script Collection

This repository contains a collection of practical AutoHotkey v2.0 scripts to enhance the Windows operating system experience.

## Script List

### 1. monitorwiseAltTab.ahk
**Monitor-Aware Alt-Tab Window Switcher**

An enhanced Alt-Tab implementation that switches windows only within the current monitor, avoiding screen jumps in multi-monitor environments.

#### Key Features:
- **Monitor Awareness**: Shows only windows on the monitor where the mouse is located
- **Beautiful GUI**: Displays window icons and titles in a list
- **Acrylic Effect**: Windows 10/11 style acrylic transparency with blur effect
- **Rounded Corners**: Modern rounded window design
- **Intelligent Window Filtering**: Automatically filters out tool windows, hidden windows, and system windows
- **Minimized Window Support**: Can recognize and display minimized windows' restore positions

#### Usage:
- Press `Alt + Tab` to open the window switcher
- Keep `Alt` key pressed and press `Tab` to cycle through windows
- Release `Alt` key to switch to the selected window
- Or directly click on a window title in the list

#### Technical Details:
- Uses `GetWindowPlacement` API to get window position information
- Implements acrylic effect through DWM API
- Supports multi-monitor coordinate calculations
- Automatically cleans up resources to prevent memory leaks

### 2. mouseButton.ahk
**Mouse Side Button Enhancement Script**

Combines mouse side buttons (forward/back) with the scroll wheel to provide more shortcut functions.

#### Function Mapping:

| Combination | Function |
|-------------|----------|
| **Forward Button (XButton2)** | Press: Sends `Shift + NumLock`; Release without wheel: Original forward function |
| **Forward Button + Scroll Wheel** | Horizontal scrolling (requires application support) |
| **Back Button (XButton1)** | Press: No action; Release without wheel: Original back function |
| **Back Button + Wheel Up** | `Shift + F3` |
| **Back Button + Wheel Down** | `F3` |

**Note**: The original function (forward/back navigation) is triggered when you release the side button without using the scroll wheel.

#### Design Purpose:
- Maximize use of mouse side buttons, reducing keyboard operations
- Prevent accidental Chinese/English IME switching when pressing Shift alone
- Provide shortcuts for common operations (like Find Next/Previous in IDEs)

#### Notes:
- Requires a mouse with side buttons (forward/back)
- Horizontal scrolling functionality depends on application support

### 3. rightClick.ahk
**Quick Right-Click Script**

The simplest script that maps `Ctrl + Space` to right-click.

#### Use Cases:
- Quickly open context menus
- Alternative to mouse right-click on touchpads or special keyboards
- Improve operational efficiency

## Installation & Usage

### System Requirements
- Windows 10 or higher
- AutoHotkey v2.0 or higher

### Installation Steps
1. Install AutoHotkey v2.0 (download from [autohotkey.com](https://www.autohotkey.com/))
2. Clone or download this repository to a local directory
3. Run any script:
   - Double-click the `.ahk` file
   - Or right-click and select "Run Script"
4. (Optional) Add scripts to startup:
   - Create a shortcut to the script
   - Place the shortcut in the startup folder: `%AppData%\Microsoft\Windows\Start Menu\Programs\Startup`

### Customization
- Each script can be opened with a text editor to modify hotkeys
- After modification, save and rerun the script

## Troubleshooting

### Script Not Running
- Confirm AutoHotkey v2.0 is installed (check version: `AutoHotkey.exe /v`)
- Check if the script's first line contains `#Requires AutoHotkey v2.0`
- Run the script as administrator

### Functions Not Working
- Check if hotkeys conflict with other applications
- Confirm mouse side buttons work properly
- In multi-monitor environments, ensure display settings are correct

### Performance Issues
- If `monitorwiseAltTab.ahk` responds slowly, it may be due to too many windows (the script is optimized but has limits)
- Ensure the system has sufficient memory

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Issues and Pull Requests are welcome to improve these scripts.

## Disclaimer

These scripts are provided "as is". The author is not responsible for any issues caused by using these scripts. Please back up important data before use.

---

**Note**: AutoHotkey v2.0 is not compatible with v1.x syntax. Do not mix versions.