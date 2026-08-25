#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

;@Ahk2Exe-SetMainIcon FoxholeMultiBoxerIcon.ico

global APP_NAME := "Foxhole Multiboxer"
global APP_VERSION := "0.1"
global APP_TITLE := APP_NAME " v" APP_VERSION
global CONFIG_DIR := A_AppData "\" APP_NAME
global CONFIG_FILE := CONFIG_DIR "\Settings.ini"

global ActionNames := ["AutoClick", "AutoWalk", "AutoReverse", "ClickHold", "RightHold", "VSpam", "MouseFocus", "SwitchSlot", "Swap"]
global ActionLabels := Map(
    "AutoClick", "Auto-Click",
    "AutoWalk", "Forward / W",
    "AutoReverse", "Reverse / S",
    "ClickHold", "Left Click Hold",
    "RightHold", "Right Click Hold",
    "VSpam", "V Spam",
    "MouseFocus", "Mouse Focus",
    "SwitchSlot", "Switch Slot",
    "Swap", "Swap"
)
global DefaultKeys := Map(
    "AutoClick", "F2",
    "AutoWalk", "F3",
    "AutoReverse", "F4",
    "ClickHold", "F5",
    "RightHold", "F6",
    "VSpam", "F7",
    "MouseFocus", "F9",
    "SwitchSlot", "F8",
    "Swap", "F10"
)
global CurrentKeys := Map()

global Instances := []
global SelectedIndex := 0
global MouseFocusEnabled := false
global HoverFocusedHwnd := 0
global HotkeyTooltipTimer := 0
global SwitchSlotMenuGui := ""
global SwitchSlotMenuList := ""
global SwitchSlotMenuHwnd := 0
global SwitchSlotMenuTargetHwnd := 0
global SwitchSlotMenuDismissTimer := 0
global SwapWindowMenuGui := ""
global SwapWindowMenuList := ""
global SwapWindowMenuHwnd := 0
global SwapWindowMenuTargetHwnd := 0
global SwapWindowMenuEntries := []
global SwapWindowMenuDismissTimer := false
global TitleOverlays := Map()
global MaxPracticalInstances := 32

global SandboxiePopupWatcherIntervalMs := 250
global SandboxiePopupLastHandledHwnd := 0
global SandboxiePopupLastHandledAt := 0
global SandboxieSteamMinimizeBoxes := Map()

global FoxholeWindowEventHook := 0
global FoxholeWindowEventCallback := 0
global FoxholeDiscoveryMessage := 0xB7A1
global FoxholeDiscoveryMessageQueued := false
global FoxholeDiscoveryInProgress := false
global FoxholeDiscoveryPending := false

global LayoutPositionWatcherActive := false
global LayoutPositionWatcherBusy := false
global LayoutWindowPositions := Map()
global LayoutReapplyPending := false
global LayoutSwapInProgress := false

global MainAlwaysOnTopCheck := ""
global ShowOverlayCheck := ""
global HotkeysAlwaysOnTopCheck := ""
global SandboxieAlwaysOnTopCheck := ""

global MainGui := ""
global HotkeysGui := ""
global LV := ""
global StatusText := ""
global MainTipText := ""
global MainTipIndex := 1
global MainDynamicControls := []
global MainVisibleTableRows := 0
global MainMaxVisibleTableRows := 10
global BannerDefinitions := [
    { fileName: "Airborne.png", displayName: "Airborne" },
    { fileName: "Entrenched.png", displayName: "Entrenched" },
    { fileName: "Naval.png", displayName: "Naval" },
    { fileName: "Inferno.png", displayName: "Inferno" },
    { fileName: "TrenchWarfare.png", displayName: "Trench Warfare" },
    { fileName: "WarMachine.png", displayName: "War Machine" },
    { fileName: "WinterArmy.png", displayName: "Winter Army" }
]
global AvailableBanners := []
global BannerAssetDir := ""
global RuntimeAssetDir := ""
global APP_ICON_PATH := ""
global BannerPicture := ""
global BannerDropDown := ""
global CurrentBannerFile := ""
global BannerVisible := false
global MainTips := [
    'Anytime Steam or Foxhole updates, press the "Reset and Relaunch Steam" button below!',
    "If you have any bugs, feature ideas, or questions, then DM Tommythebold on Discord!"
]
global SBGui := ""
global SandboxieRowCountEdit := ""
global SandboxieRows := []
global SandboxieAccounts := []
global SandboxieRowCount := 1
global MaxSandboxieRows := 50
global SandboxieSteamAllButton := ""
global SandboxieFoxholeAllButton := ""
global SandboxieDeleteAllButton := ""
global MainCloseSteamButton := ""
global MainRelaunchSteamButton := ""
global MainLaunchSteamButton := ""
global MainLaunchFoxholeButton := ""
global MainCloseFoxholeButton := ""
global GuiTooltips := Map()
global GuiLastTooltipHwnd := 0
global SandboxieSetupAllButton := ""
global SandboxieStatusTimerMs := 1000
global SandboxieStatusTimerActive := false
global SandboxieStatusDll := 0
global SandboxieStatusEnumProc := 0
global SandboxieSettingsGui := ""
global SequentialLaunchActive := false
global SequentialLaunchQueue := []
global SequentialLaunchPosition := 0
global SequentialLaunchExpectedSlot := 0
global SequentialLaunchSkipped := 0
global SequentialLaunchBaseline := Map()
global SequentialLaunchCandidateHwnd := 0
global SequentialLaunchStablePolls := 0
global SequentialLaunchStartedAt := 0
global SequentialLaunchTimeoutMs := 900000
global PendingFoxholeRenameActive := false
global PendingFoxholeRenameIndex := 0
global PendingFoxholeRenameBaseline := Map()
global PendingFoxholeRenameStartedAt := 0
global PendingFoxholeRenameTimeoutMs := 900000
global IntervalEdits := Map()
global IntervalSettings := Map(
    "AutoClick", "ClickInterval",
    "AutoWalk", "WalkInterval",
    "AutoReverse", "ReverseInterval",
    "ClickHold", "LeftHoldInterval",
    "RightHold", "RightHoldInterval",
    "VSpam", "VSpamInterval"
)
global IntervalMinimums := Map(
    "AutoClick", 10,
    "AutoWalk", 10,
    "AutoReverse", 10,
    "ClickHold", 5,
    "RightHold", 20,
    "VSpam", 10
)
global DefaultIntervals := Map(
    "AutoClick", 50,
    "AutoWalk", 50,
    "AutoReverse", 50,
    "ClickHold", 50,
    "RightHold", 50,
    "VSpam", 50
)
global LayoutEditorGui := ""
global LayoutEditorSlots := []
global LayoutEditorValueCtrls := []
global LayoutEditorSlotControls := []
global LayoutEditorCombo := ""
global LayoutEditorSelectedLayout := 0
global LayoutEditorOverlays := Map()
global LayoutEditorAlwaysOnTopCheck := ""
global Layouts := []

global RebindStatus := ""
global RebindingAction := ""
global RebindReleaseKeys := []
global RebindButtons := Map()
global PollKeyList := []
global ModifierKeyDefs := [
    { symbol: "^", keys: ["LControl", "RControl"] },
    { symbol: "+", keys: ["LShift", "RShift"] },
    { symbol: "!", keys: ["LAlt", "RAlt"] },
    { symbol: "#", keys: ["LWin", "RWin"] }
]

global Settings := Map(
    "ClickInterval", 50,
    "WalkInterval", 50,
    "ReverseInterval", 50,
    "LeftHoldInterval", 50,
    "RightHoldInterval", 50,
    "VSpamInterval", 50,
    "DefaultClickX", 0,
    "DefaultClickY", 0,
    "MainAlwaysOnTop", false,
    "ShowOverlay", true,
    "HotkeysAlwaysOnTop", false,
    "SandboxieAlwaysOnTop", false,
    "SandboxieSandManExe", "C:\Program Files\Sandboxie-Plus\SandMan.exe",
    "SandboxieSteamExe", "C:\Program Files (x86)\Steam\steam.exe",
    "SandboxieFoxholeExe", "",
    "LayoutEditorAlwaysOnTop", false,
    "LastLayoutName", "",
    "BannerSelection", "Random"
)

if !DirExist(CONFIG_DIR)
    DirCreate(CONFIG_DIR)

PrepareBannerAssets()
SetApplicationIcon()
LoadConfig()
BuildMainGui()
ApplyAllHotkeys()
ScanWindows()

if LayoutEditorSelectedLayout >= 1 && LayoutEditorSelectedLayout <= Layouts.Length
    ApplySelectedLayout(false)
InitializeFoxholeWindowWatcher()
InitializeLayoutPositionWatcher()

OnMessage(0x84, LayoutPreviewHitTest, -1)
SetTimer(InitialWindowDiscovery, -1500)
SetTimer(MaintainTitleOverlays, 250)

SetTimer(MonitorSandboxieSupporterPopup, SandboxiePopupWatcherIntervalMs)
SetTimer(MinimizeLaunchedSandboxieSteamWindows, 250)
SetTimer(MonitorGuiTooltips, 100)
OnExit(CleanupAll)

LayoutPreviewHitTest(wParam, lParam, msg, hwnd)
{
    global LayoutEditorOverlays

    if IsObject(LayoutEditorOverlays) && LayoutEditorOverlays.Has(hwnd)
        return -1
}

RegisterTooltip(ctrl, provider)
{
    global GuiTooltips
    if !IsObject(ctrl) || !ctrl.Hwnd
        return ctrl
    GuiTooltips[ctrl.Hwnd] := provider
    return ctrl
}

UnregisterTooltip(ctrl)
{
    global GuiTooltips
    if IsObject(ctrl) && ctrl.Hwnd && GuiTooltips.Has(ctrl.Hwnd)
        GuiTooltips.Delete(ctrl.Hwnd)
}

MonitorGuiTooltips(*)
{
    global GuiTooltips, GuiLastTooltipHwnd

    hoveredControlHwnd := 0
    try MouseGetPos(,,, &hoveredControlHwnd, 2)

    if hoveredControlHwnd && GuiTooltips.Has(hoveredControlHwnd)
    {
        if GuiLastTooltipHwnd != hoveredControlHwnd
        {
            provider := GuiTooltips[hoveredControlHwnd]
            text := ""
            try text := IsObject(provider) ? provider.Call() : String(provider)
            if text != ""
                ToolTip(text, , , 20)
            GuiLastTooltipHwnd := hoveredControlHwnd
        }
        return
    }

    if GuiLastTooltipHwnd
    {
        ToolTip("", , , 20)
        GuiLastTooltipHwnd := 0
    }
}

JoinTooltipNames(names)
{
    if names.Length = 0
        return "None"
    text := ""
    for index, name in names
        text .= (index > 1 ? ", " : "") name
    return text
}

GetSelectedSandboxieAccountNames()
{
    global SandboxieAccounts
    names := []
    for account in SandboxieAccounts
    {
        name := Trim(account.name)
        if account.selected && name != ""
            names.Push(name)
    }
    return names
}

MainBulkTooltip(action)
{
    names := GetSelectedSandboxieAccountNames()
    list := JoinTooltipNames(names)
    if action = "RelaunchSteam"
        return "Reset the sandboxes for all Selected accounts, then launch Steam for them in row order.`nSelected accounts: " names.Length "`nAccounts: " list "`nUse this after Steam or Foxhole updates; finish the normal update first."
    if action = "LaunchSteam"
        return "Launch Steam for every Selected account in row order.`nSelected accounts: " names.Length "`nAccounts: " list "`nSandboxed accounts launch inside their sandboxes. The selected Main account uses normal Steam; if it is already running, it is skipped and not brought into focus."
    return "Launch Foxhole for every Selected account, one at a time.`nSelected accounts: " names.Length "`nAccounts: " list "`nEach launch waits for the previous Foxhole window to appear."
}

MainCloseSteamTooltip(*)
{
    global SandboxieAccounts
    runningBoxes := []
    processCount := 0

    for account in SandboxieAccounts
    {
        boxName := Trim(account.name)
        if account.main || !IsValidSandboxieName(boxName)
            continue

        pids := GetSandboxieBoxPids(boxName)
        if pids.Length
        {
            runningBoxes.Push(boxName)
            processCount += pids.Length
        }
    }

    return "Terminate every program currently running inside the configured sandboxes.`nRunning sandbox processes: " processCount "`nActive sandboxes: " runningBoxes.Length "`nAccounts: " JoinTooltipNames(runningBoxes) "`nSandbox contents are not deleted, and normal unsandboxed programs are not affected."
}

MainCloseFoxholeTooltip(*)
{
    windows := WinGetList("ahk_exe War-Win64-Shipping.exe")
    names := []
    for hwnd in windows
    {
        title := ""
        try title := Trim(WinGetTitle("ahk_id " hwnd))
        names.Push(title != "" ? title : "Foxhole window " hwnd)
    }
    return "Close all open Foxhole game windows.`nFoxhole windows found: " windows.Length "`nWindows: " JoinTooltipNames(names)
}

AlwaysOnTopTooltip(checkCtrl, windowName)
{
    return checkCtrl.Value
        ? windowName " will remain above other windows."
        : windowName " can be covered by other windows."
}

OverlayTooltip()
{
    global ShowOverlayCheck, TitleOverlays
    return (ShowOverlayCheck.Value ? "Foxhole title overlays are enabled." : "Foxhole title overlays are hidden.")
        . "`nActive overlays: " TitleOverlays.Count
}

MainListTooltip()
{
    global LV, Instances
    row := 0
    try row := LV.GetNext(0, "F")
    if row < 1 || row > Instances.Length
        return "Detected Foxhole windows controlled by the multiboxer.`nSelect a row to make that window the current target."
    inst := Instances[row]
    account := GetAccountNameForInstance(inst)
    if account = ""
        account := "Not assigned"
    return "Slot: " inst.slot "`nAccount: " account "`nWindow: " inst.title "`nPosition: X " inst.x ", Y " inst.y "`nSize: " inst.width " x " inst.height
}

LayoutManagerTooltip(action)
{
    global LayoutEditorSelectedLayout, Layouts, LayoutEditorSlots
    name := (LayoutEditorSelectedLayout >= 1 && LayoutEditorSelectedLayout <= Layouts.Length) ? Layouts[LayoutEditorSelectedLayout].name : "No layout selected"
    if action = "Combo"
        return "Choose a saved layout. Selecting one immediately applies it.`nCurrent layout: " name
    if action = "Save"
        return "Save the current " LayoutEditorSlots.Length " slot definitions as a new named layout.`nThis does not overwrite the selected layout."
    if action = "Update"
        return LayoutEditorSelectedLayout ? "Overwrite '" name "' with the positions and sizes shown below." : "Select a saved layout before updating it."
    if action = "Delete"
        return LayoutEditorSelectedLayout ? "Permanently delete the saved layout '" name "'." : "Select a saved layout before deleting it."
    if action = "Add"
        return "Add the next available slot on the primary monitor using X 0, Y 0, W 960, H 540."
    return "Show or hide preview rectangles for all " LayoutEditorSlots.Length " layout slots."
}

LayoutSlotTooltip(index, action, prop := "", delta := 0)
{
    global LayoutEditorSlots, LayoutEditorOverlays
    if index < 1 || index > LayoutEditorSlots.Length
        return "Layout slot control."
    slot := LayoutEditorSlots[index]
    rect := "Monitor " slot.monitor ", X " slot.x ", Y " slot.y ", W " slot.width ", H " slot.height
    if action = "Header"
        return "Slot " slot.slot "`n" rect "`nPreview: " (LayoutEditorOverlays.Has(slot.slot) ? "Visible" : "Hidden")
    if action = "Monitor"
        return "Choose which monitor owns Slot " slot.slot ".`nX and Y are measured from that monitor's top-left corner.`n" rect
    if action = "Show"
        return (LayoutEditorOverlays.Has(slot.slot) ? "Hide" : "Show") " the click-through preview rectangle for Slot " slot.slot ".`n" rect
    if action = "Remove"
        return "Remove Slot " slot.slot " from this layout.`nThis does not close the actual Foxhole window."
    if action = "Match"
        return "Copy Slot " slot.slot "'s monitor, position, and size to every slot below it.`nSource: " rect "`nAffected slots: " Max(0, LayoutEditorSlots.Length - index)
    value := prop = "x" ? slot.x : prop = "y" ? slot.y : prop = "width" ? slot.width : slot.height
    label := prop = "x" ? "X position" : prop = "y" ? "Y position" : prop = "width" ? "Width" : "Height"
    if action = "Value"
        return label " of Slot " slot.slot ": " value " pixels."
    direction := delta < 0 ? "Decrease" : "Increase"
    if prop = "x"
        direction := delta < 0 ? "Move left" : "Move right"
    else if prop = "y"
        direction := delta < 0 ? "Move up" : "Move down"
    return direction " Slot " slot.slot " by " Abs(delta) " pixels.`nCurrent " label ": " value
}

HotkeyActionTooltip(action)
{
    global CurrentKeys, Settings, IntervalSettings, MouseFocusEnabled
    descriptions := Map(
        "AutoClick", "Toggle repeated left-clicking in the controlled Foxhole window.",
        "AutoWalk", "Toggle repeated W input in the controlled Foxhole window.",
        "AutoReverse", "Toggle repeated S input in the controlled Foxhole window.",
        "ClickHold", "Toggle holding the left mouse button in the controlled Foxhole window.",
        "RightHold", "Toggle holding the right mouse button in the controlled Foxhole window.",
        "VSpam", "Toggle repeated V input in the controlled Foxhole window.",
        "MouseFocus", "Toggle mouse-hover focus mode for controlled Foxhole windows.",
        "SwitchSlot", "Assign the focused Foxhole window to another numbered slot without moving it.",
        "Swap", "Swap positions and sizes with another Foxhole window without changing slot assignments."
    )
    text := "Current key: " DisplayNameForHotkeyString(CurrentKeys[action]) "`nClick to rebind.`n" descriptions[action]
    if IntervalSettings.Has(action)
        text .= "`nCurrent interval: " Settings[IntervalSettings[action]] " ms"
    if action = "MouseFocus"
        text .= "`nCurrent state: " (MouseFocusEnabled ? "Enabled" : "Disabled")
    return text
}

HotkeyResetTooltip(action)
{
    global CurrentKeys, DefaultKeys, ActionLabels
    return "Reset " ActionLabels[action] " from " DisplayNameForHotkeyString(CurrentKeys[action]) " to " DisplayNameForHotkeyString(DefaultKeys[action]) "."
}

IntervalTooltip(action, reset := false)
{
    global Settings, IntervalSettings, IntervalMinimums, DefaultIntervals, ActionLabels
    current := Settings[IntervalSettings[action]]
    if reset
        return "Reset " ActionLabels[action] " interval from " current " ms to " DefaultIntervals[action] " ms."
    return "Delay for " ActionLabels[action] ": " current " ms.`nMinimum: " IntervalMinimums[action] " ms.`nLower values repeat faster; the value saves when the field loses focus."
}

SandboxieSummaryTooltip(action)
{
    global SandboxieAccounts, MaxSandboxieRows, SandboxieRowCountEdit
    if action = "RowsEdit"
        return "Number of account rows to display: " SandboxieRowCountEdit.Value ".`nMaximum supported rows: " MaxSandboxieRows ".`nPress Rows to apply the change."
    if action = "Rows"
        return "Rebuild the account table with " SandboxieRowCountEdit.Value " rows.`nExisting saved account data is preserved where possible."
    valid := [], selected := []
    for account in SandboxieAccounts
    {
        name := Trim(account.name)
        if name != ""
            valid.Push(name)
        if account.selected && name != ""
            selected.Push(name)
    }
    if action = "Setup"
        return "Create or configure a Sandboxie box for every valid non-main account.`nConfigured accounts: " valid.Length "`nEnables required settings including Emulate Admin Rights."
    if action = "Reset"
        return "Delete the contents of every configured non-main account sandbox.`nConfigured accounts: " valid.Length "`nThis does not delete the sandbox definitions."
    if action = "Steam"
        return "Launch Steam for all Selected accounts in row order.`nSelected accounts: " selected.Length "`nAccounts: " JoinTooltipNames(selected)
    return "Launch Foxhole for all Selected accounts, one at a time.`nSelected accounts: " selected.Length "`nAccounts: " JoinTooltipNames(selected)
}

SandboxieAccountTooltip(index, kind)
{
    global SandboxieAccounts
    if index < 1 || index > SandboxieAccounts.Length
        return "Account row control."
    account := SandboxieAccounts[index]
    name := Trim(account.name)
    display := name != "" ? name : "Not configured"
    if kind = "Row"
        return "Account row " index "`nName: " display "`nType: " (account.main ? "Main" : "Sandboxed") "`nSelected: " (account.selected ? "Yes" : "No")
    if kind = "Name"
        return "Account " index ": " display "`nExpected Foxhole title: War " index " - " display "`nSandbox names must contain 1-32 letters or numbers."
    if kind = "Steam"
        return account.main ? "Launch normal unsandboxed Steam for " display ".`nIf already open, it will not be brought forward." : "Launch Steam inside sandbox '" display "' using SandMan.exe.`nCredentials saved: " ((account.steamUsername != "" && name != "" && GetSteamCredentialPassword(name) != "") ? "Yes" : "No")
    if kind = "Cred"
        return account.steamUsername != "" ? "Edit or clear the Steam credentials saved for " display ".`nThe password is stored in Windows Credential Manager." : "Save Steam credentials for " display " in Windows Credential Manager.`nThe password is not stored in Settings.ini."
    if kind = "Foxhole"
        return (account.main ? "Launch Foxhole normally for main account " : "Launch Foxhole inside sandbox '") display (account.main ? "." : "'.") "`nExpected slot: " index "`nExpected title: War " index " - " display
    if kind = "Main"
        return account.main ? display " is the Main account and launches outside Sandboxie." : "Mark " display " as the single Main account.`nThis clears the previous Main selection."
    return account.selected ? display " is included in bulk launch and relaunch actions." : display " is excluded from bulk launch and relaunch actions."
}

SandboxieProgramStatusTooltip(index, product)
{
    global SandboxieAccounts, Settings
    if index < 1 || index > SandboxieAccounts.Length
        return product " status is unavailable."
    account := SandboxieAccounts[index]
    name := Trim(account.name)
    display := name != "" ? name : "account " index
    exePath := product = "Steam" ? Settings["SandboxieSteamExe"] : Settings["SandboxieFoxholeExe"]
    exeName := GetExecutableBaseName(exePath)
    running := false
    if account.main
        running := exeName != "" && IsProcessImageRunning(exeName)
    else if IsValidSandboxieName(name)
    {
        processes := GetSandboxieProcessNames(name)
        running := exeName != "" && processes.Has(StrLower(exeName))
    }
    return product " for " display ": " (running ? "Running" : "Not running") "`nMode: " (account.main ? "Main unsandboxed" : "Sandbox '" display "'")
}

PathTooltip(editCtrl, label, expected := "")
{
    path := Trim(editCtrl.Value)
    text := label " path: " (path != "" ? path : "Not set") "`nFile found: " (path != "" && FileExist(path) ? "Yes" : "No")
    if expected != ""
        text .= "`nExpected file: " expected
    return text
}

InitializeFoxholeWindowWatcher()
{
    global MainGui, FoxholeWindowEventHook, FoxholeWindowEventCallback, FoxholeDiscoveryMessage

    if FoxholeWindowEventHook
        return true

    if !IsObject(MainGui) || !MainGui.Hwnd
        return false

    OnMessage(FoxholeDiscoveryMessage, FoxholeWindowEventMessage, 1)

    FoxholeWindowEventCallback := CallbackCreate(FoxholeWinEventCallback, , 7)
    FoxholeWindowEventHook := DllCall("SetWinEventHook",
        "UInt", 0x8000,
        "UInt", 0x8002,
        "Ptr", 0,
        "Ptr", FoxholeWindowEventCallback,
        "UInt", 0,
        "UInt", 0,
        "UInt", 0x0002,
        "Ptr")

    if !FoxholeWindowEventHook
    {
        try OnMessage(FoxholeDiscoveryMessage, FoxholeWindowEventMessage, 0)
        CallbackFree(FoxholeWindowEventCallback)
        FoxholeWindowEventCallback := 0
        return false
    }

    return true
}

FoxholeWinEventCallback(hook, event, hwnd, idObject, idChild, eventThread, eventTime)
{
    global MainGui, FoxholeDiscoveryMessage, FoxholeDiscoveryMessageQueued

    if idObject != 0 || idChild != 0
        return 0

    if !IsObject(MainGui) || !MainGui.Hwnd
        return 0

    if FoxholeDiscoveryMessageQueued
        return 0

    FoxholeDiscoveryMessageQueued := true
    try PostMessage(FoxholeDiscoveryMessage, 0, 0, , "ahk_id " MainGui.Hwnd)
    catch
    {
        FoxholeDiscoveryMessageQueued := false
    }

    return 0
}

FoxholeWindowEventMessage(wParam, lParam, msg, hwnd)
{
    global FoxholeDiscoveryMessageQueued

    FoxholeDiscoveryMessageQueued := false
    SetTimer(EventDrivenFoxholeDiscovery, -125)
    return 0
}

EventDrivenFoxholeDiscovery(*)
{
    global FoxholeDiscoveryInProgress, FoxholeDiscoveryPending

    if FoxholeDiscoveryInProgress
    {
        FoxholeDiscoveryPending := true
        return
    }

    FoxholeDiscoveryInProgress := true
    FoxholeDiscoveryPending := false
    try
    {
        ScanWindows()
    }
    finally
    {
        FoxholeDiscoveryInProgress := false
        if FoxholeDiscoveryPending
        {
            FoxholeDiscoveryPending := false
            SetTimer(EventDrivenFoxholeDiscovery, -125)
        }
    }
}

StopFoxholeWindowWatcher()
{
    global FoxholeWindowEventHook, FoxholeWindowEventCallback, FoxholeDiscoveryMessage

    if FoxholeWindowEventHook
    {
        try DllCall("UnhookWinEvent", "Ptr", FoxholeWindowEventHook)
        FoxholeWindowEventHook := 0
    }

    if FoxholeWindowEventCallback
    {
        try CallbackFree(FoxholeWindowEventCallback)
        FoxholeWindowEventCallback := 0
    }

    try OnMessage(FoxholeDiscoveryMessage, FoxholeWindowEventMessage, 0)
}

PrepareBannerAssets()
{
    global BannerDefinitions, AvailableBanners, BannerAssetDir, RuntimeAssetDir, APP_ICON_PATH

    AvailableBanners := []

    if A_IsCompiled
    {
        RuntimeAssetDir := A_Temp "\FoxholeMultiboxer"
        BannerAssetDir := RuntimeAssetDir "\Banners"
        APP_ICON_PATH := RuntimeAssetDir "\FoxholeMultiBoxerIcon.ico"

        if !DirExist(RuntimeAssetDir)
            DirCreate(RuntimeAssetDir)
        if !DirExist(BannerAssetDir)
            DirCreate(BannerAssetDir)

        FileInstall "FoxholeMultiBoxerIcon.ico", APP_ICON_PATH, 1
        FileInstall "Airborne.png", BannerAssetDir "\Airborne.png", 1
        FileInstall "Entrenched.png", BannerAssetDir "\Entrenched.png", 1
        FileInstall "Naval.png", BannerAssetDir "\Naval.png", 1
        FileInstall "Inferno.png", BannerAssetDir "\Inferno.png", 1
        FileInstall "TrenchWarfare.png", BannerAssetDir "\TrenchWarfare.png", 1
        FileInstall "WarMachine.png", BannerAssetDir "\WarMachine.png", 1
        FileInstall "WinterArmy.png", BannerAssetDir "\WinterArmy.png", 1
    }
    else
    {
        RuntimeAssetDir := A_ScriptDir
        BannerAssetDir := A_ScriptDir
        APP_ICON_PATH := A_ScriptDir "\FoxholeMultiBoxerIcon.ico"
    }

    for banner in BannerDefinitions
    {
        bannerPath := BannerAssetDir "\" banner.fileName
        if FileExist(bannerPath)
            AvailableBanners.Push({fileName: banner.fileName, displayName: banner.displayName, path: bannerPath})
    }
}

ChooseStartupBanner()
{
    global Settings, AvailableBanners

    if AvailableBanners.Length = 0
        return ""

    savedSelection := Settings["BannerSelection"]
    if StrLower(savedSelection) = "disabled"
        return ""

    if savedSelection != "Random" && savedSelection != "Random Cycle"
    {
        for banner in AvailableBanners
        {
            if StrLower(banner.fileName) = StrLower(savedSelection)
                return banner.fileName
        }
    }

    return AvailableBanners[Random(1, AvailableBanners.Length)].fileName
}

ChooseDifferentRandomBanner()
{
    global AvailableBanners, CurrentBannerFile

    if AvailableBanners.Length = 0
        return ""
    if AvailableBanners.Length = 1
        return AvailableBanners[1].fileName

    candidates := []
    for banner in AvailableBanners
    {
        if StrLower(banner.fileName) != StrLower(CurrentBannerFile)
            candidates.Push(banner.fileName)
    }

    return candidates[Random(1, candidates.Length)]
}

FindAvailableBanner(fileName)
{
    global AvailableBanners

    for banner in AvailableBanners
    {
        if StrLower(banner.fileName) = StrLower(fileName)
            return banner
    }
    return ""
}

SetMainBanner(fileName)
{
    global BannerPicture, CurrentBannerFile

    banner := FindAvailableBanner(fileName)
    if !IsObject(banner) || !IsObject(BannerPicture)
        return false

    try BannerPicture.Value := banner.path
    catch
        return false

    CurrentBannerFile := banner.fileName
    return true
}

