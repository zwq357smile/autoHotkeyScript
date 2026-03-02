#SingleInstance Ignore

ActivateWindowAndCleanup(index, doExit := false) {
    global windows, hIL, mygui, guiClosedByClick

    if(!WinExist(windows[index])) {
        return
    }

    ; 激活窗口
    WinActivate(windows[index])
    ; 清理资源
    if (IsSet(hIL) && hIL) {
        try IL_Destroy(hIL)
        hIL := 0
    }
    if (IsSet(mygui) && mygui) {
        try mygui.Destroy()
        mygui := 0
    }
    if (doExit) {
        guiClosedByClick := true
    }
}

OnListViewClickFunc(GuiCtrl, ItemIndex) {
    if (ItemIndex > 0) {
        ActivateWindowAndCleanup(ItemIndex, true)
    }
}

IsAltTabWindow(hwnd) {
    ; 检查窗口是否存在
    if !WinExist(hwnd)
        return false
    
    ; 检查窗口是否可见
    if !WinGetStyle(hwnd) & 0x10000000  ; WS_VISIBLE
        return false
    
    ; 获取扩展样式
    exStyle := WinGetExStyle(hwnd)
    
    ; 排除工具窗口（WS_EX_TOOLWINDOW = 0x80）
    if exStyle & 0x80
        return false
    
    ; 排除没有WS_EX_APPWINDOW的窗口（可选，根据需求调整）
    ; if !(exStyle & 0x40000)  ; WS_EX_APPWINDOW
    ;     return false
    
    ; 检查窗口所有者（owner）
    ownerHwnd := DllCall("GetWindow", "ptr", hwnd, "uint", 4, "ptr")  ; GW_OWNER = 4
    if ownerHwnd != 0
        return false
    
    ; 检查窗口标题和类名（排除一些已知的隐藏窗口）
    title := WinGetTitle(hwnd)
    class := WinGetClass(hwnd)
    
    ; 排除标题为空或特定标题
    if title == "" || title == "Program Manager" || title == "Drag"
        return false
    
    ; 排除特定类名（如TopLevelWindowForOverflowXamlIsland）
    ;if class == "TopLevelWindowForOverflowXamlIsland"
    ;    return false
    
    return true
}


GetCurrentMonitor() {
    MouseGetPos &mouse_x, &mouse_y
    
    mon := 0
    monCount := MonitorGetCount()
    loop monCount
    {
        MonitorGet A_Index, &Left, &Top, &Right, &Bottom
        if (mouse_x >= left && mouse_x <= right && mouse_y >= top && mouse_y <= bottom) {
            mon := A_Index
            break
        }
    }
    ; 如果没找到显示器，返回主显示器
    if (mon = 0) {
        mon := MonitorGetPrimary()
    }
    return mon
}

GetWindowPlacement(hwnd) {
    ; WINDOWPLACEMENT 结构体
    ; 结构体定义：
    ;   UINT  length;      // 0
    ;   UINT  flags;       // 4
    ;   UINT  showCmd;     // 8
    ;   POINT ptMinPosition;  // 12 (两个LONG，共8字节)
    ;   POINT ptMaxPosition;  // 20 (两个LONG，共8字节)
    ;   RECT  rcNormalPosition; // 28 (四个LONG，共16字节)
    ; 总大小：28 + 16 = 44字节（32位和64位相同）
    
    ; 无论32位还是64位，偏移量都相同
    wpSize := 44
    rcNormalOffset := 28  ; rcNormalPosition 的偏移量
    
    wp := Buffer(wpSize, 0)
    NumPut("UInt", wpSize, wp, 0)  ; length 字段
    
    ; 调用 Windows API GetWindowPlacement
    result := DllCall("GetWindowPlacement", "Ptr", hwnd, "Ptr", wp.Ptr, "Int")
    
    if (result) {
        ; 解析结构体
        showCmd := NumGet(wp, 8, "UInt")  ; showCmd 在偏移量8处
        
        ; rcNormalPosition (RECT: left, top, right, bottom)
        ; RECT结构：left(4), top(4), right(4), bottom(4)
        left := NumGet(wp, rcNormalOffset, "Int")
        top := NumGet(wp, rcNormalOffset + 4, "Int")
        right := NumGet(wp, rcNormalOffset + 8, "Int")
        bottom := NumGet(wp, rcNormalOffset + 12, "Int")
        
        ; 检查是否为有效位置（排除-32000等特殊值）
        if (left <= -32000 || top <= -32000) {
            ; 这是最小化位置，不是恢复位置
            return {valid: false}
        }
        
        return {
            showCmd: showCmd,      ; 2=最小化, 3=最大化, 1=正常
            left: left,
            top: top,
            right: right,
            bottom: bottom,
            width: right - left,
            height: bottom - top,
            valid: true
        }
    }
    
    return {valid: false}
}



