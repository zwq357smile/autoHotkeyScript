#Requires AutoHotkey v2.0
;鼠标侧键：前进+滚轮=横向滚动
;鼠标侧键：后退+滚轮=F3 / shift + F3
;鼠标侧键：前进键映射到shift + numlock（防止单按shift会导致输入法切换中英文） 
;Alt 后退键 => F12

; 全局变量
g_sideButtonHeld := false
g_wheelUsed := false
g_button := 2

; 侧键1按下(后退键)
XButton1::
{
    global g_sideButtonHeld := true
    global g_wheelUsed := false
    global g_button := 1
    
    ;什么也不做
    
}

; 侧键2按下(前进键)
XButton2::
{
    global g_sideButtonHeld := true
    global g_wheelUsed := false
    global g_button := 2
    
    ; 按下侧键时立即发送 Shift+NumLock
    Send "{LShift Down}{NumLock Down}"
    
}

; 侧键1释放
XButton1 Up::
{
    global g_sideButtonHeld, g_wheelUsed
    
    ; 如果没有使用滚轮，发送原功能
    if (!g_wheelUsed) {
        Send "{XButton1}"
    }
    
    ; 重置状态
    g_sideButtonHeld := false
    g_wheelUsed := false
}

; 侧键2释放
XButton2 Up::
{
    global g_sideButtonHeld, g_wheelUsed
    
    
    ; 松开修饰键
    Send "{LShift Up}{NumLock Up}"
    
    ; 如果没有使用滚轮，发送原功能
    if (!g_wheelUsed) {
        Send "{XButton2}"
    }
    
    ; 重置状态
    g_sideButtonHeld := false
    g_wheelUsed := false
}


#HotIf g_sideButtonHeld && g_button == 1
WheelUp::
{
    global g_wheelUsed := true
    
    Send "+{F3}"
    
}

WheelDown::
{
    global g_wheelUsed := true

    Send "{F3}"
}

#HotIf

#HotIf g_sideButtonHeld && g_button == 2
+WheelUp::
{
    global g_wheelUsed := true
    global g_button
    
    Send "{WheelUp}"
}

+WheelDown::
{
    global g_wheelUsed := true
    global g_button

    Send "{WheelDown}"
}


~+F3::UpdateKeyPress()
~+LButton::UpdateKeyPress()

;防止松开侧键时触发原本的功能
UpdateKeyPress() {
    global g_wheelUsed := true
}
#HotIf

;alt 后退键 => f12
!XButton1::F12



; Shift + Backspace => 屏蔽 Backspace，只保留 Shift
#HotIf !g_sideButtonHeld  ; 不在鼠标侧键模式下生效

; 当按下 Shift 时检查 Backspace 状态
LShift::
{
    if GetKeyState("Backspace", "P") {
        ; Backspace 也被按下，屏蔽 Backspace，发送 Shift
        Send "{LShift}"
        return
    }
    Send "{LShift Down}"
}

; 释放 Shift 时
LShift Up::
{
    if GetKeyState("Backspace", "P") {
        ; Backspace 还按着，什么都不做
        return
    }
    Send "{LShift Up}"
}

#HotIf


; 两次滚轮间隔小于这个时间(ms)就认为是快速滚动
fastThreshold := 22

; 快速滚动倍数
fastMultiplier := 6

lastScrollTime := 0

timer := 0

isFaster := false

HandleScroll(direction)
{
    global lastScrollTime, fastThreshold, fastMultiplier, timer, isFaster

    now := A_TickCount
    interval := now - lastScrollTime
    lastScrollTime := now

    if (interval < fastThreshold)
        isFaster := true
    clearTimeout(timer)
    timer := setTimeout(ResetIsFaster, 50)

    multiplier := isFaster ? fastMultiplier :  1

    Loop multiplier
        Send "{" direction "}"
}

resetIsFaster() {
    global isFaster
    isFaster := false
}

setTimeout(callback, ms) {
    f := callback
    SetTimer(f, -ms)
    return f
}
clearTimeout(id) {
    if IsInteger(id)
        return
    SetTimer(id, 0)
}

WheelUp::
{
    HandleScroll("WheelUp")
}

WheelDown::
{
    HandleScroll("WheelDown")
}

; Trae中将鼠标中键映射为Ctrl+Alt+B
#HotIf WinActive("ahk_exe Trae CN.exe")
MButton::Send("^!b")
#HotIf