SetMainBannerVisibility(visible)
{
    global MainGui, BannerPicture, BannerVisible, MainTipText, LV, MainDynamicControls

    visible := visible ? true : false
    if visible = BannerVisible || !IsObject(BannerPicture)
        return

    offset := 187
    deltaY := visible ? offset : -offset

    if visible
        BannerPicture.Visible := true

    for ctrl in [MainTipText, LV]
    {
        if !IsObject(ctrl) || !ctrl.Hwnd
            continue
        ctrl.GetPos(&x, &y, &w, &h)
        ctrl.Move(, y + deltaY)
    }

    for ctrl in MainDynamicControls
    {
        if !IsObject(ctrl) || !ctrl.Hwnd
            continue
        ctrl.GetPos(&x, &y, &w, &h)
        ctrl.Move(, y + deltaY)
    }

    if !visible
        BannerPicture.Visible := false

    try
    {
        MainGui.GetPos(&guiX, &guiY, &guiW, &guiH)
        MainGui.Move(, , , guiH + deltaY)
    }

    BannerVisible := visible
}

BannerSelectionChanged(ctrl, *)
{
    global Settings, AvailableBanners, CONFIG_FILE

    if !IsObject(ctrl) || ctrl.Value < 1
        return

    if ctrl.Value = 1
    {
        Settings["BannerSelection"] := "Disabled"
        SetMainBannerVisibility(false)
    }
    else if ctrl.Value = 2
    {
        Settings["BannerSelection"] := "Random"
        if AvailableBanners.Length > 0
        {
            SetMainBanner(AvailableBanners[Random(1, AvailableBanners.Length)].fileName)
            SetMainBannerVisibility(true)
        }
    }
    else if ctrl.Value = 3
    {
        Settings["BannerSelection"] := "Random Cycle"
        if AvailableBanners.Length > 0
        {
            SetMainBanner(ChooseDifferentRandomBanner())
            SetMainBannerVisibility(true)
        }
    }
    else
    {
        bannerIndex := ctrl.Value - 3
        if bannerIndex < 1 || bannerIndex > AvailableBanners.Length
            return
        Settings["BannerSelection"] := AvailableBanners[bannerIndex].fileName
        SetMainBanner(AvailableBanners[bannerIndex].fileName)
        SetMainBannerVisibility(true)
    }

    IniWrite(Settings["BannerSelection"], CONFIG_FILE, "Settings", "BannerSelection")
}

SetApplicationIcon()
{
    global APP_ICON_PATH

    if FileExist(APP_ICON_PATH)
    {
        try
            TraySetIcon(APP_ICON_PATH)
        catch
            TraySetIcon("*")
    }
    else
        TraySetIcon("*")
}

SetGuiIcon(guiObj)
{
    global APP_ICON_PATH

    if !FileExist(APP_ICON_PATH) || !IsObject(guiObj) || !guiObj.Hwnd
        return

    try
    {

        hIcon := DllCall("LoadImage", "Ptr", 0, "Str", APP_ICON_PATH, "UInt", 1, "Int", 0, "Int", 0, "UInt", 0x00000010 | 0x00000040, "Ptr")
        if hIcon
        {
            SendMessage(0x0080, 1, hIcon, , "ahk_id " guiObj.Hwnd)
            SendMessage(0x0080, 0, hIcon, , "ahk_id " guiObj.Hwnd)
        }
    }
    catch
    {
    }
}

BuildMainGui()
{
    global MainGui, LV, StatusText, MainTipText, MainTipIndex, MainTips, IntervalEdits
    global RebindButtons, CurrentKeys, Settings, MainAlwaysOnTopCheck
    global MainCloseSteamButton, MainRelaunchSteamButton, MainLaunchSteamButton, MainLaunchFoxholeButton, MainCloseFoxholeButton
    global MainDynamicControls, MainVisibleTableRows
    global AvailableBanners, BannerPicture, BannerDropDown, CurrentBannerFile, BannerVisible

    MainGui := Gui("+Resize", APP_TITLE)
    MainGui.SetFont("s9", "Segoe UI")
    SetGuiIcon(MainGui)

    contentW := 535
    bannerY := 12
    bannerH := 179
    bannerGap := 8
    BannerPicture := ""
    BannerVisible := false

    if AvailableBanners.Length > 0
    {
        CurrentBannerFile := ChooseStartupBanner()
        pictureBanner := CurrentBannerFile != "" ? FindAvailableBanner(CurrentBannerFile) : AvailableBanners[1]
        if IsObject(pictureBanner)
        {
            BannerPicture := MainGui.AddPicture("x12 y" bannerY " w" contentW " h" bannerH, pictureBanner.path)
            BannerVisible := CurrentBannerFile != ""
            BannerPicture.Visible := BannerVisible
        }
    }

    MainTipIndex := 1
    tipY := BannerVisible ? (bannerY + bannerH + bannerGap) : 12
    MainTipText := MainGui.AddText("x12 y" tipY " w" contentW " h40 +Wrap +Center +0x200", MainTips[MainTipIndex])
    SetTimer(RotateMainTip, 10000)

    tableY := tipY + 44
    LV := MainGui.AddListView(
        "x12 y" tableY " w" contentW " h200 Grid -Multi",
        ["Slot", "Window Title", "HWND", "Status", "Hotkeys", "X", "Y", "W", "H"]
    )
    LV.ModifyCol(1, 55)
    LV.ModifyCol(2, 140)
    LV.ModifyCol(3, 68)
    LV.ModifyCol(4, 52)
    LV.ModifyCol(5, 53)
    LV.ModifyCol(6, 36)
    LV.ModifyCol(7, 36)
    LV.ModifyCol(8, 36)
    LV.ModifyCol(9, 36)
    LV.ModifyCol(1, "Logical Sort")
    LV.OnEvent("ItemSelect", OnListSelect)

    controlsY := tableY + 208
    RegisterTooltip(LV, MainListTooltip)
    sandboxieBtn := RegisterTooltip(MainGui.AddButton("x12 y" controlsY " w90 h28", "Sandboxie"), "Open the Sandboxie account manager to configure accounts, credentials, sandboxes, and launch Steam or Foxhole.")
    sandboxieBtn.OnEvent("Click", OpenSBGui)
    hotkeysBtn := RegisterTooltip(MainGui.AddButton("x108 y" controlsY " w90 h28", "Hotkeys"), "Open hotkey settings to view, rebind, and reset multiboxing hotkeys and repeat intervals.")
    hotkeysBtn.OnEvent("Click", OpenHotkeysGui)
    layoutBtn := RegisterTooltip(MainGui.AddButton("x204 y" controlsY " w105 h28", "Layout Editor"), (*) => LayoutManagerTooltip("Combo"))
    layoutBtn.OnEvent("Click", OpenLayoutEditor)
    resetSlotsBtn := RegisterTooltip(MainGui.AddButton("x314 y" controlsY " w100 h28", "Reset Slots"), "Clear all current Foxhole window-to-slot assignments. Open windows will be rediscovered and assigned again.")
    resetSlotsBtn.OnEvent("Click", (*) => ResetInstanceSlots())
    settingsBtn := RegisterTooltip(MainGui.AddButton("x419 y" controlsY " w35 h28", "⚙"), "Open the multiboxer Settings.ini file in your default text editor.")
    settingsBtn.OnEvent("Click", OpenSettingsFile)

    steamRowY := controlsY + 36
    MainCloseSteamButton := MainGui.AddButton("x12 y" steamRowY " w95 h28", "Close Steam")
    MainCloseSteamButton.OnEvent("Click", CloseAllSandboxedSteam)
    RegisterTooltip(MainCloseSteamButton, MainCloseSteamTooltip)

    MainLaunchSteamButton := MainGui.AddButton("x113 y" steamRowY " w100 h28", "Launch Steam")
    MainLaunchSteamButton.OnEvent("Click", StartSelectedSandboxieSteamLaunches)
    RegisterTooltip(MainLaunchSteamButton, (*) => MainBulkTooltip("LaunchSteam"))

    MainRelaunchSteamButton := MainGui.AddButton("x219 y" steamRowY " w160 h28", "Reset && Relaunch Steam")
    MainRelaunchSteamButton.OnEvent("Click", RelaunchSelectedSteamAfterSandboxReset)
    RegisterTooltip(MainRelaunchSteamButton, (*) => MainBulkTooltip("RelaunchSteam"))

    foxholeRowY := steamRowY + 36
    MainLaunchFoxholeButton := MainGui.AddButton("x12 y" foxholeRowY " w110 h28", "Launch Foxhole")
    MainLaunchFoxholeButton.OnEvent("Click", StartSelectedFoxholeLaunches)
    RegisterTooltip(MainLaunchFoxholeButton, (*) => MainBulkTooltip("LaunchFoxhole"))

    MainCloseFoxholeButton := MainGui.AddButton("x128 y" foxholeRowY " w110 h28", "Close Foxhole")
    MainCloseFoxholeButton.OnEvent("Click", CloseAllFoxholeWindows)
    RegisterTooltip(MainCloseFoxholeButton, MainCloseFoxholeTooltip)

    bannerSelectorLabel := ""
    BannerDropDown := ""
    if AvailableBanners.Length > 0
    {
        bannerSelectorLabel := MainGui.AddText("x249 y" (foxholeRowY + 4) " w48 h20 +Right", "Banner:")
        bannerChoices := ["Disabled", "Random", "Random Cycle"]
        selectedChoice := 2
        if StrLower(Settings["BannerSelection"]) = "disabled"
            selectedChoice := 1
        else if StrLower(Settings["BannerSelection"]) = "random cycle"
            selectedChoice := 3
        for index, banner in AvailableBanners
        {
            bannerChoices.Push(banner.displayName)
            if Settings["BannerSelection"] != "Random" && Settings["BannerSelection"] != "Random Cycle" && StrLower(Settings["BannerSelection"]) = StrLower(banner.fileName)
                selectedChoice := index + 3
        }
        BannerDropDown := MainGui.AddDropDownList("x302 y" foxholeRowY " w125", bannerChoices)
        BannerDropDown.Choose(selectedChoice)
        BannerDropDown.OnEvent("Change", BannerSelectionChanged)
        RegisterTooltip(BannerDropDown, "Disable the banner, choose Random for a different banner each startup, choose Random Cycle to change it with the tips every 10 seconds, or select a named banner to always use it.")
    }

    statusY := foxholeRowY + 36
    StatusText := MainGui.AddText("x12 y" statusY " w270 h30", "Status: Starting...")
    RegisterTooltip(StatusText, (*) => "Shows the most recent multiboxer action or result.`n" StatusText.Text)
    MainAlwaysOnTopCheck := MainGui.AddCheckBox("x292 y" (statusY + 4) " w120 h24", "Always on top?")
    MainAlwaysOnTopCheck.Value := Settings["MainAlwaysOnTop"] ? 1 : 0
    MainAlwaysOnTopCheck.OnEvent("Click", MainAlwaysOnTopChanged)
    RegisterTooltip(MainAlwaysOnTopCheck, (*) => AlwaysOnTopTooltip(MainAlwaysOnTopCheck, "The main Foxhole Multiboxer window"))

    ShowOverlayCheck := MainGui.AddCheckBox("x417 y" (statusY + 4) " w120 h24", "Show Overlay?")
    ShowOverlayCheck.Value := Settings["ShowOverlay"] ? 1 : 0
    ShowOverlayCheck.OnEvent("Click", ShowOverlayChanged)
    RegisterTooltip(ShowOverlayCheck, OverlayTooltip)

    MainDynamicControls := [
        sandboxieBtn, hotkeysBtn, layoutBtn, resetSlotsBtn, settingsBtn,
        MainCloseSteamButton, MainLaunchSteamButton, MainRelaunchSteamButton,
        MainLaunchFoxholeButton, MainCloseFoxholeButton, StatusText,
        MainAlwaysOnTopCheck, ShowOverlayCheck
    ]
    if IsObject(bannerSelectorLabel)
        MainDynamicControls.Push(bannerSelectorLabel)
    if IsObject(BannerDropDown)
        MainDynamicControls.Push(BannerDropDown)
    MainVisibleTableRows := 0

    MainGui.OnEvent("Close", (*) => ExitApp())
    MainGui.OnEvent("Escape", (*) => ExitApp())
    MainGui.OnEvent("Size", MainGuiResize)

    BuildHotkeysGui()
    guiBottom := statusY + 42
    MainGui.Show("w559 h" guiBottom)
    ApplyGuiAlwaysOnTop(MainGui, Settings["MainAlwaysOnTop"])
}

ResizeMainGuiForRows(rowCount := "")
{
    global MainGui, LV, MainDynamicControls, MainVisibleTableRows, MainMaxVisibleTableRows

    if !IsObject(MainGui) || !MainGui.Hwnd || !IsObject(LV) || !LV.Hwnd
        return

    if rowCount = ""
        rowCount := LV.GetCount()

    visibleRows := Min(Max(Integer(rowCount), 1), MainMaxVisibleTableRows)
    if visibleRows = MainVisibleTableRows
        return

    LV.GetPos(&tableX, &tableY, &tableW, &oldTableH)
    newTableH := GetListViewHeightForRows(LV, visibleRows)
    deltaY := newTableH - oldTableH

    if Abs(deltaY) <= 1
    {
        MainVisibleTableRows := visibleRows
        return
    }

    LV.Move(, , , newTableH)
    for ctrl in MainDynamicControls
    {
        if !IsObject(ctrl) || !ctrl.Hwnd
            continue
        ctrl.GetPos(&x, &y, &w, &h)
        ctrl.Move(, y + deltaY)
    }

    try
    {
        MainGui.GetPos(&guiX, &guiY, &guiW, &guiH)
        MainGui.Move(, , , guiH + deltaY)
    }

    MainVisibleTableRows := visibleRows
}

GetListViewHeightForRows(listView, visibleRows)
{

    headerHeight := 24
    try
    {
        headerHwnd := SendMessage(0x101F, 0, 0, listView)
        if headerHwnd
        {
            rect := Buffer(16, 0)
            if DllCall("GetWindowRect", "Ptr", headerHwnd, "Ptr", rect.Ptr)
                headerHeight := NumGet(rect, 12, "Int") - NumGet(rect, 4, "Int")
        }
    }

    rowHeight := 20
    if listView.GetCount() > 0
    {
        try
        {
            itemRect := Buffer(16, 0)
            NumPut("Int", 0, itemRect, 0)
            if SendMessage(0x100E, 0, itemRect.Ptr, listView)
                rowHeight := NumGet(itemRect, 12, "Int") - NumGet(itemRect, 4, "Int")
        }
    }

    return headerHeight + (rowHeight * visibleRows) + 6
}

RotateMainTip(*)
{
    global MainTipText, MainTipIndex, MainTips, Settings, AvailableBanners

    if IsObject(MainTipText) && MainTips.Length > 0
    {
        MainTipIndex := MainTipIndex >= MainTips.Length ? 1 : MainTipIndex + 1
        MainTipText.Text := MainTips[MainTipIndex]
    }

    if StrLower(Settings["BannerSelection"]) = "random cycle" && AvailableBanners.Length > 0
    {
        SetMainBanner(ChooseDifferentRandomBanner())
        SetMainBannerVisibility(true)
    }
}

InitializeLayoutPositionWatcher()
{
    global LayoutPositionWatcherActive, LayoutWindowPositions

    if LayoutPositionWatcherActive
        return true

    LayoutWindowPositions := CaptureFoxholeWindowPositions()
    SetTimer(MonitorFoxholeWindowPositions, 100)
    LayoutPositionWatcherActive := true
    return true
}

MonitorFoxholeWindowPositions(*)
{
    global LayoutPositionWatcherActive, LayoutPositionWatcherBusy
    global LayoutWindowPositions, LayoutReapplyPending, LayoutSwapInProgress
    global Instances, Layouts, LayoutEditorSelectedLayout

    if !LayoutPositionWatcherActive
        return
    if LayoutPositionWatcherBusy
        return

    if LayoutSwapInProgress
        return

    current := CaptureFoxholeWindowPositions()
    moved := false

    for hwnd, rect in current
    {
        if !LayoutWindowPositions.Has(hwnd)
        {

            continue
        }

        old := LayoutWindowPositions[hwnd]
        if rect.x != old.x || rect.y != old.y || rect.w != old.w || rect.h != old.h
        {
            moved := true
            break
        }
    }

    LayoutWindowPositions := current

    if !moved
        return

    if LayoutEditorSelectedLayout < 1 || LayoutEditorSelectedLayout > Layouts.Length
        return

    if LayoutReapplyPending
        return

    LayoutReapplyPending := true
    SetTimer(ReapplyLayoutAfterWindowMove, -50)
}

ReapplyLayoutAfterWindowMove(*)
{
    global LayoutReapplyPending, LayoutPositionWatcherBusy, LayoutWindowPositions
    global LayoutSwapInProgress
    global Layouts, LayoutEditorSelectedLayout

    LayoutReapplyPending := false

    if LayoutSwapInProgress
        return

    if LayoutEditorSelectedLayout < 1 || LayoutEditorSelectedLayout > Layouts.Length
        return

    LayoutPositionWatcherBusy := true
    try
    {

        Sleep(25)
        ApplySelectedLayout(false)
        LayoutWindowPositions := CaptureFoxholeWindowPositions()
    }
    finally
    {
        LayoutPositionWatcherBusy := false
    }
}

CaptureFoxholeWindowPositions()
{
    positions := Map()
    for hwnd in WinGetList("ahk_exe War-Win64-Shipping.exe")
    {
        if !IsWindowAlive(hwnd)
            continue

        try
        {
            WinGetPos(&x, &y, &w, &h, "ahk_id " hwnd)
            positions[hwnd] := {x: x, y: y, w: w, h: h}
        }
        catch
        {
        }
    }
    return positions
}

StopLayoutPositionWatcher()
{
    global LayoutPositionWatcherActive, LayoutPositionWatcherBusy
    global LayoutWindowPositions, LayoutReapplyPending, LayoutSwapInProgress

    SetTimer(MonitorFoxholeWindowPositions, 0)
    SetTimer(ReapplyLayoutAfterWindowMove, 0)
    LayoutPositionWatcherActive := false
    LayoutPositionWatcherBusy := false
    LayoutReapplyPending := false
    LayoutSwapInProgress := false
    LayoutWindowPositions := Map()
}

OpenLayoutEditor(*)
{
    global LayoutEditorGui

    if !IsObject(LayoutEditorGui)
        BuildLayoutEditorGui()

    RefreshLayoutEditorGui()
    LayoutEditorGui.Show()
    WinActivate("ahk_id " LayoutEditorGui.Hwnd)
}

BuildLayoutEditorGui()
{
    global LayoutEditorGui, LayoutEditorCombo, LayoutEditorAlwaysOnTopCheck, Settings

    LayoutEditorGui := Gui("+Resize", "Layout Editor")
    LayoutEditorGui.SetFont("s9", "Segoe UI")
    LayoutEditorGui.MarginX := 12
    LayoutEditorGui.MarginY := 10

    LayoutEditorGui.AddText("x12 y10 w55 h24", "Layout:")
    LayoutEditorCombo := LayoutEditorGui.AddComboBox("x68 y8 w235 h25 r10", [])
    LayoutEditorCombo.OnEvent("Change", LayoutEditorSelectionChanged)
    RegisterTooltip(LayoutEditorCombo, (*) => LayoutManagerTooltip("Combo"))

    LayoutEditorAlwaysOnTopCheck := LayoutEditorGui.AddCheckBox("x315 y8 w130 h24", "Always on top?")
    LayoutEditorAlwaysOnTopCheck.Value := Settings["LayoutEditorAlwaysOnTop"] ? 1 : 0
    LayoutEditorAlwaysOnTopCheck.OnEvent("Click", LayoutEditorAlwaysOnTopChanged)
    RegisterTooltip(LayoutEditorAlwaysOnTopCheck, (*) => AlwaysOnTopTooltip(LayoutEditorAlwaysOnTopCheck, "The Layout Editor"))
    ApplyGuiAlwaysOnTop(LayoutEditorGui, Settings["LayoutEditorAlwaysOnTop"])

    saveLayoutBtn := RegisterTooltip(LayoutEditorGui.AddButton("x68 y38 w105 h25", "Save New Layout"), (*) => LayoutManagerTooltip("Save"))
    saveLayoutBtn.OnEvent("Click", SaveNewLayoutFromEditor)
    updateLayoutBtn := RegisterTooltip(LayoutEditorGui.AddButton("x176 y38 w95 h25", "Update Layout"), (*) => LayoutManagerTooltip("Update"))
    updateLayoutBtn.OnEvent("Click", UpdateSelectedLayout)
    deleteLayoutBtn := RegisterTooltip(LayoutEditorGui.AddButton("x274 y38 w70 h25", "Delete"), (*) => LayoutManagerTooltip("Delete"))
    deleteLayoutBtn.OnEvent("Click", DeleteSelectedLayout)
    addSlotBtn := RegisterTooltip(LayoutEditorGui.AddButton("x347 y38 w85 h25", "+ Add Slot"), (*) => LayoutManagerTooltip("Add"))
    addSlotBtn.OnEvent("Click", AddLayoutSlot)

    allPreviewBtn := RegisterTooltip(LayoutEditorGui.AddButton("x68 y66 w80 h25", "Show/Hide"), (*) => LayoutManagerTooltip("Preview"))
    allPreviewBtn.OnEvent("Click", ToggleAllLayoutPreviews)

    LayoutEditorGui.OnEvent("Close", CloseLayoutEditor)
    LayoutEditorGui.OnEvent("Escape", CloseLayoutEditor)
}

RefreshLayoutEditorGui(*)
{
    global LayoutEditorGui, LayoutEditorSlots, LayoutEditorValueCtrls, LayoutEditorSlotControls
    global LayoutEditorCombo, LayoutEditorSelectedLayout, Layouts, Instances

    if !IsObject(LayoutEditorGui)
        BuildLayoutEditorGui()

    SetGuiRedraw(LayoutEditorGui, false)
    DestroyLayoutEditorRows()
    LayoutEditorSlots := []

    if LayoutEditorSelectedLayout >= 1 && LayoutEditorSelectedLayout <= Layouts.Length
    {
        LayoutEditorSlots := CloneLayoutSlots(Layouts[LayoutEditorSelectedLayout].slots)
    }
    else
    {
        for _, inst in Instances
        {
            if inst.slot < 1
                continue
            if IsWindowAlive(inst.hwnd)
                LayoutEditorSlots.Push(CreateLayoutSlotFromAbsoluteRect(inst.slot, inst.x, inst.y, inst.width, inst.height))
        }
        SortLayoutSlots(LayoutEditorSlots)
    }

    if LayoutEditorSlots.Length = 0
        LayoutEditorSlots.Push(CreateDefaultLayoutSlot(1))

    LayoutEditorValueCtrls := []
    LayoutEditorSlotControls := []

    y := 100
    for slotIndex, slot in LayoutEditorSlots
    {
        header := LayoutEditorGui.AddText("x12 y" y " w52 h24 +0x200", "SLOT " slot.slot)
        monitorLabel := LayoutEditorGui.AddText("x68 y" y " w52 h24 +0x200", "Monitor:")
        monitorCombo := LayoutEditorGui.AddComboBox("x122 y" y " w170 h24 r5", GetMonitorDisplayNames())
        monitorCombo.Value := ResolveLayoutMonitorNumber(slot)
        monitorCombo.OnEvent("Change", MakeLayoutMonitorHandler(slotIndex))
        showBtn := LayoutEditorGui.AddButton("x298 y" y " w72 h24", "Show/Hide")
        removeBtn := LayoutEditorGui.AddButton("x373 y" y " w57 h24", "Remove")
        matchBtn := LayoutEditorGui.AddButton("x433 y" y " w55 h24", "Match")
        showBtn.OnEvent("Click", MakeLayoutShowHandler(slotIndex))
        removeBtn.OnEvent("Click", MakeLayoutRemoveHandler(slotIndex))
        matchBtn.OnEvent("Click", MakeLayoutMatchBelowHandler(slotIndex))
        RegisterTooltip(header, LayoutSlotTooltip.Bind(slotIndex, "Header"))
        RegisterTooltip(monitorCombo, LayoutSlotTooltip.Bind(slotIndex, "Monitor"))
        RegisterTooltip(showBtn, LayoutSlotTooltip.Bind(slotIndex, "Show"))
        RegisterTooltip(removeBtn, LayoutSlotTooltip.Bind(slotIndex, "Remove"))
        RegisterTooltip(matchBtn, LayoutSlotTooltip.Bind(slotIndex, "Match"))
        controls := [header, monitorLabel, monitorCombo, showBtn, removeBtn, matchBtn]
        values := Map()

        y += 28
        y := BuildLayoutEditorValueRow("X", "x", slotIndex, slot.x, y, values)
        y := BuildLayoutEditorValueRow("Y", "y", slotIndex, slot.y, y, values)
        y := BuildLayoutEditorValueRow("W", "width", slotIndex, slot.width, y, values)
        y := BuildLayoutEditorValueRow("H", "height", slotIndex, slot.height, y, values)
        y += 12

        LayoutEditorValueCtrls.Push(values)
        LayoutEditorSlotControls.Push(controls)
    }

    height := y + 42
    if height < 140
        height := 140
    LayoutEditorGui.Move(, , 510, height)
    RefreshLayoutEditorLayoutList()
    SetGuiRedraw(LayoutEditorGui, true)
}

SetGuiRedraw(guiObj, enabled)
{
    if !IsObject(guiObj)
        return

    DllCall("SendMessage", "Ptr", guiObj.Hwnd, "UInt", 0x000B, "Ptr", enabled ? 1 : 0, "Ptr", 0)
    if enabled
        DllCall("RedrawWindow", "Ptr", guiObj.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0085)
}

BuildLayoutEditorValueRow(label, prop, slotIndex, value, y, values)
{
    global LayoutEditorGui

    buttonW := 34
    gap := 2
    labelW := 12
    valueW := 54

    groupW := (buttonW * 8) + (gap * 9) + labelW + valueW
    x := Floor((510 - groupW) / 2)

    for _, delta in [-100, -50, -10, -1]
    {
        btn := LayoutEditorGui.AddButton("x" x " y" y " w" buttonW " h24", String(delta))
        btn.OnEvent("Click", MakeLayoutAdjustHandler(slotIndex, prop, delta))
        RegisterTooltip(btn, LayoutSlotTooltip.Bind(slotIndex, "Adjust", prop, delta))
        x += buttonW + gap
    }

    LayoutEditorGui.AddText("x" x " y" y " w" labelW " h24 +0x200 Center", label)
    x += labelW + gap

    valueCtrl := LayoutEditorGui.AddText("x" x " y" y " w" valueW " h24 +0x200 Center", String(value))
    values[prop] := valueCtrl
    RegisterTooltip(valueCtrl, LayoutSlotTooltip.Bind(slotIndex, "Value", prop))
    x += valueW + gap

    for _, delta in [1, 10, 50, 100]
    {
        btn := LayoutEditorGui.AddButton("x" x " y" y " w" buttonW " h24", "+" delta)
        btn.OnEvent("Click", MakeLayoutAdjustHandler(slotIndex, prop, delta))
        RegisterTooltip(btn, LayoutSlotTooltip.Bind(slotIndex, "Adjust", prop, delta))
        x += buttonW + gap
    }

    return y + 28
}

RefreshLayoutEditorLayoutList()
{
    global LayoutEditorCombo, Layouts, LayoutEditorSelectedLayout
    if !IsObject(LayoutEditorCombo)
        return

    names := []
    for layout in Layouts
        names.Push(layout.name)
    LayoutEditorCombo.Delete()
    if names.Length
        LayoutEditorCombo.Add(names)
    if LayoutEditorSelectedLayout >= 1 && LayoutEditorSelectedLayout <= names.Length
        LayoutEditorCombo.Value := LayoutEditorSelectedLayout
    else
        LayoutEditorCombo.Value := 0
}

LayoutEditorSelectionChanged(ctrl, *)
{
    global LayoutEditorSelectedLayout, Layouts, Settings, CONFIG_FILE

    value := ctrl.Value
    if value >= 1 && value <= Layouts.Length
    {
        LayoutEditorSelectedLayout := value
        Settings["LastLayoutName"] := Layouts[value].name
        IniWrite(Settings["LastLayoutName"], CONFIG_FILE, "Settings", "LastLayoutName")
        ApplySelectedLayout(false)
        RefreshLayoutEditorGui()
        RefreshVisibleLayoutPreviews()
    }
}

AddLayoutSlot(*)
{
    global LayoutEditorSlots
    nextSlot := 1
    used := Map()
    for slot in LayoutEditorSlots
        used[slot.slot] := true
    while used.Has(nextSlot)
        nextSlot++

    LayoutEditorSlots.Push(CreateDefaultLayoutSlot(nextSlot))
    RefreshLayoutEditorRowsOnly()
}

RemoveLayoutSlot(index)
{
    global LayoutEditorSlots
    if index < 1 || index > LayoutEditorSlots.Length
        return
    HideLayoutPreview(LayoutEditorSlots[index].slot)
    LayoutEditorSlots.RemoveAt(index)
    RefreshLayoutEditorRowsOnly()
}