GetWindowsInMonitor() {
    wins := []
    MonitorGet GetCurrentMonitor(), &Left, &Top, &Right, &Bottom
    for win in WinGetList() {
        if !IsAltTabWindow(win)
            continue

        if InStr(WinGetClass(win), "tooltip")
            continue

        ; 检查窗口最小化状态
        WinGetMinMaxState := WinGetMinMax(win)

        if (WinGetMinMaxState = -1) {
            ; 最小化窗口：使用 GetWindowPlacement 获取恢复位置
            placement := GetWindowPlacement(win)
            if (placement.valid && placement.showCmd == 2) {  ; SW_SHOWMINIMIZED = 2
                ; 计算恢复位置的中心点
                centerX := placement.left + (placement.width / 2)
                centerY := placement.top + (placement.height / 2)
                
                ; 检查恢复位置是否在当前显示器内
                if (centerX >= Left && centerX <= Right && 
                    centerY >= Top && centerY <= Bottom) {
                    ; 位置在当前显示器内，添加到列表
                    title := WinGetTitle(win)
                    if (title != "" && title != "Program Manager" && 
                        WinGetClass(win) != "TopLevelWindowForOverflowXamlIsland" &&
                        WinGetTitle(win) != "Drag" && WinExist(win)) {
                        wins.push(win)
                    }
                }
            }
            ; 如果无法获取恢复位置，跳过该窗口
            continue
        }

        WinGetPos &X, &Y, &W, &H, win
        X := X + (W/2)
        
        ;ToolTip WinGetTitle(win) H W X Y
        
        if(X < (Right) && X > (Left)){
            title := WinGetTitle(win)
            if (title != "" && title != "Program Manager" && WinGetClass(win) != "TopLevelWindowForOverflowXamlIsland"
            && WinGetTitle(win) != "Drag" && WinExist(win)){
                wins.push(win)
            }
        }
    }
    return wins
}

changeWinOption(index){
    global myListView
    ; 取消所有选择
    myListView.Modify(0, "-Select")
    ; 选择指定索引的行
    myListView.Modify(index, "Select")
    ; 确保可见
    myListView.Modify(index, "Vis")
}

