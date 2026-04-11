# AutoHotkey Script Collection

[简体中文](README_zh-CN.md) | **English**

This repository contains a collection of practical AutoHotkey v2.0 scripts to enhance the Windows operating system experience.

## Script List

### 1. monitorwiseAltTab.ahk

#### Monitor-Aware Alt-Tab Window Switcher

An enhanced Alt-Tab implementation that switches windows only within the current monitor, avoiding screen jumps in multi-monitor environments.

#### Key Features

- **Monitor Awareness**: Shows only windows on the monitor where the mouse is located.
- **Beautiful GUI**: Displays window icons and titles in a list.
- **Acrylic Effect**: Uses a Windows 10/11-style acrylic blur effect.
- **Rounded Corners**: Uses a modern rounded popup window.
- **Intelligent Window Filtering**: Filters out tool windows, hidden windows, and system windows.
- **Minimized Window Support**: Can recognize minimized windows by their restore position.
- **Click-to-Activate**: Supports direct mouse click selection in the popup list.
- **Previous-Window First**: Defaults to the second item when opened, closer to standard Alt-Tab behavior.

#### Usage

- Press `Alt + Tab` to open the window switcher.
- Keep `Alt` pressed and press `Tab` to cycle through windows.
- Release `Alt` to switch to the selected window.
- Or click a window title directly in the list.
- If there are no usable windows on the current monitor, the script shows a short tooltip instead of opening the list.

#### Technical Details

- Uses the `GetWindowPlacement` API to get window position information.
- Implements acrylic and blur effects through the DWM API.
- Supports multi-monitor coordinate calculations.
- Cleans up GUI and icon resources automatically.

### 2. mouseButton.ahk

#### Mouse Side Button Enhancement Script

Combines mouse side buttons (forward/back) with the scroll wheel and several keyboard remaps to provide more shortcut functions.

#### Function Mapping

| Combination | Function |
| ----------- | -------- |
| **Forward Button (XButton2)** | Press: sends `Shift + NumLock`; release without wheel input: original forward action |
| **Forward Button + Scroll Wheel** | Horizontal scrolling, depending on application support |
| **Back Button (XButton1)** | Press: no action; release without wheel input: original back action |
| **Back Button + Wheel Up** | `Shift + F3` |
| **Back Button + Wheel Down** | `F3` |
| **Alt + Back Button** | `F12` |
| **Shift + Backspace** | Blocks `Backspace` and keeps only `Shift` |
| **Wheel Up / Down** | Global accelerated scrolling for rapid wheel input |
| **Middle Button in Trae CN** | Sends `Ctrl + Alt + B` when `Trae CN.exe` is active |

The original forward/back navigation is triggered when you release the side button without using the wheel.

#### Design Purpose

- Maximize use of mouse side buttons and reduce keyboard operations.
- Prevent accidental Chinese/English IME switching when pressing Shift alone.
- Provide shortcuts for common operations such as Find Next and Find Previous in IDEs.
- Add a few workflow-specific remaps without heavily affecting unrelated apps.

#### Notes

- Requires a mouse with forward/back side buttons.
- Horizontal scrolling depends on target application support.
- The forward-button wheel combo relies on the script-held `Shift` state while the side button is pressed.
- The Trae-specific middle-click remap only applies when the active window is `Trae CN.exe`.

### 3. rightClick.ahk

#### Quick Right-Click Script

Maps `Ctrl + Space` to a right-click.

#### Use Cases

- Quickly open context menus.
- Replace mouse right-click on touchpads or special keyboards.
- Improve operational efficiency.

## Installation & Usage

### System Requirements

- Windows 10 or higher.
- AutoHotkey v2.0 or higher.

### Installation Steps

1. Install AutoHotkey v2.0 from [autohotkey.com](https://www.autohotkey.com/).
2. Clone or download this repository to a local directory.
3. Run any script.
   - Double-click the `.ahk` file.
   - Or right-click it and select `Run Script`.
4. Optionally add scripts to startup.
   - Create a shortcut to the script.
   - Place the shortcut in `%AppData%\Microsoft\Windows\Start Menu\Programs\Startup`.

### Customization

- Open each script in a text editor to modify hotkeys.
- Save and rerun the script after modification.
- Run scripts independently if you only need part of the behavior.

## Troubleshooting

### Script Not Running

- Confirm AutoHotkey v2.0 is installed by checking `AutoHotkey.exe /v`.
- Check whether the first line contains `#Requires AutoHotkey v2.0`.
- Try running the script as administrator.

### Functions Not Working

- Check whether hotkeys conflict with other applications.
- Confirm the mouse side buttons work correctly.
- In multi-monitor environments, verify display settings are correct.
- If horizontal scrolling does not work, verify the target application supports horizontal wheel input.
- If `Alt + Tab` does not keep cycling, make sure `Alt` remains pressed while you tap `Tab`.

### Performance Issues

- If `monitorwiseAltTab.ahk` responds slowly, there may simply be too many windows open.
- Ensure the system has sufficient memory.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Issues and pull requests are welcome.

## Disclaimer

These scripts are provided "as is". The author is not responsible for any issues caused by using them. Back up important data before use.

AutoHotkey v2.0 is not compatible with v1.x syntax. Do not mix versions.