RefreshLayoutEditorRowsOnly()
{
    global LayoutEditorGui, LayoutEditorSlots, LayoutEditorValueCtrls, LayoutEditorSlotControls
    DestroyLayoutEditorRows()
    LayoutEditorValueCtrls := []
    LayoutEditorSlotControls := []

    y := 100
    for slotIndex, slot in LayoutEditorSlots
    {
        header := LayoutEditorGui.AddText("x12 y" y " w52 h24 +0x200", "SLOT " slot.slot)
        monitorLabel := LayoutEditorGui.AddText("x68 y" y " w52 h24 +0x200", "Monitor:")
        monitorCombo := LayoutEditorGui.AddComboBox("x122 y" y " w170 h24 r5", GetMonitorDisplayNames())
        monitorCombo.Value := ResolveLayoutMonitorNumber(slot)
        monitorCombo.OnEvent("Change", MakeLayoutMonitorHandler(slotIndex))
        showBtn := LayoutEditorGui.AddButton("x298 y" y " w72 h24", "Show/Hide")
        removeBtn := LayoutEditorGui.AddButton("x373 y" y " w57 h24", "Remove")
        matchBtn := LayoutEditorGui.AddButton("x433 y" y " w55 h24", "Match")
        showBtn.OnEvent("Click", MakeLayoutShowHandler(slotIndex))
        removeBtn.OnEvent("Click", MakeLayoutRemoveHandler(slotIndex))
        matchBtn.OnEvent("Click", MakeLayoutMatchBelowHandler(slotIndex))
        RegisterTooltip(header, LayoutSlotTooltip.Bind(slotIndex, "Header"))
        RegisterTooltip(monitorCombo, LayoutSlotTooltip.Bind(slotIndex, "Monitor"))
        RegisterTooltip(showBtn, LayoutSlotTooltip.Bind(slotIndex, "Show"))
        RegisterTooltip(removeBtn, LayoutSlotTooltip.Bind(slotIndex, "Remove"))
        RegisterTooltip(matchBtn, LayoutSlotTooltip.Bind(slotIndex, "Match"))
        LayoutEditorSlotControls.Push([header, monitorLabel, monitorCombo, showBtn, removeBtn, matchBtn])
        values := Map()
        y += 28
        y := BuildLayoutEditorValueRow("X", "x", slotIndex, slot.x, y, values)
        y := BuildLayoutEditorValueRow("Y", "y", slotIndex, slot.y, y, values)
        y := BuildLayoutEditorValueRow("W", "width", slotIndex, slot.width, y, values)
        y := BuildLayoutEditorValueRow("H", "height", slotIndex, slot.height, y, values)
        y += 12
        LayoutEditorValueCtrls.Push(values)
    }

    newHeight := y + 42
    if newHeight < 140
        newHeight := 140
    LayoutEditorGui.Move(, , 510, newHeight)
}

DestroyLayoutEditorRows()
{
    global LayoutEditorSlotControls, LayoutEditorValueCtrls
    for controls in LayoutEditorSlotControls
        for control in controls
        {
            try UnregisterTooltip(control)
            try control.Destroy()
        }
    for values in LayoutEditorValueCtrls
        for _, control in values
        {
            try UnregisterTooltip(control)
            try control.Destroy()
        }
    LayoutEditorSlotControls := []
    LayoutEditorValueCtrls := []
}

MakeLayoutAdjustHandler(index, prop, delta)
{
    return (*) => AdjustLayoutSlot(index, prop, delta)
}

AdjustLayoutSlot(index, prop, delta)
{
    global LayoutEditorSlots, LayoutEditorValueCtrls, LayoutEditorOverlays
    if index < 1 || index > LayoutEditorSlots.Length
        return

    slot := LayoutEditorSlots[index]
    value := slot.%prop% + delta

    if prop = "x" || prop = "y"
        value := ClampLayoutCoordinate(slot, prop, value)
    else if prop = "width" || prop = "height"
        value := ClampLayoutSize(slot, prop, value)

    slot.%prop% := value

    ClampLayoutSlotToAssignedMonitor(slot)

    if LayoutEditorValueCtrls.Length >= index
    {
        ctrls := LayoutEditorValueCtrls[index]
        for _, field in ["x", "y", "width", "height"]
        {
            if ctrls.Has(field)
                ctrls[field].Text := String(slot.%field%)
        }
    }

    ApplyLayoutSlotToWindow(slot)
    if LayoutEditorOverlays.Has(slot.slot)
        UpdateLayoutPreview(index)
}

ClampLayoutCoordinate(slot, prop, value)
{
    bounds := GetLayoutMonitorBounds(slot)

    if prop = "x"
    {
        maxX := Max(0, bounds.width - slot.width)
        return Min(Max(value, 0), maxX)
    }

    maxY := Max(0, bounds.height - slot.height)
    return Min(Max(value, 0), maxY)
}

ClampLayoutSize(slot, prop, value)
{
    bounds := GetLayoutMonitorBounds(slot)

    if prop = "width"
    {
        maxWidth := Max(1, bounds.width - slot.x)
        minWidth := Min(100, maxWidth)
        return Max(1, Min(Max(minWidth, value), maxWidth))
    }

    maxHeight := Max(1, bounds.height - slot.y)
    minHeight := Min(100, maxHeight)
    return Max(1, Min(Max(minHeight, value), maxHeight))
}

ClampLayoutSlotToAssignedMonitor(slot)
{
    bounds := GetLayoutMonitorBounds(slot)

    slot.x := Min(Max(slot.x, 0), Max(0, bounds.width - 1))
    slot.y := Min(Max(slot.y, 0), Max(0, bounds.height - 1))

    maxWidth := Max(1, bounds.width - slot.x)
    maxHeight := Max(1, bounds.height - slot.y)

    minWidth := Min(100, maxWidth)
    minHeight := Min(100, maxHeight)
    slot.width := Max(1, Min(Max(minWidth, slot.width), maxWidth))
    slot.height := Max(1, Min(Max(minHeight, slot.height), maxHeight))
}

GetLayoutMonitorBounds(slot)
{
    monitorNumber := ResolveLayoutMonitorNumber(slot)
    left := 0
    top := 0
    right := 0
    bottom := 0
    MonitorGet(monitorNumber, &left, &top, &right, &bottom)
    return {
        number: monitorNumber,
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        width: right - left,
        height: bottom - top
    }
}

ResolveLayoutMonitorNumber(slot)
{
    monitorCount := MonitorGetCount()
    requested := HasProp(slot, "monitor") ? Integer(slot.monitor) : MonitorGetPrimary()

    if requested >= 1 && requested <= monitorCount
    {
        if HasProp(slot, "monitorWidth") && HasProp(slot, "monitorHeight")
        {
            left := 0
            top := 0
            right := 0
            bottom := 0
            MonitorGet(requested, &left, &top, &right, &bottom)
            if right - left = slot.monitorWidth && bottom - top = slot.monitorHeight
                return requested

            Loop monitorCount
            {
                MonitorGet(A_Index, &left, &top, &right, &bottom)
                if right - left = slot.monitorWidth && bottom - top = slot.monitorHeight
                    return A_Index
            }
        }
        return requested
    }

    if HasProp(slot, "monitorWidth") && HasProp(slot, "monitorHeight")
    {
        Loop monitorCount
        {
            left := 0
            top := 0
            right := 0
            bottom := 0
            MonitorGet(A_Index, &left, &top, &right, &bottom)
            if right - left = slot.monitorWidth && bottom - top = slot.monitorHeight
                return A_Index
        }
    }

    return MonitorGetPrimary()
}

GetMonitorDisplayNames()
{
    names := []
    primary := MonitorGetPrimary()
    Loop MonitorGetCount()
    {
        left := 0
        top := 0
        right := 0
        bottom := 0
        MonitorGet(A_Index, &left, &top, &right, &bottom)
        label := A_Index = primary ? A_Index " - Primary" : String(A_Index)
        names.Push(label " - " (right - left) "x" (bottom - top))
    }
    return names
}

CreateDefaultLayoutSlot(slotNumber)
{
    primary := MonitorGetPrimary()
    left := 0
    top := 0
    right := 0
    bottom := 0
    MonitorGet(primary, &left, &top, &right, &bottom)
    slot := {
        slot: slotNumber,
        monitor: primary,
        monitorWidth: right - left,
        monitorHeight: bottom - top,
        x: 0,
        y: 0,
        width: 960,
        height: 540
    }
    ClampLayoutSlotToAssignedMonitor(slot)
    return slot
}

GetMonitorForAbsolutePoint(x, y)
{
    monitorCount := MonitorGetCount()
    Loop monitorCount
    {
        left := 0
        top := 0
        right := 0
        bottom := 0
        MonitorGet(A_Index, &left, &top, &right, &bottom)
        if x >= left && x < right && y >= top && y < bottom
            return A_Index
    }

    bestMonitor := MonitorGetPrimary()
    bestDistance := 0x7FFFFFFF
    Loop monitorCount
    {
        left := 0
        top := 0
        right := 0
        bottom := 0
        MonitorGet(A_Index, &left, &top, &right, &bottom)
        nearestX := Min(Max(x, left), right - 1)
        nearestY := Min(Max(y, top), bottom - 1)
        distance := Abs(x - nearestX) + Abs(y - nearestY)
        if distance < bestDistance
        {
            bestDistance := distance
            bestMonitor := A_Index
        }
    }
    return bestMonitor
}

CreateLayoutSlotFromAbsoluteRect(slotNumber, absoluteX, absoluteY, width, height)
{
    monitorNumber := GetMonitorForAbsolutePoint(absoluteX, absoluteY)
    left := 0
    top := 0
    right := 0
    bottom := 0
    MonitorGet(monitorNumber, &left, &top, &right, &bottom)
    slot := {
        slot: slotNumber,
        monitor: monitorNumber,
        monitorWidth: right - left,
        monitorHeight: bottom - top,
        x: absoluteX - left,
        y: absoluteY - top,
        width: width,
        height: height
    }
    ClampLayoutSlotToAssignedMonitor(slot)
    return slot
}

GetLayoutSlotAbsoluteRect(slot)
{
    ClampLayoutSlotToAssignedMonitor(slot)
    bounds := GetLayoutMonitorBounds(slot)
    return {
        x: bounds.left + slot.x,
        y: bounds.top + slot.y,
        width: slot.width,
        height: slot.height
    }
}

MakeLayoutMonitorHandler(index)
{
    return (ctrl, *) => ChangeLayoutSlotMonitor(index, ctrl.Value)
}

ChangeLayoutSlotMonitor(index, monitorNumber)
{
    global LayoutEditorSlots, LayoutEditorValueCtrls, LayoutEditorOverlays

    if index < 1 || index > LayoutEditorSlots.Length
        return
    if monitorNumber < 1 || monitorNumber > MonitorGetCount()
        return

    slot := LayoutEditorSlots[index]
    left := 0
    top := 0
    right := 0
    bottom := 0
    MonitorGet(monitorNumber, &left, &top, &right, &bottom)
    slot.monitor := monitorNumber
    slot.monitorWidth := right - left
    slot.monitorHeight := bottom - top
    ClampLayoutSlotToAssignedMonitor(slot)

    if LayoutEditorValueCtrls.Length >= index
    {
        values := LayoutEditorValueCtrls[index]
        for _, field in ["x", "y", "width", "height"]
            if values.Has(field)
                values[field].Text := String(slot.%field%)
    }

    ApplyLayoutSlotToWindow(slot)
    if LayoutEditorOverlays.Has(slot.slot)
        UpdateLayoutPreview(index)
}

ApplyLayoutSlotToWindow(slot)
{
    global Instances
    idx := FindLiveInstanceBySlot(slot.slot)
    if !idx
        return
    inst := Instances[idx]
    if !IsWindowAlive(inst.hwnd)
        return
    try
    {
        rect := GetLayoutSlotAbsoluteRect(slot)
        WinMove(rect.x, rect.y, rect.width, rect.height, "ahk_id " inst.hwnd)
        inst.x := rect.x
        inst.y := rect.y
        inst.width := rect.width
        inst.height := rect.height
        RefreshList()
    }
}

ToggleAllLayoutPreviews(*)
{
    global LayoutEditorSlots, LayoutEditorOverlays

    if LayoutEditorSlots.Length = 0
        return

    allVisible := true
    for slot in LayoutEditorSlots
    {
        if !LayoutEditorOverlays.Has(slot.slot)
        {
            allVisible := false
            break
        }
    }

    if allVisible
    {
        for slot in LayoutEditorSlots
            HideLayoutPreview(slot.slot)
    }
    else
    {
        for index, slot in LayoutEditorSlots
        {
            if !LayoutEditorOverlays.Has(slot.slot)
                ShowLayoutPreview(index)
        }
    }
}

MakeLayoutShowHandler(index)
{
    return (*) => ShowLayoutPreview(index)
}

ShowLayoutPreview(index)
{
    global LayoutEditorSlots, LayoutEditorOverlays
    if index < 1 || index > LayoutEditorSlots.Length
        return
    slot := LayoutEditorSlots[index]
    if LayoutEditorOverlays.Has(slot.slot)
    {
        preview := LayoutEditorOverlays[slot.slot]
        try preview.gui.Destroy()
        LayoutEditorOverlays.Delete(slot.slot)
        return
    }

    overlay := Gui("-AlwaysOnTop -Caption +ToolWindow", "Slot " slot.slot " Preview")
    overlay.BackColor := "00AEEF"
    overlay.SetFont("s16 bold", "Segoe UI")
    text := overlay.AddText("x0 y0 w" slot.width " h" slot.height " Center +0x200 +Border", "SLOT " slot.slot)

    overlay.Show("Hide w" slot.width " h" slot.height)

    previewExStyle := 0x00080000 | 0x00000020 | 0x08000000 | 0x00000080
    try WinSetExStyle(previewExStyle, "ahk_id " overlay.Hwnd)

    try DllCall("SetLayeredWindowAttributes", "Ptr", overlay.Hwnd, "UInt", 0, "UChar", 40, "UInt", 0x2)

    HWND_NOTOPMOST := -2
    HWND_BOTTOM := 1
    SWP_NOSIZE := 0x0001
    SWP_NOMOVE := 0x0002
    SWP_NOACTIVATE := 0x0010
    SWP_SHOWWINDOW := 0x0040
    rect := GetLayoutSlotAbsoluteRect(slot)
    try DllCall("SetWindowPos", "Ptr", overlay.Hwnd, "Ptr", HWND_NOTOPMOST,
        "Int", rect.x, "Int", rect.y, "Int", rect.width, "Int", rect.height,
        "UInt", SWP_NOACTIVATE | SWP_SHOWWINDOW)

    try DllCall("SetWindowPos", "Ptr", overlay.Hwnd, "Ptr", HWND_BOTTOM,
        "Int", 0, "Int", 0, "Int", 0, "Int", 0,
        "UInt", SWP_NOSIZE | SWP_NOMOVE | SWP_NOACTIVATE)

    LayoutEditorOverlays[slot.slot] := {gui: overlay, text: text}
}

UpdateLayoutPreview(index)
{
    global LayoutEditorSlots, LayoutEditorOverlays
    if index < 1 || index > LayoutEditorSlots.Length
        return
    slot := LayoutEditorSlots[index]
    if !LayoutEditorOverlays.Has(slot.slot)
        return
    preview := LayoutEditorOverlays[slot.slot]
    try
    {
        preview.gui.Move(, , slot.width, slot.height)
        preview.text.Move(0, 0, slot.width, slot.height)

        preview.gui.Show("Hide w" slot.width " h" slot.height)
        try WinSetExStyle(0x00080000 | 0x00000020 | 0x08000000 | 0x00000080, "ahk_id " preview.gui.Hwnd)
        try DllCall("SetLayeredWindowAttributes", "Ptr", preview.gui.Hwnd, "UInt", 0, "UChar", 40, "UInt", 0x2)
        rect := GetLayoutSlotAbsoluteRect(slot)
        try DllCall("SetWindowPos", "Ptr", preview.gui.Hwnd, "Ptr", -2,
            "Int", rect.x, "Int", rect.y, "Int", rect.width, "Int", rect.height,
            "UInt", 0x0010 | 0x0040)
        try DllCall("SetWindowPos", "Ptr", preview.gui.Hwnd, "Ptr", 1,
            "Int", 0, "Int", 0, "Int", 0, "Int", 0,
            "UInt", 0x0001 | 0x0002 | 0x0010)
    }
    catch
    {
        HideLayoutPreview(slot.slot)
    }
}

HideLayoutPreview(slotNumber)
{
    global LayoutEditorOverlays
    if LayoutEditorOverlays.Has(slotNumber)
    {
        try LayoutEditorOverlays[slotNumber].gui.Destroy()
        LayoutEditorOverlays.Delete(slotNumber)
    }
}

RefreshVisibleLayoutPreviews()
{
    global LayoutEditorSlots, LayoutEditorOverlays

    visibleSlotNumbers := []
    for slotNumber, _ in LayoutEditorOverlays
        visibleSlotNumbers.Push(slotNumber)

    for _, slotNumber in visibleSlotNumbers
    {
        slotIndex := 0
        for index, slot in LayoutEditorSlots
        {
            if slot.slot = slotNumber
            {
                slotIndex := index
                break
            }
        }

        if slotIndex
            UpdateLayoutPreview(slotIndex)
        else
            HideLayoutPreview(slotNumber)
    }
}

MakeLayoutRemoveHandler(index)
{
    return (*) => RemoveLayoutSlot(index)
}

MakeLayoutMatchBelowHandler(index)
{
    return (*) => MatchLayoutSlotsBelow(index)
}

MatchLayoutSlotsBelow(index)
{
    global LayoutEditorSlots, LayoutEditorValueCtrls, LayoutEditorOverlays, LayoutEditorSlotControls
    if index < 1 || index > LayoutEditorSlots.Length
        return

    source := LayoutEditorSlots[index]
    targetIndex := index + 1
    while targetIndex <= LayoutEditorSlots.Length
    {
        target := LayoutEditorSlots[targetIndex]
        target.monitor := source.monitor
        target.monitorWidth := source.monitorWidth
        target.monitorHeight := source.monitorHeight
        target.x := source.x
        target.y := source.y
        target.width := source.width
        target.height := source.height
        targetIndex++
    }

    targetIndex := index + 1
    while targetIndex <= LayoutEditorSlots.Length
    {
        if targetIndex > LayoutEditorValueCtrls.Length
        {
            targetIndex++
            continue
        }
        values := LayoutEditorValueCtrls[targetIndex]
        slot := LayoutEditorSlots[targetIndex]
        try values["x"].Text := String(slot.x)
        try values["y"].Text := String(slot.y)
        try values["width"].Text := String(slot.width)
        try values["height"].Text := String(slot.height)
        if targetIndex <= LayoutEditorSlotControls.Length
        {
            controls := LayoutEditorSlotControls[targetIndex]
            if controls.Length >= 3
                try controls[3].Value := ResolveLayoutMonitorNumber(slot)
        }

        ApplyLayoutSlotToWindow(slot)
        if LayoutEditorOverlays.Has(slot.slot)
            UpdateLayoutPreview(targetIndex)

        targetIndex++
    }
}

CloneLayoutSlots(source)
{
    result := []
    for slot in source
    {

        copy := {
            slot: slot.slot,
            monitor: ResolveLayoutMonitorNumber(slot),
            monitorWidth: HasProp(slot, "monitorWidth") ? slot.monitorWidth : GetLayoutMonitorBounds(slot).width,
            monitorHeight: HasProp(slot, "monitorHeight") ? slot.monitorHeight : GetLayoutMonitorBounds(slot).height,
            x: slot.x,
            y: slot.y,
            width: slot.width,
            height: slot.height
        }
        ClampLayoutSlotToAssignedMonitor(copy)
        result.Push(copy)
    }
    return result
}

SortLayoutSlots(slots)
{

    count := slots.Length
    Loop count - 1
    {
        i := A_Index + 1
        current := slots[i]
        j := i - 1
        while j >= 1 && slots[j].slot > current.slot
        {
            slots[j + 1] := slots[j]
            j--
        }
        slots[j + 1] := current
    }
}

SaveNewLayoutFromEditor(*)
{
    global LayoutEditorSlots, Layouts, LayoutEditorSelectedLayout, Settings
    name := InputBox("Enter a name for this layout:", "Save New Layout", "w360 h140")
    if name.Result != "OK"
        return
    name := Trim(name.Value)
    if name = ""
        return

    for layout in Layouts
    {
        if StrLower(layout.name) = StrLower(name)
        {
            MsgBox("A layout with that name already exists.", "Layout Editor", "Icon!")
            return
        }
    }

    Layouts.Push({name: name, slots: CloneLayoutSlots(LayoutEditorSlots)})
    LayoutEditorSelectedLayout := Layouts.Length
    Settings["LastLayoutName"] := name
    SaveLayoutsConfig()
    RefreshLayoutEditorGui()
}

UpdateSelectedLayout(*)
{
    global Layouts, LayoutEditorSelectedLayout, LayoutEditorSlots
    if LayoutEditorSelectedLayout < 1 || LayoutEditorSelectedLayout > Layouts.Length
    {
        MsgBox("Select a saved layout first.", "Layout Editor", "Icon!")
        return
    }
    Layouts[LayoutEditorSelectedLayout].slots := CloneLayoutSlots(LayoutEditorSlots)
    SaveLayoutsConfig()
}

DeleteSelectedLayout(*)
{
    global Layouts, LayoutEditorSelectedLayout, Settings
    if LayoutEditorSelectedLayout < 1 || LayoutEditorSelectedLayout > Layouts.Length
        return
    name := Layouts[LayoutEditorSelectedLayout].name
    If MsgBox("Delete layout " . Chr(34) . name . Chr(34) . "?", "Layout Editor", "YesNo Icon!") != "Yes"
        return
    Layouts.RemoveAt(LayoutEditorSelectedLayout)
    LayoutEditorSelectedLayout := 0
    Settings["LastLayoutName"] := ""
    SaveLayoutsConfig()
    RefreshLayoutEditorGui()
}

ApplySelectedLayout(refreshEditor := true, *)
{
    global Layouts, LayoutEditorSelectedLayout, LayoutEditorSlots
    if LayoutEditorSelectedLayout < 1 || LayoutEditorSelectedLayout > Layouts.Length
        return false

    LayoutEditorSlots := CloneLayoutSlots(Layouts[LayoutEditorSelectedLayout].slots)
    for slot in LayoutEditorSlots
        ApplyLayoutSlotToWindow(slot)

    if refreshEditor
        RefreshLayoutEditorGui()

    return true
}

CloseLayoutEditor(*)
{
    global LayoutEditorGui, LayoutEditorOverlays
    for _, preview in LayoutEditorOverlays
        try preview.gui.Destroy()
    LayoutEditorOverlays := Map()
    if IsObject(LayoutEditorGui)
        LayoutEditorGui.Hide()
}

OpenSettingsFile(*)
{
    global CONFIG_FILE

    if !DirExist(CONFIG_DIR)
        DirCreate(CONFIG_DIR)

    if !FileExist(CONFIG_FILE)
        SaveConfig()

    try
        Run('notepad.exe "' CONFIG_FILE '"')
    catch
        MsgBox("Could not open the settings file:`n" CONFIG_FILE)
}

OpenHotkeysGui(*)
{
    global HotkeysGui
    if !IsObject(HotkeysGui)
        BuildHotkeysGui()
    HotkeysGui.Show("w500 h380")
}