GetWindowIconHandle(windowHwnd) {
    ; 方法1: 尝试从窗口获取图标
    WM_GETICON := 0x7F
    hIcon := SendMessage(WM_GETICON, 1, 0, windowHwnd)  ; ICON_BIG = 1
    
    ; 如果没获取到大图标，尝试获取小图标
    if !hIcon {
        hIcon := SendMessage(WM_GETICON, 0, 0, windowHwnd)  ; ICON_SMALL = 0
    }
    
    ; 方法2: 从窗口类获取
    if !hIcon {
        hIcon := DllCall("GetClassLong" (A_PtrSize=8 ? "Ptr" : ""), "Ptr", windowHwnd, "Int", -14, "Ptr")  ; GCL_HICON = -14
    }
    
    if !hIcon {
        hIcon := DllCall("GetClassLong" (A_PtrSize=8 ? "Ptr" : ""), "Ptr", windowHwnd, "Int", -34, "Ptr")  ; GCL_HICONSM = -34
    }
    
    ; 方法3: 从进程文件获取图标（最可靠）
    if !hIcon {
        try {
            ; 获取进程可执行文件路径
            WinGetProcessPath &procPath, windowHwnd
            if (procPath != "") {
                ; 检查是否为UWP宿主进程（ApplicationFrameHost.exe），如果是则跳过，因为图标可能不是实际应用图标
                ; 对于其他进程（包括WindowsApps中的UWP应用），尝试提取图标
                if (!InStr(procPath, "ApplicationFrameHost.exe")) {
                    ; 使用ExtractIconEx获取不同尺寸的图标
                    ; 首先尝试获取大图标
                    hIconLarge := Buffer(A_PtrSize)
                    hIconSmall := Buffer(A_PtrSize)
                    
                    ; ExtractIconEx可以同时提取大图标和小图标
                    iconCount := DllCall("Shell32.dll\ExtractIconEx", "Str", procPath, "Int", 0, 
                                         "Ptr", hIconLarge.Ptr, "Ptr", hIconSmall.Ptr, "UInt", 1, "UInt")
                    
                    if (iconCount > 0) {
                        hIcon := NumGet(hIconLarge, 0, "Ptr")
                        ; 如果大图标无效，尝试小图标
                        if (!hIcon && NumGet(hIconSmall, 0, "Ptr")) {
                            hIcon := NumGet(hIconSmall, 0, "Ptr")
                        }
                    }
                    
                    ; 如果ExtractIconEx失败，回退到ExtractIcon
                    if (!hIcon) {
                        hIcon := DllCall("Shell32.dll\ExtractIcon", "Ptr", 0, "Str", procPath, "UInt", 0, "Ptr")
                        if (hIcon == 0 or hIcon == 1) {
                            hIcon := 0
                        }
                    }
                }
            }
        }
    }
    
    ; 方法4: 使用SHGetFileInfo获取关联图标
    if !hIcon {
        try {
            WinGetProcessPath &procPath, windowHwnd
            if (procPath != "") {
                ; 跳过UWP宿主进程，但允许其他进程
                if (!InStr(procPath, "ApplicationFrameHost.exe")) {
                    ; SHGetFileInfo需要SHFILEINFO结构
                    structSize := A_PtrSize == 8 ? 696 : 540  ; SHFILEINFO结构大小
                    shfi := Buffer(structSize, 0)
                    
                    flags := 0x100  ; SHGFI_ICON
                    flags |= 0x1    ; SHGFI_LARGEICON
                    
                    result := DllCall("Shell32.dll\SHGetFileInfo", "Str", procPath, "UInt", 0, 
                                     "Ptr", shfi.Ptr, "UInt", structSize, "UInt", flags, "UInt")
                    
                    if (result) {
                        ; 图标句柄在结构体中的偏移量
                        iconOffset := A_PtrSize == 8 ? 0 : 0  ; hIcon是第一个字段
                        hIcon := NumGet(shfi, iconOffset, "Ptr")
                    }
                }
            }
        }
    }
    
    ; 方法5: 对于UWP应用或图标获取失败，尝试从窗口标题获取应用名称并查找关联图标
    if !hIcon {
        try {
            ; 获取窗口标题
            title := WinGetTitle(windowHwnd)
            if (title != "") {
                ; 尝试从常见UWP应用标题映射到已知可执行文件
                ; 这里只处理几个常见应用作为示例
                mappedPath := ""
                if (InStr(title, "设置") || InStr(title, "Settings")) {
                    mappedPath := "C:\Windows\ImmersiveControlPanel\SystemSettings.exe"
                } else if (InStr(title, "计算器") || InStr(title, "Calculator")) {
                    mappedPath := "C:\Program Files\WindowsApps\Microsoft.WindowsCalculator_*"
                } else if (InStr(title, "相册") || InStr(title, "Photos")) {
                    mappedPath := "C:\Program Files\WindowsApps\Microsoft.Windows.Photos_*"
                }
                
                ; 如果找到映射路径，尝试提取图标
                if (mappedPath != "") {
                    ; 检查路径是否包含通配符
                    if (InStr(mappedPath, "*")) {
                        ; 使用通配符查找最新版本目录
                        found := false
                        Loop Files, mappedPath, "D" {
                            exePath := A_LoopFileFullPath "\App.exe"
                            if (FileExist(exePath)) {
                                ; 尝试从该exe提取图标
                                hIcon := DllCall("Shell32.dll\ExtractIcon", "Ptr", 0, "Str", exePath, "UInt", 0, "Ptr")
                                if (hIcon == 0 or hIcon == 1) {
                                    hIcon := 0
                                }
                                if (hIcon) {
                                    found := true
                                    break
                                }
                            }
                        }
                        if (found) {
                            return hIcon
                        }
                    } else {
                        ; 直接使用文件路径
                        if (FileExist(mappedPath)) {
                            hIcon := DllCall("Shell32.dll\ExtractIcon", "Ptr", 0, "Str", mappedPath, "UInt", 0, "Ptr")
                            if (hIcon == 0 or hIcon == 1) {
                                hIcon := 0
                            }
                            if (hIcon) {
                                return hIcon
                            }
                        }
                    }
                }
            }
        }
    }
    
    ; 方法6: 加载系统默认应用程序图标
    if !hIcon {
        ; 加载标准应用程序图标（IDI_APPLICATION = 32512）
        hIcon := DllCall("LoadImage", "Ptr", 0, "Ptr", 32512, "UInt", 1, "Int", 0, "Int", 0, "UInt", 0x8000)  ; LR_SHARED
    }
    
    return hIcon
}