BuildHotkeysGui()
{
    global HotkeysGui, RebindButtons, CurrentKeys, IntervalEdits, Settings, HotkeysAlwaysOnTopCheck

    HotkeysGui := Gui("+ToolWindow", "Hotkeys")
    HotkeysGui.SetFont("s9", "Segoe UI")
    OnMessage(0x0200, HotkeysGuiMouseMove)

    hotkeyY := 10
    HotkeysGui.AddText("x12 y" hotkeyY " w476 h22 +0x200", "HOTKEYS")
    rebindY := hotkeyY + 25
    intervalY := hotkeyY + 92
    resetIntervalY := hotkeyY + 120
    secondHotkeyY := hotkeyY + 140
    thirdHotkeyY := hotkeyY + 255
    RebindButtons["AutoClick"] := HotkeysGui.AddButton("x12 y" rebindY " w145 h40", "Auto Click | " DisplayNameForHotkeyString(CurrentKeys["AutoClick"]))
    RebindButtons["AutoClick"].OnEvent("Click", MakeHotkeysRebindHandler("AutoClick"))
    RegisterTooltip(RebindButtons["AutoClick"], (*) => HotkeyActionTooltip("AutoClick"))
    resetKeyAutoClick := HotkeysGui.AddButton("x12 y" (rebindY + 44) " w145 h20", "Reset")
    resetKeyAutoClick.OnEvent("Click", (*) => ResetSingleHotkey("AutoClick"))
    RegisterTooltip(resetKeyAutoClick, (*) => HotkeyResetTooltip("AutoClick"))
    IntervalEdits["AutoClick"] := HotkeysGui.AddEdit("x12 y" intervalY " w55 h24 Number", String(Settings["ClickInterval"]))
    IntervalEdits["AutoClick"].OnEvent("LoseFocus", (ctrl, *) => SaveHotkeyInterval("AutoClick", ctrl))
    RegisterTooltip(IntervalEdits["AutoClick"], (*) => IntervalTooltip("AutoClick"))
    HotkeysGui.AddText("x71 y" intervalY " w20 h24", "ms")
    resetIntervalAutoClick := HotkeysGui.AddButton("x94 y" intervalY " w63 h24", "Reset")
    resetIntervalAutoClick.OnEvent("Click", (*) => ResetHotkeyInterval("AutoClick"))
    RegisterTooltip(resetIntervalAutoClick, (*) => IntervalTooltip("AutoClick", true))

    RebindButtons["AutoWalk"] := HotkeysGui.AddButton("x170 y" rebindY " w145 h40", "Forward | " DisplayNameForHotkeyString(CurrentKeys["AutoWalk"]))
    RebindButtons["AutoWalk"].OnEvent("Click", MakeHotkeysRebindHandler("AutoWalk"))
    RegisterTooltip(RebindButtons["AutoWalk"], (*) => HotkeyActionTooltip("AutoWalk"))
    resetKeyAutoWalk := HotkeysGui.AddButton("x170 y" (rebindY + 44) " w145 h20", "Reset")
    resetKeyAutoWalk.OnEvent("Click", (*) => ResetSingleHotkey("AutoWalk"))
    RegisterTooltip(resetKeyAutoWalk, (*) => HotkeyResetTooltip("AutoWalk"))
    IntervalEdits["AutoWalk"] := HotkeysGui.AddEdit("x170 y" intervalY " w55 h24 Number", String(Settings["WalkInterval"]))
    IntervalEdits["AutoWalk"].OnEvent("LoseFocus", (ctrl, *) => SaveHotkeyInterval("AutoWalk", ctrl))
    RegisterTooltip(IntervalEdits["AutoWalk"], (*) => IntervalTooltip("AutoWalk"))
    HotkeysGui.AddText("x229 y" intervalY " w20 h24", "ms")
    resetIntervalAutoWalk := HotkeysGui.AddButton("x252 y" intervalY " w63 h24", "Reset")
    resetIntervalAutoWalk.OnEvent("Click", (*) => ResetHotkeyInterval("AutoWalk"))
    RegisterTooltip(resetIntervalAutoWalk, (*) => IntervalTooltip("AutoWalk", true))

    RebindButtons["AutoReverse"] := HotkeysGui.AddButton("x328 y" rebindY " w145 h40", "Reverse | " DisplayNameForHotkeyString(CurrentKeys["AutoReverse"]))
    RebindButtons["AutoReverse"].OnEvent("Click", MakeHotkeysRebindHandler("AutoReverse"))
    RegisterTooltip(RebindButtons["AutoReverse"], (*) => HotkeyActionTooltip("AutoReverse"))
    resetKeyAutoReverse := HotkeysGui.AddButton("x328 y" (rebindY + 44) " w145 h20", "Reset")
    resetKeyAutoReverse.OnEvent("Click", (*) => ResetSingleHotkey("AutoReverse"))
    RegisterTooltip(resetKeyAutoReverse, (*) => HotkeyResetTooltip("AutoReverse"))
    IntervalEdits["AutoReverse"] := HotkeysGui.AddEdit("x328 y" intervalY " w55 h24 Number", String(Settings["ReverseInterval"]))
    IntervalEdits["AutoReverse"].OnEvent("LoseFocus", (ctrl, *) => SaveHotkeyInterval("AutoReverse", ctrl))
    RegisterTooltip(IntervalEdits["AutoReverse"], (*) => IntervalTooltip("AutoReverse"))
    HotkeysGui.AddText("x387 y" intervalY " w20 h24", "ms")
    resetIntervalAutoReverse := HotkeysGui.AddButton("x410 y" intervalY " w63 h24", "Reset")
    resetIntervalAutoReverse.OnEvent("Click", (*) => ResetHotkeyInterval("AutoReverse"))
    RegisterTooltip(resetIntervalAutoReverse, (*) => IntervalTooltip("AutoReverse", true))

    RebindButtons["ClickHold"] := HotkeysGui.AddButton("x12 y" secondHotkeyY " w145 h40", "Left Hold | " DisplayNameForHotkeyString(CurrentKeys["ClickHold"]))
    RebindButtons["ClickHold"].OnEvent("Click", MakeHotkeysRebindHandler("ClickHold"))
    RegisterTooltip(RebindButtons["ClickHold"], (*) => HotkeyActionTooltip("ClickHold"))
    resetKeyClickHold := HotkeysGui.AddButton("x12 y" (secondHotkeyY + 44) " w145 h20", "Reset")
    resetKeyClickHold.OnEvent("Click", (*) => ResetSingleHotkey("ClickHold"))
    RegisterTooltip(resetKeyClickHold, (*) => HotkeyResetTooltip("ClickHold"))
    IntervalEdits["ClickHold"] := HotkeysGui.AddEdit("x12 y" (secondHotkeyY + 68) " w55 h24 Number", String(Settings["LeftHoldInterval"]))
    IntervalEdits["ClickHold"].OnEvent("LoseFocus", (ctrl, *) => SaveHotkeyInterval("ClickHold", ctrl))
    RegisterTooltip(IntervalEdits["ClickHold"], (*) => IntervalTooltip("ClickHold"))
    HotkeysGui.AddText("x71 y" (secondHotkeyY + 68) " w20 h24", "ms")
    resetIntervalClickHold := HotkeysGui.AddButton("x94 y" (secondHotkeyY + 68) " w63 h24", "Reset")
    resetIntervalClickHold.OnEvent("Click", (*) => ResetHotkeyInterval("ClickHold"))
    RegisterTooltip(resetIntervalClickHold, (*) => IntervalTooltip("ClickHold", true))

    RebindButtons["RightHold"] := HotkeysGui.AddButton("x170 y" secondHotkeyY " w145 h40", "Right Hold | " DisplayNameForHotkeyString(CurrentKeys["RightHold"]))
    RebindButtons["RightHold"].OnEvent("Click", MakeHotkeysRebindHandler("RightHold"))
    RegisterTooltip(RebindButtons["RightHold"], (*) => HotkeyActionTooltip("RightHold"))
    resetKeyRightHold := HotkeysGui.AddButton("x170 y" (secondHotkeyY + 44) " w145 h20", "Reset")
    resetKeyRightHold.OnEvent("Click", (*) => ResetSingleHotkey("RightHold"))
    RegisterTooltip(resetKeyRightHold, (*) => HotkeyResetTooltip("RightHold"))
    IntervalEdits["RightHold"] := HotkeysGui.AddEdit("x170 y" (secondHotkeyY + 68) " w55 h24 Number", String(Settings["RightHoldInterval"]))
    IntervalEdits["RightHold"].OnEvent("LoseFocus", (ctrl, *) => SaveHotkeyInterval("RightHold", ctrl))
    RegisterTooltip(IntervalEdits["RightHold"], (*) => IntervalTooltip("RightHold"))
    HotkeysGui.AddText("x229 y" (secondHotkeyY + 68) " w20 h24", "ms")
    resetIntervalRightHold := HotkeysGui.AddButton("x252 y" (secondHotkeyY + 68) " w63 h24", "Reset")
    resetIntervalRightHold.OnEvent("Click", (*) => ResetHotkeyInterval("RightHold"))
    RegisterTooltip(resetIntervalRightHold, (*) => IntervalTooltip("RightHold", true))

    RebindButtons["VSpam"] := HotkeysGui.AddButton("x328 y" secondHotkeyY " w145 h40", "V Spam | " DisplayNameForHotkeyString(CurrentKeys["VSpam"]))
    RebindButtons["VSpam"].OnEvent("Click", MakeHotkeysRebindHandler("VSpam"))
    RegisterTooltip(RebindButtons["VSpam"], (*) => HotkeyActionTooltip("VSpam"))
    resetKeyVSpam := HotkeysGui.AddButton("x328 y" (secondHotkeyY + 44) " w145 h20", "Reset")
    resetKeyVSpam.OnEvent("Click", (*) => ResetSingleHotkey("VSpam"))
    RegisterTooltip(resetKeyVSpam, (*) => HotkeyResetTooltip("VSpam"))
    IntervalEdits["VSpam"] := HotkeysGui.AddEdit("x328 y" (secondHotkeyY + 68) " w55 h24 Number", String(Settings["VSpamInterval"]))
    IntervalEdits["VSpam"].OnEvent("LoseFocus", (ctrl, *) => SaveHotkeyInterval("VSpam", ctrl))
    RegisterTooltip(IntervalEdits["VSpam"], (*) => IntervalTooltip("VSpam"))
    HotkeysGui.AddText("x387 y" (secondHotkeyY + 68) " w20 h24", "ms")
    resetIntervalVSpam := HotkeysGui.AddButton("x410 y" (secondHotkeyY + 68) " w63 h24", "Reset")
    resetIntervalVSpam.OnEvent("Click", (*) => ResetHotkeyInterval("VSpam"))
    RegisterTooltip(resetIntervalVSpam, (*) => IntervalTooltip("VSpam", true))

    RebindButtons["MouseFocus"] := HotkeysGui.AddButton("x12 y" thirdHotkeyY " w145 h40", "Mouse Focus | " DisplayNameForHotkeyString(CurrentKeys["MouseFocus"]))
    RebindButtons["MouseFocus"].OnEvent("Click", MakeHotkeysRebindHandler("MouseFocus"))
    RegisterTooltip(RebindButtons["MouseFocus"], (*) => HotkeyActionTooltip("MouseFocus"))
    resetKeyMouseFocus := HotkeysGui.AddButton("x12 y" (thirdHotkeyY + 44) " w145 h20", "Reset")
    resetKeyMouseFocus.OnEvent("Click", (*) => ResetSingleHotkey("MouseFocus"))
    RegisterTooltip(resetKeyMouseFocus, (*) => HotkeyResetTooltip("MouseFocus"))

    swapY := thirdHotkeyY
    RebindButtons["SwitchSlot"] := HotkeysGui.AddButton("x170 y" swapY " w145 h40", "Switch Slot | " DisplayNameForHotkeyString(CurrentKeys["SwitchSlot"]))
    RebindButtons["SwitchSlot"].OnEvent("Click", MakeHotkeysRebindHandler("SwitchSlot"))
    RegisterTooltip(RebindButtons["SwitchSlot"], (*) => HotkeyActionTooltip("SwitchSlot"))
    resetKeySwitchSlot := HotkeysGui.AddButton("x170 y" (swapY + 44) " w145 h20", "Reset")
    resetKeySwitchSlot.OnEvent("Click", (*) => ResetSingleHotkey("SwitchSlot"))
    RegisterTooltip(resetKeySwitchSlot, (*) => HotkeyResetTooltip("SwitchSlot"))

    RebindButtons["Swap"] := HotkeysGui.AddButton("x328 y" swapY " w145 h40", "Swap | " DisplayNameForHotkeyString(CurrentKeys["Swap"]))
    RebindButtons["Swap"].OnEvent("Click", MakeHotkeysRebindHandler("Swap"))
    RegisterTooltip(RebindButtons["Swap"], (*) => HotkeyActionTooltip("Swap"))
    resetKeySwap := HotkeysGui.AddButton("x328 y" (swapY + 44) " w145 h20", "Reset")
    resetKeySwap.OnEvent("Click", (*) => ResetSingleHotkey("Swap"))
    RegisterTooltip(resetKeySwap, (*) => HotkeyResetTooltip("Swap"))

    HotkeysAlwaysOnTopCheck := HotkeysGui.AddCheckBox("x12 y348 w130 h24", "Always on top?")
    HotkeysAlwaysOnTopCheck.Value := Settings["HotkeysAlwaysOnTop"] ? 1 : 0
    HotkeysAlwaysOnTopCheck.OnEvent("Click", HotkeysAlwaysOnTopChanged)
    RegisterTooltip(HotkeysAlwaysOnTopCheck, (*) => AlwaysOnTopTooltip(HotkeysAlwaysOnTopCheck, "The Hotkeys window"))
    ApplyGuiAlwaysOnTop(HotkeysGui, Settings["HotkeysAlwaysOnTop"])

    HotkeysGui.OnEvent("Close", (*) => HotkeysGui.Hide())
    HotkeysGui.OnEvent("Escape", (*) => HotkeysGui.Hide())
}

OpenSBGui(*)
{
    global SBGui

    if !IsObject(SBGui)
        BuildSBGui()

    StartSandboxieStatusWatcher()
    SBGui.Show()
    WinActivate("ahk_id " SBGui.Hwnd)
}

BuildSBGui()
{
    global SBGui, SandboxieRowCountEdit, SandboxieRowCount
    global SandboxieAlwaysOnTopCheck, Settings
    global SandboxieSteamAllButton, SandboxieFoxholeAllButton, SandboxieSetupAllButton, SandboxieDeleteAllButton

    SBGui := Gui("+ToolWindow", "Sandboxie")
    SBGui.SetFont("s9", "Segoe UI")
    SBGui.MarginX := 12
    SBGui.MarginY := 10

    SandboxieAlwaysOnTopCheck := SBGui.AddCheckBox("x12 y8 w145 h24", "Always on top?")
    SandboxieAlwaysOnTopCheck.Value := Settings["SandboxieAlwaysOnTop"] ? 1 : 0
    SandboxieAlwaysOnTopCheck.OnEvent("Click", SandboxieAlwaysOnTopChanged)
    RegisterTooltip(SandboxieAlwaysOnTopCheck, (*) => AlwaysOnTopTooltip(SandboxieAlwaysOnTopCheck, "The Sandboxie manager"))

    SandboxieRowCountEdit := SBGui.AddEdit("x173 y8 w55 h24 Number", String(SandboxieRowCount))
    RegisterTooltip(SandboxieRowCountEdit, (*) => SandboxieSummaryTooltip("RowsEdit"))
    rowsBtn := RegisterTooltip(SBGui.AddButton("x233 y8 w55 h24", "Rows"), (*) => SandboxieSummaryTooltip("Rows"))
    rowsBtn.OnEvent("Click", ApplySandboxieRowCount)
    sbSettingsBtn := RegisterTooltip(SBGui.AddButton("x296 y8 w32 h24", "⚙"), "Configure the paths to SandMan.exe, Steam.exe, and the Foxhole executable.")
    sbSettingsBtn.OnEvent("Click", OpenSandboxieSettings)
    SandboxieSetupAllButton := SBGui.AddButton("x334 y8 w150 h24", "Setup All Sandboxes")
    SandboxieSetupAllButton.OnEvent("Click", SetupAllSandboxieSandboxes)
    RegisterTooltip(SandboxieSetupAllButton, (*) => SandboxieSummaryTooltip("Setup"))
    SandboxieDeleteAllButton := SBGui.AddButton("x334 y36 w145 h24", "Reset Sandboxes")
    SandboxieDeleteAllButton.OnEvent("Click", DeleteAllProgramSandboxContents)
    RegisterTooltip(SandboxieDeleteAllButton, (*) => SandboxieSummaryTooltip("Reset"))

    SBGui.AddText("x12 y68 w20 h20", "#")
    SBGui.AddText("x40 y68 w125 h20", "Account")
    SandboxieSteamAllButton := SBGui.AddButton("x173 y64 w70 h28", "Steam")
    SandboxieSteamAllButton.OnEvent("Click", StartSelectedSandboxieSteamLaunches)
    RegisterTooltip(SandboxieSteamAllButton, (*) => SandboxieSummaryTooltip("Steam"))
    credHeader := RegisterTooltip(SBGui.AddText("x251 y68 w42 h20 +0x200 Center", "Cred."), "Open, edit, or clear the Windows Credential Manager entry used to log this account into Steam.")
    SandboxieFoxholeAllButton := SBGui.AddButton("x299 y64 w70 h28", "Foxhole")
    SandboxieFoxholeAllButton.OnEvent("Click", StartSelectedFoxholeLaunches)
    RegisterTooltip(SandboxieFoxholeAllButton, (*) => SandboxieSummaryTooltip("Foxhole"))
    mainHeader := RegisterTooltip(SBGui.AddText("x377 y68 w55 h20", "Main"), "Exactly one account can be Main. It uses unsandboxed Steam and Foxhole and does not use Sandboxie credentials.")
    selectedHeader := RegisterTooltip(SBGui.AddText("x437 y68 w65 h20", "Selected"), "Selected accounts are included by bulk Steam, Foxhole, and Relaunch Steam actions.")

    SBGui.OnEvent("Close", CloseSBGui)
    SBGui.OnEvent("Escape", (*) => SBGui.Hide())
    ApplyGuiAlwaysOnTop(SBGui, Settings["SandboxieAlwaysOnTop"])

    RebuildSandboxieRows(SandboxieRowCount)
    StartSandboxieStatusWatcher()
}

CloseSBGui(*)
{
    SaveSandboxieVisibleRows()
    SaveConfig()
    StopSandboxieStatusWatcher()
    ReleaseSandboxieStatusDll()
    SBGui.Hide()
}

ApplySandboxieRowCount(*)
{
    global SBGui, SandboxieRowCountEdit, SandboxieRowCount, MaxSandboxieRows, SandboxieRows

    value := Trim(SandboxieRowCountEdit.Value)
    if !RegExMatch(value, "^\d+$")
    {
        MsgBox("Enter a whole number from 1 to " MaxSandboxieRows ".", "Sandboxie", "Icon!")
        SandboxieRowCountEdit.Focus()
        return
    }

    count := Integer(value)
    if count < 1 || count > MaxSandboxieRows
    {
        MsgBox("Enter a whole number from 1 to " MaxSandboxieRows ".", "Sandboxie", "Icon!")
        SandboxieRowCountEdit.Focus()
        return
    }

    SaveSandboxieVisibleRows()
    SandboxieRowCount := count
    SaveConfig()

    StopSandboxieStatusWatcher()
    SBGui.Hide()
    SBGui.Destroy()
    SBGui := ""
    SandboxieRows := []

    BuildSBGui()
    SBGui.Show()
    WinActivate("ahk_id " SBGui.Hwnd)
}

RebuildSandboxieRows(count)
{
    global SBGui, SandboxieRows, SandboxieAccounts

    if !IsObject(SBGui)
        return

    SBGui.Hide()
    for row in SandboxieRows
    {
        for control in row
        {
            try UnregisterTooltip(control)
            try control.Visible := false
            try control.Destroy()
        }
    }
    SandboxieRows := []

    while SandboxieAccounts.Length < count

        SandboxieAccounts.Push({ name: "", selected: false, main: false, steamUsername: "" })

    rowY := 96
    for index in Range(1, count)
    {
        account := SandboxieAccounts[index]
        rowNumber := SBGui.AddText("x12 y" rowY " w20 h24", String(index))
        nameEdit := SBGui.AddEdit("x40 y" rowY " w125 h24", account.name)
        steamButton := SBGui.AddButton("x173 y" rowY " w62 h24", "Steam")
        steamStatus := SBGui.AddText("x237 y" rowY " w12 h24 +0x200 Center", "●")
        loginButton := ""
        if !account.main
        {
            loginButton := SBGui.AddButton("x251 y" rowY " w42 h24", "⚿")
            loginButton.OnEvent("Click", MakeSandboxieCredentialHandler(index))
        }
        foxholeButton := SBGui.AddButton("x299 y" rowY " w62 h24", "Foxhole")
        foxholeStatus := SBGui.AddText("x363 y" rowY " w12 h24 +0x200 Center", "●")
        mainCheck := SBGui.AddCheckBox("x377 y" rowY " w55 h24")
        mainCheck.Value := account.main ? 1 : 0
        selectedCheck := SBGui.AddCheckBox("x437 y" rowY " w65 h24")
        selectedCheck.Value := account.selected ? 1 : 0

        nameEdit.OnEvent("LoseFocus", MakeSandboxieNameHandler(index))
        steamButton.OnEvent("Click", MakeSandboxieLaunchHandler(index, "Steam"))
        foxholeButton.OnEvent("Click", MakeSandboxieLaunchHandler(index, "Foxhole"))
        mainCheck.OnEvent("Click", MakeSandboxieMainHandler(index))
        selectedCheck.OnEvent("Click", MakeSandboxieSelectionHandler(index))
        RegisterTooltip(rowNumber, SandboxieAccountTooltip.Bind(index, "Row"))
        RegisterTooltip(nameEdit, SandboxieAccountTooltip.Bind(index, "Name"))
        RegisterTooltip(steamButton, SandboxieAccountTooltip.Bind(index, "Steam"))
        RegisterTooltip(steamStatus, SandboxieProgramStatusTooltip.Bind(index, "Steam"))
        if IsObject(loginButton)
            RegisterTooltip(loginButton, SandboxieAccountTooltip.Bind(index, "Cred"))
        RegisterTooltip(foxholeButton, SandboxieAccountTooltip.Bind(index, "Foxhole"))
        RegisterTooltip(foxholeStatus, SandboxieProgramStatusTooltip.Bind(index, "Foxhole"))
        RegisterTooltip(mainCheck, SandboxieAccountTooltip.Bind(index, "Main"))
        RegisterTooltip(selectedCheck, SandboxieAccountTooltip.Bind(index, "Selected"))
        SandboxieRows.Push([rowNumber, nameEdit, steamButton, steamStatus, loginButton, foxholeButton, foxholeStatus, mainCheck, selectedCheck])
        rowY += 30
    }

    height := rowY + 18
    if height < 190
        height := 190
    SBGui.Move(, , 650, height)
}

StartSandboxieStatusWatcher()
{
    global SandboxieStatusTimerActive, SandboxieStatusTimerMs

    if SandboxieStatusTimerActive
        return

    SandboxieStatusTimerActive := true
    SetTimer(UpdateSandboxieProgramStatus, SandboxieStatusTimerMs)
    UpdateSandboxieProgramStatus()
}

StopSandboxieStatusWatcher()
{
    global SandboxieStatusTimerActive

    if !SandboxieStatusTimerActive
        return

    SetTimer(UpdateSandboxieProgramStatus, 0)
    SandboxieStatusTimerActive := false
}

ReleaseSandboxieStatusDll()
{
    global SandboxieStatusDll, SandboxieStatusEnumProc

    if SandboxieStatusDll
        try DllCall("FreeLibrary", "Ptr", SandboxieStatusDll)
    SandboxieStatusDll := 0
    SandboxieStatusEnumProc := 0
}

UpdateSandboxieProgramStatus(*)
{
    global SBGui, SandboxieRows, SandboxieAccounts, Settings

    if !IsObject(SBGui) || !SBGui.Hwnd || !WinExist("ahk_id " SBGui.Hwnd)
        return

    steamName := GetExecutableBaseName(Settings["SandboxieSteamExe"])
    foxholeName := GetExecutableBaseName(Settings["SandboxieFoxholeExe"])

    for index, row in SandboxieRows
    {
        if index > SandboxieAccounts.Length
            continue

        account := SandboxieAccounts[index]
        boxName := Trim(account.name)
        steamRunning := false
        foxholeRunning := false

        if account.main
        {
            if steamName != ""
                steamRunning := IsProcessImageRunning(steamName)
            if foxholeName != ""
                foxholeRunning := IsProcessImageRunning(foxholeName)
        }
        else if IsValidSandboxieName(boxName)
        {
            running := GetSandboxieProcessNames(boxName)
            if running
            {
                if steamName != ""
                    steamRunning := running.Has(StrLower(steamName))
                if foxholeName != ""
                    foxholeRunning := running.Has(StrLower(foxholeName))
            }
        }

        UpdateSandboxieStatusIndicator(row[4], steamRunning)
        UpdateSandboxieStatusIndicator(row[7], foxholeRunning)
    }
}

UpdateSandboxieStatusIndicator(ctrl, isRunning)
{
    if !IsObject(ctrl)
        return

    ctrl.Text := isRunning ? "●" : "●"
    try ctrl.SetFont(isRunning ? "cGreen" : "cGray")
    try ctrl.ToolTip := isRunning ? "Running" : "Not running"
}

GetExecutableBaseName(path)
{
    path := Trim(path)
    if path = ""
        return ""
    return RegExReplace(path, ".*\\", "")
}

IsProcessImageRunning(imageName)
{
    imageName := StrLower(Trim(imageName))
    if imageName = ""
        return false

    pid := ProcessExist(imageName)
    return pid != 0
}

GetSandboxieProcessNames(boxName)
{
    global Settings
    result := Map()
    dllPath := GetSandboxieDllPath()
    if dllPath = "" || !IsValidSandboxieName(boxName)
        return result

    global SandboxieStatusDll, SandboxieStatusEnumProc

    try
    {
        if !SandboxieStatusDll
            SandboxieStatusDll := DllCall("LoadLibraryW", "WStr", dllPath, "Ptr")
        if !SandboxieStatusDll
            return result

        if !SandboxieStatusEnumProc
            SandboxieStatusEnumProc := DllCall("GetProcAddress", "Ptr", SandboxieStatusDll, "AStr", "SbieApi_EnumProcessEx", "Ptr")
        if !SandboxieStatusEnumProc
            return result

        maxPids := 512
        pids := Buffer(maxPids * 4, 0)
        count := Buffer(4, 0)
        NumPut("UInt", maxPids, count, 0)

        rc := DllCall(SandboxieStatusEnumProc,
            "WStr", boxName,
            "Int", 1,
            "UInt", 0xFFFFFFFF,
            "Ptr", pids.Ptr,
            "Ptr", count.Ptr,
            "Int")

        if rc != 0
            return result

        pidCount := NumGet(count, 0, "UInt")
        if pidCount > maxPids
            pidCount := maxPids

        Loop pidCount
        {
            pid := NumGet(pids, (A_Index - 1) * 4, "UInt")
            if !pid
                continue
            try
            {
                image := ProcessGetName(pid)
                if image != ""
                    result[StrLower(image)] := true
            }
        }
    }
    catch
    {
        return result
    }
    return result
}

GetSandboxieDllPath()
{
    global Settings
    sandman := Trim(Settings["SandboxieSandManExe"])
    if sandman = ""
        return ""
    dir := RegExReplace(sandman, "\\[^\\]+$", "")
    candidate := dir "\\SbieDll.dll"
    return FileExist(candidate) ? candidate : ""
}

SaveSandboxieVisibleRows()
{
    global SandboxieRows, SandboxieAccounts

    for index, row in SandboxieRows
    {
        SandboxieAccounts[index].name := row[2].Value
        SandboxieAccounts[index].main := row[8].Value = 1
        SandboxieAccounts[index].selected := row[9].Value = 1
    }
}

MakeSandboxieNameHandler(index)
{
    return (ctrl, *) => SaveSandboxieName(index, ctrl)
}

MakeSandboxieLaunchHandler(index, product)
{
    if product = "Steam"
        return (*) => LaunchSandboxieSteam(index)
    if product = "Foxhole"
        return (*) => LaunchSandboxieFoxhole(index)
    return (*) => SandboxieLaunchPlaceholder(index, product)
}

GetSandboxieBoxPids(boxName)
{
    startExe := GetSandboxieStartPath()
    if startExe = "" || !IsValidSandboxieName(boxName)
        return []

    outputFile := A_Temp "\FoxholeMultiboxer_BoxPids_" A_TickCount "_" Random(1000, 9999) ".txt"
    pids := []
    try
    {
        innerCommand := Format('"{1}" /box:{2} /listpids > "{3}"', startExe, boxName, outputFile)
        RunWait(A_ComSpec " /D /C " Chr(34) innerCommand Chr(34), , "Hide")
        if !FileExist(outputFile)
            return pids

        lines := StrSplit(FileRead(outputFile), "`n", "`r")
        skippedCount := false
        for line in lines
        {
            line := Trim(line)
            if !RegExMatch(line, "^\d+$")
                continue
            if !skippedCount
            {
                skippedCount := true
                continue
            }
            pid := Integer(line)
            if pid > 0
                pids.Push(pid)
        }
    }
    catch
    {
    }
    finally
    {
        try FileDelete(outputFile)
    }
    return pids
}

BeginSandboxieSteamMinimizeWatch(boxName)
{
    global SandboxieSteamMinimizeBoxes
    if !IsValidSandboxieName(boxName)
        return

    SandboxieSteamMinimizeBoxes[boxName] := A_TickCount + 30000
    if MinimizeSandboxieSteamWindowsForBox(boxName)
        SandboxieSteamMinimizeBoxes.Delete(boxName)
}

MinimizeLaunchedSandboxieSteamWindows(*)
{
    global SandboxieSteamMinimizeBoxes
    if SandboxieSteamMinimizeBoxes.Count = 0
        return

    finished := []
    for boxName, deadline in SandboxieSteamMinimizeBoxes
    {
        if A_TickCount > deadline
        {
            finished.Push(boxName)
            continue
        }

        if MinimizeSandboxieSteamWindowsForBox(boxName)
            finished.Push(boxName)
    }

    for boxName in finished
    {
        if SandboxieSteamMinimizeBoxes.Has(boxName)
            SandboxieSteamMinimizeBoxes.Delete(boxName)
    }
}

MinimizeSandboxieSteamWindowsForBox(boxName)
{

    closedStartupWindow := false

    for pid in GetSandboxieBoxPids(boxName)
    {
        processName := ""
        try processName := StrLower(ProcessGetName(pid))
        catch
            continue

        if processName != "steam.exe" && processName != "steamwebhelper.exe"
            continue

        try windows := WinGetList("ahk_pid " pid)
        catch
            continue

        for hwnd in windows
        {
            try
            {

                if !WinExist("ahk_id " hwnd) || !WinGetStyle("ahk_id " hwnd)
                    continue
                if !(WinGetStyle("ahk_id " hwnd) & 0x10000000)
                    continue

                WinGetPos(,, &windowWidth, &windowHeight, "ahk_id " hwnd)
                if windowWidth < 200 || windowHeight < 120
                    continue

                WinClose("ahk_id " hwnd)
                closedStartupWindow := true
            }
        }
    }

    return closedStartupWindow
}

MakeSandboxieCredentialHandler(index)
{
    return (*) => ManageSandboxieSteamCredentials(index)
}

MakeSandboxieSelectionHandler(index)
{
    return (ctrl, *) => SaveSandboxieSelection(index, ctrl)
}

MakeSandboxieMainHandler(index)
{
    return (ctrl, *) => SaveSandboxieMain(index, ctrl)
}

SaveSandboxieName(index, ctrl)
{
    global SandboxieAccounts

    newName := Trim(ctrl.Value)
    SandboxieAccounts[index].name := newName
    SaveConfig()
}

SaveSandboxieSelection(index, ctrl)
{
    global SandboxieAccounts
    SandboxieAccounts[index].selected := ctrl.Value = 1
    SaveConfig()
}

SaveSandboxieMain(index, ctrl)
{
    global SandboxieAccounts, SandboxieRows, SBGui

    isMain := ctrl.Value = 1

    for accountIndex, account in SandboxieAccounts
        account.main := isMain && accountIndex = index

    for accountIndex, row in SandboxieRows
    {
        row[8].Value := SandboxieAccounts[accountIndex].main ? 1 : 0

        loginButton := row[5]
        if IsObject(loginButton)
        {
            if SandboxieAccounts[accountIndex].main
                loginButton.Visible := false
            else
                loginButton.Visible := true
        }
        else if !SandboxieAccounts[accountIndex].main
        {
            loginButton := SBGui.AddButton("x251 y" (68 + (accountIndex - 1) * 30) " w42 h24", "⚿")
            loginButton.OnEvent("Click", MakeSandboxieCredentialHandler(accountIndex))
            row[5] := loginButton
        }
    }

    SaveConfig()
}

SandboxieLaunchPlaceholder(index, product)
{
    global SandboxieAccounts, StatusText
    StatusText.Text := "Status: " product " action for " SandboxieAccounts[index].name "."
}

OpenSandboxieSettings(*)
{
    global SandboxieSettingsGui, Settings

    if IsObject(SandboxieSettingsGui)
    {
        SandboxieSettingsGui.Show()
        WinActivate("ahk_id " SandboxieSettingsGui.Hwnd)
        return
    }

    SandboxieSettingsGui := Gui("+ToolWindow", "Sandboxie Settings")
    SandboxieSettingsGui.SetFont("s9", "Segoe UI")
    SandboxieSettingsGui.AddText("x12 y12 w100 h20", "SandMan.exe:")
    sandmanEdit := SandboxieSettingsGui.AddEdit("x112 y10 w330 h24", Settings["SandboxieSandManExe"])
    RegisterTooltip(sandmanEdit, (*) => PathTooltip(sandmanEdit, "Sandboxie launcher", "SandMan.exe"))
    sandmanBrowse := RegisterTooltip(SandboxieSettingsGui.AddButton("x446 y10 w30 h24", "..."), "Browse for Sandboxie Plus SandMan.exe.")
    sandmanBrowse.OnEvent("Click", (*) => SelectSandboxieSettingsPath(sandmanEdit, "SandboxieSandManExe"))

    SandboxieSettingsGui.AddText("x12 y44 w100 h20", "Steam.exe:")
    steamEdit := SandboxieSettingsGui.AddEdit("x112 y42 w330 h24", Settings["SandboxieSteamExe"])
    RegisterTooltip(steamEdit, (*) => PathTooltip(steamEdit, "Steam executable", "Steam.exe"))
    steamBrowse := RegisterTooltip(SandboxieSettingsGui.AddButton("x446 y42 w30 h24", "..."), "Browse for Steam.exe.")
    steamBrowse.OnEvent("Click", (*) => SelectSandboxieSettingsPath(steamEdit, "SandboxieSteamExe"))

    SandboxieSettingsGui.AddText("x12 y76 w100 h20", "Foxhole.exe:")
    foxholeEdit := SandboxieSettingsGui.AddEdit("x112 y74 w330 h24", Settings["SandboxieFoxholeExe"])
    RegisterTooltip(foxholeEdit, (*) => PathTooltip(foxholeEdit, "Foxhole executable", "War-Win64-Shipping.exe"))
    foxholeBrowse := RegisterTooltip(SandboxieSettingsGui.AddButton("x446 y74 w30 h24", "..."), "Browse for War-Win64-Shipping.exe.")
    foxholeBrowse.OnEvent("Click", (*) => SelectSandboxieSettingsPath(foxholeEdit, "SandboxieFoxholeExe"))

    saveBtn := SandboxieSettingsGui.AddButton("x326 y112 w70 h26", "Save")
    cancelBtn := SandboxieSettingsGui.AddButton("x402 y112 w74 h26", "Cancel")
    saveBtn.OnEvent("Click", (*) => SaveSandboxieSettings(SandboxieSettingsGui, sandmanEdit, steamEdit, foxholeEdit))
    cancelBtn.OnEvent("Click", CloseSandboxieSettings)
    RegisterTooltip(saveBtn, "Save all three executable paths to Settings.ini.")
    RegisterTooltip(cancelBtn, "Close without saving changes made in this window.")
    SandboxieSettingsGui.OnEvent("Close", CloseSandboxieSettings)
    SandboxieSettingsGui.Show("w490 h152")
}

CloseSandboxieSettings(*)
{
    global SandboxieSettingsGui
    if IsObject(SandboxieSettingsGui)
        try SandboxieSettingsGui.Destroy()
    SandboxieSettingsGui := ""
}

SelectSandboxieSettingsPath(editCtrl, settingKey)
{
    global Settings
    title := "Select executable"
    if settingKey = "SandboxieSandManExe"
        title := "Select Sandboxie SandMan.exe"
    else if settingKey = "SandboxieSteamExe"
        title := "Select Steam.exe"
    else if settingKey = "SandboxieFoxholeExe"
        title := "Select War-Win64-Shipping.exe"

    path := FileSelect("3", Settings[settingKey], title, "Programs (*.exe)")
    if path != ""
        editCtrl.Value := path
}

SaveSandboxieSettings(guiObj, sandmanEdit, steamEdit, foxholeEdit)
{
    global Settings, StatusText, SandboxieSettingsGui
    Settings["SandboxieSandManExe"] := Trim(sandmanEdit.Value)
    Settings["SandboxieSteamExe"] := Trim(steamEdit.Value)
    Settings["SandboxieFoxholeExe"] := Trim(foxholeEdit.Value)
    SaveConfig()
    StatusText.Text := "Status: Sandboxie paths saved."
    SandboxieSettingsGui := ""
    guiObj.Destroy()
}

SetupAllSandboxieSandboxes(*)
{
    global SandboxieAccounts, StatusText, SandboxieSetupAllButton

    SaveSandboxieVisibleRows()
    created := 0
    existing := 0
    invalid := 0
    failed := 0

    for index, account in SandboxieAccounts
    {

        if account.main
            continue

        accountName := Trim(account.name)
        if !IsValidSandboxieName(accountName)
        {
            if index > 0
                invalid++
            continue
        }

        if GetSandboxieBoxExists(accountName)
        {
            existing++
            continue
        }

        result := CreateSandboxieSandbox(accountName)
        if result.ok
            created++
        else
            failed++
    }

    SaveConfig()
    summary := "Setup complete.`n`nCreated: " created "`nAlready existed: " existing
    if invalid
        summary .= "`nInvalid account names: " invalid
    if failed
        summary .= "`nFailed: " failed

    if failed || invalid
        MsgBox(summary, "Sandboxie", "Icon!")
    else
        MsgBox(summary, "Sandboxie", "Iconi")
    StatusText.Text := "Status: Sandbox setup complete — " created " created, " existing " already existed."
}

DeleteAllProgramSandboxContents(*)
{
    global SandboxieAccounts, SandboxieDeleteAllButton, StatusText

    SaveSandboxieVisibleRows()

    names := []
    seen := Map()
    for index, account in SandboxieAccounts
    {
        accountName := Trim(account.name)
        if !IsValidSandboxieName(accountName)
            continue

        key := StrLower(accountName)
        if seen.Has(key)
            continue

        seen[key] := true
        names.Push(accountName)
    }

    if names.Length = 0
    {
        StatusText.Text := "Status: Reset Sandboxes — no valid Account names found."
        return
    }

    if IsObject(SandboxieDeleteAllButton)
        SandboxieDeleteAllButton.Enabled := false
    StatusText.Text := "Status: Resetting " names.Length " sandboxes..."

    try
    {
        result := DeleteSandboxieContentsFast(names)
        if result.failed.Length
        {
            StatusText.Text := "Status: Reset Sandboxes finished — " result.deleted " reset, " result.missing " not found, " result.failed.Length " failed."
        }
        else
        {
            StatusText.Text := "Status: Reset Sandboxes finished — " result.deleted " reset, " result.missing " not found."
        }
    }
    catch as e
    {
        StatusText.Text := "Status: Reset Sandboxes failed — " e.Message
    }
    finally
    {
        if IsObject(SandboxieDeleteAllButton)
            SandboxieDeleteAllButton.Enabled := true
    }
}

CloseAllSandboxedSteam(*)
{
    global SandboxieAccounts, StatusText, SandboxieSteamMinimizeBoxes

    SaveSandboxieVisibleRows()
    closed := 0
    failed := 0
    activeBoxes := 0
    checkedPids := Map()

    for account in SandboxieAccounts
    {
        boxName := Trim(account.name)
        if account.main || !IsValidSandboxieName(boxName)
            continue

        boxPids := GetSandboxieBoxPids(boxName)
        if boxPids.Length
            activeBoxes++

        for pid in boxPids
        {
            if checkedPids.Has(pid)
                continue
            checkedPids[pid] := true

            try
            {
                ProcessClose(pid)
                closed++
            }
            catch
                failed++
        }

        if SandboxieSteamMinimizeBoxes.Has(boxName)
            SandboxieSteamMinimizeBoxes.Delete(boxName)
    }

    StatusText.Text := "Status: Terminated " closed " program(s) in " activeBoxes " sandbox(es)." (failed ? " " failed " process(es) could not be closed." : " Sandbox contents were preserved.")
}

CloseAllFoxholeWindows(*)
{
    global Instances, SelectedIndex, StatusText, TitleOverlays

    windows := WinGetList("ahk_exe War-Win64-Shipping.exe")
    closed := 0
    failed := 0
    for hwnd in windows
    {
        try
        {
            WinClose("ahk_id " hwnd)
            closed++
        }
        catch
            failed++
    }

    overlayHwnds := []
    for hwnd, overlay in TitleOverlays
        overlayHwnds.Push(hwnd)
    for hwnd in overlayHwnds
        RemoveTitleOverlay(hwnd)
    Instances := []
    SelectedIndex := 0
    RefreshList()

    StatusText.Text := "Status: Close Foxhole sent to " closed " window(s)." (failed ? " " failed " could not be closed." : "")
}

RelaunchSelectedSteamAfterSandboxReset(*)
{
    global MainRelaunchSteamButton, MainLaunchSteamButton

    if IsObject(MainRelaunchSteamButton) && !MainRelaunchSteamButton.Enabled
        return

    if IsObject(MainRelaunchSteamButton)
        MainRelaunchSteamButton.Enabled := false
    if IsObject(MainLaunchSteamButton)
        MainLaunchSteamButton.Enabled := false

    try
    {

        DeleteAllProgramSandboxContents()
        StartSelectedSandboxieSteamLaunches()
    }
    finally
    {
        if IsObject(MainRelaunchSteamButton)
            MainRelaunchSteamButton.Enabled := true
        if IsObject(MainLaunchSteamButton)
            MainLaunchSteamButton.Enabled := true
    }
}

IsUnsandboxedSteamRunning()
{
    global SandboxieAccounts

    sandboxedPids := Map()
    for account in SandboxieAccounts
    {
        boxName := Trim(account.name)
        if account.main || !IsValidSandboxieName(boxName)
            continue

        for pid in GetSandboxieBoxPids(boxName)
            sandboxedPids[pid] := true
    }

    try
    {
        wmi := ComObjGet("winmgmts:")
        for process in wmi.ExecQuery("SELECT ProcessId FROM Win32_Process WHERE Name='steam.exe'")
        {
            pid := Integer(process.ProcessId)
            if pid > 0 && !sandboxedPids.Has(pid)
                return true
        }
    }
    catch
    {

        return ProcessExist("steam.exe") != 0 && sandboxedPids.Count = 0
    }

    return false
}

TryRepairSteamLaunchPaths()
{
    global Settings

    changed := false
    sandman := Trim(Settings["SandboxieSandManExe"])
    steamExe := Trim(Settings["SandboxieSteamExe"])

    if sandman = "" || !FileExist(sandman)
    {
        candidates := [
            "C:\Program Files\Sandboxie-Plus\SandMan.exe",
            "C:\Program Files\Sandboxie\SandMan.exe"
        ]
        for candidate in candidates
        {
            if FileExist(candidate)
            {
                Settings["SandboxieSandManExe"] := candidate
                sandman := candidate
                changed := true
                break
            }
        }
    }

    if steamExe = "" || !FileExist(steamExe)
    {
        candidates := [
            "C:\Program Files (x86)\Steam\steam.exe",
            "C:\Program Files\Steam\steam.exe"
        ]
        for candidate in candidates
        {
            if FileExist(candidate)
            {
                Settings["SandboxieSteamExe"] := candidate
                steamExe := candidate
                changed := true
                break
            }
        }
    }

    if changed
        SaveConfig()

    return {
        sandman: sandman,
        steamExe: steamExe,
        sandmanOk: sandman != "" && FileExist(sandman),
        steamOk: steamExe != "" && FileExist(steamExe),
        repaired: changed
    }
}

JoinSteamLaunchAccountNames(items)
{
    text := ""
    for item in items
        text .= (text = "" ? "" : "`n") "• " item.name
    return text
}

IsSteamRunningInSandbox(boxName, steamExe)
{
    steamName := StrLower(GetExecutableBaseName(steamExe))
    if steamName = "" || !IsValidSandboxieName(boxName)
        return false

    running := GetSandboxieProcessNames(boxName)
    return IsObject(running) && running.Has(steamName)
}

StartSelectedSandboxieSteamLaunches(*)
{
    global SandboxieAccounts, SandboxieSteamAllButton, StatusText, Settings

    if SandboxieSteamAllButton && !SandboxieSteamAllButton.Enabled
        return

    SaveSandboxieVisibleRows()
    selected := []
    for index, account in SandboxieAccounts
    {
        if account.selected
            selected.Push(index)
    }

    if selected.Length = 0
    {
        StatusText.Text := "Status: No accounts selected."
        return
    }

    if IsObject(SandboxieSteamAllButton)
        SandboxieSteamAllButton.Enabled := false

    try
    {
        paths := TryRepairSteamLaunchPaths()
        ready := []
        missingCredentials := []
        invalidAccounts := []
        sandboxFailures := []
        pathFailures := []
        alreadyRunningMain := 0
        alreadyRunningSandboxed := 0
        createdSandboxes := 0

        if !paths.steamOk
            pathFailures.Push("Steam.exe could not be found.")
        if !paths.sandmanOk
            pathFailures.Push("Sandboxie Plus SandMan.exe could not be found.")

        for index in selected
        {
            account := SandboxieAccounts[index]
            accountName := Trim(account.name)
            displayName := accountName != "" ? accountName : "Row " index

            if account.main
            {
                if IsUnsandboxedSteamRunning()
                {
                    alreadyRunningMain++
                    continue
                }
                if !paths.steamOk
                    continue
                ready.Push({ index: index, name: displayName, main: true })
                continue
            }

            if !IsValidSandboxieName(accountName)
            {
                invalidAccounts.Push({ index: index, name: displayName })
                continue
            }

            if !paths.sandmanOk || !paths.steamOk
                continue

            if !GetSandboxieBoxExists(accountName)
            {
                createResult := CreateSandboxieSandbox(accountName)
                if createResult.ok
                    createdSandboxes++
                else
                {
                    sandboxFailures.Push({ index: index, name: accountName, message: createResult.message })
                    continue
                }
            }

            if IsSteamRunningInSandbox(accountName, paths.steamExe)
            {
                alreadyRunningSandboxed++
                continue
            }

            username := Trim(account.steamUsername)
            password := GetSteamCredentialPassword(accountName)
            if username = "" || password = ""
            {
                missingCredentials.Push({ index: index, name: accountName })
                password := ""
                continue
            }
            password := ""
            ready.Push({ index: index, name: accountName, main: false })
        }

        notice := ""
        if missingCredentials.Length
            notice .= "Missing Steam credentials:`n" JoinSteamLaunchAccountNames(missingCredentials)
        if invalidAccounts.Length
            notice .= (notice != "" ? "`n`n" : "") "Invalid or blank account names:`n" JoinSteamLaunchAccountNames(invalidAccounts)
        if sandboxFailures.Length
            notice .= (notice != "" ? "`n`n" : "") "Sandbox creation failed:`n" JoinSteamLaunchAccountNames(sandboxFailures)
        if pathFailures.Length
        {
            pathText := ""
            for problem in pathFailures
                pathText .= (pathText = "" ? "" : "`n") "• " problem
            notice .= (notice != "" ? "`n`n" : "") "Program paths need attention:`n" pathText
        }

        if notice != ""
        {
            notice .= "`n`nReady to launch: " ready.Length
            if createdSandboxes
                notice .= "`nSandboxes automatically created: " createdSandboxes
            if alreadyRunningMain
                notice .= "`nMain Steam already running and silently skipped: " alreadyRunningMain
            if alreadyRunningSandboxed
                notice .= "`nSandboxed Steam already running and skipped: " alreadyRunningSandboxed

            if missingCredentials.Length
            {
                notice .= "`n`nYes = launch every ready account`nNo = open credentials for " missingCredentials[1].name "`nCancel = launch nothing"
                choice := MsgBox(notice, "Selected Steam Accounts Need Attention", "YesNoCancel Icon!")
                if choice = "No"
                {
                    ManageSandboxieSteamCredentials(missingCredentials[1].index)
                    StatusText.Text := "Status: Steam launch paused for missing credentials."
                    return
                }
                if choice != "Yes"
                {
                    StatusText.Text := "Status: Selected Steam launch cancelled."
                    return
                }
            }
            else
            {
                notice .= "`n`nContinue launching every ready account?"
                if MsgBox(notice, "Selected Steam Accounts Need Attention", "OKCancel Icon!") != "OK"
                {
                    StatusText.Text := "Status: Selected Steam launch cancelled."
                    return
                }
            }
        }

        launched := 0
        failedLaunches := []
        for item in ready
        {
            account := SandboxieAccounts[item.index]
            accountName := Trim(account.name)

            if item.main
            {
                try
                {
                    Run(QuoteWindowsCommandLineArg(paths.steamExe))
                    launched++
                }
                catch as e
                    failedLaunches.Push({ name: item.name, message: e.Message })
                continue
            }

            username := Trim(account.steamUsername)
            password := GetSteamCredentialPassword(accountName)
            command := QuoteWindowsCommandLineArg(paths.sandman) " /box:" accountName " " QuoteWindowsCommandLineArg(paths.steamExe) " -silent -nochatui -nofriendsui -login " QuoteWindowsCommandLineArg(username) " " QuoteWindowsCommandLineArg(password)
            try
            {
                Run(command)
                BeginSandboxieSteamMinimizeWatch(accountName)
                launched++
            }
            catch as e
                failedLaunches.Push({ name: item.name, message: e.Message })
            password := ""
            command := ""
        }

        skippedAttention := missingCredentials.Length + invalidAccounts.Length + sandboxFailures.Length
        StatusText.Text := "Status: Launched Steam for " launched " selected account(s)."
        if createdSandboxes
            StatusText.Text .= " Created " createdSandboxes " missing sandbox(es)."
        if alreadyRunningMain || alreadyRunningSandboxed
            StatusText.Text .= " Already running: " (alreadyRunningMain + alreadyRunningSandboxed) "."
        if skippedAttention
            StatusText.Text .= " Needs attention: " skippedAttention "."
        if failedLaunches.Length
        {
            StatusText.Text .= " Launch failed: " failedLaunches.Length "."
            MsgBox("Steam could not be launched for:`n" JoinSteamLaunchAccountNames(failedLaunches), "Steam Launch Failed", "Icon!")
        }
    }
    finally
    {
        if IsObject(SandboxieSteamAllButton)
            SandboxieSteamAllButton.Enabled := true
    }
}

GetSandboxieHelperPath()
{
    global Settings
    sandman := Trim(Settings["SandboxieSandManExe"])
    if sandman = ""
        return ""
    dir := RegExReplace(sandman, "\\[^\\]+$", "")
    candidate := dir "\SbieIni.exe"
    return FileExist(candidate) ? candidate : ""
}

GetSandboxieBoxExists(boxName)
{
    helper := GetSandboxieHelperPath()
    if helper = "" || boxName = ""
        return false

    temp := A_Temp "\FoxholeMultiboxer_SbieBoxes_" A_TickCount ".txt"
    try
    {
        command := Format('"{1}" query /boxes * > "{2}"', helper, temp)
        RunWait(A_ComSpec " /D /C " Chr(34) command Chr(34), , "Hide")
        if !FileExist(temp)
            return false
        for line in StrSplit(FileRead(temp), "`n", "`r")
        {
            line := Trim(line, " `t[]")
            if line != "" && StrLower(line) = StrLower(boxName)
                return true
        }
    }
    catch
    {
    }
    finally
    {
        try FileDelete(temp)
    }
    return false
}

ReloadSandboxieConfiguration()
{
    global Settings
    sandman := Trim(Settings["SandboxieSandManExe"])
    if sandman = "" || !FileExist(sandman)
        return false

    dir := RegExReplace(sandman, "\\[^\\]+$", "")
    dllPath := dir "\SbieDll.dll"
    if !FileExist(dllPath)
        return false

    hDll := 0
    try
    {
        hDll := DllCall("LoadLibraryW", "WStr", dllPath, "Ptr")
        if !hDll
            return false
        proc := DllCall("GetProcAddress", "Ptr", hDll, "AStr", "SbieApi_ReloadConf", "Ptr")
        if !proc
            return false
        return DllCall(proc, "UInt", 0xFFFFFFFF, "Int") = 0
    }
    catch
    {
        return false
    }
    finally
    {
        if hDll
            DllCall("FreeLibrary", "Ptr", hDll)
    }
}

CreateSandboxieSandbox(boxName)
{
    helper := GetSandboxieHelperPath()
    if helper = ""
        return { ok: false, message: "SbieIni.exe was not found beside SandMan.exe." }

    try
    {
        rc := RunWait(Format('"{1}" set "{2}" ConfigLevel 7', helper, boxName), , "Hide")
        if rc != 0
            return { ok: false, message: "Sandboxie rejected the standard sandbox configuration command (code " rc " )." }

        rc := RunWait(Format('"{1}" set "{2}" Enabled y', helper, boxName), , "Hide")
        if rc != 0
            return { ok: false, message: "Sandboxie rejected the sandbox creation command (code " rc ")." }

        rc := RunWait(Format('"{1}" set "{2}" FakeAdminRights y', helper, boxName), , "Hide")
        if rc != 0
            return { ok: false, message: "Sandbox was created, but FakeAdminRights could not be enabled (code " rc ")." }

        ReloadSandboxieConfiguration()
        if !GetSandboxieBoxExists(boxName)
            return { ok: false, message: "Sandboxie did not report the new sandbox after creation." }

        return { ok: true, message: "Sandbox created and FakeAdminRights enabled." }
    }
    catch as e
    {
        return { ok: false, message: e.Message }
    }
}

GetSandboxieStartPath()
{
    global Settings

    sandman := Trim(Settings["SandboxieSandManExe"])
    if sandman = ""
        return ""

    dir := RegExReplace(sandman, "\\[^\\]+$", "")
    candidate := dir "\Start.exe"
    return FileExist(candidate) ? candidate : ""
}

DeleteSandboxieContentsFast(boxNames)
{
    startExe := GetSandboxieStartPath()
    if startExe = ""
        throw Error("Start.exe was not found beside SandMan.exe.")

    existing := []
    missing := 0
    failed := []

    for boxName in boxNames
    {
        if !IsValidSandboxieName(boxName)
            continue
        if !GetSandboxieBoxExists(boxName)
        {
            missing++
            continue
        }
        existing.Push(boxName)
    }

    terminatePids := []
    for boxName in existing
    {
        try
        {
            Run(Format('"{1}" /box:{2} /terminate', startExe, boxName), , "Hide", &pid)
            if pid
                terminatePids.Push(pid)
        }
        catch as e
            failed.Push(boxName ": terminate failed: " e.Message)
    }

    deadline := A_TickCount + 3000
    for pid in terminatePids
    {
        remaining := deadline - A_TickCount
        if remaining <= 0
            break
        try ProcessWaitClose(pid, remaining / 1000.0)
    }
    Sleep(250)

    deleteJobs := []
    for boxName in existing
    {
        alreadyFailed := false
        for failure in failed
        {
            if InStr(failure, boxName ":") = 1
            {
                alreadyFailed := true
                break
            }
        }
        if alreadyFailed
            continue

        try
        {
            Run(Format('"{1}" /box:{2} delete_sandbox_silent', startExe, boxName), , "Hide", &pid)
            deleteJobs.Push({ name: boxName, pid: pid })
        }
        catch as e
            failed.Push(boxName ": delete failed: " e.Message)
    }

    deleteDeadline := A_TickCount + 110000
    for job in deleteJobs
    {
        remaining := deleteDeadline - A_TickCount
        if remaining <= 0
        {
            failed.Push(job.name ": deletion timed out.")
            continue
        }

        try
        {
            if ProcessExist(job.pid)
                ProcessWaitClose(job.pid, remaining / 1000.0)
            if ProcessExist(job.pid)
                failed.Push(job.name ": deletion timed out.")
        }
        catch as e
            failed.Push(job.name ": " e.Message)
    }

    try RunWait(Format('"{1}" delete_sandbox_silent_phase2', startExe), , "Hide")

    deleted := deleteJobs.Length
    for failure in failed
    {
        for job in deleteJobs
        {
            if InStr(failure, job.name ":") = 1
            {
                deleted--
                break
            }
        }
    }
    if deleted < 0
        deleted := 0

    return { deleted: deleted, missing: missing, failed: failed }
}

IsValidSandboxieName(name)
{
    name := Trim(name)
    if name = "" || StrLen(name) > 32
        return false
    return RegExMatch(name, "^[A-Za-z0-9]+$") = 1
}

ManageSandboxieSteamCredentials(index)
{
    global SandboxieAccounts, StatusText
    accountName := Trim(SandboxieAccounts[index].name)
    if !IsValidSandboxieName(accountName)
    {
        MsgBox("Enter a valid account name first. Sandboxie account names must be 1-32 letters/numbers.", "Steam Credentials", "Icon!")
        return
    }

    username := Trim(SandboxieAccounts[index].steamUsername)
    password := GetSteamCredentialPassword(accountName)

    if username != "" && password != ""
    {
        choice := MsgBox("Steam credentials are already saved for " accountName ".`n`nYes = edit credentials`nNo = clear saved credentials`nCancel = do nothing", "Steam Credentials", "YesNoCancel Iconi Default3")
        if choice = "Cancel"
            return
        if choice = "No"
        {
            DeleteSteamCredential(accountName)
            SandboxieAccounts[index].steamUsername := ""
            SaveConfig()
            StatusText.Text := "Status: Steam credentials cleared for " accountName "."
            return
        }
    }

    usernameGui := Gui("+ToolWindow", "Steam Credentials")
    usernameGui.SetFont("s9", "Segoe UI")
    usernameGui.AddText("x12 y12 w290 h20", "Steam username for " accountName ":")
    userEdit := usernameGui.AddEdit("x12 y36 w290 h24", username)
    RegisterTooltip(userEdit, "Steam username for " accountName ".`nThe username is stored in the multiboxer configuration.")
    usernameGui.AddText("x12 y68 w290 h20", "Steam password:")
    passEdit := usernameGui.AddEdit("x12 y92 w290 h24 Password", "")
    RegisterTooltip(passEdit, "Steam password for " accountName ".`nStored through Windows Credential Manager, not Settings.ini.`nThe entered password remains hidden.")
    usernameGui.AddText("x12 y124 w410 h70 +Wrap", "You should not use your regular password for your Steam alt accounts! Your password is safely stored in Windows Credential Manager, but may be exposed at command-line level when the program is running.")
    usernameGui.AddText("x12 y198 w410 h20", "You can verify how the program functions with the source code at the")

    usernameGui.SetFont("s9 cBlue underline", "Segoe UI")
    githubLink := usernameGui.AddText("x12 y220 w45 h20 +0x100", "GitHub")
    githubLink.OnEvent("Click", (*) => Run("https://github.com/Tommythebold/Foxhole-Multiboxer"))
    RegisterTooltip(githubLink, "Open the Foxhole Multiboxer source code on GitHub.")
    usernameGui.SetFont("s9 norm cBlack", "Segoe UI")
    usernameGui.AddText("x58 y220 w40 h20", "page.")

    credentialSaveBtn := RegisterTooltip(usernameGui.AddButton("x252 y254 w80 h26", "Save"), "Save the Steam login for " accountName ".`nBoth username and password are required.")
    credentialSaveBtn.OnEvent("Click", (*) => SaveSteamCredentialDialog(usernameGui, index, accountName, userEdit, passEdit))
    credentialCancelBtn := RegisterTooltip(usernameGui.AddButton("x342 y254 w80 h26", "Cancel"), "Close without changing the saved credentials.")
    credentialCancelBtn.OnEvent("Click", (*) => usernameGui.Destroy())
    usernameGui.OnEvent("Close", (*) => usernameGui.Destroy())
    usernameGui.Show("w435 h295")
    userEdit.Focus()
}

SaveSteamCredentialDialog(guiObj, index, accountName, userEdit, passEdit)
{
    global SandboxieAccounts, StatusText
    username := Trim(userEdit.Value)
    password := passEdit.Value
    if username = "" || password = ""
    {
        MsgBox("Both the Steam username and password are required.", "Steam Credentials", "Icon!")
        return
    }

    if !WriteSteamCredential(accountName, username, password)
    {
        MsgBox("Windows Credential Manager rejected the credential. The password was not saved.", "Steam Credentials", "Icon!")
        return
    }

    SandboxieAccounts[index].steamUsername := username
    SaveConfig()
    StatusText.Text := "Status: Steam credentials saved securely for " accountName "."
    guiObj.Destroy()
}

SteamCredentialTarget(accountName)
{

    safe := RegExReplace(Trim(accountName), "[^A-Za-z0-9._-]", "_")
    return "FoxholeMultiboxer\Steam\" safe
}

WriteSteamCredential(accountName, username, password)
{
    target := SteamCredentialTarget(accountName)
    targetBuf := Buffer((StrLen(target) + 1) * 2, 0)
    usernameBuf := Buffer((StrLen(username) + 1) * 2, 0)
    blobBuf := Buffer(StrPut(password, "UTF-16") - 2, 0)
    StrPut(target, targetBuf, "UTF-16")
    StrPut(username, usernameBuf, "UTF-16")
    StrPut(password, blobBuf, "UTF-16")

    if A_PtrSize = 8
    {
        cred := Buffer(80, 0)
        NumPut("UInt", 0, cred, 0)
        NumPut("UInt", 1, cred, 4)
        NumPut("Ptr", targetBuf.Ptr, cred, 8)
        NumPut("Ptr", 0, cred, 16)
        NumPut("UInt", blobBuf.Size, cred, 32)
        NumPut("Ptr", blobBuf.Ptr, cred, 40)
        NumPut("UInt", 2, cred, 48)
        NumPut("UInt", 0, cred, 52)
        NumPut("Ptr", 0, cred, 56)
        NumPut("Ptr", 0, cred, 64)
        NumPut("Ptr", usernameBuf.Ptr, cred, 72)
    }
    else
    {
        cred := Buffer(52, 0)
        NumPut("UInt", 0, cred, 0)
        NumPut("UInt", 1, cred, 4)
        NumPut("Ptr", targetBuf.Ptr, cred, 8)
        NumPut("Ptr", 0, cred, 12)
        NumPut("UInt", blobBuf.Size, cred, 24)
        NumPut("Ptr", blobBuf.Ptr, cred, 28)
        NumPut("UInt", 2, cred, 32)
        NumPut("UInt", 0, cred, 36)
        NumPut("Ptr", 0, cred, 40)
        NumPut("Ptr", 0, cred, 44)
        NumPut("Ptr", usernameBuf.Ptr, cred, 48)
    }

    return DllCall("Advapi32\CredWriteW", "Ptr", cred.Ptr, "UInt", 0) != 0
}