EnableBlurEffect(hwnd) {
    ; 启用毛玻璃效果
    static DWMWA_USE_IMMERSIVE_DARK_MODE := 20
    static DWMWA_WINDOW_CORNER_PREFERENCE := 33
    static DWMWA_SYSTEMBACKDROP_TYPE := 38
    
    ; 设置窗口背景为透明，允许DWM绘制
    ; WinSetTransColor("242424 0", hwnd)  ; 使该颜色完全透明
    
    ; 尝试使用DWM设置毛玻璃效果（Windows 10/11）
    try {
        ; 设置窗口角为圆角
        cornerPreference := 2  ; DWMWCP_ROUND
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", DWMWA_WINDOW_CORNER_PREFERENCE, "int*", cornerPreference, "int", 4)
        
        ; 设置亚克力背景（Windows 11）
        backdropType := 3  ; DWMSBT_ACRYLIC
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", DWMWA_SYSTEMBACKDROP_TYPE, "int*", backdropType, "int", 4)
        
        ; 设置深色模式
        darkMode := 1
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", DWMWA_USE_IMMERSIVE_DARK_MODE, "int*", darkMode, "int", 4)
        
        ; 旧版模糊效果（Windows 10）
        blurBehind := Buffer(16, 0)  ; DWM_BLURBEHIND结构
        NumPut("UInt", 0x3, blurBehind, 0)   ; dwFlags: DWM_BB_ENABLE | DWM_BB_BLURREGION
        NumPut("UInt", 1, blurBehind, 4)     ; fEnable: TRUE
        DllCall("dwmapi\DwmEnableBlurBehindWindow", "ptr", hwnd, "ptr", blurBehind.Ptr)
    }
    
    ; 设置轻微透明度
    WinSetTransparent(240, hwnd)
}

SetRoundedCorners(hwnd, width := 800, height := 600, radius := 10) {
    ; 创建圆角区域
    rgn := DllCall("CreateRoundRectRgn", "int", 0, "int", 0, "int", width, "int", height, "int", radius, "int", radius)
    DllCall("SetWindowRgn", "ptr", hwnd, "ptr", rgn, "int", true)
}