GetSteamCredentialPassword(accountName)
{
    target := SteamCredentialTarget(accountName)
    targetBuf := Buffer((StrLen(target) + 1) * 2, 0)
    StrPut(target, targetBuf, "UTF-16")
    pCred := 0
    if !DllCall("Advapi32\CredReadW", "Ptr", targetBuf.Ptr, "UInt", 1, "UInt", 0, "Ptr*", &pCred)
        return ""

    try
    {
        blobSizeOffset := A_PtrSize = 8 ? 32 : 24
        blobPtrOffset := A_PtrSize = 8 ? 40 : 28
        blobSize := NumGet(pCred, blobSizeOffset, "UInt")
        blobPtr := NumGet(pCred, blobPtrOffset, "Ptr")
        if blobSize <= 0 || !blobPtr
            return ""
        return StrGet(blobPtr, blobSize // 2, "UTF-16")
    }
    finally
    {
        DllCall("Advapi32\CredFree", "Ptr", pCred)
    }
}

DeleteSteamCredential(accountName)
{
    target := SteamCredentialTarget(accountName)
    targetBuf := Buffer((StrLen(target) + 1) * 2, 0)
    StrPut(target, targetBuf, "UTF-16")
    return DllCall("Advapi32\CredDeleteW", "Ptr", targetBuf.Ptr, "UInt", 1, "UInt", 0) != 0
}

RepeatBackslashes(count)
{
    result := ""
    Loop count
        result .= "\"
    return result
}

QuoteWindowsCommandLineArg(value)
{

    value := String(value)
    result := '"'
    backslashes := 0
    Loop Parse value
    {
        ch := A_LoopField
        if ch = "\"
        {
            backslashes++
            continue
        }
        if ch = '"'
        {
            result .= RepeatBackslashes(backslashes * 2 + 1) . Chr(34)
            backslashes := 0
            continue
        }
        if backslashes
        {
            result .= RepeatBackslashes(backslashes)
            backslashes := 0
        }
        result .= ch
    }
    if backslashes
        result .= RepeatBackslashes(backslashes * 2)
    result .= '"'
    return result
}

LaunchSandboxieSteam(index)
{
    global SandboxieAccounts, Settings, StatusText

    account := SandboxieAccounts[index]
    accountName := Trim(account.name)
    steamExe := Trim(Settings["SandboxieSteamExe"])

    if account.main
    {
        if steamExe = "" || !FileExist(steamExe)
        {
            MsgBox("Select a valid Steam.exe path first.", "Steam", "Icon!")
            return
        }

        try
        {
            Run(QuoteWindowsCommandLineArg(steamExe))
            StatusText.Text := "Status: Steam launched normally for " (accountName != "" ? accountName : "Main account") "."
        }
        catch as e
            StatusText.Text := "Status: Could not launch Steam normally: " e.Message
        return
    }

    sandman := Trim(Settings["SandboxieSandManExe"])
    username := Trim(account.steamUsername)
    password := GetSteamCredentialPassword(accountName)

    if !IsValidSandboxieName(accountName)
    {
        MsgBox("Enter a valid account name first.", "Steam", "Icon!")
        return
    }
    if sandman = "" || !FileExist(sandman)
    {
        MsgBox("Select a valid Sandboxie SandMan.exe path first.", "Steam", "Icon!")
        return
    }
    if steamExe = "" || !FileExist(steamExe)
    {
        MsgBox("Select a valid Steam.exe path first.", "Steam", "Icon!")
        return
    }
    if !GetSandboxieBoxExists(accountName)
    {
        MsgBox("The Sandboxie sandbox " accountName " does not exist. Use Setup All Sandboxes first.", "Steam", "Icon!")
        return
    }
    if username = "" || password = ""
    {
        ManageSandboxieSteamCredentials(index)
        return
    }

    command := QuoteWindowsCommandLineArg(sandman) " /box:" accountName " " QuoteWindowsCommandLineArg(steamExe) " -silent -nochatui -nofriendsui -login " QuoteWindowsCommandLineArg(username) " " QuoteWindowsCommandLineArg(password)
    try
    {
        Run(command)
        BeginSandboxieSteamMinimizeWatch(accountName)
        password := ""
        command := ""
        StatusText.Text := "Status: Steam launched to tray in sandbox " accountName "."
    }
    catch as e
    {
        password := ""
        command := ""
        StatusText.Text := "Status: Could not launch Steam for " accountName ": " e.Message
    }
}

LaunchSandboxieFoxhole(index)
{
    global SandboxieAccounts, Settings, PendingFoxholeRenameActive
    global PendingFoxholeRenameIndex, PendingFoxholeRenameBaseline, PendingFoxholeRenameStartedAt
    global StatusText

    account := SandboxieAccounts[index]
    accountName := Trim(account.name)
    foxholeExe := Trim(Settings["SandboxieFoxholeExe"])

    if account.main
    {
        if foxholeExe = "" || !FileExist(foxholeExe)
        {
            MsgBox("Select a valid War-Win64-Shipping.exe path first.", "Foxhole", "Icon!")
            return
        }
        try
        {
            Run(QuoteWindowsCommandLineArg(foxholeExe))
            StatusText.Text := "Status: Foxhole launched normally for " (accountName != "" ? accountName : "Main account") "."
        }
        catch as e
            StatusText.Text := "Status: Could not launch Foxhole normally: " e.Message
        return
    }

    sandman := Trim(Settings["SandboxieSandManExe"])

    if !IsValidSandboxieName(accountName)
    {
        MsgBox("Enter a valid account name first.", "Foxhole", "Icon!")
        return
    }
    if sandman = "" || !FileExist(sandman)
    {
        MsgBox("Select a valid Sandboxie SandMan.exe path first.", "Foxhole", "Icon!")
        return
    }
    if foxholeExe = "" || !FileExist(foxholeExe)
    {
        MsgBox("Select a valid War-Win64-Shipping.exe path first.", "Foxhole", "Icon!")
        return
    }
    if !GetSandboxieBoxExists(accountName)
    {
        MsgBox("The Sandboxie sandbox " accountName " does not exist. Use Setup All Sandboxes first.", "Foxhole", "Icon!")
        return
    }
    if PendingFoxholeRenameActive
    {
        StatusText.Text := "Status: Already waiting for a Foxhole window to launch."
        return
    }

    PendingFoxholeRenameBaseline := CaptureFoxholeWindowSnapshot()
    PendingFoxholeRenameIndex := index
    PendingFoxholeRenameStartedAt := A_TickCount
    PendingFoxholeRenameActive := true

    command := Format('"{1}" /box:{2} "{3}"', sandman, accountName, foxholeExe)
    try
        Run(command)
    catch as e
    {
        ClearPendingSandboxieFoxholeRename()
        StatusText.Text := "Status: Could not launch Foxhole for " accountName ": " e.Message
        return
    }

    StatusText.Text := "Status: Foxhole launched for " accountName ". Waiting for game window..."
    SetTimer(WaitForSandboxieFoxholeWindow, 250)
    WaitForSandboxieFoxholeWindow()
}

WaitForSandboxieFoxholeWindow(*)
{
    global PendingFoxholeRenameActive, PendingFoxholeRenameIndex
    global PendingFoxholeRenameBaseline, PendingFoxholeRenameStartedAt
    global PendingFoxholeRenameTimeoutMs, SandboxieAccounts, StatusText
    global Instances

    if !PendingFoxholeRenameActive
    {
        SetTimer(WaitForSandboxieFoxholeWindow, 0)
        return
    }

    if A_TickCount - PendingFoxholeRenameStartedAt > PendingFoxholeRenameTimeoutMs
    {
        accountName := (PendingFoxholeRenameIndex >= 1 && PendingFoxholeRenameIndex <= SandboxieAccounts.Length)
            ? SandboxieAccounts[PendingFoxholeRenameIndex].name
            : "the account"
        StatusText.Text := "Status: Timed out waiting for " accountName "'s Foxhole window."
        ClearPendingSandboxieFoxholeRename()
        return
    }

    candidate := 0
    for hwnd in WinGetList("ahk_exe War-Win64-Shipping.exe")
    {
        if !PendingFoxholeRenameBaseline.Has(hwnd) && IsWindowAlive(hwnd)
        {
            candidate := hwnd
            break
        }
    }

    if !candidate
        return

    ScanWindows()
    idx := FindInstanceByHwnd(candidate)
    if !idx
        return

    accountIndex := PendingFoxholeRenameIndex
    if accountIndex < 1 || accountIndex > SandboxieAccounts.Length
    {
        ClearPendingSandboxieFoxholeRename()
        return
    }

    accountName := Trim(SandboxieAccounts[accountIndex].name)
    if accountName = ""
    {
        ClearPendingSandboxieFoxholeRename()
        return
    }

    inst := Instances[idx]
    desiredTitle := AssignInstanceToAccountSlot(inst, accountIndex, accountName)

    if desiredTitle
    {
        StatusText.Text := "Status: Foxhole named " desiredTitle "."
        ClearPendingSandboxieFoxholeRename()
        RefreshList()
    }
}

ClearPendingSandboxieFoxholeRename()
{
    global PendingFoxholeRenameActive, PendingFoxholeRenameIndex
    global PendingFoxholeRenameBaseline, PendingFoxholeRenameStartedAt

    SetTimer(WaitForSandboxieFoxholeWindow, 0)
    PendingFoxholeRenameActive := false
    PendingFoxholeRenameIndex := 0
    PendingFoxholeRenameBaseline := Map()
    PendingFoxholeRenameStartedAt := 0
}

MonitorSandboxieSupporterPopup(*)
{
    global SandboxiePopupLastHandledHwnd, SandboxiePopupLastHandledAt

    popupList := WinGetList("ahk_exe SandMan.exe")
    if popupList.Length = 0
    {
        SandboxiePopupLastHandledHwnd := 0
        return
    }

    for popupHwnd in popupList
    {
        if !IsWindowAlive(popupHwnd)
            continue

        try popupTitle := WinGetTitle("ahk_id " popupHwnd)
        catch
            continue

        popupTitleLower := StrLower(popupTitle)
        isSupportReminder := InStr(popupTitleLower, "support reminder")
        isAboutSandboxie := InStr(popupTitleLower, "about sandboxie")

        if !isSupportReminder && !isAboutSandboxie
            continue

        if popupHwnd = SandboxiePopupLastHandledHwnd
            && A_TickCount - SandboxiePopupLastHandledAt < 1000
            continue

        try
        {

            controlHwnds := WinGetControlsHwnd("ahk_id " popupHwnd)

            for controlHwnd in controlHwnds
            {
                if !IsWindowAlive(controlHwnd)
                    continue

                if WinGetClass("ahk_id " controlHwnd) != "Button"
                    continue

                buttonText := Trim(ControlGetText("ahk_id " controlHwnd, "ahk_id " popupHwnd))
                buttonText := StrReplace(buttonText, "&", "")

                if StrCompare(buttonText, "Continue", false) != 0
                    continue

                try
                {
                    PostMessage(0x00F5, 0, 0, , "ahk_id " controlHwnd)
                }
                catch
                {

                    try ControlClick("ahk_id " controlHwnd, "ahk_id " popupHwnd, , "Left", 1, "NA")
                    catch
                        continue
                }

                SandboxiePopupLastHandledHwnd := popupHwnd
                SandboxiePopupLastHandledAt := A_TickCount
                return
            }
        }
        catch
        {

        }

        try
        {
            WinActivate("ahk_id " popupHwnd)
            if WinWaitActive("ahk_id " popupHwnd, , 0.35)
            {
                Send("!c")
                Sleep(100)

                if WinExist("ahk_id " popupHwnd)
                    Send("{Enter}")

                SandboxiePopupLastHandledHwnd := popupHwnd
                SandboxiePopupLastHandledAt := A_TickCount
                return
            }
        }
        catch
        {

        }
    }
}

StartSelectedFoxholeLaunches(*)
{
    global SandboxieAccounts, SequentialLaunchActive, SequentialLaunchQueue, Settings
    global SequentialLaunchPosition, SequentialLaunchExpectedSlot, SequentialLaunchSkipped
    global SandboxieFoxholeAllButton, MainLaunchSteamButton, StatusText, Instances

    if SequentialLaunchActive
        return

    SaveSandboxieVisibleRows()
    SequentialLaunchQueue := []
    SequentialLaunchSkipped := 0

    for index, account in SandboxieAccounts
    {
        if !account.selected
            continue

        if Trim(Settings["SandboxieFoxholeExe"]) = "" || !FileExist(Settings["SandboxieFoxholeExe"])
        {
            SequentialLaunchSkipped++
            continue
        }

        if !account.main
        {
            if !IsValidSandboxieName(Trim(account.name)) || !GetSandboxieBoxExists(Trim(account.name))
            {
                SequentialLaunchSkipped++
                continue
            }
        }

        SequentialLaunchQueue.Push({ index: index, name: account.name, main: account.main })
    }

    if SequentialLaunchQueue.Length = 0
    {
        StatusText.Text := SequentialLaunchSkipped ? "Status: No selected Foxhole executables found. Skipped " SequentialLaunchSkipped " account(s)." : "Status: No accounts selected."
        return
    }

    if Instances.Length > 0
    {
        if CountLiveInstances() > 0
        {
            StatusText.Text := "Status: Close existing Foxhole windows before launching a selected batch."
            return
        }
    }

    SequentialLaunchActive := true
    SequentialLaunchPosition := 1
    SequentialLaunchExpectedSlot := 1
    if IsObject(SandboxieFoxholeAllButton)
        SandboxieFoxholeAllButton.Enabled := false
    if IsObject(MainLaunchSteamButton)
        MainLaunchSteamButton.Enabled := false
    StatusText.Text := "Status: Starting " SequentialLaunchQueue.Length " selected Foxhole account(s)..."
    LaunchNextSelectedFoxhole()
}

LaunchNextSelectedFoxhole()
{
    global SequentialLaunchQueue, SequentialLaunchPosition, SequentialLaunchExpectedSlot, Settings
    global SequentialLaunchBaseline, SequentialLaunchCandidateHwnd
    global SequentialLaunchStablePolls, SequentialLaunchStartedAt, StatusText

    if SequentialLaunchPosition > SequentialLaunchQueue.Length
    {
        FinishSequentialFoxholeLaunches()
        return
    }

    SequentialLaunchBaseline := CaptureFoxholeWindowSnapshot()
    SequentialLaunchCandidateHwnd := 0
    SequentialLaunchStablePolls := 0
    SequentialLaunchStartedAt := A_TickCount
    account := SequentialLaunchQueue[SequentialLaunchPosition]

    SequentialLaunchExpectedSlot := Integer(account.index)

    foxholeExe := Trim(Settings["SandboxieFoxholeExe"])
    if account.main
        command := QuoteWindowsCommandLineArg(foxholeExe)
    else
    {
        sandman := Trim(Settings["SandboxieSandManExe"])
        command := Format('"{1}" /box:{2} "{3}"', sandman, Trim(account.name), foxholeExe)
    }
    try
    {
        Run(command)
    }
    catch as e
    {
        StatusText.Text := "Status: Could not launch " account.name ": " e.Message
        StopSequentialFoxholeLaunches()
        return
    }

    StatusText.Text := "Status: Waiting for " account.name " to become War " SequentialLaunchExpectedSlot "..."
    SetTimer(WaitForSequentialFoxholeWindow, 250)
    WaitForSequentialFoxholeWindow()
}

WaitForSequentialFoxholeWindow(*)
{
    global SequentialLaunchActive, SequentialLaunchBaseline, SequentialLaunchCandidateHwnd
    global SequentialLaunchStablePolls, SequentialLaunchStartedAt, SequentialLaunchTimeoutMs
    global SequentialLaunchExpectedSlot, SequentialLaunchQueue, SequentialLaunchPosition, StatusText

    if !SequentialLaunchActive
    {
        SetTimer(WaitForSequentialFoxholeWindow, 0)
        return
    }

    if A_TickCount - SequentialLaunchStartedAt > SequentialLaunchTimeoutMs
    {
        account := SequentialLaunchQueue[SequentialLaunchPosition]
        StatusText.Text := "Status: Timed out waiting for " account.name " to create a Foxhole window."
        StopSequentialFoxholeLaunches()
        return
    }

    candidate := SequentialLaunchCandidateHwnd
    if !candidate
    {
        for hwnd in WinGetList("ahk_exe War-Win64-Shipping.exe")
        {
            if !SequentialLaunchBaseline.Has(hwnd) && IsWindowAlive(hwnd)
            {
                candidate := hwnd
                break
            }
        }
    }

    if !candidate
        return

    ScanWindows()
    idx := FindInstanceByHwnd(candidate)
    if !idx
        return

    inst := Instances[idx]

    account := SequentialLaunchQueue[SequentialLaunchPosition]
    accountName := Trim(account.name)

    desiredTitle := AssignInstanceToAccountSlot(inst, SequentialLaunchExpectedSlot, accountName)
    if !desiredTitle
        return

    RemoveTitleOverlay(candidate)
    CreateTitleOverlay(inst)
    UpdateTitleOverlay(inst)

    if !IsWindowAlive(candidate)
    {
        SequentialLaunchCandidateHwnd := 0
        SequentialLaunchStablePolls := 0
        return
    }

    currentTitle := WinGetTitle("ahk_id " candidate)
    if currentTitle != desiredTitle
    {
        SequentialLaunchCandidateHwnd := candidate
        SequentialLaunchStablePolls := 0
        return
    }

    SequentialLaunchCandidateHwnd := candidate
    SequentialLaunchStablePolls++
    if SequentialLaunchStablePolls < 3
        return

    SequentialLaunchPosition++
    LaunchNextSelectedFoxhole()
}

CaptureFoxholeWindowSnapshot()
{
    snapshot := Map()
    for hwnd in WinGetList("ahk_exe War-Win64-Shipping.exe")
        snapshot[hwnd] := true
    return snapshot
}

FinishSequentialFoxholeLaunches(skipped := 0)
{
    global SequentialLaunchActive, SequentialLaunchQueue, SequentialLaunchSkipped, SandboxieFoxholeAllButton, MainLaunchSteamButton, StatusText

    SetTimer(WaitForSequentialFoxholeWindow, 0)
    SequentialLaunchActive := false

    RebuildAllTitleOverlays()

    if IsObject(SandboxieFoxholeAllButton)
        SandboxieFoxholeAllButton.Enabled := true
    if IsObject(MainLaunchSteamButton)
        MainLaunchSteamButton.Enabled := true
    suffix := SequentialLaunchSkipped ? " Skipped " SequentialLaunchSkipped " selected account(s) without a valid executable." : ""
    StatusText.Text := "Status: Finished launching " SequentialLaunchQueue.Length " Foxhole account(s)." suffix
}

StopSequentialFoxholeLaunches(*)
{
    global SequentialLaunchActive, SandboxieFoxholeAllButton, MainLaunchSteamButton

    SetTimer(WaitForSequentialFoxholeWindow, 0)
    SequentialLaunchActive := false
    RebuildAllTitleOverlays()
    if IsObject(SandboxieFoxholeAllButton)
        SandboxieFoxholeAllButton.Enabled := true
    if IsObject(MainLaunchSteamButton)
        MainLaunchSteamButton.Enabled := true
}

MainGuiResize(guiObj, minMax, width, height)
{
    global LV, StatusText
    if minMax = -1
        return
}

OnListSelect(lv, row, selected)
{
    if selected
    {
        global SelectedIndex
        SelectedIndex := row
    }
}

ScanWindows(*)
{
    global Instances, MaxPracticalInstances, SelectedIndex, Settings
    global SequentialLaunchActive, SequentialLaunchCandidateHwnd, SequentialLaunchExpectedSlot

    for inst in Instances
    {
        if inst.hwnd && !IsWindowAlive(inst.hwnd)
        {
            StopAllHotkeys(inst)
            RemoveTitleOverlay(inst.hwnd)
            inst.hwnd := 0
            inst.displayName := ""
        }
    }

    candidates := Map()

    for hwnd in WinGetList("ahk_exe War-Win64-Shipping.exe")
    {
        if !IsWindowAlive(hwnd)
            continue

        title := WinGetTitle("ahk_id " hwnd)
        slot := ExactWarSlotFromTitle(title)
        candidates[hwnd] := slot
    }

    for hwnd, discoveredSlot in candidates
    {
        idx := FindInstanceByHwnd(hwnd)

        if idx
        {
            inst := Instances[idx]
            isSequentialCandidate := SequentialLaunchActive && SequentialLaunchCandidateHwnd = hwnd

            if isSequentialCandidate
            {

                inst.slot := SequentialLaunchExpectedSlot
            }
            else if discoveredSlot >= 1 && discoveredSlot <= MaxPracticalInstances
            {
                otherIdx := FindLiveInstanceBySlot(discoveredSlot)
                if !otherIdx || otherIdx = idx
                    inst.slot := discoveredSlot
                else
                {

                    freeSlot := LowestFreeSlot()
                    if freeSlot >= 1 && freeSlot <= MaxPracticalInstances
                        inst.slot := freeSlot
                }
            }
            else
            {
                freeSlot := LowestFreeSlot()
                if freeSlot >= 1 && freeSlot <= MaxPracticalInstances
                    inst.slot := freeSlot
            }

            try
            {
                WinGetPos(&x, &y, &w, &h, "ahk_id " hwnd)
                inst.x := x
                inst.y := y
                inst.width := w
                inst.height := h
            }

            if !isSequentialCandidate
                RenameInstance(inst)
            continue
        }

        isSequentialCandidate := SequentialLaunchActive && SequentialLaunchCandidateHwnd = hwnd
        slot := isSequentialCandidate ? SequentialLaunchExpectedSlot : discoveredSlot
        if !isSequentialCandidate && (slot < 1 || slot > MaxPracticalInstances || FindLiveInstanceBySlot(slot))
            slot := LowestFreeSlot()

        if slot < 1 || slot > MaxPracticalInstances
            continue

        try
        {
            WinGetPos(&x, &y, &w, &h, "ahk_id " hwnd)
        }
        catch
        {
            x := 0
            y := 0
            w := 0
            h := 0
        }

        emptyIdx := FindEmptyInstanceBySlot(slot)
        if emptyIdx
        {
            inst := Instances[emptyIdx]
            inst.hwnd := hwnd
            inst.originalTitle := title
            inst.displayName := title
            inst.x := x
            inst.y := y
            inst.width := w
            inst.height := h
            inst.clickInterval := Settings["ClickInterval"]
            inst.borderless := false
            inst.originalStyle := 0
            ApplyBorderless(inst, true)
        }
        else
        {
            Instances.Push({
                hwnd: hwnd,
                slot: slot,
                originalTitle: title,
                displayName: title,
                x: x,
                y: y,
                width: w,
                height: h,
                clickX: Settings["DefaultClickX"],
                clickY: Settings["DefaultClickY"],
                clickInterval: Settings["ClickInterval"],
                autoClick: false,
                autoWalk: false,
                autoReverse: false,
                clickHold: false,
                rightHold: false,
                vSpam: false,
                borderless: false,
                originalStyle: 0,
                timers: Map()
            })

            inst := Instances[Instances.Length]
            ApplyBorderless(inst, true)
        }

        if !isSequentialCandidate
            RenameInstance(inst)

        CreateTitleOverlay(inst)
    }

    i := Instances.Length
    while i >= 1
    {
        inst := Instances[i]
        if inst.hwnd && !IsWindowAlive(inst.hwnd)
        {
            StopAllHotkeys(inst)
            RemoveTitleOverlay(inst.hwnd)
            inst.hwnd := 0
            inst.displayName := ""
        }
        i--
    }

    RefreshList()
}

InitialWindowDiscovery(*)
{
    EnsureFoxholeInstances(6, 250)
}

EnsureFoxholeInstances(attempts := 6, delayMs := 250)
{
    global Instances

    Loop attempts
    {
        ScanWindows()

        live := 0
        for inst in Instances
        {
            if IsWindowAlive(inst.hwnd)
            {
                live := 1
                break
            }
        }

        if live
            return true

        if A_Index < attempts
            Sleep(delayMs)
    }

    return false
}

ExactWarSlotFromTitle(title)
{
    if RegExMatch(title, "i)(?:^|[^\w])War\s+([0-9]+)(?:$|[^\w])", &m)
        return Integer(m[1])
    return 0
}

LowestFreeSlot()
{
    global Instances
    used := Map()
    for inst in Instances
        if inst.hwnd
            used[inst.slot] := true

    slot := 1
    global MaxPracticalInstances
    while slot <= MaxPracticalInstances && used.Has(slot)
        slot++
    return slot
}

FindEmptyInstanceBySlot(slot)
{
    global Instances
    for i, inst in Instances
        if !inst.hwnd && inst.slot = slot
            return i
    return 0
}

FindLiveInstanceBySlot(slot)
{
    global Instances
    for i, inst in Instances
        if inst.hwnd && inst.slot = slot
            return i
    return 0
}

FindInstanceByHwnd(hwnd)
{
    global Instances
    for i, inst in Instances
        if inst.hwnd = hwnd
            return i
    return 0
}

IsWindowAlive(hwnd)
{
    return hwnd && WinExist("ahk_id " hwnd)
}

RefreshList()
{
    global LV, Instances, SelectedIndex, StatusText

    selectedHwnd := 0
    if SelectedIndex >= 1 && SelectedIndex <= Instances.Length
        selectedHwnd := Instances[SelectedIndex].hwnd

    LV.Delete()
    liveCount := 0
    emptyCount := 0
    for i, inst in Instances
    {
        alive := IsWindowAlive(inst.hwnd)
        if alive
        {
            liveCount++
            title := WinGetTitle("ahk_id " inst.hwnd)
            status := "Online"
            hwndText := "0x" Format("{:X}", inst.hwnd)
        }
        else
        {
            emptyCount++
            title := "Slot available"
            status := "Empty"
            hwndText := ""
        }
        hotkeys := HotkeysSummary(inst)
        row := LV.Add(
            "",
            "War " inst.slot,
            title,
            hwndText,
            status,
            hotkeys,
            inst.x, inst.y, inst.width, inst.height
        )
        if inst.hwnd = selectedHwnd && selectedHwnd
            LV.Modify(row, "Select Focus")
    }

    if selectedHwnd
    {
        newSelectedIndex := FindInstanceByHwnd(selectedHwnd)
        if newSelectedIndex
            SelectedIndex := newSelectedIndex
    }

    LV.ModifyCol(1, "Logical Sort")
    ResizeMainGuiForRows(LV.GetCount())

    StatusText.Text := "Status: " liveCount " Foxhole instance(s) online, " emptyCount " slot(s) available."
}

HotkeysSummary(inst)
{
    s := ""
    if inst.autoClick
        s .= "C "
    if inst.autoWalk
        s .= "W "
    if inst.autoReverse
        s .= "R "
    if inst.clickHold
        s .= "L "
    if inst.rightHold
        s .= "B "
    if inst.vSpam
        s .= "V "
    return s = "" ? "—" : Trim(s)
}

ResetInstanceSlots(*)
{
    global Instances, SelectedIndex, StatusText

    ScanWindows()

    selectedHwnd := 0
    if SelectedIndex >= 1 && SelectedIndex <= Instances.Length
    {
        if IsWindowAlive(Instances[SelectedIndex].hwnd)
            selectedHwnd := Instances[SelectedIndex].hwnd
    }

    ordered := []
    for _, inst in Instances
    {
        if IsWindowAlive(inst.hwnd)
            ordered.Push(inst)
    }
    SortInstancesBySlot(ordered)

    for slot, inst in ordered
    {
        inst.slot := slot
        RenameInstance(inst)
    }

    i := Instances.Length
    while i >= 1
    {
        if !IsWindowAlive(Instances[i].hwnd)
            Instances.RemoveAt(i)
        i--
    }

    if selectedHwnd
        SelectedIndex := FindInstanceByHwnd(selectedHwnd)
    else
        SelectedIndex := 0

    RefreshList()

    StatusText.Text := "Status: Reset " ordered.Length " Foxhole slot(s)."
}

GetAccountNameForInstance(inst)
{
    global SandboxieAccounts

    if !inst
        return "Account 1"

    try currentTitle := WinGetTitle("ahk_id " inst.hwnd)
    catch
        currentTitle := ""

    accountName := GetAccountNameFromTitle(currentTitle)
    if accountName != ""
        return accountName

    if inst.slot >= 1 && inst.slot <= SandboxieAccounts.Length
    {
        accountName := Trim(SandboxieAccounts[inst.slot].name)
        if accountName != ""
            return accountName
    }

    return "Account " inst.slot
}

RenameInstance(inst, accountName := "")
{
    global SandboxieAccounts

    if !IsWindowAlive(inst.hwnd)
        return false

    accountName := Trim(accountName)
    if accountName = ""
        accountName := GetAccountNameForInstance(inst)

    newTitle := "War " inst.slot " - " accountName

    try WinSetTitle(newTitle, "ahk_id " inst.hwnd)
    catch
        return false

    inst.displayName := newTitle
    UpdateTitleOverlay(inst)
    return newTitle
}

AssignInstanceToAccountSlot(inst, accountIndex, accountName)
{
    global Instances, MaxPracticalInstances

    if !inst || !IsWindowAlive(inst.hwnd)
        return false

    accountIndex := Integer(accountIndex)
    accountName := Trim(accountName)

    if accountIndex < 1 || accountIndex > MaxPracticalInstances || accountName = ""
        return false

    occupiedIdx := FindLiveInstanceBySlot(accountIndex)
    if occupiedIdx && Instances[occupiedIdx].hwnd != inst.hwnd
    {
        occupied := Instances[occupiedIdx]
        oldSlot := inst.slot
        occupiedAccount := GetAccountNameForInstance(occupied)

        if oldSlot < 1 || oldSlot > MaxPracticalInstances || (FindLiveInstanceBySlot(oldSlot) && FindLiveInstanceBySlot(oldSlot) != FindInstanceByHwnd(inst.hwnd))
            oldSlot := LowestFreeSlot()

        if oldSlot < 1 || oldSlot > MaxPracticalInstances
            return false

        inst.slot := accountIndex
        occupied.slot := oldSlot

        if occupiedAccount != ""
            RenameInstance(occupied, occupiedAccount)
        else
            RenameInstance(occupied)
    }
    else
        inst.slot := accountIndex

    return RenameInstance(inst, accountName)
}

SwitchSlotAccountOntoInstance(inst, accountName)
{
    global Instances

    if !inst || !IsWindowAlive(inst.hwnd)
        return false

    accountName := Trim(accountName)
    if accountName = ""
        return false

    currentAccount := GetAccountNameForInstance(inst)

    holderIdx := 0
    for i, candidate in Instances
    {
        if candidate.hwnd = inst.hwnd || !IsWindowAlive(candidate.hwnd)
            continue

        candidateAccount := GetAccountNameForInstance(candidate)
        if candidateAccount != "" && StrLower(candidateAccount) = StrLower(accountName)
        {
            holderIdx := i
            break
        }
    }

    if holderIdx
    {
        holder := Instances[holderIdx]
        targetSlot := inst.slot
        holderSlot := holder.slot

        if targetSlot < 1 || holderSlot < 1
            return false

        inst.slot := holderSlot
        holder.slot := targetSlot

        if currentAccount != ""
            RenameInstance(holder, currentAccount)
        else
            RenameInstance(holder)

        return RenameInstance(inst, accountName)
    }

    return RenameInstance(inst, accountName)
}

ShowSwitchSlotAccountMenu(inst)
{
    global SwitchSlotMenuGui, SwitchSlotMenuList, SwitchSlotMenuHwnd, SwitchSlotMenuTargetHwnd
    global SwitchSlotMenuDismissTimer, SandboxieRowCount, CONFIG_FILE

    CloseSwitchSlotAccountMenu()
    CloseWindowSwapMenu()

    accounts := GetNamedSandboxieAccounts()
    if accounts.Length = 0
    {
        ToolTip("No named Sandboxie accounts found.")
        SetTimer(HideSwitchSlotNoAccountsTooltip, -1500)
        return
    }

    SwitchSlotMenuTargetHwnd := inst.hwnd
    SwitchSlotMenuGui := Gui("+ToolWindow -Caption +AlwaysOnTop", "Switch Slot")
    SwitchSlotMenuGui.SetFont("s9 c000000", "Segoe UI")
    SwitchSlotMenuGui.BackColor := "FFFFFF"
    SwitchSlotMenuGui.MarginX := 6
    SwitchSlotMenuGui.MarginY := 6

    SwitchSlotMenuGui.AddText("x6 y5 w250 h40 +0x200", "What account is this?")
    SwitchSlotMenuList := SwitchSlotMenuGui.AddListBox("x6 y50 w250 r12", accounts)
    SwitchSlotMenuList.OnEvent("Change", SwitchSlotAccountListChanged)

    menuHeight := Min(12, accounts.Length) * 22 + 56
    if menuHeight < 70
        menuHeight := 70

    CoordMode "Mouse", "Screen"
    MouseGetPos(&mx, &my)

    MonitorGetWorkArea(, &left, &top, &right, &bottom)
    menuW := 262
    menuH := menuHeight
    if mx + menuW > right
        mx := Max(left, right - menuW)
    if my + menuH > bottom
        my := Max(top, bottom - menuH)

    SwitchSlotMenuGui.Show("x" mx " y" my " w" menuW " h" menuH)
    SwitchSlotMenuHwnd := SwitchSlotMenuGui.Hwnd
    SwitchSlotMenuList.Focus()
    SetTimer(CheckSwitchSlotAccountMenuDismissal, 75)
    SwitchSlotMenuDismissTimer := true
}

GetNamedSandboxieAccounts()
{
    global CONFIG_FILE, SandboxieRowCount, MaxSandboxieRows

    accounts := []
    seen := Map()

    count := Min(Max(1, Integer(IniRead(CONFIG_FILE, "Sandboxie", "RowCount", String(SandboxieRowCount)))), MaxSandboxieRows)
    Loop count
    {
        name := Trim(IniRead(CONFIG_FILE, "Sandboxie", "Account" A_Index "Name", ""))
        if name = ""
            continue

        if StrLower(name) = StrLower("Account " A_Index)
            continue

        key := StrLower(name)
        if seen.Has(key)
            continue
        seen[key] := true
        accounts.Push(name)
    }

    return accounts
}

SwitchSlotAccountListChanged(ctrl, *)
{
    if ctrl.Value > 0
        SwitchSlotSelectedAccount(ctrl)
}

SwitchSlotSelectedAccount(ctrl := "")
{
    global SwitchSlotMenuTargetHwnd

    if !IsObject(ctrl)
        return

    name := Trim(ctrl.Text)
    if name = ""
        return

    idx := FindInstanceByHwnd(SwitchSlotMenuTargetHwnd)
    if !idx
    {
        CloseSwitchSlotAccountMenu()
        return
    }

    inst := Instances[idx]
    if !IsWindowAlive(inst.hwnd)
    {
        CloseSwitchSlotAccountMenu()
        return
    }

    newTitle := SwitchSlotAccountOntoInstance(inst, name)
    if newTitle
    {
        ShowSwitchSlotTooltip(inst, name)
        RefreshList()
        UpdateAllTitleOverlays()
    }

    CloseSwitchSlotAccountMenu()
}

CloseSwitchSlotAccountMenu(*)
{
    global SwitchSlotMenuGui, SwitchSlotMenuList, SwitchSlotMenuHwnd, SwitchSlotMenuTargetHwnd, SwitchSlotMenuDismissTimer

    SetTimer(CheckSwitchSlotAccountMenuDismissal, 0)
    SwitchSlotMenuDismissTimer := false
    SwitchSlotMenuList := ""
    SwitchSlotMenuHwnd := 0
    SwitchSlotMenuTargetHwnd := 0

    if IsObject(SwitchSlotMenuGui)
    {
        try SwitchSlotMenuGui.Destroy()
    }
    SwitchSlotMenuGui := ""
}

CheckSwitchSlotAccountMenuDismissal(*)
{
    global SwitchSlotMenuGui, SwitchSlotMenuHwnd

    if !IsObject(SwitchSlotMenuGui) || !SwitchSlotMenuHwnd
    {
        SetTimer(CheckSwitchSlotAccountMenuDismissal, 0)
        return
    }

    if GetKeyState("Escape", "P")
    {
        KeyWait("Escape")
        CloseSwitchSlotAccountMenu()
        return
    }

    active := WinExist("A")
    if active && active != SwitchSlotMenuHwnd
    {
        if !WinActive("ahk_id " SwitchSlotMenuHwnd)
            CloseSwitchSlotAccountMenu()
    }
}

HideSwitchSlotNoAccountsTooltip(*)
{
    ToolTip("")
}

ShowSwitchSlotTooltip(inst, accountName)
{
    if !inst || !IsWindowAlive(inst.hwnd)
        return
    ToolTip("War " inst.slot " - " accountName, , , 1)
    SetTimer(HideHotkeysHotkeyTooltip, 0)
    SetTimer(HideHotkeysHotkeyTooltip, -1500)
}

ShowWindowSwapMenu(inst)
{
    global SwapWindowMenuGui, SwapWindowMenuList, SwapWindowMenuHwnd
    global SwapWindowMenuTargetHwnd, SwapWindowMenuEntries, SwapWindowMenuDismissTimer
    global Instances

    CloseWindowSwapMenu()
    if !inst || !IsWindowAlive(inst.hwnd)
        return

    entries := []
    SwapWindowMenuEntries := []
    ordered := []
    for _, candidate in Instances
    {
        if !IsWindowAlive(candidate.hwnd)
            continue
        ordered.Push(candidate)
    }
    SortInstancesBySlot(ordered)

    for _, candidate in ordered
    {
        accountName := GetAccountNameForInstance(candidate)
        if accountName = ""
            accountName := "Account " candidate.slot
        entries.Push(String(candidate.slot) ". " accountName)
        SwapWindowMenuEntries.Push(candidate.hwnd)
    }

    if entries.Length = 0
        return

    SwapWindowMenuTargetHwnd := inst.hwnd
    DisableAllHotkeys()
    SwapWindowMenuGui := Gui("+ToolWindow -Caption +AlwaysOnTop", "Swap")
    SwapWindowMenuGui.SetFont("s9 c000000", "Segoe UI")
    SwapWindowMenuGui.BackColor := "FFFFFF"
    SwapWindowMenuGui.MarginX := 6
    SwapWindowMenuGui.MarginY := 6
    SwapWindowMenuGui.AddText("x6 y5 w270 h40 +0x200", "Swap with... (Can use # keys).")
    SwapWindowMenuList := SwapWindowMenuGui.AddListBox("x6 y50 w270 r12", entries)
    SwapWindowMenuList.OnEvent("Change", WindowSwapListChanged)

    menuHeight := Min(12, entries.Length) * 22 + 58
    if menuHeight < 70
        menuHeight := 70
    if menuHeight > 340
        menuHeight := 340
    CoordMode "Mouse", "Screen"
    MouseGetPos(&mx, &my)
    MonitorGetWorkArea(, &left, &top, &right, &bottom)
    menuW := 282
    menuH := menuHeight
    if mx + menuW > right
        mx := Max(left, right - menuW)
    if my + menuH > bottom
        my := Max(top, bottom - menuH)

    SwapWindowMenuGui.Show("x" mx " y" my " w" menuW " h" menuH)
    SwapWindowMenuHwnd := SwapWindowMenuGui.Hwnd

    WinSetTransparent(255, "ahk_id " SwapWindowMenuHwnd)
    SwapWindowMenuList.Focus()
    SetTimer(CheckWindowSwapMenuDismissal, 75)
    SwapWindowMenuDismissTimer := true
    OnMessage(0x0100, WindowSwapMenuKeyDown)
}

WindowSwapListChanged(ctrl, *)
{
    if ctrl.Value > 0
        SwapSelectedWindow(ctrl.Value)
}

WindowSwapMenuKeyDown(wParam, lParam, msg, hwnd)
{
    global SwapWindowMenuGui, SwapWindowMenuList, SwapWindowMenuEntries
    if !IsObject(SwapWindowMenuGui) || !SwapWindowMenuGui.Hwnd || !IsObject(SwapWindowMenuList)
        return

    if wParam >= 0x31 && wParam <= 0x39
        entry := wParam - 0x30
    else if wParam >= 0x61 && wParam <= 0x69
        entry := wParam - 0x60
    else
        entry := 0

    if entry >= 1 && entry <= SwapWindowMenuEntries.Length
    {
        SwapWindowMenuList.Value := entry
        SwapSelectedWindow(entry)
        return 0
    }

    if wParam = 0x1B
    {
        CloseWindowSwapMenu()
        return 0
    }
}

SwapSelectedWindow(entry)
{
    global SwapWindowMenuEntries, SwapWindowMenuTargetHwnd
    entry := Integer(entry)
    if entry < 1 || entry > SwapWindowMenuEntries.Length
        return

    targetHwnd := SwapWindowMenuEntries[entry]
    sourceHwnd := SwapWindowMenuTargetHwnd
    if !IsWindowAlive(sourceHwnd) || !IsWindowAlive(targetHwnd)
    {
        CloseWindowSwapMenu()
        return
    }
    if sourceHwnd = targetHwnd
    {
        CloseWindowSwapMenu()
        return
    }

    swapSucceeded := SwapFoxholeWindowRectangles(sourceHwnd, targetHwnd)
    CloseWindowSwapMenu()

    if swapSucceeded && IsWindowAlive(targetHwnd)
        ForceForegroundWindow(targetHwnd)
}

SwapFoxholeWindowRectangles(sourceHwnd, targetHwnd)
{
    global Instances, LayoutWindowPositions
    global LayoutSwapInProgress, LayoutReapplyPending

    if !IsWindowAlive(sourceHwnd) || !IsWindowAlive(targetHwnd)
        return false

    LayoutSwapInProgress := true
    SetTimer(ReapplyLayoutAfterWindowMove, 0)
    LayoutReapplyPending := false

    success := false

    try
    {
        try
        {
            WinGetPos(&sourceX, &sourceY, &sourceW, &sourceH, "ahk_id " sourceHwnd)
            WinGetPos(&targetX, &targetY, &targetW, &targetH, "ahk_id " targetHwnd)
        }
        catch
        {
            return false
        }

        try
        {
            WinMove(targetX, targetY, targetW, targetH, "ahk_id " sourceHwnd)
            WinMove(sourceX, sourceY, sourceW, sourceH, "ahk_id " targetHwnd)
        }
        catch
        {
            return false
        }

        sourceIdx := FindInstanceByHwnd(sourceHwnd)
        targetIdx := FindInstanceByHwnd(targetHwnd)
        if sourceIdx
        {
            Instances[sourceIdx].x := targetX
            Instances[sourceIdx].y := targetY
            Instances[sourceIdx].width := targetW
            Instances[sourceIdx].height := targetH
        }
        if targetIdx
        {
            Instances[targetIdx].x := sourceX
            Instances[targetIdx].y := sourceY
            Instances[targetIdx].width := sourceW
            Instances[targetIdx].height := sourceH
        }

        LayoutWindowPositions := CaptureFoxholeWindowPositions()
        success := true
    }
    finally
    {

        LayoutWindowPositions := CaptureFoxholeWindowPositions()
        LayoutSwapInProgress := false
        LayoutReapplyPending := false
    }

    if success
        RefreshList()
    return success
}

CloseWindowSwapMenu(*)
{
    global SwapWindowMenuGui, SwapWindowMenuList, SwapWindowMenuHwnd
    global SwapWindowMenuTargetHwnd, SwapWindowMenuEntries, SwapWindowMenuDismissTimer
    wasOpen := IsObject(SwapWindowMenuGui) && SwapWindowMenuHwnd
    SetTimer(CheckWindowSwapMenuDismissal, 0)
    SwapWindowMenuDismissTimer := false
    OnMessage(0x0100, WindowSwapMenuKeyDown, 0)
    SwapWindowMenuList := ""
    SwapWindowMenuHwnd := 0
    SwapWindowMenuTargetHwnd := 0
    SwapWindowMenuEntries := []
    if IsObject(SwapWindowMenuGui)
    {
        try SwapWindowMenuGui.Destroy()
    }
    SwapWindowMenuGui := ""
    if wasOpen
        EnableAllHotkeys()
}

CheckWindowSwapMenuDismissal(*)
{
    global SwapWindowMenuGui, SwapWindowMenuHwnd
    if !IsObject(SwapWindowMenuGui) || !SwapWindowMenuHwnd
    {
        SetTimer(CheckWindowSwapMenuDismissal, 0)
        return
    }
    if GetKeyState("Escape", "P")
    {
        KeyWait("Escape")
        CloseWindowSwapMenu()
        return
    }

    active := WinExist("A")
    if active && active != SwapWindowMenuHwnd
    {
        if !WinActive("ahk_id " SwapWindowMenuHwnd)
            CloseWindowSwapMenu()
    }
}

ApplyBorderless(inst, borderless)
{
    if !IsWindowAlive(inst.hwnd)
        return false

    hwnd := inst.hwnd
    if borderless
    {
        if !inst.HasOwnProp("borderless")
            inst.borderless := false

        if !inst.HasOwnProp("originalStyle")
            inst.originalStyle := 0

        if !inst.borderless
            inst.originalStyle := WinGetStyle("ahk_id " hwnd)

        style := WinGetStyle("ahk_id " hwnd)
        remove := 0x00C00000 | 0x00040000 | 0x00020000 | 0x00010000 | 0x00080000
        newStyle := style & ~remove
        WinSetStyle(newStyle, "ahk_id " hwnd)
        RefreshFrame(hwnd)
        inst.borderless := true
    }
    else
    {
        if !inst.HasOwnProp("originalStyle")
            inst.originalStyle := 0

        if inst.originalStyle
            WinSetStyle(inst.originalStyle, "ahk_id " hwnd)
        else
            WinSetStyle(0x10CF0000, "ahk_id " hwnd)
        RefreshFrame(hwnd)
        inst.borderless := false
    }
    return true
}

RefreshFrame(hwnd)
{
    DllCall("SetWindowPos",
        "Ptr", hwnd,
        "Ptr", 0,
        "Int", 0, "Int", 0, "Int", 0, "Int", 0,
        "UInt", 0x0001 | 0x0002 | 0x0004 | 0x0020 | 0x0400)
}

CreateTitleOverlay(inst)
{
    global TitleOverlays, Settings

    if !Settings["ShowOverlay"]
        return
    if !IsWindowAlive(inst.hwnd)
        return
    if TitleOverlays.Has(inst.hwnd)
        return

    overlay := Gui("-Caption +ToolWindow +AlwaysOnTop +E0x20", "")
    overlay.BackColor := "000000"
    overlay.SetFont("s10 bold", "Segoe UI")
    text := overlay.AddText("x6 y3 w180 h24 cFFFFFF +0x200", "")

    overlay.Show("Hide w200 h30")
    try WinSetTransColor("000000 0", "ahk_id " . overlay.Hwnd)
    try WinSetTransparent(200, "ahk_id " . overlay.Hwnd)

    TitleOverlays[inst.hwnd] := {gui: overlay, text: text}
}

UpdateTitleOverlay(inst)
{
    global TitleOverlays, Settings

    if !Settings["ShowOverlay"]
    {
        if TitleOverlays.Has(inst.hwnd)
            RemoveTitleOverlay(inst.hwnd)
        return
    }

    if !IsWindowAlive(inst.hwnd)
    {
        RemoveTitleOverlay(inst.hwnd)
        return
    }

    if !TitleOverlays.Has(inst.hwnd)
        CreateTitleOverlay(inst)
    if !TitleOverlays.Has(inst.hwnd)
        return

    overlay := TitleOverlays[inst.hwnd]
    try
    {
        title := WinGetTitle("ahk_id " inst.hwnd)
        if title = ""
        {
            accountName := GetAccountNameForInstance(inst)
            title := "War " inst.slot " - " accountName
        }
        overlay.text.Text := title

        WinGetPos(&x, &y, &w, &h, "ahk_id " inst.hwnd)
        oldOverlayW := Min(500, Max(180, w - 20))
        overlayW := Max(100, Round(oldOverlayW * 0.40))
        overlayH := 30
        overlay.text.Move(6, 3, overlayW - 12, 24)
        overlay.gui.Show("NA x" (x + 50) " y" (y + 8) " w" overlayW " h" overlayH)
        try WinSetTransparent(200, "ahk_id " . overlay.gui.Hwnd)
    }
    catch
    {
        RemoveTitleOverlay(inst.hwnd)
    }
}

RemoveTitleOverlay(hwnd)
{
    global TitleOverlays
    if TitleOverlays.Has(hwnd)
    {
        try TitleOverlays[hwnd].gui.Destroy()
        TitleOverlays.Delete(hwnd)
    }
}

UpdateAllTitleOverlays()
{
    global Instances, TitleOverlays, Settings

    if !Settings["ShowOverlay"]
    {
        for hwnd, overlay in TitleOverlays
        {
            try overlay.gui.Destroy()
        }
        TitleOverlays := Map()
        return
    }

    live := Map()
    for inst in Instances
    {
        if IsWindowAlive(inst.hwnd)
        {
            live[inst.hwnd] := true
            UpdateTitleOverlay(inst)
        }
    }

    for hwnd, _ in TitleOverlays
    {
        if !live.Has(hwnd)
            RemoveTitleOverlay(hwnd)
    }
}

RebuildAllTitleOverlays()
{
    global Instances, TitleOverlays, Settings

    for hwnd, overlay in TitleOverlays
    {
        try overlay.gui.Destroy()
    }
    TitleOverlays := Map()

    if !Settings["ShowOverlay"]
        return

    for inst in Instances
    {
        if !IsWindowAlive(inst.hwnd)
            continue
        CreateTitleOverlay(inst)
        UpdateTitleOverlay(inst)
    }
}

MaintainTitleOverlays(*)
{
    UpdateAllTitleOverlays()
}

Range(a, b)
{
    arr := []
    Loop b - a + 1
        arr.Push(a + A_Index - 1)
    return arr
}

GetAccountNameFromTitle(title)
{
    if RegExMatch(title, "i)^War\s+[0-9]+\s+-\s+(.+?)\s*$", &m)
        return Trim(m[1])
    return ""
}

SortInstancesBySlot(arr)
{
    Loop arr.Length - 1
    {
        i := A_Index + 1
        current := arr[i]
        j := i - 1

        while j >= 1 && arr[j].slot > current.slot
        {
            arr[j + 1] := arr[j]
            j -= 1
        }
        arr[j + 1] := current
    }
}

CountLiveInstances()
{
    global Instances
    count := 0
    for inst in Instances
    {
        if IsWindowAlive(inst.hwnd)
            count++
    }
    return count
}

ToggleAction(inst, action)
{
    if !IsWindowAlive(inst.hwnd)
        return

    switch action
    {
        case "AutoClick":
            if inst.clickHold
                StopAction(inst, "ClickHold")
            inst.autoClick := !inst.autoClick
            if inst.autoClick
                StartAction(inst, "AutoClick")
            else
                StopAction(inst, "AutoClick")

        case "AutoWalk":
            if inst.autoReverse
                StopAction(inst, "AutoReverse")
            inst.autoWalk := !inst.autoWalk
            if inst.autoWalk
                StartAction(inst, "AutoWalk")
            else
                StopAction(inst, "AutoWalk")

        case "AutoReverse":
            if inst.autoWalk
                StopAction(inst, "AutoWalk")
            inst.autoReverse := !inst.autoReverse
            if inst.autoReverse
                StartAction(inst, "AutoReverse")
            else
                StopAction(inst, "AutoReverse")

        case "ClickHold":
            if inst.autoClick
                StopAction(inst, "AutoClick")
            inst.clickHold := !inst.clickHold
            if inst.clickHold
                StartAction(inst, "ClickHold")
            else
                StopAction(inst, "ClickHold")

        case "RightHold":
            inst.rightHold := !inst.rightHold
            if inst.rightHold
                StartAction(inst, "RightHold")
            else
                StopAction(inst, "RightHold")

        case "VSpam":
            inst.vSpam := !inst.vSpam
            if inst.vSpam
                StartAction(inst, "VSpam")
            else
                StopAction(inst, "VSpam")
    }
}

StartAction(inst, action)
{
    if !IsWindowAlive(inst.hwnd)
        return

    if action = "AutoClick" || action = "ClickHold"
    {
        if WinActive("ahk_id " inst.hwnd)
            CaptureMouseForInstance(inst)
    }

    switch action
    {
        case "AutoClick":
            SendBackgroundClick(inst)
            SetInstanceTimer(inst, "AutoClick", (*) => SendBackgroundClick(inst), inst.clickInterval)

        case "AutoWalk":
            SetInstanceTimer(inst, "AutoWalk", (*) => SendBackgroundW(inst), Settings["WalkInterval"])
            SendBackgroundW(inst)

        case "AutoReverse":
            SetInstanceTimer(inst, "AutoReverse", (*) => SendBackgroundS(inst), Settings["ReverseInterval"])
            SendBackgroundS(inst)

        case "ClickHold":
            SendBackgroundHold(inst)
            SetInstanceTimer(inst, "ClickHold", (*) => SendBackgroundHold(inst), Settings["LeftHoldInterval"])

        case "RightHold":
            SendBackgroundRightHold(inst)
            SetInstanceTimer(inst, "RightHold", (*) => SendBackgroundRightHold(inst), Settings["RightHoldInterval"])

        case "VSpam":
            SendBackgroundV(inst)
            SetInstanceTimer(inst, "VSpam", (*) => SendBackgroundV(inst), Settings["VSpamInterval"])
    }
}

StopAction(inst, action)
{
    RemoveInstanceTimer(inst, action)

    alive := IsWindowAlive(inst.hwnd)

    switch action
    {
        case "AutoClick":
            inst.autoClick := false
            if alive
                PostMouseUp(inst.hwnd, inst.clickX, inst.clickY)

        case "AutoWalk":
            inst.autoWalk := false
            if alive
                PostKeyUp(inst.hwnd, 0x57, 0xC0570001)

        case "AutoReverse":
            inst.autoReverse := false
            if alive
                PostKeyUp(inst.hwnd, 0x53, 0xC0530001)

        case "ClickHold":
            inst.clickHold := false
            if alive
                PostMouseUp(inst.hwnd, inst.clickX, inst.clickY)

        case "RightHold":
            inst.rightHold := false
            if alive
                PostMessage(0x0205, 0, 0, , "ahk_id " inst.hwnd)

        case "VSpam":
            inst.vSpam := false
            if alive
                PostKeyUp(inst.hwnd, 0x56, 0xC0560001)
    }
}

SetInstanceTimer(inst, action, callback, interval)
{
    RemoveInstanceTimer(inst, action)
    inst.timers[action] := callback
    SetTimer(callback, interval)
}

RemoveInstanceTimer(inst, action)
{
    if inst.timers.Has(action)
    {
        try SetTimer(inst.timers[action], 0)
        catch
        {
        }
        inst.timers.Delete(action)
    }
}

StopAllHotkeys(inst)
{
    for action in ["AutoClick", "AutoWalk", "AutoReverse", "ClickHold", "RightHold", "VSpam"]
        StopAction(inst, action)
}

GetHotkeysTargets(hwnd)
{
    targets := []
    if !IsWindowAlive(hwnd)
        return targets

    child := DllCall("GetWindow", "Ptr", hwnd, "UInt", 5, "Ptr")
    if child
    {
        loop
        {
            next := DllCall("GetWindow", "Ptr", child, "UInt", 5, "Ptr")
            if !next
                break
            child := next
        }
        if child
            targets.Push(child)
    }
    targets.Push(hwnd)
    return targets
}

SendBackgroundClick(inst)
{
    if !IsWindowAlive(inst.hwnd)
        return
    lp := MakeLParam(inst.clickX, inst.clickY)
    target := "ahk_id " inst.hwnd
    PostMessage(0x0200, 0, lp, , target)
    PostMessage(0x0201, 0, lp, , target)
    PostMessage(0x0202, 0, lp, , target)
}

SendBackgroundW(inst)
{
    if !IsWindowAlive(inst.hwnd)
        return
    for targetHwnd in GetHotkeysTargets(inst.hwnd)
        PostMessage(0x0100, 0x57, 0x00570001, , "ahk_id " targetHwnd)
}

SendBackgroundS(inst)
{
    if !IsWindowAlive(inst.hwnd)
        return
    for targetHwnd in GetHotkeysTargets(inst.hwnd)
        PostMessage(0x0100, 0x53, 0x00530001, , "ahk_id " targetHwnd)
}

SendBackgroundHold(inst)
{
    if !IsWindowAlive(inst.hwnd)
        return
    lp := MakeLParam(inst.clickX, inst.clickY)
    for targetHwnd in GetHotkeysTargets(inst.hwnd)
    {
        target := "ahk_id " targetHwnd
        PostMessage(0x0200, 0, lp, , target)
        PostMessage(0x0201, 0, lp, , target)
    }
}

SendBackgroundRightHold(inst)
{
    if IsWindowAlive(inst.hwnd)
        ControlClick(, "ahk_id " inst.hwnd, , "RIGHT", 1, "NA D{Blind}")
}

SendBackgroundV(inst)
{
    if !IsWindowAlive(inst.hwnd)
        return
    target := "ahk_id " inst.hwnd
    PostMessage(0x0100, 0x56, 0x00560001, , target)
    PostMessage(0x0101, 0x56, 0xC0560001, , target)
}

PostKeyUp(hwnd, vk, lp := 0)
{
    for targetHwnd in GetHotkeysTargets(hwnd)
        PostMessage(0x0101, vk, lp, , "ahk_id " targetHwnd)
}

PostMouseUp(hwnd, x, y)
{
    lp := MakeLParam(x, y)
    for targetHwnd in GetHotkeysTargets(hwnd)
    {
        target := "ahk_id " targetHwnd
        PostMessage(0x0200, 0, lp, , target)
        PostMessage(0x0202, 0, lp, , target)
    }
}

MakeLParam(x, y)
{
    return (x & 0xFFFF) | ((y & 0xFFFF) << 16)
}

CaptureMouseForInstance(inst)
{
    if !WinActive("ahk_id " inst.hwnd)
        return false

    CoordMode "Mouse", "Client"
    MouseGetPos(&mx, &my)
    inst.clickX := mx
    inst.clickY := my
    return true
}

SaveHotkeyInterval(action, ctrl)
{
    global Instances, IntervalSettings, IntervalMinimums, Settings, StatusText, ActionLabels

    try
    {
        interval := Max(IntervalMinimums[action], Integer(ctrl.Value))
    }
    catch
    {
        return
    }

    ctrl.Value := String(interval)
    settingName := IntervalSettings[action]
    Settings[settingName] := interval

    for inst in Instances
    {
        if action = "AutoClick"
            inst.clickInterval := interval

        if IsHotkeysActionEnabled(inst, action)
        {
            StopAction(inst, action)
            StartAction(inst, action)
        }
    }

    SaveConfig()
    StatusText.Text := "Status: " ActionLabels[action] " interval set to " interval " ms."
}

ApplyAllHotkeys()
{
    EnableAllHotkeys()
}

GlobalSharedHotkey(keyName)
{
    global Instances, ActionNames, CurrentKeys

    normalizedKey := StrLower(keyName)
    idx := 0

    for action in ActionNames
    {
        if CurrentKeys[action] = "" || StrLower(CurrentKeys[action]) != normalizedKey
            continue

        if action = "MouseFocus"
        {
            ToggleMouseFocus()
        }
        else if action = "SwitchSlot"
        {
            if !idx
                idx := GetActiveFoxholeInstanceIndex()
            if !idx
                continue
            ShowSwitchSlotAccountMenu(Instances[idx])
        }
        else if action = "Swap"
        {
            if !idx
                idx := GetActiveFoxholeInstanceIndex()
            if !idx
                continue
            ShowWindowSwapMenu(Instances[idx])
        }
        else
        {
            if !idx
                idx := GetActiveFoxholeInstanceIndex()
            if !idx
                continue

            ToggleAction(Instances[idx], action)
            ShowHotkeysHotkeyTooltip(action, Instances[idx])
        }
    }

    RefreshList()
}

MakeSharedHotkeyHandler(keyName)
{
    return (*) => GlobalSharedHotkey(keyName)
}

HotkeysGuiMouseMove(wParam, lParam, msg, hwnd)
{
    global HotkeysGui, RebindButtons, CurrentKeys

    if !IsObject(HotkeysGui) || !HotkeysGui.Hwnd
        return

    MouseGetPos(,, &mouseGuiHwnd, &mouseControlHwnd)
    if !mouseGuiHwnd || !mouseControlHwnd
        return

    for action, button in RebindButtons
    {
        if mouseControlHwnd = button.Hwnd
        {
            if CurrentKeys.Has(action)
            {
                displayKey := DisplayNameForHotkeyString(CurrentKeys[action])
                ToolTip("Current keybind: " displayKey, , , 2)
            }
            return
        }
    }

    ToolTip("", , , 2)
}

ShowHotkeysHotkeyTooltip(action, inst)
{
    global HotkeyTooltipTimer

    if !inst || !IsWindowAlive(inst.hwnd)
        return

    warTitle := "War " inst.slot
    actionName := Map(
        "AutoClick", "Auto Click",
        "AutoWalk", "Forward",
        "AutoReverse", "Reverse",
        "ClickHold", "Left Click Hold",
        "RightHold", "Right Click Hold",
        "VSpam", "V Spam"
    )[action]

    state := IsHotkeysActionEnabled(inst, action) ? "ON" : "OFF"
    ToolTip(actionName " " state ", " warTitle, , , 1)

    SetTimer(HideHotkeysHotkeyTooltip, 0)
    SetTimer(HideHotkeysHotkeyTooltip, -1500)
}

IsHotkeysActionEnabled(inst, action)
{
    switch action
    {
        case "AutoClick":
            return inst.autoClick
        case "AutoWalk":
            return inst.autoWalk
        case "AutoReverse":
            return inst.autoReverse
        case "ClickHold":
            return inst.clickHold
        case "RightHold":
            return inst.rightHold
        case "VSpam":
            return inst.vSpam
    }
    return false
}

HideHotkeysHotkeyTooltip()
{
    ToolTip("", , , 1)
}

ToggleMouseFocus()
{
    global MouseFocusEnabled, HoverFocusedHwnd, StatusText

    MouseFocusEnabled := !MouseFocusEnabled
    HoverFocusedHwnd := 0

    if MouseFocusEnabled
    {
        SetTimer(FocusHoveredFoxholeWindow, 50)
        StatusText.Text := "Status: Mouse Focus ON."
        ShowMouseFocusTooltip()
        FocusHoveredFoxholeWindow()
    }
    else
    {
        SetTimer(FocusHoveredFoxholeWindow, 0)
        StatusText.Text := "Status: Mouse Focus OFF."
        ShowMouseFocusTooltip()
    }
}

ShowMouseFocusTooltip()
{
    global MouseFocusEnabled

    state := MouseFocusEnabled ? "ON" : "OFF"
    ToolTip("Mouse Focus " state, , , 1)
    SetTimer(HideHotkeysHotkeyTooltip, 0)
    SetTimer(HideHotkeysHotkeyTooltip, -1500)
}

FocusHoveredFoxholeWindow()
{
    global Instances, MouseFocusEnabled, HoverFocusedHwnd

    if !MouseFocusEnabled
        return

    MouseGetPos(,, &mouseHwnd)
    if !mouseHwnd
        return

    rootHwnd := DllCall("GetAncestor", "ptr", mouseHwnd, "uint", 2, "ptr")
    if !rootHwnd
        rootHwnd := mouseHwnd

    idx := FindInstanceByHwnd(rootHwnd)
    if !idx
        return

    if HoverFocusedHwnd = rootHwnd && WinActive("ahk_id " rootHwnd)
        return

    if !IsWindowAlive(rootHwnd)
        return

    if ForceForegroundWindow(rootHwnd)
        HoverFocusedHwnd := rootHwnd
}

ForceForegroundWindow(hwnd)
{
    if !IsWindowAlive(hwnd)
        return false

    try
    {
        if WinGetMinMax("ahk_id " hwnd) = -1
            WinRestore("ahk_id " hwnd)

        foreground := DllCall("GetForegroundWindow", "Ptr")
        if foreground = hwnd
            return true

        targetThread := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", 0, "UInt")
        currentThread := DllCall("GetCurrentThreadId", "UInt")
        foregroundThread := foreground ? DllCall("GetWindowThreadProcessId", "Ptr", foreground, "UInt*", 0, "UInt") : 0

        if foregroundThread && foregroundThread != currentThread
            DllCall("AttachThreadInput", "UInt", currentThread, "UInt", foregroundThread, "Int", 1)
        if targetThread && targetThread != currentThread
            DllCall("AttachThreadInput", "UInt", currentThread, "UInt", targetThread, "Int", 1)

        DllCall("BringWindowToTop", "Ptr", hwnd)
        WinActivate("ahk_id " hwnd)
        DllCall("SetForegroundWindow", "Ptr", hwnd)
        DllCall("SetActiveWindow", "Ptr", hwnd)

        if targetThread && targetThread != currentThread
            DllCall("AttachThreadInput", "UInt", currentThread, "UInt", targetThread, "Int", 0)
        if foregroundThread && foregroundThread != currentThread
            DllCall("AttachThreadInput", "UInt", currentThread, "UInt", foregroundThread, "Int", 0)

        return DllCall("GetForegroundWindow", "Ptr") = hwnd
    }
    catch
    {
        try WinActivate("ahk_id " hwnd)
        return WinActive("ahk_id " hwnd)
    }
}

GetActiveFoxholeInstanceIndex()
{
    global Instances

    hwnd := WinGetID("A")
    if !hwnd
        return 0

    return FindInstanceByHwnd(hwnd)
}

DisableAllHotkeys()
{
    global ActionNames, CurrentKeys

    disabled := Map()

    for action in ActionNames
    {
        key := CurrentKeys[action]
        if key = ""
            continue

        normalizedKey := StrLower(key)
        if disabled.Has(normalizedKey)
            continue

        try Hotkey(key, "Off")
        disabled[normalizedKey] := true
    }

}

EnableAllHotkeys()
{
    global ActionNames, CurrentKeys

    registered := Map()

    for action in ActionNames
    {
        key := CurrentKeys[action]
        if key = ""
            continue

        normalizedKey := StrLower(key)
        if registered.Has(normalizedKey)
            continue

        try
        {
            Hotkey(key, MakeSharedHotkeyHandler(key), "On")
            registered[normalizedKey] := true
        }
        catch as e
        {
            MsgBox("Could not register " DisplayNameForHotkeyString(key) ".`n" e.Message, APP_NAME, "Icon!")
        }
    }

}

MakeHotkeysRebindHandler(action)
{
    handler(ctrlObj, info)
    {
        StartRebind(action, ctrlObj)
    }
    return handler
}

StartRebind(action, btn)
{
    global RebindingAction, RebindStatus, CurrentKeys, PollKeyList

    if RebindingAction != ""
        return

    if PollKeyList.Length = 0
        InitPollKeyList()

    DisableAllHotkeys()
    RebindingAction := action
    btn.Text := "Press any key..."
    StatusText.Text := "Status: Listening for " ActionLabels[action] " (Esc to cancel)..."

    SetTimer(PollForHotkeysRebind, 20)

    PollForHotkeysRebind()
    {
        global RebindingAction, PollKeyList

        if RebindingAction = ""
        {
            SetTimer(PollForHotkeysRebind, 0)
            return
        }

        for keyName in PollKeyList
        {
            if IsModifierKeyName(keyName)
                continue

            if GetKeyState(keyName, "P")
            {
                SetTimer(PollForHotkeysRebind, 0)

                modPrefix := BuildHeldModifierPrefix()

                SetTimer(PollForHotkeysRebind, 0)
                BeginRebindReleaseWatch(keyName)
                FinishRebind(action, btn, modPrefix, keyName)

                SetTimer(WaitForRebindInputRelease, 10)
                return
            }
        }
    }
}

InitPollKeyList()
{
    global PollKeyList

    list := []

    Loop 26
        list.Push(Chr(64 + A_Index))

    Loop 10
        list.Push(String(A_Index - 1))

    Loop 24
        list.Push("F" A_Index)

    for k in ["Space", "Enter", "Tab", "Escape", "Backspace", "Delete", "Insert",
        "Home", "End", "PgUp", "PgDn", "Up", "Down", "Left", "Right",
        "CapsLock", "PrintScreen", "Pause", "AppsKey",
        "LWin", "RWin", "LControl", "RControl", "LShift", "RShift", "LAlt", "RAlt",
        "NumpadDot", "NumpadDiv", "NumpadMult", "NumpadAdd", "NumpadSub", "NumpadEnter",
        "Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4",
        "Numpad5", "Numpad6", "Numpad7", "Numpad8", "Numpad9",
        "MButton", "XButton1", "XButton2",
        "`;", "'", "``", "[", "]", "\", ",", ".", "/", "-", "="]
        list.Push(k)

    PollKeyList := list
}

BuildHeldModifierPrefix()
{
    global ModifierKeyDefs

    prefix := ""

    for modDef in ModifierKeyDefs
    {
        for sideKey in modDef.keys
        {
            if GetKeyState(sideKey, "P")
            {
                prefix .= modDef.symbol
                break
            }
        }
    }

    return prefix
}

FinishRebind(action, btn, modPrefix, keyName)
{
    global RebindingAction, CurrentKeys, ActionNames, ActionLabels, RebindButtons

    RebindingAction := ""

    if keyName = "Escape" && modPrefix = ""
    {
        btn.Text := ActionButtonText(action, CurrentKeys[action])
        StatusText.Text := "Status: Rebind cancelled."
        BeginRebindReleaseWatch(keyName)
        return
    }

    fullKey := modPrefix . keyName

    oldKey := CurrentKeys[action]

    for otherAction in ActionNames
    {
        if otherAction = action
            continue
        if CurrentKeys[otherAction] != "" && StrLower(CurrentKeys[otherAction]) = StrLower(fullKey)
        {
            CurrentKeys[otherAction] := DefaultKeys[otherAction]
            if RebindButtons.Has(otherAction)
                RebindButtons[otherAction].Text := ActionButtonText(otherAction, CurrentKeys[otherAction])
        }
    }

    CurrentKeys[action] := fullKey

    SaveHotkeysConfig()

    btn.Text := ActionButtonText(action, fullKey)
    StatusText.Text := "Status: " ActionLabels[action] " = " DisplayNameForHotkeyString(fullKey)
}

BeginRebindReleaseWatch(keyName)
{
    global RebindReleaseKeys, ModifierKeyDefs

    RebindReleaseKeys := [keyName]

    for modDef in ModifierKeyDefs
    {
        for sideKey in modDef.keys
        {
            if GetKeyState(sideKey, "P")
            {
                RebindReleaseKeys.Push(sideKey)
                break
            }
        }
    }

    SetTimer(WaitForRebindInputRelease, 10)
}

WaitForRebindInputRelease(*)
{
    global RebindReleaseKeys

    for keyName in RebindReleaseKeys
    {
        if GetKeyState(keyName, "P")
            return
    }

    SetTimer(WaitForRebindInputRelease, 0)
    RebindReleaseKeys := []
    EnableAllHotkeys()
}

SaveHotkeysConfig()
{
    global CONFIG_FILE, ActionNames, CurrentKeys

    for action in ActionNames
        IniWrite(CurrentKeys[action], CONFIG_FILE, "Hotkeys", action)
}

ActionButtonText(action, key)
{
    global ActionLabels
    return ActionLabels[action] " | " DisplayNameForHotkeyString(key)
}

IsModifierKeyName(keyName)
{
    static modNames := ["LControl", "RControl", "LShift", "RShift", "LAlt", "RAlt", "LWin", "RWin"]

    for m in modNames
        if keyName = m
            return true

    return false
}

DisplayNameForHotkeyString(hotkeyStr)
{
    if hotkeyStr = ""
        return "Unbound"

    modPrefix := ""
    pos := 1

    Loop Parse, hotkeyStr
    {
        if (A_LoopField = "^" || A_LoopField = "+" || A_LoopField = "!" || A_LoopField = "#")
        {
            modPrefix .= A_LoopField
            pos += 1
        }
        else
            break
    }

    keyName := SubStr(hotkeyStr, pos)
    return FormatKeyDisplay(modPrefix, keyName)
}

FormatKeyDisplay(modPrefix, keyName)
{
    parts := []

    if InStr(modPrefix, "^")
        parts.Push("Ctrl")
    if InStr(modPrefix, "+")
        parts.Push("Shift")
    if InStr(modPrefix, "!")
        parts.Push("Alt")
    if InStr(modPrefix, "#")
        parts.Push("Win")

    parts.Push(keyName)

    result := ""
    for i, p in parts
        result .= (i = 1 ? "" : "+") . p

    return result
}

ResetSingleHotkey(action)
{
    global DefaultKeys, CurrentKeys, RebindButtons, ActionLabels

    DisableAllHotkeys()

    CurrentKeys[action] := DefaultKeys[action]
    if RebindButtons.Has(action)
        RebindButtons[action].Text := ActionButtonText(action, CurrentKeys[action])

    EnableAllHotkeys()
    SaveConfig()
    StatusText.Text := "Status: " ActionLabels[action] " hotkey reset to default."
}

ResetHotkeyInterval(action)
{
    global DefaultIntervals, IntervalSettings, IntervalEdits, Settings
    global Instances, ActionLabels

    if !IntervalSettings.Has(action)
        return

    interval := DefaultIntervals[action]
    Settings[IntervalSettings[action]] := interval
    IntervalEdits[action].Value := String(interval)

    for inst in Instances
    {
        if action = "AutoClick"
            inst.clickInterval := interval

        if IsHotkeysActionEnabled(inst, action)
        {
            StopAction(inst, action)
            StartAction(inst, action)
        }
    }

    SaveConfig()
    StatusText.Text := "Status: " ActionLabels[action] " interval reset to default."
}

MainAlwaysOnTopChanged(ctrl, *)
{
    global Settings, MainGui
    Settings["MainAlwaysOnTop"] := ctrl.Value = 1
    ApplyGuiAlwaysOnTop(MainGui, Settings["MainAlwaysOnTop"])
    SaveConfig()
}

ShowOverlayChanged(ctrl, *)
{
    global Settings
    Settings["ShowOverlay"] := ctrl.Value = 1
    UpdateAllTitleOverlays()
    SaveConfig()
}

HotkeysAlwaysOnTopChanged(ctrl, *)
{
    global Settings, HotkeysGui
    Settings["HotkeysAlwaysOnTop"] := ctrl.Value = 1
    ApplyGuiAlwaysOnTop(HotkeysGui, Settings["HotkeysAlwaysOnTop"])
    SaveConfig()
}

SandboxieAlwaysOnTopChanged(ctrl, *)
{
    global Settings, SBGui
    Settings["SandboxieAlwaysOnTop"] := ctrl.Value = 1
    ApplyGuiAlwaysOnTop(SBGui, Settings["SandboxieAlwaysOnTop"])
    SaveConfig()
}

LayoutEditorAlwaysOnTopChanged(ctrl, *)
{
    global Settings, LayoutEditorGui
    Settings["LayoutEditorAlwaysOnTop"] := ctrl.Value = 1
    ApplyGuiAlwaysOnTop(LayoutEditorGui, Settings["LayoutEditorAlwaysOnTop"])
    SaveConfig()
}

ApplyGuiAlwaysOnTop(guiObj, enabled)
{
    if !IsObject(guiObj)
        return
    try WinSetAlwaysOnTop(enabled ? 1 : 0, "ahk_id " guiObj.Hwnd)
}

LoadConfig()
{
    global CONFIG_FILE, ActionNames, DefaultKeys, CurrentKeys, Settings
    global SandboxieRowCount, SandboxieAccounts, MaxSandboxieRows, Layouts
    global LayoutEditorSelectedLayout

    legacySwapKey := IniRead(CONFIG_FILE, "Hotkeys", "Swap", "")
    switchSlotKey := IniRead(CONFIG_FILE, "Hotkeys", "SwitchSlot", "")
    if switchSlotKey = "" && legacySwapKey != ""
        switchSlotKey := legacySwapKey
    if switchSlotKey = ""
        switchSlotKey := DefaultKeys["SwitchSlot"]
    CurrentKeys["SwitchSlot"] := switchSlotKey
    CurrentKeys["Swap"] := DefaultKeys["Swap"]

    if IniRead(CONFIG_FILE, "Hotkeys", "SwitchSlot", "") != "" && legacySwapKey != ""
        CurrentKeys["Swap"] := legacySwapKey
    for action in ActionNames
    {
        if action = "SwitchSlot" || action = "Swap"
            continue
        CurrentKeys[action] := IniRead(CONFIG_FILE, "Hotkeys", action, DefaultKeys[action])
    }

    Settings["ClickInterval"] := Max(10, Integer(IniRead(CONFIG_FILE, "Settings", "ClickInterval", "50")))
    Settings["WalkInterval"] := Max(10, Integer(IniRead(CONFIG_FILE, "Settings", "WalkInterval", "50")))
    Settings["ReverseInterval"] := Max(10, Integer(IniRead(CONFIG_FILE, "Settings", "ReverseInterval", "50")))
    Settings["LeftHoldInterval"] := Max(5, Integer(IniRead(CONFIG_FILE, "Settings", "LeftHoldInterval", "50")))
    Settings["RightHoldInterval"] := Max(20, Integer(IniRead(CONFIG_FILE, "Settings", "RightHoldInterval", "50")))
    Settings["VSpamInterval"] := Max(10, Integer(IniRead(CONFIG_FILE, "Settings", "VSpamInterval", "50")))
    Settings["DefaultClickX"] := Integer(IniRead(CONFIG_FILE, "Settings", "DefaultClickX", "0"))
    Settings["DefaultClickY"] := Integer(IniRead(CONFIG_FILE, "Settings", "DefaultClickY", "0"))
    Settings["MainAlwaysOnTop"] := IniRead(CONFIG_FILE, "Settings", "MainAlwaysOnTop", "0") = "1"
    Settings["ShowOverlay"] := IniRead(CONFIG_FILE, "Settings", "ShowOverlay", "1") = "1"
    Settings["HotkeysAlwaysOnTop"] := IniRead(CONFIG_FILE, "Settings", "HotkeysAlwaysOnTop", "0") = "1"
    Settings["SandboxieAlwaysOnTop"] := IniRead(CONFIG_FILE, "Settings", "SandboxieAlwaysOnTop", "0") = "1"
    Settings["LayoutEditorAlwaysOnTop"] := IniRead(CONFIG_FILE, "Settings", "LayoutEditorAlwaysOnTop", "0") = "1"
    Settings["LastLayoutName"] := Trim(IniRead(CONFIG_FILE, "Settings", "LastLayoutName", ""))
    Settings["BannerSelection"] := Trim(IniRead(CONFIG_FILE, "Settings", "BannerSelection", "Random"))
    if Settings["BannerSelection"] = ""
        Settings["BannerSelection"] := "Random"
    Settings["SandboxieSandManExe"] := IniRead(CONFIG_FILE, "SandboxiePaths", "SandManExe", Settings["SandboxieSandManExe"])
    Settings["SandboxieSteamExe"] := IniRead(CONFIG_FILE, "SandboxiePaths", "SteamExe", Settings["SandboxieSteamExe"])
    Settings["SandboxieFoxholeExe"] := IniRead(CONFIG_FILE, "SandboxiePaths", "FoxholeExe", "")

    Layouts := []
    layoutCount := Max(0, Integer(IniRead(CONFIG_FILE, "Layouts", "Count", "0")))
    Loop layoutCount
    {
        section := "Layout" A_Index
        layoutName := IniRead(CONFIG_FILE, section, "Name", "")
        if layoutName = ""
            continue
        slotCount := Max(0, Integer(IniRead(CONFIG_FILE, section, "SlotCount", "0")))
        slots := []
        Loop slotCount
        {
            slotNo := A_Index
            monitorNo := Integer(IniRead(CONFIG_FILE, section, "Slot" slotNo "_Monitor", String(MonitorGetPrimary())))
            monitorWidth := Integer(IniRead(CONFIG_FILE, section, "Slot" slotNo "_MonitorWidth", "0"))
            monitorHeight := Integer(IniRead(CONFIG_FILE, section, "Slot" slotNo "_MonitorHeight", "0"))
            slot := {
                slot: slotNo,
                monitor: monitorNo,
                monitorWidth: monitorWidth,
                monitorHeight: monitorHeight,
                x: Integer(IniRead(CONFIG_FILE, section, "Slot" slotNo "_X", "0")),
                y: Integer(IniRead(CONFIG_FILE, section, "Slot" slotNo "_Y", "0")),
                width: Max(100, Integer(IniRead(CONFIG_FILE, section, "Slot" slotNo "_W", "960"))),
                height: Max(100, Integer(IniRead(CONFIG_FILE, section, "Slot" slotNo "_H", "540")))
            }
            if slot.monitorWidth <= 0 || slot.monitorHeight <= 0
            {
                bounds := GetLayoutMonitorBounds(slot)
                slot.monitorWidth := bounds.width
                slot.monitorHeight := bounds.height
            }
            ClampLayoutSlotToAssignedMonitor(slot)
            slots.Push(slot)
        }
        Layouts.Push({name: layoutName, slots: slots})
    }

    LayoutEditorSelectedLayout := 0
    if Settings["LastLayoutName"] != ""
    {
        for index, layout in Layouts
        {
            if StrLower(layout.name) = StrLower(Settings["LastLayoutName"])
            {
                LayoutEditorSelectedLayout := index
                Settings["LastLayoutName"] := layout.name
                break
            }
        }

        if LayoutEditorSelectedLayout = 0
        {
            Settings["LastLayoutName"] := ""
            IniWrite("", CONFIG_FILE, "Settings", "LastLayoutName")
        }
    }

    SandboxieRowCount := Integer(IniRead(CONFIG_FILE, "Sandboxie", "RowCount", "1"))
    SandboxieRowCount := Min(Max(1, SandboxieRowCount), MaxSandboxieRows)
    SandboxieAccounts := []

    mainAlreadyLoaded := false
    for index in Range(1, SandboxieRowCount)
    {
        missingValue := "__SANDBOXIE_ACCOUNT_MISSING__"
        accountName := IniRead(CONFIG_FILE, "Sandboxie", "Account" index "Name", missingValue)
        selectedValue := IniRead(CONFIG_FILE, "Sandboxie", "Account" index "Selected", missingValue)
        mainValue := IniRead(CONFIG_FILE, "Sandboxie", "Account" index "Main", "0")
        steamUsername := IniRead(CONFIG_FILE, "Sandboxie", "Account" index "SteamUsername", missingValue)
        legacySteamPath := IniRead(CONFIG_FILE, "Sandboxie", "Account" index "SteamPath", missingValue)
        legacyFoxholePath := IniRead(CONFIG_FILE, "Sandboxie", "Account" index "FoxholePath", missingValue)

        if accountName = missingValue
            accountName := ""

        if StrLower(Trim(accountName)) = StrLower("Account " index)
            accountName := ""
        if selectedValue = missingValue
            selectedValue := "0"
        if steamUsername = missingValue
            steamUsername := ""

        selected := selectedValue = "1"
        isMain := mainValue = "1" && !mainAlreadyLoaded
        if isMain
            mainAlreadyLoaded := true
        SandboxieAccounts.Push({ name: accountName, selected: selected, main: isMain, steamUsername: steamUsername })
    }
}

SaveLayoutsConfig()
{
    global CONFIG_FILE, Layouts, Settings

    oldLayoutCount := Max(0, Integer(IniRead(CONFIG_FILE, "Layouts", "Count", "0")))
    maxLayoutCount := Max(oldLayoutCount, Layouts.Length)

    Loop maxLayoutCount
    {
        section := "Layout" A_Index
        if A_Index > Layouts.Length
        {
            IniDelete(CONFIG_FILE, section)
            continue
        }

        layout := Layouts[A_Index]
        sectionText := "Name=" layout.name "`nSlotCount=" layout.slots.Length
        for _, slot in layout.slots
        {
            ClampLayoutSlotToAssignedMonitor(slot)
            prefix := "Slot" slot.slot "_"
            sectionText .= "`n" prefix "Monitor=" slot.monitor
            sectionText .= "`n" prefix "MonitorWidth=" slot.monitorWidth
            sectionText .= "`n" prefix "MonitorHeight=" slot.monitorHeight
            sectionText .= "`n" prefix "X=" slot.x
            sectionText .= "`n" prefix "Y=" slot.y
            sectionText .= "`n" prefix "W=" slot.width
            sectionText .= "`n" prefix "H=" slot.height
        }
        IniWrite(sectionText, CONFIG_FILE, section)
    }

    IniWrite(Layouts.Length, CONFIG_FILE, "Layouts", "Count")
    IniWrite(Settings["LastLayoutName"], CONFIG_FILE, "Settings", "LastLayoutName")
}

SaveConfig()
{
    global CONFIG_FILE, ActionNames, CurrentKeys, Settings
    global SandboxieRowCount, SandboxieAccounts, MaxSandboxieRows, Layouts
    for action in ActionNames
        IniWrite(CurrentKeys[action], CONFIG_FILE, "Hotkeys", action)

    IniWrite(Settings["ClickInterval"], CONFIG_FILE, "Settings", "ClickInterval")
    IniWrite(Settings["WalkInterval"], CONFIG_FILE, "Settings", "WalkInterval")
    IniWrite(Settings["ReverseInterval"], CONFIG_FILE, "Settings", "ReverseInterval")
    IniWrite(Settings["LeftHoldInterval"], CONFIG_FILE, "Settings", "LeftHoldInterval")
    IniWrite(Settings["RightHoldInterval"], CONFIG_FILE, "Settings", "RightHoldInterval")
    IniWrite(Settings["VSpamInterval"], CONFIG_FILE, "Settings", "VSpamInterval")
    IniWrite(Settings["DefaultClickX"], CONFIG_FILE, "Settings", "DefaultClickX")
    IniWrite(Settings["DefaultClickY"], CONFIG_FILE, "Settings", "DefaultClickY")

    IniDelete(CONFIG_FILE, "Settings", "AutoRename")
    IniWrite(Settings["MainAlwaysOnTop"] ? "1" : "0", CONFIG_FILE, "Settings", "MainAlwaysOnTop")
    IniWrite(Settings["ShowOverlay"] ? "1" : "0", CONFIG_FILE, "Settings", "ShowOverlay")
    IniWrite(Settings["HotkeysAlwaysOnTop"] ? "1" : "0", CONFIG_FILE, "Settings", "HotkeysAlwaysOnTop")
    IniWrite(Settings["SandboxieAlwaysOnTop"] ? "1" : "0", CONFIG_FILE, "Settings", "SandboxieAlwaysOnTop")
    IniWrite(Settings["LayoutEditorAlwaysOnTop"] ? "1" : "0", CONFIG_FILE, "Settings", "LayoutEditorAlwaysOnTop")
    IniWrite(Settings["LastLayoutName"], CONFIG_FILE, "Settings", "LastLayoutName")
    IniWrite(Settings["BannerSelection"], CONFIG_FILE, "Settings", "BannerSelection")
    IniWrite(Settings["SandboxieSandManExe"], CONFIG_FILE, "SandboxiePaths", "SandManExe")
    IniWrite(Settings["SandboxieSteamExe"], CONFIG_FILE, "SandboxiePaths", "SteamExe")
    IniWrite(Settings["SandboxieFoxholeExe"], CONFIG_FILE, "SandboxiePaths", "FoxholeExe")

    SaveLayoutsConfig()

    for index in Range(1, MaxSandboxieRows)
    {
        IniDelete(CONFIG_FILE, "Sandboxie", "Account" index "Name")
        IniDelete(CONFIG_FILE, "Sandboxie", "Account" index "Selected")
        IniDelete(CONFIG_FILE, "Sandboxie", "Account" index "Main")
        IniDelete(CONFIG_FILE, "Sandboxie", "Account" index "SteamUsername")
        IniDelete(CONFIG_FILE, "Sandboxie", "Account" index "SteamPath")
        IniDelete(CONFIG_FILE, "Sandboxie", "Account" index "FoxholePath")
    }

    IniWrite(SandboxieRowCount, CONFIG_FILE, "Sandboxie", "RowCount")
    for index, account in SandboxieAccounts
    {
        accountName := Trim(account.name)
        steamUsername := Trim(account.steamUsername)

        if accountName = "" && !account.selected && !account.main && steamUsername = ""
            continue

        if accountName != ""
            IniWrite(accountName, CONFIG_FILE, "Sandboxie", "Account" index "Name")
        if account.selected && accountName != ""
            IniWrite("1", CONFIG_FILE, "Sandboxie", "Account" index "Selected")
        if account.main && accountName != ""
            IniWrite("1", CONFIG_FILE, "Sandboxie", "Account" index "Main")
        if steamUsername != "" && accountName != ""
            IniWrite(steamUsername, CONFIG_FILE, "Sandboxie", "Account" index "SteamUsername")
    }
}

CleanupAll(*)
{
    global Instances
    global TitleOverlays, LayoutEditorOverlays

    for _, preview in LayoutEditorOverlays
        try preview.gui.Destroy()
    LayoutEditorOverlays := Map()

    SetTimer(EventDrivenFoxholeDiscovery, 0)
    SetTimer(InitialWindowDiscovery, 0)
    SetTimer(MaintainTitleOverlays, 0)
    SetTimer(MonitorSandboxieSupporterPopup, 0)
    SetTimer(RotateMainTip, 0)
    StopLayoutPositionWatcher()
    StopFoxholeWindowWatcher()
    CloseSwitchSlotAccountMenu()
    CloseWindowSwapMenu()
    for hwnd, overlay in TitleOverlays
    {
        try overlay.Destroy()
    }
    TitleOverlays := Map()
    for inst in Instances
    {
        try StopAllHotkeys(inst)
        catch
        {
        }
    }
}