createTabsGUI(){
    global mygui
    global myListView
    global hIL
    global optIndex
    
    ; 清理之前的资源
    if (IsSet(mygui) && mygui) {
        try mygui.Destroy()
        mygui := 0
    }
    if (IsSet(hIL) && hIL) {
        try IL_Destroy(hIL)
        hIL := 0
    }

    global windows := GetWindowsInMonitor()

    if (windows.Length = 0){
        return
    }
    
    mygui := Gui("-Caption -Border -SysMenu -ToolWindow +AlwaysOnTop +E0x80000 -DPIScale", , )  ; 移除所有装饰，禁用DPI缩放
    MyGui.BackColor := "24242400"  ; 完全透明，让毛玻璃效果显示
    MyGui.SetFont("s14", "Segoe UI")
    MyGui.MarginX := 0
    MyGui.MarginY := 0
    
    ; 创建ImageList用于图标，使用大图标列表（系统大图标尺寸，通常32x32或更大）
    hIL := IL_Create(10, 5, true)  ; 初始容量10，增长数5，大图标列表
    ; 动态计算行数，限制最大15行
    maxRows := 15
    rows := windows.Length + 2
    if (rows > maxRows)
        rows := maxRows
    ; 创建ListView，设置样式为报告视图，动态行数，设置背景色和文本颜色，隐藏标题
    myListView := MyGui.Add("ListView", "w810 r" rows " +Report -Wrap -Hdr -Grid Background00000000 cFFFFFF", ["活动列表"])
    ; 将ImageList分配给ListView，并指定为小图标列表（覆盖默认，使报告视图显示大图标）
    myListView.SetImageList(hIL, 1)
    ; 设置选中项的颜色
    try myListView.SetColor("Select", "33AA33")
    try myListView.SetColor("SelectText", "FFFFFF")
    ; 添加点击事件
    myListView.OnEvent("Click", OnListViewClickFunc)
    

    
    ; 遍历窗口，添加图标和标题
    for (w in windows){
        if(!WinExist(w)) {
            continue
        }
        hIcon := GetWindowIconHandle(w)
        iconIndex := 0
        if (hIcon){
            iconIndex := IL_Add(hIL, "HICON:" hIcon)
        }
        ; 添加行，图标索引为1-based，0表示无图标
        options := iconIndex ? "Icon" . iconIndex : ""
        myListView.Add(options, WinGetTitle(w))
    }
    ; 添加完所有行后设置列宽和对齐方式
    myListView.ModifyCol(1, 797)  ; 图标列宽，总宽800减去边距
    myListView.Redraw()
    ; 确保optIndex在有效范围内
    if (optIndex < 1 || optIndex > windows.Length){
        optIndex := windows.Length >= 2 ? 2 : 1
    }
    myListView.Modify(optIndex, "Select")
    ; 获取当前显示器的工作区边界
    MonitorGetWorkArea GetCurrentMonitor(), &Left, &Top, &Right, &Bottom
    ; 隐藏显示以获取窗口和客户区尺寸
    mygui.Show("Hide")
    ; 获取窗口实际尺寸
    mygui.GetPos(&winX, &winY, &winW, &winH)
    ; 获取客户区位置和尺寸（屏幕坐标）
    WinGetClientPos(&clientX, &clientY, &clientW, &clientH, mygui.Hwnd)
    ; 计算边框厚度
    borderLeft := clientX - winX
    borderTop := clientY - winY
    ; 计算客户区居中位置
    targetClientX := Left + ((Right - Left) / 2) - (clientW / 2)
    targetClientY := Top + ((Bottom - Top) / 2) - (clientH / 2)
    ; 计算窗口位置使客户区居中
    newX := targetClientX - borderLeft
    newY := targetClientY - borderTop
    ; 显示窗口在中央
    mygui.Show("x" newX " y" newY)
    
    ; 应用圆角和毛玻璃效果（使用窗口尺寸）
    try SetRoundedCorners(mygui.Hwnd, winW, winH, 12)
    try EnableBlurEffect(mygui.Hwnd)
}

!Tab::{
    CoordMode "Mouse" , "Screen"
    global optIndex := 2
    global guiClosedByClick := false
    createTabsGUI()
    ; 确保optIndex不超过窗口数量
    if (windows.Length = 0){
        ToolTip "当前显示器没有可用窗口"
        SetTimer () => ToolTip(), -1000
        return
    }
    if (optIndex > windows.Length){
        optIndex := windows.Length
    }


    first := 1
    while(GetKeyState("LAlt", "P") && !guiClosedByClick && (IsSet(mygui) && mygui)){
        if(GetKeyState("Tab", "p")){
            if(first = 0) {
                first := 1
                optIndex := optIndex + 1
                if(optIndex > windows.Length){
                    optIndex := 1
                }
               changeWinOption(optIndex) 
            }
        } else {
            first := 0
        }

        ; 短暂休眠以减少CPU占用
        Sleep(10)
    }
    ; 如果GUI被点击关闭，则不执行激活操作（点击事件已处理）
    if (guiClosedByClick) {
        return
    }

    ; 激活选中的窗口并清理资源
    ActivateWindowAndCleanup(optIndex, false)
}

