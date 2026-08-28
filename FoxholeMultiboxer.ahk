#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

;@Ahk2Exe-SetMainIcon Bin\FoxholeMultiBoxerIcon.ico

global APP_NAME := "Foxhole Multiboxer"
global APP_VERSION := "0.1"
global APP_TITLE := APP_NAME " v" APP_VERSION
global CONFIG_DIR := A_AppData "\" APP_NAME
global CONFIG_FILE := CONFIG_DIR "\Settings.ini"

global ActionNames := ["AutoClick", "AutoWalk", "AutoReverse", "ClickHold", "RightHold", "VSpam", "TrainSlow", "MouseFocus", "SwitchSlot", "Swap", "SwapFirst", "ShowFoxhole", "ShowSteam"]
global ActionLabels := Map(
    "AutoClick", "Auto-Click",
    "AutoWalk", "Forward / W",
    "AutoReverse", "Reverse / S",
    "ClickHold", "Left Click Hold",
    "RightHold", "Right Click Hold",
    "VSpam", "V Spam",
    "TrainSlow", "Train Slow",
    "MouseFocus", "Mouse Focus",
    "SwitchSlot", "Switch Slot",
    "Swap", "Swap",
    "SwapFirst", "Swap to First",
    "ShowFoxhole", "Show Foxhole",
    "ShowSteam", "Show Steam"
)
global DefaultKeys := Map(
    "AutoClick", "F2",
    "AutoWalk", "F3",
    "AutoReverse", "F4",
    "ClickHold", "F5",
    "RightHold", "F6",
    "VSpam", "F7",
    "TrainSlow", "F9",
    "MouseFocus", "",
    "SwitchSlot", "",
    "Swap", "",
    "SwapFirst", "",
    "ShowFoxhole", "",
    "ShowSteam", ""
)
global CurrentKeys := Map()
global OutputActionNames := ["AutoWalk", "AutoReverse", "VSpam", "TrainSlow"]
global DefaultOutputKeys := Map(
    "AutoWalk", "W",
    "AutoReverse", "S",
    "VSpam", "V",
    "TrainSlow", "W"
)
global CurrentOutputKeys := Map()
global OutputKeyButtons := Map()
global OutputCaptureHook := ""
global ChangeOutputKeysCheck := ""
global SwapByAccountCheck := ""
global AccountSwapKeys := Map()
global AccountSwapButtons := Map()
global AccountSwapTargetLabels := Map()
global HotkeysExpandedSections := Map("Game", false, "Manage", false, "Swap", false)

global Instances := []
global SelectedIndex := 0
global MouseFocusEnabled := false
global ShowFoxholeWindowsVisible := true
global ShowSteamWindowsVisible := true
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
global SwapWindowMenuEntrySlots := []
global SwapWindowMenuDismissTimer := false
global SwapWindowMenuNumberHotkeys := []
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
global LayoutTemporarySlotOverrides := Map()
global LayoutEditorEditingActive := false

global MainAlwaysOnTopCheck := ""
global ShowOverlayCheck := ""
global ShowTooltipsCheck := ""
global ShowUiTooltipsCheck := ""
global MouseFocusCheck := ""
global AutoResetSlotsCheck := ""
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
global MainResizePendingRows := 0
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
    'Use a saved workflow preset to reset or launch Sandboxes, Steam, and Foxhole in a safe order!',
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
global MainLaunchSteamFoxholeButton := ""
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
global CombinedLaunchActive := false
global CombinedLaunchAccounts := []
global CombinedSteamReadyPolls := Map()
global CombinedSteamLaunchStartedAt := 0
global CombinedSteamTimeoutMs := 120000
global CombinedSteamPaths := ""
global PendingFoxholeRenameActive := false
global PendingFoxholeRenameIndex := 0
global PendingFoxholeRenameBaseline := Map()
global PendingFoxholeRenameStartedAt := 0
global PendingFoxholeRenameTimeoutMs := 900000
global IntervalEdits := Map()
global IntervalSettings := Map(
    "AutoClick", "ClickInterval",
    "TrainSlow", "TrainSlowInterval"
)
global IntervalMinimums := Map(
    "AutoClick", 10,
    "TrainSlow", 10
)
global DefaultIntervals := Map(
    "AutoClick", 50,
    "TrainSlow", 300
)
global TrainSlowHoldDuration := 200
global LayoutEditorGui := ""
global LayoutEditorRowsGui := ""
global LayoutEditorSlots := []
global LayoutEditorValueCtrls := []
global LayoutEditorSlotControls := []
global LayoutEditorTooltipHwnds := []
global LayoutEditorRequiredHeight := 600
global LayoutEditorExpandedSlots := Map()
global LayoutEditorCombo := ""
global LayoutEditorFavoriteSlotCombo := ""
global LayoutEditorSelectedLayout := 0
global LayoutEditorOverlays := Map()
global LayoutEditorAlwaysOnTopCheck := ""
global Layouts := []
global LayoutFavorites := [0, 0, 0, 0]
global LayoutFavoriteButtons := []

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

global MainNavButtons := Map()
global MainPageControls := []
global CurrentMainPage := "Main"
global EmbeddedPageY := 235
global WorkflowPresets := []
global WorkflowFavorites := [0, 0, 0, 0, 0, 0, 0, 0]
global WorkflowPresetCombo := ""
global WorkflowFavoriteButtons := []
global WorkflowResetFoxholeCheck := ""
global WorkflowLaunchFoxholeCheck := ""
global WorkflowResetSteamCheck := ""
global WorkflowLaunchSteamCheck := ""
global WorkflowResetSandboxesCheck := ""
global WorkflowVerifySandboxesCheck := ""
global WorkflowLaunchSteamMinimizedCheck := ""
global WorkflowIncludedAccountNames := []
global WorkflowAccountPickerGui := ""
global WorkflowAccountPickerChecks := []
global WorkflowAccountSummary := ""
global WorkflowAccountSummaryHeight := 22
global WorkflowSequenceText := ""
global WorkflowRunButton := ""
global WorkflowStopButton := ""
global WorkflowFavoriteSlotCombo := ""
global WorkflowRunning := false
global WorkflowEditorExpanded := false
global WorkflowEditorHeader := ""
global WorkflowEditorControls := []
global WorkflowBelowEditorControls := []
global WorkflowEditorCollapseHeight := 0
global SettingsSectionExpanded := false
global SettingsSectionHeader := ""
global SettingsSectionControls := []
global WorkflowPendingFoxholeAfterSteam := false

global Settings := Map(
    "ClickInterval", 50,
    "TrainSlowInterval", 300,
    "DefaultClickX", 0,
    "DefaultClickY", 0,
    "MainAlwaysOnTop", false,
    "ShowOverlay", true,
    "ShowHotkeyTooltips", true,
    "ShowUiTooltips", true,
    "MouseFocusOn", true,
    "AutoResetSlots", false,
    "ChangeOutputKeys", false,
    "SwapByAccount", true,
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
SetMouseFocusEnabled(Settings["MouseFocusOn"], false)
ApplyAllHotkeys()
ScanWindows()
MaybeAutoResetSlots()

if LayoutEditorSelectedLayout >= 1 && LayoutEditorSelectedLayout <= Layouts.Length
    ApplySelectedLayout(false)
InitializeFoxholeWindowWatcher()
InitializeLayoutPositionWatcher()

OnMessage(0x84, LayoutPreviewHitTest, -1)
SetTimer(InitialWindowDiscovery, -1500)
SetTimer(RestoreMainGuiAfterStartup, -1900)
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
    if !IsObject(ctrl)
        return
    hwnd := 0
    try hwnd := ctrl.Hwnd
    if hwnd && GuiTooltips.Has(hwnd)
        GuiTooltips.Delete(hwnd)
}

RegisterLayoutEditorTooltip(ctrl, provider)
{
    global LayoutEditorTooltipHwnds
    RegisterTooltip(ctrl, provider)
    hwnd := 0
    try hwnd := ctrl.Hwnd
    if hwnd
        LayoutEditorTooltipHwnds.Push(hwnd)
    return ctrl
}

ClearLayoutEditorTooltips()
{
    global GuiTooltips, LayoutEditorTooltipHwnds, GuiLastTooltipHwnd
    for hwnd in LayoutEditorTooltipHwnds
    {
        if GuiTooltips.Has(hwnd)
            GuiTooltips.Delete(hwnd)
        if GuiLastTooltipHwnd = hwnd
        {
            ToolTip("", , , 20)
            GuiLastTooltipHwnd := 0
        }
    }
    LayoutEditorTooltipHwnds := []
}

MonitorGuiTooltips(*)
{
    global GuiTooltips, GuiLastTooltipHwnd, Settings

    if !Settings["ShowUiTooltips"]
    {
        if GuiLastTooltipHwnd
        {
            ToolTip("", , , 20)
            GuiLastTooltipHwnd := 0
        }
        return
    }

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
    if action = "Max"
    {
        if prop = "x"
            return (delta < 0 ? "Move Slot " slot.slot " fully left." : "Move Slot " slot.slot " fully right without crossing the monitor edge.") "`nCurrent " label ": " value
        if prop = "y"
            return (delta < 0 ? "Move Slot " slot.slot " fully up." : "Move Slot " slot.slot " fully down without crossing the monitor edge.") "`nCurrent " label ": " value
        return (delta < 0 ? "Reduce Slot " slot.slot " to the 50-pixel minimum " StrLower(label) "." : "Expand Slot " slot.slot " to the maximum " StrLower(label) " available from its current position.") "`nCurrent " label ": " value
    }
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
        "AutoClick", "Toggle repeated left-clicking in the controlled Foxhole window. Use Shift+Scroll to adjust this account’s interval; increasing past 500 ms pauses it.",
        "AutoWalk", "Toggle repeated W input in the controlled Foxhole window.",
        "AutoReverse", "Toggle repeated S input in the controlled Foxhole window.",
        "ClickHold", "Toggle holding the left mouse button in the controlled Foxhole window.",
        "RightHold", "Toggle holding the right mouse button in the controlled Foxhole window.",
        "VSpam", "Toggle repeated V input in the controlled Foxhole window.",
        "TrainSlow", "Periodically holds the configured Train Slow output key. Use Shift+Scroll to adjust this account’s interval.",
        "MouseFocus", "Toggle mouse-hover focus mode for controlled Foxhole windows.",
        "SwitchSlot", "Assign the focused Foxhole window to another numbered slot without moving it.",
        "Swap", "Swap positions and sizes with another Foxhole window without changing slot assignments.",
        "SwapFirst", "Swap the focused Foxhole window with the window currently occupying the first layout position.",
        "ShowFoxhole", "Toggle all open Foxhole game windows between minimized and maximized. The first press minimizes them.",
        "ShowSteam", "Toggle Steam windows for all Included accounts between closed-to-tray and restored. Steam windows are restored without being maximized."
    )
    text := "Current key: " DisplayNameForHotkeyString(CurrentKeys[action]) "`nClick to rebind.`n" descriptions[action]
    if IntervalSettings.Has(action)
        text .= "`nInterval is saved separately for each account. Use Shift+Scroll while this action is active."
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
        MaybeAutoResetSlots()
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

        FileInstall "Bin\FoxholeMultiBoxerIcon.ico", APP_ICON_PATH, 1
        FileInstall "Bin\Airborne.png", BannerAssetDir "\Airborne.png", 1
        FileInstall "Bin\Entrenched.png", BannerAssetDir "\Entrenched.png", 1
        FileInstall "Bin\Naval.png", BannerAssetDir "\Naval.png", 1
        FileInstall "Bin\Inferno.png", BannerAssetDir "\Inferno.png", 1
        FileInstall "Bin\TrenchWarfare.png", BannerAssetDir "\TrenchWarfare.png", 1
        FileInstall "Bin\WarMachine.png", BannerAssetDir "\WarMachine.png", 1
        FileInstall "Bin\WinterArmy.png", BannerAssetDir "\WinterArmy.png", 1
    }
    else
    {
        RuntimeAssetDir := A_ScriptDir "\Bin"
        BannerAssetDir := RuntimeAssetDir
        APP_ICON_PATH := RuntimeAssetDir "\FoxholeMultiBoxerIcon.ico"
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
    global MainGui, BannerPicture, BannerVisible, MainTipText, LV, MainDynamicControls, CurrentMainPage

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
    ReflowCurrentPageAfterBannerChange()
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
    global MainGui, LV, StatusText, MainTipText, MainTipIndex, MainTips, Settings
    global MainAlwaysOnTopCheck, ShowOverlayCheck, ShowTooltipsCheck, ShowUiTooltipsCheck, MouseFocusCheck, AutoResetSlotsCheck
    global MainDynamicControls, MainVisibleTableRows, AvailableBanners, BannerPicture, BannerDropDown
    global CurrentBannerFile, BannerVisible, MainNavButtons, MainPageControls
    global WorkflowFavoriteButtons, WorkflowPresetCombo, WorkflowFavoriteSlotCombo
    global LayoutFavoriteButtons
    global WorkflowResetFoxholeCheck, WorkflowLaunchFoxholeCheck, WorkflowResetSteamCheck, WorkflowLaunchSteamCheck
    global WorkflowResetSandboxesCheck, WorkflowVerifySandboxesCheck, WorkflowLaunchSteamMinimizedCheck, WorkflowAccountSummary, WorkflowSequenceText
    global WorkflowRunButton, WorkflowStopButton
    global WorkflowEditorExpanded, WorkflowEditorHeader, WorkflowEditorControls, WorkflowBelowEditorControls, WorkflowEditorCollapseHeight
    global SettingsSectionExpanded, SettingsSectionHeader, SettingsSectionControls

    MainGui := Gui("+Resize +0x02000000", APP_TITLE)
    MainGui.SetFont("s9", "Segoe UI")
    SetGuiIcon(MainGui)

    contentW := 535
    navY := 8
    navDefs := [["Main", 12, 80], ["Accounts", 96, 135], ["Hotkeys", 235, 90], ["Layouts", 329, 90]]
    MainNavButtons := Map()
    for def in navDefs
    {
        btn := MainGui.AddButton("x" def[2] " y" navY " w" def[3] " h28", def[1] = "Accounts" ? "Accounts && Sandboxes" : def[1])
        btn.OnEvent("Click", SwitchMainPage.Bind(def[1]))
        MainNavButtons[def[1]] := btn
    }
    settingsBtn := RegisterTooltip(MainGui.AddButton("x502 y8 w35 h28", "⚙"), "Open the multiboxer Settings.ini file in your default text editor.")
    settingsBtn.OnEvent("Click", OpenSettingsFile)

    bannerY := 44
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
    tipY := BannerVisible ? bannerY + bannerH + bannerGap : bannerY
    MainTipText := MainGui.AddText("x12 y" tipY " w" contentW " h40 +Wrap +Center +0x200", MainTips[MainTipIndex])
    SetTimer(RotateMainTip, 10000)

    tableY := tipY + 44
    LV := MainGui.AddListView("x12 y" tableY " w" contentW " h200 Grid -Multi", ["Slot", "Window Title", "HWND", "Status", "Hotkeys", "X", "Y", "W", "H"])
    for col, width in [55,140,68,52,53,36,36,36,36]
        LV.ModifyCol(col, width)
    LV.ModifyCol(1, "Logical Sort")
    LV.OnEvent("ItemSelect", OnListSelect)
    RegisterTooltip(LV, MainListTooltip)

    y := tableY + 208
    resetSlotsBtn := MainGui.AddButton("x12 y" y " w92 h28", "Reset Slots")
    resetSlotsBtn.OnEvent("Click", (*) => ResetInstanceSlots())
    RegisterTooltip(resetSlotsBtn, "Compact all active Foxhole windows into consecutive slots and refresh their War slot titles.")
    AutoResetSlotsCheck := MainGui.AddCheckBox("x114 y" (y + 2) " w120 h24", "Auto Reset?")
    AutoResetSlotsCheck.Value := Settings["AutoResetSlots"] ? 1 : 0
    AutoResetSlotsCheck.OnEvent("Click", AutoResetSlotsChanged)
    RegisterTooltip(AutoResetSlotsCheck, "Automatically compact and rename slots whenever Foxhole windows open or close.")
    StatusText := MainGui.AddText("x245 y" (y + 2) " w292 h24 +0x200", "Status: Starting...")
    y += 34
    MainGui.AddText("x12 y" y " w535 h22 +0x200", "LAYOUTS")
    y += 25
    LayoutFavoriteButtons := []
    Loop 4
    {
        x := 12 + (A_Index - 1) * 132
        btn := MainGui.AddButton("x" x " y" y " w126 h27", "")
        btn.Enabled := false
        btn.OnEvent("Click", ApplyLayoutFavorite.Bind(A_Index))
        RegisterTooltip(btn, "Immediately apply this favorite layout to the currently detected Foxhole windows.")
        LayoutFavoriteButtons.Push(btn)
    }
    y += 34

    MainGui.AddText("x12 y" y " w535 h22 +0x200", "WORKFLOWS")
    y += 25
    WorkflowFavoriteButtons := []
    Loop 8
    {
        row := Floor((A_Index - 1) / 4)
        column := Mod(A_Index - 1, 4)
        x := 12 + column * 132
        buttonY := y + row * 34
        btn := MainGui.AddButton("x" x " y" buttonY " w126 h27", "")
        btn.Enabled := false
        btn.OnEvent("Click", LoadWorkflowFavorite.Bind(A_Index))
        RegisterTooltip(btn, "Load and immediately run this favorite workflow preset.")
        WorkflowFavoriteButtons.Push(btn)
    }
    y += 68
    WorkflowEditorHeader := MainGui.AddButton("x12 y" y " w525 h28 +Left", (WorkflowEditorExpanded ? "▼  " : "▶  ") "EDIT WORKFLOWS")
    WorkflowEditorHeader.OnEvent("Click", ToggleWorkflowEditorSection)
    RegisterTooltip(WorkflowEditorHeader, "Expand or collapse the workflow preset editor. Workflow favorite buttons remain visible.")
    y += 32
    workflowEditorStartY := y
    MainGui.AddText("x12 y" (y+4) " w42 h22", "Preset:")
    WorkflowPresetCombo := MainGui.AddDropDownList("x56 y" y " w126 r10", [])
    WorkflowPresetCombo.OnEvent("Change", WorkflowPresetChanged)
    saveBtn := MainGui.AddButton("x187 y" y " w61 h24", "Save New")
    saveBtn.OnEvent("Click", SaveNewWorkflowPreset)
    updateBtn := MainGui.AddButton("x253 y" y " w55 h24", "Update")
    updateBtn.OnEvent("Click", UpdateWorkflowPreset)
    renameBtn := MainGui.AddButton("x313 y" y " w58 h24", "Rename")
    renameBtn.OnEvent("Click", RenameWorkflowPreset)
    deleteBtn := MainGui.AddButton("x376 y" y " w50 h24", "Delete")
    deleteBtn.OnEvent("Click", DeleteWorkflowPreset)
    WorkflowFavoriteSlotCombo := MainGui.AddDropDownList("x431 y" y " w106 r9", ["Not Favorite", "Favorite 1", "Favorite 2", "Favorite 3", "Favorite 4", "Favorite 5", "Favorite 6", "Favorite 7", "Favorite 8"])
    WorkflowFavoriteSlotCombo.OnEvent("Change", WorkflowFavoriteSlotChanged)

    y += 32
    WorkflowAccountSummary := MainGui.AddText("x12 y" (y+4) " w410 h22 +Wrap", "Accounts: none included")
    chooseBtn := MainGui.AddButton("x425 y" y " w112 h25", "Choose Accounts")
    chooseBtn.OnEvent("Click", ShowWorkflowAccountPicker)

    y += 34
    MainGui.AddText("x112 y" y " w58 h22 +Center", "Reset")
    MainGui.AddText("x174 y" y " w58 h22 +Center", "Launch")
    y += 24
    MainGui.AddText("x12 y" y " w92 h24", "Foxhole")
    WorkflowResetFoxholeCheck := MainGui.AddCheckBox("x132 y" y " w25 h24")
    WorkflowLaunchFoxholeCheck := MainGui.AddCheckBox("x194 y" y " w25 h24")
    y += 28
    MainGui.AddText("x12 y" y " w92 h24", "Steam")
    WorkflowResetSteamCheck := MainGui.AddCheckBox("x132 y" y " w25 h24")
    WorkflowLaunchSteamCheck := MainGui.AddCheckBox("x194 y" y " w25 h24")
    WorkflowLaunchSteamMinimizedCheck := MainGui.AddCheckBox("x252 y" y " w190 h24", "Launch Steam Minimized?")
    WorkflowLaunchSteamMinimizedCheck.Value := 1
    y += 28
    MainGui.AddText("x12 y" y " w92 h24", "Sandboxes")
    WorkflowResetSandboxesCheck := MainGui.AddCheckBox("x132 y" y " w25 h24")
    WorkflowVerifySandboxesCheck := MainGui.AddCheckBox("x194 y" y " w25 h24")
    for ctrl in [WorkflowResetFoxholeCheck, WorkflowLaunchFoxholeCheck, WorkflowResetSteamCheck, WorkflowLaunchSteamCheck, WorkflowResetSandboxesCheck, WorkflowVerifySandboxesCheck, WorkflowLaunchSteamMinimizedCheck]
        ctrl.OnEvent("Click", UpdateWorkflowSequencePreview)

    y += 32
    WorkflowSequenceText := MainGui.AddText("x12 y" y " w315 h30 +Wrap +0x200", "Next run: No operations selected.")
    WorkflowRunButton := MainGui.AddButton("x337 y" y " w110 h28 Default", "Run Workflow")
    WorkflowRunButton.OnEvent("Click", RunSelectedWorkflow)
    WorkflowStopButton := MainGui.AddButton("x457 y" y " w80 h28", "Stop")
    WorkflowStopButton.Enabled := false
    WorkflowStopButton.OnEvent("Click", StopWorkflow)

    y += 34
    workflowEditorEndY := y
    WorkflowEditorCollapseHeight := workflowEditorEndY - workflowEditorStartY

    SettingsSectionHeader := MainGui.AddButton("x12 y" y " w525 h28 +Left", (SettingsSectionExpanded ? "▼  " : "▶  ") "SETTINGS")
    SettingsSectionHeader.OnEvent("Click", ToggleSettingsSection)
    RegisterTooltip(SettingsSectionHeader, "Expand or collapse the main-page banner and behavior settings.")
    y += 32
    settingsSectionStartY := y
    BannerDropDown := ""
    if AvailableBanners.Length > 0
    {
        MainGui.AddText("x12 y" (y+4) " w48 h20 +Right", "Banner:")
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
        BannerDropDown := MainGui.AddDropDownList("x64 y" y " w125", bannerChoices)
        BannerDropDown.Choose(selectedChoice)
        BannerDropDown.OnEvent("Change", BannerSelectionChanged)
    }

    y += 30
    MainAlwaysOnTopCheck := MainGui.AddCheckBox("x12 y" y " w125 h24", "Always on top?")
    MainAlwaysOnTopCheck.Value := Settings["MainAlwaysOnTop"] ? 1 : 0
    MainAlwaysOnTopCheck.OnEvent("Click", MainAlwaysOnTopChanged)
    ShowOverlayCheck := MainGui.AddCheckBox("x145 y" y " w118 h24", "Show Overlay?")
    ShowOverlayCheck.Value := Settings["ShowOverlay"] ? 1 : 0
    ShowOverlayCheck.OnEvent("Click", ShowOverlayChanged)
    ShowTooltipsCheck := MainGui.AddCheckBox("x273 y" y " w115 h24", "Show Tooltips?")
    ShowTooltipsCheck.Value := Settings["ShowHotkeyTooltips"] ? 1 : 0
    ShowTooltipsCheck.OnEvent("Click", ShowHotkeyTooltipsChanged)
    ShowUiTooltipsCheck := MainGui.AddCheckBox("x398 y" y " w139 h24", "Show UI Tooltips?")
    ShowUiTooltipsCheck.Value := Settings["ShowUiTooltips"] ? 1 : 0
    ShowUiTooltipsCheck.OnEvent("Click", ShowUiTooltipsChanged)

    y += 26
    MouseFocusCheck := MainGui.AddCheckBox("x12 y" y " w160 h24", "Mouse Focus On?")
    MouseFocusCheck.Value := Settings["MouseFocusOn"] ? 1 : 0
    MouseFocusCheck.OnEvent("Click", MouseFocusSettingChanged)
    y += 30
    settingsSectionEndY := y

    WorkflowEditorControls := []
    WorkflowBelowEditorControls := []
    for ctrlHwnd, ctrl in MainGui
    {
        if !IsObject(ctrl) || !ctrl.Hwnd || ctrl.Hwnd = WorkflowEditorHeader.Hwnd
            continue
        try
        {
            ctrl.GetPos(&workflowCtrlX, &workflowCtrlY, &workflowCtrlW, &workflowCtrlH)
            if workflowCtrlY >= workflowEditorStartY && workflowCtrlY < workflowEditorEndY
                WorkflowEditorControls.Push(ctrl)
            else if workflowCtrlY >= workflowEditorEndY
                WorkflowBelowEditorControls.Push(ctrl)
        }
    }
    SettingsSectionControls := []
    for ctrlHwnd, ctrl in MainGui
    {
        if !IsObject(ctrl) || !ctrl.Hwnd || ctrl.Hwnd = SettingsSectionHeader.Hwnd
            continue
        try
        {
            ctrl.GetPos(&settingsCtrlX, &settingsCtrlY, &settingsCtrlW, &settingsCtrlH)
            if settingsCtrlY >= settingsSectionStartY && settingsCtrlY < settingsSectionEndY
                SettingsSectionControls.Push(ctrl)
        }
    }
    if !SettingsSectionExpanded
    {
        for ctrl in SettingsSectionControls
            ctrl.Visible := false
    }

    if !WorkflowEditorExpanded
    {
        for ctrl in WorkflowEditorControls
            ctrl.Visible := false
        for ctrl in WorkflowBelowEditorControls
        {
            ctrl.GetPos(&workflowCtrlX, &workflowCtrlY, &workflowCtrlW, &workflowCtrlH)
            ctrl.Move(, workflowCtrlY - WorkflowEditorCollapseHeight)
        }
    }

    MainPageControls := []
    MainDynamicControls := []
    for ctrlHwnd, ctrl in MainGui
    {
        isNavigation := false
        for navName, navButton in MainNavButtons
        {
            if ctrl.Hwnd = navButton.Hwnd
            {
                isNavigation := true
                break
            }
        }
        if isNavigation || ctrl.Hwnd = settingsBtn.Hwnd || (IsObject(BannerPicture) && ctrl.Hwnd = BannerPicture.Hwnd)
            continue

        MainPageControls.Push(ctrl)
        try
        {
            ctrl.GetPos(&ctrlX, &ctrlY, &ctrlW, &ctrlH)
            if ctrlY > tableY + 200
                MainDynamicControls.Push(ctrl)
        }
    }
    MainVisibleTableRows := 0

    MainGui.OnEvent("Close", (*) => ExitApp())
    MainGui.OnEvent("Escape", (*) => ExitApp())
    MainGui.OnEvent("Size", MainGuiResize)

    BuildHotkeysGui()
    BuildSBGui()
    BuildLayoutEditorGui()
    RefreshWorkflowPresetControls()
    RefreshLayoutFavoriteControls()
    UpdateWorkflowAccountSummary()
    UpdateWorkflowSequencePreview()
    MainGui.Show("w559 h" GetMainPageRequiredHeight())
    ApplyGuiAlwaysOnTop(MainGui, Settings["MainAlwaysOnTop"])
    SwitchMainPage("Main")
}

ToggleWorkflowEditorSection(*)
{
    global WorkflowEditorExpanded, WorkflowEditorHeader, WorkflowEditorControls
    global WorkflowBelowEditorControls, WorkflowEditorCollapseHeight, MainGui, CurrentMainPage

    if !IsObject(WorkflowEditorHeader) || !WorkflowEditorHeader.Hwnd
        return

    SetGuiRedraw(MainGui, false)
    WorkflowEditorExpanded := !WorkflowEditorExpanded
    direction := WorkflowEditorExpanded ? 1 : -1

    if WorkflowEditorExpanded
    {
        for ctrl in WorkflowBelowEditorControls
        {
            try
            {
                ctrl.GetPos(&x, &y, &w, &h)
                ctrl.Move(, y + WorkflowEditorCollapseHeight)
            }
        }
        for ctrl in WorkflowEditorControls
            try ctrl.Visible := CurrentMainPage = "Main"
    }
    else
    {
        for ctrl in WorkflowEditorControls
            try ctrl.Visible := false
        for ctrl in WorkflowBelowEditorControls
        {
            try
            {
                ctrl.GetPos(&x, &y, &w, &h)
                ctrl.Move(, y - WorkflowEditorCollapseHeight)
            }
        }
    }

    WorkflowEditorHeader.Text := (WorkflowEditorExpanded ? "▼  " : "▶  ") "EDIT WORKFLOWS"
    if CurrentMainPage = "Main"
        MainGui.Move(, , 559, GetMainPageRequiredHeight())
    SetGuiRedraw(MainGui, true)
    DllCall("RedrawWindow", "Ptr", MainGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0085)
}

ToggleSettingsSection(*)
{
    global SettingsSectionExpanded, SettingsSectionHeader, SettingsSectionControls
    global MainGui, CurrentMainPage

    if !IsObject(SettingsSectionHeader) || !SettingsSectionHeader.Hwnd
        return

    SetGuiRedraw(MainGui, false)
    SettingsSectionExpanded := !SettingsSectionExpanded
    for ctrl in SettingsSectionControls
        try ctrl.Visible := SettingsSectionExpanded && CurrentMainPage = "Main"

    SettingsSectionHeader.Text := (SettingsSectionExpanded ? "▼  " : "▶  ") "SETTINGS"
    if CurrentMainPage = "Main"
        MainGui.Move(, , 559, GetMainPageRequiredHeight())
    SetGuiRedraw(MainGui, true)
    DllCall("RedrawWindow", "Ptr", MainGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0085)
}

ResizeMainGuiForRows(rowCount := "")
{
    global LV, MainResizePendingRows, MainMaxVisibleTableRows

    if !IsObject(LV) || !LV.Hwnd
        return
    if rowCount = ""
        rowCount := LV.GetCount()

    MainResizePendingRows := Min(Max(Integer(rowCount), 1), MainMaxVisibleTableRows)
    SetTimer(ApplyPendingMainGuiResize, 0)
    SetTimer(ApplyPendingMainGuiResize, -75)
}

ApplyPendingMainGuiResize(*)
{
    global MainGui, LV, MainDynamicControls, MainVisibleTableRows, MainResizePendingRows

    if !IsObject(MainGui) || !MainGui.Hwnd || !IsObject(LV) || !LV.Hwnd
        return

    visibleRows := MainResizePendingRows
    if visibleRows < 1 || visibleRows = MainVisibleTableRows
        return

    LV.GetPos(&tableX, &tableY, &tableW, &oldTableH)
    newTableH := GetListViewHeightForRows(LV, visibleRows)
    deltaY := newTableH - oldTableH
    if Abs(deltaY) <= 1
    {
        MainVisibleTableRows := visibleRows
        return
    }

    SetGuiRedraw(MainGui, false)
    try
    {
        LV.Move(, , , newTableH)
        for ctrl in MainDynamicControls
        {
            if !IsObject(ctrl) || !ctrl.Hwnd
                continue
            ctrl.GetPos(&x, &y, &w, &h)
            ctrl.Move(, y + deltaY)
        }

        MainVisibleTableRows := visibleRows
        MainGui.Move(, , , GetMainPageRequiredHeight())
    }
    finally
    {
        SetGuiRedraw(MainGui, true)
        DllCall("RedrawWindow", "Ptr", MainGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0085)
    }
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
    SetTimer(MonitorFoxholeWindowPositions, 250)
    LayoutPositionWatcherActive := true
    return true
}

MonitorFoxholeWindowPositions(*)
{
    global LayoutPositionWatcherActive, LayoutPositionWatcherBusy
    global LayoutWindowPositions, LayoutSwapInProgress, LayoutTemporarySlotOverrides
    global Layouts, LayoutEditorSelectedLayout, LayoutEditorSlots, Instances

    if !LayoutPositionWatcherActive || LayoutPositionWatcherBusy || LayoutSwapInProgress
        return

    if LayoutEditorSelectedLayout < 1 || LayoutEditorSelectedLayout > Layouts.Length
        return

    desiredSlots := LayoutEditorSlots
    if desiredSlots.Length = 0
        return

    slotByNumber := Map()
    for slot in desiredSlots
        slotByNumber[slot.slot] := slot

    LayoutPositionWatcherBusy := true
    movedAny := false
    try
    {

        staleOverrides := []
        for hwnd, _ in LayoutTemporarySlotOverrides
            if !IsWindowAlive(hwnd)
                staleOverrides.Push(hwnd)
        for hwnd in staleOverrides
            LayoutTemporarySlotOverrides.Delete(hwnd)


        if HasDuplicateEffectiveLayoutSlots()
            LayoutTemporarySlotOverrides := Map()

        for _, inst in Instances
        {
            if !IsWindowAlive(inst.hwnd)
                continue

            desiredSlotNumber := LayoutTemporarySlotOverrides.Has(inst.hwnd)
                ? LayoutTemporarySlotOverrides[inst.hwnd]
                : inst.slot
            if !slotByNumber.Has(desiredSlotNumber)
                continue

            desired := GetLayoutSlotAbsoluteRect(slotByNumber[desiredSlotNumber])
            try WinGetPos(&x, &y, &w, &h, "ahk_id " inst.hwnd)
            catch
                continue

            if Abs(x - desired.x) <= 1
                && Abs(y - desired.y) <= 1
                && Abs(w - desired.width) <= 1
                && Abs(h - desired.height) <= 1
                continue

            try
            {
                WinMove(desired.x, desired.y, desired.width, desired.height, "ahk_id " inst.hwnd)
                inst.x := desired.x
                inst.y := desired.y
                inst.width := desired.width
                inst.height := desired.height
                movedAny := true
            }
        }

        LayoutWindowPositions := CaptureFoxholeWindowPositions()
        if movedAny
            RefreshList()
    }
    finally
    {
        LayoutPositionWatcherBusy := false
    }
}

ReapplyLayoutAfterWindowMove(*)
{

    MonitorFoxholeWindowPositions()
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

BuildLayoutEditorGui()
{
    global LayoutEditorGui, LayoutEditorCombo, LayoutEditorFavoriteSlotCombo, MainGui

    LayoutEditorGui := Gui("+Parent" MainGui.Hwnd " -Caption -Border", "Layout Editor")
    LayoutEditorGui.SetFont("s9", "Segoe UI")
    LayoutEditorGui.MarginX := 12
    LayoutEditorGui.MarginY := 10

    LayoutEditorGui.AddText("x12 y10 w55 h24", "Layout:")
    LayoutEditorCombo := LayoutEditorGui.AddComboBox("x68 y8 w364 h25 r10", [])
    LayoutEditorCombo.OnEvent("Change", LayoutEditorSelectionChanged)
    RegisterTooltip(LayoutEditorCombo, (*) => LayoutManagerTooltip("Combo"))

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
    LayoutEditorGui.AddText("x156 y70 w55 h20 +Right", "Favorite:")
    LayoutEditorFavoriteSlotCombo := LayoutEditorGui.AddDropDownList("x216 y66 w128 r5", ["Not Favorite", "Favorite 1", "Favorite 2", "Favorite 3", "Favorite 4"])
    LayoutEditorFavoriteSlotCombo.OnEvent("Change", LayoutFavoriteSlotChanged)
    RegisterTooltip(LayoutEditorFavoriteSlotCombo, "Assign the selected saved layout to one of the four favorite buttons on the Main page.")

    LayoutEditorGui.OnEvent("Close", CloseLayoutEditor)
    LayoutEditorGui.OnEvent("Escape", CloseLayoutEditor)
}

EnsureLastSelectedLayout()
{
    global LayoutEditorSelectedLayout, Layouts, Settings, CONFIG_FILE

    if LayoutEditorSelectedLayout >= 1 && LayoutEditorSelectedLayout <= Layouts.Length
        return true

    lastName := Trim(Settings["LastLayoutName"])
    if lastName != ""
    {
        for index, layout in Layouts
        {
            if StrLower(layout.name) = StrLower(lastName)
            {
                LayoutEditorSelectedLayout := index
                Settings["LastLayoutName"] := layout.name
                return true
            }
        }
    }

    if Layouts.Length
    {
        LayoutEditorSelectedLayout := 1
        Settings["LastLayoutName"] := Layouts[1].name
        IniWrite(Settings["LastLayoutName"], CONFIG_FILE, "Settings", "LastLayoutName")
        return true
    }

    LayoutEditorSelectedLayout := 0
    return false
}

RefreshLayoutEditorGui(*)
{
    global LayoutEditorGui, LayoutEditorSlots, LayoutEditorValueCtrls, LayoutEditorSlotControls
    global LayoutEditorCombo, LayoutEditorSelectedLayout, Layouts, Instances

    if !IsObject(LayoutEditorGui)
        BuildLayoutEditorGui()

    EnsureLastSelectedLayout()
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

    BuildCurrentLayoutEditorRows()
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

BuildLayoutEditorValueRow(label, prop, slotIndex, value, y, values, controls)
{
    global LayoutEditorGui

    buttonW := 34
    maxButtonW := 42
    gap := 2
    labelW := 12
    valueW := 54

    groupW := (buttonW * 8) + (maxButtonW * 2) + (gap * 11) + labelW + valueW
    x := Floor((510 - groupW) / 2)

    maxNegativeBtn := LayoutEditorGui.AddButton("x" x " y" y " w" maxButtonW " h24", "Max")
    maxNegativeBtn.OnEvent("Click", MakeLayoutMaxHandler(slotIndex, prop, -1))
    RegisterLayoutEditorTooltip(maxNegativeBtn, LayoutSlotTooltip.Bind(slotIndex, "Max", prop, -1))
    controls.Push(maxNegativeBtn)
    x += maxButtonW + gap

    for _, delta in [-100, -50, -10, -1]
    {
        btn := LayoutEditorGui.AddButton("x" x " y" y " w" buttonW " h24", String(delta))
        btn.OnEvent("Click", MakeLayoutAdjustHandler(slotIndex, prop, delta))
        RegisterLayoutEditorTooltip(btn, LayoutSlotTooltip.Bind(slotIndex, "Adjust", prop, delta))
        controls.Push(btn)
        x += buttonW + gap
    }

    labelCtrl := LayoutEditorGui.AddText("x" x " y" y " w" labelW " h24 +0x200 Center", label)
    controls.Push(labelCtrl)
    x += labelW + gap

    valueCtrl := LayoutEditorGui.AddEdit("x" x " y" y " w" valueW " h24 Center Number", String(value))
    valueCtrl.OnEvent("LoseFocus", MakeLayoutManualValueHandler(slotIndex, prop))
    controls.Push(valueCtrl)
    values[prop] := valueCtrl
    RegisterLayoutEditorTooltip(valueCtrl, LayoutSlotTooltip.Bind(slotIndex, "Value", prop))
    x += valueW + gap

    for _, delta in [1, 10, 50, 100]
    {
        btn := LayoutEditorGui.AddButton("x" x " y" y " w" buttonW " h24", "+" delta)
        btn.OnEvent("Click", MakeLayoutAdjustHandler(slotIndex, prop, delta))
        RegisterLayoutEditorTooltip(btn, LayoutSlotTooltip.Bind(slotIndex, "Adjust", prop, delta))
        controls.Push(btn)
        x += buttonW + gap
    }

    maxPositiveBtn := LayoutEditorGui.AddButton("x" x " y" y " w" maxButtonW " h24", "Max")
    maxPositiveBtn.OnEvent("Click", MakeLayoutMaxHandler(slotIndex, prop, 1))
    RegisterLayoutEditorTooltip(maxPositiveBtn, LayoutSlotTooltip.Bind(slotIndex, "Max", prop, 1))
    controls.Push(maxPositiveBtn)

    return y + 28
}

RefreshLayoutEditorLayoutList()
{
    global LayoutEditorCombo, LayoutEditorFavoriteSlotCombo, Layouts, LayoutEditorSelectedLayout, LayoutFavorites
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

    if IsObject(LayoutEditorFavoriteSlotCombo)
    {
        favoriteSlot := 0
        if LayoutEditorSelectedLayout >= 1
            Loop 4
                if LayoutFavorites[A_Index] = LayoutEditorSelectedLayout
                    favoriteSlot := A_Index
        LayoutEditorFavoriteSlotCombo.Value := favoriteSlot + 1
    }
    RefreshLayoutFavoriteControls()
}

RefreshLayoutFavoriteControls()
{
    global LayoutFavoriteButtons, LayoutFavorites, Layouts
    if !IsObject(LayoutFavoriteButtons) || LayoutFavoriteButtons.Length = 0
        return
    Loop 4
    {
        idx := LayoutFavorites[A_Index]
        btn := LayoutFavoriteButtons[A_Index]
        if idx >= 1 && idx <= Layouts.Length
        {
            btn.Text := Layouts[idx].name
            btn.Enabled := true
        }
        else
        {
            LayoutFavorites[A_Index] := 0
            btn.Text := ""
            btn.Enabled := false
        }
    }
}

LayoutFavoriteSlotChanged(ctrl, *)
{
    global LayoutEditorSelectedLayout, LayoutFavorites
    idx := LayoutEditorSelectedLayout
    if idx < 1
    {
        ctrl.Value := 1
        return
    }
    Loop 4
        if LayoutFavorites[A_Index] = idx
            LayoutFavorites[A_Index] := 0
    slot := ctrl.Value - 1
    if slot >= 1 && slot <= 4
        LayoutFavorites[slot] := idx
    SaveLayoutsConfig()
    RefreshLayoutFavoriteControls()
    ctrl.Value := slot + 1
}

ApplyLayoutFavorite(slot, *)
{
    global LayoutFavorites, Layouts, LayoutEditorSelectedLayout, LayoutEditorSlots, Settings, CONFIG_FILE
    global LayoutTemporarySlotOverrides
    idx := LayoutFavorites[slot]
    if idx < 1 || idx > Layouts.Length
        return
    LayoutTemporarySlotOverrides := Map()
    LayoutEditorSelectedLayout := idx
    Settings["LastLayoutName"] := Layouts[idx].name
    IniWrite(Settings["LastLayoutName"], CONFIG_FILE, "Settings", "LastLayoutName")
    LayoutEditorSlots := CloneLayoutSlots(Layouts[idx].slots)
    ApplySelectedLayout(false)
    RefreshLayoutEditorLayoutList()
}

LayoutEditorSelectionChanged(ctrl, *)
{
    global LayoutEditorSelectedLayout, Layouts, Settings, CONFIG_FILE
    global LayoutTemporarySlotOverrides

    value := ctrl.Value
    if value >= 1 && value <= Layouts.Length
    {
        LayoutTemporarySlotOverrides := Map()
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
    global LayoutEditorSlots, LayoutEditorExpandedSlots
    nextSlot := 1
    used := Map()
    for slot in LayoutEditorSlots
        used[slot.slot] := true
    while used.Has(nextSlot)
        nextSlot++

    LayoutEditorSlots.Push(CreateDefaultLayoutSlot(nextSlot))
    LayoutEditorExpandedSlots[nextSlot] := true
    RefreshLayoutEditorRowsOnly()
}

RemoveLayoutSlot(index)
{
    global LayoutEditorSlots, LayoutEditorExpandedSlots
    if index < 1 || index > LayoutEditorSlots.Length
        return
    slotNumber := LayoutEditorSlots[index].slot
    HideLayoutPreview(slotNumber)
    LayoutEditorSlots.RemoveAt(index)
    if LayoutEditorExpandedSlots.Has(slotNumber)
        LayoutEditorExpandedSlots.Delete(slotNumber)
    RefreshLayoutEditorRowsOnly()
}

RefreshLayoutEditorRowsOnly()
{
    global LayoutEditorGui, LayoutEditorSlots, LayoutEditorValueCtrls, LayoutEditorSlotControls

    SetGuiRedraw(LayoutEditorGui, false)
    DestroyLayoutEditorRows()
    LayoutEditorValueCtrls := []
    LayoutEditorSlotControls := []

    BuildCurrentLayoutEditorRows()
    SetGuiRedraw(LayoutEditorGui, true)
    ReflowCurrentPageAfterBannerChange()
}

BuildCurrentLayoutEditorRows()
{
    global LayoutEditorGui, LayoutEditorSlots, LayoutEditorValueCtrls
    global LayoutEditorSlotControls, LayoutEditorExpandedSlots, LayoutEditorRequiredHeight

    y := 100
    for slotIndex, slot in LayoutEditorSlots
    {
        expanded := LayoutEditorExpandedSlots.Has(slot.slot) ? LayoutEditorExpandedSlots[slot.slot] : false
        toggleText := (expanded ? "▼ " : "▶ ") "SLOT " slot.slot
        toggleBtn := LayoutEditorGui.AddButton("x12 y" y " w82 h24", toggleText)
        toggleBtn.OnEvent("Click", MakeLayoutExpandHandler(slotIndex))

        monitorLabel := LayoutEditorGui.AddText("x100 y" y " w50 h24 +0x200", "Monitor:")
        monitorCombo := LayoutEditorGui.AddComboBox("x151 y" y " w112 h24 r5", GetMonitorDisplayNames())
        monitorCombo.Value := ResolveLayoutMonitorNumber(slot)
        monitorCombo.OnEvent("Change", MakeLayoutMonitorHandler(slotIndex))
        aspectCheck := LayoutEditorGui.AddCheckBox("x269 y" y " w92 h24", "Keep Ratio")
        aspectCheck.Value := HasProp(slot, "keepAspect") && slot.keepAspect ? 1 : 0
        aspectCheck.OnEvent("Click", MakeLayoutAspectHandler(slotIndex))
        showBtn := LayoutEditorGui.AddButton("x363 y" y " w62 h24", "Preview")
        removeBtn := LayoutEditorGui.AddButton("x428 y" y " w58 h24", "Remove")
        matchBtn := LayoutEditorGui.AddButton("x489 y" y " w48 h24", "Match")
        showBtn.OnEvent("Click", MakeLayoutShowHandler(slotIndex))
        removeBtn.OnEvent("Click", MakeLayoutRemoveHandler(slotIndex))
        matchBtn.OnEvent("Click", MakeLayoutMatchBelowHandler(slotIndex))

        RegisterLayoutEditorTooltip(toggleBtn, LayoutSlotTooltip.Bind(slotIndex, "Header"))
        RegisterLayoutEditorTooltip(monitorCombo, LayoutSlotTooltip.Bind(slotIndex, "Monitor"))
        RegisterLayoutEditorTooltip(aspectCheck, "Keep this slot's current width-to-height ratio while resizing either dimension.")
        RegisterLayoutEditorTooltip(showBtn, LayoutSlotTooltip.Bind(slotIndex, "Show"))
        RegisterLayoutEditorTooltip(removeBtn, LayoutSlotTooltip.Bind(slotIndex, "Remove"))
        RegisterLayoutEditorTooltip(matchBtn, LayoutSlotTooltip.Bind(slotIndex, "Match"))

        controls := [toggleBtn, monitorLabel, monitorCombo, aspectCheck, showBtn, removeBtn, matchBtn]
        values := Map()
        y += 28

        if expanded
        {
            y := BuildLayoutEditorValueRow("X", "x", slotIndex, slot.x, y, values, controls)
            y := BuildLayoutEditorValueRow("Y", "y", slotIndex, slot.y, y, values, controls)
            y := BuildLayoutEditorValueRow("W", "width", slotIndex, slot.width, y, values, controls)
            y := BuildLayoutEditorValueRow("H", "height", slotIndex, slot.height, y, values, controls)
            y += 8
        }
        else
            y += 2

        LayoutEditorValueCtrls.Push(values)
        LayoutEditorSlotControls.Push(controls)
    }

    LayoutEditorRequiredHeight := Max(140, y + 42)
    LayoutEditorGui.Move(, , 559, LayoutEditorRequiredHeight)
}

MakeLayoutExpandHandler(index)
{
    return (*) => ToggleLayoutSlotExpanded(index)
}

ToggleLayoutSlotExpanded(index)
{
    global LayoutEditorSlots, LayoutEditorExpandedSlots
    if index < 1 || index > LayoutEditorSlots.Length
        return
    slotNumber := LayoutEditorSlots[index].slot
    current := LayoutEditorExpandedSlots.Has(slotNumber) ? LayoutEditorExpandedSlots[slotNumber] : false
    LayoutEditorExpandedSlots[slotNumber] := !current
    RefreshLayoutEditorRowsOnly()
}

DestroyLayoutEditorRows()
{
    global LayoutEditorSlotControls, LayoutEditorValueCtrls

    ClearLayoutEditorTooltips()
    for controls in LayoutEditorSlotControls
        for ctrl in controls
            try DllCall("DestroyWindow", "Ptr", ctrl.Hwnd)
    for values in LayoutEditorValueCtrls
        for _, ctrl in values
            try DllCall("DestroyWindow", "Ptr", ctrl.Hwnd)

    LayoutEditorSlotControls := []
    LayoutEditorValueCtrls := []
}

MakeLayoutManualValueHandler(index, prop)
{
    return (ctrl, *) => CommitLayoutManualValue(index, prop, ctrl)
}

CommitLayoutManualValue(index, prop, ctrl)
{
    global LayoutEditorSlots
    if index < 1 || index > LayoutEditorSlots.Length
        return
    raw := Trim(ctrl.Value)
    if !RegExMatch(raw, "^-?\d+$")
    {
        ctrl.Value := String(LayoutEditorSlots[index].%prop%)
        return
    }
    SetLayoutSlotValue(index, prop, Integer(raw))
}

MakeLayoutAspectHandler(index)
{
    return (ctrl, *) => SetLayoutAspectLock(index, ctrl.Value = 1)
}

SetLayoutAspectLock(index, enabled)
{
    global LayoutEditorSlots
    if index < 1 || index > LayoutEditorSlots.Length
        return
    slot := LayoutEditorSlots[index]
    slot.keepAspect := !!enabled
    slot.aspectRatio := slot.height > 0 ? slot.width / slot.height : 1.0
}

MakeLayoutMaxHandler(index, prop, direction)
{
    return (*) => MaximizeLayoutSlotValue(index, prop, direction)
}

MaximizeLayoutSlotValue(index, prop, direction)
{
    global LayoutEditorSlots, LayoutEditorValueCtrls, LayoutEditorOverlays
    if index < 1 || index > LayoutEditorSlots.Length
        return

    slot := LayoutEditorSlots[index]
    bounds := GetLayoutMonitorBounds(slot)

    if prop = "x"
        value := direction < 0 ? 0 : Max(0, bounds.width - slot.width)
    else if prop = "y"
        value := direction < 0 ? 0 : Max(0, bounds.height - slot.height)
    else if prop = "width"
        value := direction < 0 ? Min(50, Max(1, bounds.width - slot.x)) : Max(1, bounds.width - slot.x)
    else
        value := direction < 0 ? Min(50, Max(1, bounds.height - slot.y)) : Max(1, bounds.height - slot.y)

    SetLayoutSlotValue(index, prop, value)
}

MakeLayoutAdjustHandler(index, prop, delta)
{
    return (*) => AdjustLayoutSlot(index, prop, delta)
}

SetLayoutSlotValue(index, prop, value)
{
    global LayoutEditorSlots, LayoutEditorValueCtrls, LayoutEditorOverlays
    if index < 1 || index > LayoutEditorSlots.Length
        return

    slot := LayoutEditorSlots[index]
    if prop = "x" || prop = "y"
        slot.%prop% := ClampLayoutCoordinate(slot, prop, value)
    else
    {
        slot.%prop% := ClampLayoutSize(slot, prop, value)
        if HasProp(slot, "keepAspect") && slot.keepAspect
        {
            ratio := HasProp(slot, "aspectRatio") && slot.aspectRatio > 0 ? slot.aspectRatio : (slot.height > 0 ? slot.width / slot.height : 1.0)
            if prop = "width"
                slot.height := ClampLayoutSize(slot, "height", Round(slot.width / ratio))
            else if prop = "height"
                slot.width := ClampLayoutSize(slot, "width", Round(slot.height * ratio))
        }
    }

    ClampLayoutSlotToAssignedMonitor(slot)
    if LayoutEditorValueCtrls.Length >= index
    {
        ctrls := LayoutEditorValueCtrls[index]
        for _, field in ["x", "y", "width", "height"]
            if ctrls.Has(field)
                ctrls[field].Value := String(slot.%field%)
    }
    ApplyLayoutSlotToWindow(slot)
    if LayoutEditorOverlays.Has(slot.slot)
        UpdateLayoutPreview(index)
}

AdjustLayoutSlot(index, prop, delta)
{
    global LayoutEditorSlots
    if index < 1 || index > LayoutEditorSlots.Length
        return
    SetLayoutSlotValue(index, prop, LayoutEditorSlots[index].%prop% + delta)
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
        minWidth := Min(50, maxWidth)
        return Max(1, Min(Max(minWidth, value), maxWidth))
    }

    maxHeight := Max(1, bounds.height - slot.y)
    minHeight := Min(50, maxHeight)
    return Max(1, Min(Max(minHeight, value), maxHeight))
}

ClampLayoutSlotToAssignedMonitor(slot)
{
    bounds := GetLayoutMonitorBounds(slot)

    slot.x := Min(Max(slot.x, 0), Max(0, bounds.width - 1))
    slot.y := Min(Max(slot.y, 0), Max(0, bounds.height - 1))

    maxWidth := Max(1, bounds.width - slot.x)
    maxHeight := Max(1, bounds.height - slot.y)

    minWidth := Min(50, maxWidth)
    minHeight := Min(50, maxHeight)
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
        height: 540,
        keepAspect: false,
        aspectRatio: 960 / 540
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
        height: height,
        keepAspect: false,
        aspectRatio: height > 0 ? width / height : 1.0
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
                values[field].Value := String(slot.%field%)
    }

    ApplyLayoutSlotToWindow(slot)
    if LayoutEditorOverlays.Has(slot.slot)
        UpdateLayoutPreview(index)
}

ApplyLayoutSlotToWindow(slot, refreshListAfter := true)
{
    global Instances
    idx := FindLiveInstanceBySlot(slot.slot)
    if !idx
        return false
    inst := Instances[idx]
    if !IsWindowAlive(inst.hwnd)
        return false
    try
    {
        rect := GetLayoutSlotAbsoluteRect(slot)
        WinMove(rect.x, rect.y, rect.width, rect.height, "ahk_id " inst.hwnd)
        inst.x := rect.x
        inst.y := rect.y
        inst.width := rect.width
        inst.height := rect.height
        if refreshListAfter
            RefreshList()
        return true
    }
    catch
    {
        return false
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
        target.keepAspect := HasProp(source, "keepAspect") ? source.keepAspect : false
        target.aspectRatio := HasProp(source, "aspectRatio") ? source.aspectRatio : (source.height > 0 ? source.width / source.height : 1.0)
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
        try values["x"].Value := String(slot.x)
        try values["y"].Value := String(slot.y)
        try values["width"].Value := String(slot.width)
        try values["height"].Value := String(slot.height)
        if targetIndex <= LayoutEditorSlotControls.Length
        {
            controls := LayoutEditorSlotControls[targetIndex]
            if controls.Length >= 3
                try controls[3].Value := ResolveLayoutMonitorNumber(slot)
            if controls.Length >= 4
                try controls[4].Value := (HasProp(slot, "keepAspect") && slot.keepAspect) ? 1 : 0
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
            height: slot.height,
            keepAspect: HasProp(slot, "keepAspect") ? slot.keepAspect : false,
            aspectRatio: HasProp(slot, "aspectRatio") && slot.aspectRatio > 0 ? slot.aspectRatio : (slot.height > 0 ? slot.width / slot.height : 1.0)
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
    global Layouts, LayoutEditorSelectedLayout, Settings, LayoutFavorites
    if LayoutEditorSelectedLayout < 1 || LayoutEditorSelectedLayout > Layouts.Length
        return
    name := Layouts[LayoutEditorSelectedLayout].name
    If MsgBox("Delete layout " . Chr(34) . name . Chr(34) . "?", "Layout Editor", "YesNo Icon!") != "Yes"
        return
    deletedIndex := LayoutEditorSelectedLayout
    Layouts.RemoveAt(deletedIndex)
    Loop 4
    {
        if LayoutFavorites[A_Index] = deletedIndex
            LayoutFavorites[A_Index] := 0
        else if LayoutFavorites[A_Index] > deletedIndex
            LayoutFavorites[A_Index]--
    }
    LayoutEditorSelectedLayout := 0
    Settings["LastLayoutName"] := ""
    SaveLayoutsConfig()
    RefreshLayoutEditorGui()
}

ApplySelectedLayout(refreshEditor := true, resetTemporarySwaps := true, *)
{
    global Layouts, LayoutEditorSelectedLayout, LayoutEditorSlots, LayoutTemporarySlotOverrides
    if LayoutEditorSelectedLayout < 1 || LayoutEditorSelectedLayout > Layouts.Length
        return false

    if resetTemporarySwaps
        LayoutTemporarySlotOverrides := Map()
    LayoutEditorSlots := CloneLayoutSlots(Layouts[LayoutEditorSelectedLayout].slots)
    movedAny := false
    for slot in LayoutEditorSlots
        if ApplyLayoutSlotToWindow(slot, false)
            movedAny := true

    if movedAny
        RefreshList()

    if refreshEditor
        RefreshLayoutEditorGui()

    return true
}

CloseLayoutEditor(*)
{
    SwitchMainPage("Main")
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

MakeActionClickHandler(callback, action)
{
    handler(*)
    {
        callback.Call(action)
    }
    return handler
}

MakeActionControlHandler(callback, action)
{
    handler(ctrl, *)
    {
        callback.Call(action, ctrl)
    }
    return handler
}

MakeUnbindTooltipProvider(action)
{
    provider(*)
    {
        global ActionLabels
        return "Remove the " ActionLabels[action] " hotkey entirely. The setting is saved as an empty value until you rebind or reset it."
    }
    return provider
}

BuildHotkeysGui()
{
    global HotkeysGui, RebindButtons, CurrentKeys, IntervalEdits, Settings, MainGui
    global IntervalSettings, DefaultOutputKeys, CurrentOutputKeys, OutputKeyButtons, ChangeOutputKeysCheck
    global SandboxieAccounts, AccountSwapKeys, AccountSwapButtons, AccountSwapTargetLabels
    global SwapByAccountCheck, CurrentMainPage, HotkeysExpandedSections

    oldGui := HotkeysGui
    if IsObject(oldGui)
    {
        try oldGui.Destroy()
    }

    RebindButtons := Map()
    IntervalEdits := Map()
    OutputKeyButtons := Map()
    AccountSwapButtons := Map()
    AccountSwapTargetLabels := Map()

    HotkeysGui := Gui("+Parent" MainGui.Hwnd " -Caption +0x04000000", "Hotkeys")
    HotkeysGui.SetFont("s9", "Segoe UI")
    OnMessage(0x0200, HotkeysGuiMouseMove)

    HotkeysGui.AddText("x12 y10 w476 h22 +0x200", "HOTKEYS")
    y := 38

    y := BuildHotkeySection("Game", "GAME KEYS", ["AutoClick", "AutoWalk", "AutoReverse", "ClickHold", "RightHold", "VSpam", "TrainSlow"], y)
    y := BuildHotkeySection("Manage", "MANAGE GAMES", ["MouseFocus", "SwitchSlot", "Swap", "SwapFirst", "ShowFoxhole", "ShowSteam"], y)
    y := BuildAccountSwapSection(y)

    HotkeysGui.OnEvent("Close", (*) => SwitchMainPage("Main"))
    HotkeysGui.OnEvent("Escape", (*) => SwitchMainPage("Main"))
}

BuildHotkeySection(sectionKey, title, actions, y)
{
    global HotkeysGui, HotkeysExpandedSections, RebindButtons, CurrentKeys, IntervalEdits, Settings
    global IntervalSettings, DefaultOutputKeys, CurrentOutputKeys, OutputKeyButtons, ChangeOutputKeysCheck

    expanded := HotkeysExpandedSections.Has(sectionKey) && HotkeysExpandedSections[sectionKey]
    header := HotkeysGui.AddButton("x12 y" y " w476 h28 +Left", (expanded ? "▼  " : "▶  ") title)
    header.OnEvent("Click", MakeHotkeysSectionToggleHandler(sectionKey))
    RegisterTooltip(header, (expanded ? "Collapse " : "Expand ") title ".")
    y += 32

    if !expanded
        return y

    HotkeysGui.AddText("x12 y" y " w166 h18 +Center", "Hotkey / Current Binding")
    HotkeysGui.AddText("x184 y" y " w52 h18 +Center", "Default")
    HotkeysGui.AddText("x242 y" y " w58 h18 +Center", "Unbind")
    HotkeysGui.AddText("x306 y" y " w62 h18 +Center", "Output")
    HotkeysGui.AddText("x374 y" y " w114 h18 +Center", "Interval")
    y += 21

    for action in actions
    {
        RebindButtons[action] := HotkeysGui.AddButton("x12 y" y " w166 h28", ActionButtonText(action, CurrentKeys[action]))
        RebindButtons[action].OnEvent("Click", MakeHotkeysRebindHandler(action))
        RegisterTooltip(RebindButtons[action], HotkeyActionTooltip.Bind(action))

        resetBtn := HotkeysGui.AddButton("x184 y" y " w52 h28", "Reset")
        resetBtn.OnEvent("Click", MakeActionClickHandler(ResetSingleHotkey, action))
        RegisterTooltip(resetBtn, HotkeyResetTooltip.Bind(action))

        unbindBtn := HotkeysGui.AddButton("x242 y" y " w58 h28", "Unbind")
        unbindBtn.OnEvent("Click", MakeActionClickHandler(UnbindSingleHotkey, action))
        RegisterTooltip(unbindBtn, MakeUnbindTooltipProvider(action))

        if DefaultOutputKeys.Has(action)
        {
            outputBtn := HotkeysGui.AddButton("x306 y" y " w62 h28", DisplayNameForOutputKey(CurrentOutputKeys[action]))
            outputBtn.OnEvent("Click", MakeOutputKeyHandler(action))
            outputBtn.Visible := Settings["ChangeOutputKeys"]
            OutputKeyButtons[action] := outputBtn
            RegisterTooltip(outputBtn, "Choose the keyboard key this action sends to Foxhole. Useful for AZERTY and other keyboard layouts.")
        }
        else
            HotkeysGui.AddText("x306 y" (y + 5) " w62 h20 +Center", "—")

        if IntervalSettings.Has(action)
        {
            settingName := IntervalSettings[action]
            IntervalEdits[action] := HotkeysGui.AddEdit("x374 y" (y + 2) " w42 h24 Number", String(Settings[settingName]))
            IntervalEdits[action].OnEvent("LoseFocus", MakeActionControlHandler(SaveHotkeyInterval, action))
            RegisterTooltip(IntervalEdits[action], IntervalTooltip.Bind(action))
            HotkeysGui.AddText("x420 y" (y + 5) " w20 h20", "ms")
            resetIntervalBtn := HotkeysGui.AddButton("x442 y" y " w46 h28", "Reset")
            resetIntervalBtn.OnEvent("Click", MakeActionClickHandler(ResetHotkeyInterval, action))
            RegisterTooltip(resetIntervalBtn, IntervalTooltip.Bind(action, true))
        }
        else
            HotkeysGui.AddText("x374 y" (y + 5) " w114 h20 +Center", "—")

        y += 34
    }

    if sectionKey = "Game"
    {
        ChangeOutputKeysCheck := HotkeysGui.AddCheckBox("x12 y" y " w250 h24", "Change Output Keys? (AZERTY etc.)")
        ChangeOutputKeysCheck.Value := Settings["ChangeOutputKeys"] ? 1 : 0
        ChangeOutputKeysCheck.OnEvent("Click", ToggleChangeOutputKeys)
        RegisterTooltip(ChangeOutputKeysCheck, "Show or hide controls for changing the keys sent to Foxhole. This does not change the activation hotkeys.")
        y += 30
    }

    return y + 4
}

BuildAccountSwapSection(y)
{
    global HotkeysGui, HotkeysExpandedSections, SandboxieAccounts, AccountSwapKeys
    global AccountSwapButtons, AccountSwapTargetLabels, SwapByAccountCheck, Settings

    expanded := HotkeysExpandedSections.Has("Swap") && HotkeysExpandedSections["Swap"]
    header := HotkeysGui.AddButton("x12 y" y " w476 h28 +Left", (expanded ? "▼  " : "▶  ") "SWAP TO ACCOUNT")
    header.OnEvent("Click", MakeHotkeysSectionToggleHandler("Swap"))
    RegisterTooltip(header, (expanded ? "Collapse" : "Expand") " the generated Swap to N hotkeys.")
    y += 32

    if !expanded
        return y

    HotkeysGui.AddText("x12 y" y " w476 h18", "Generated from named rows on the Accounts page")
    y += 23
    HotkeysGui.AddText("x12 y" y " w226 h18 +Center", "Hotkey / Current Binding")
    HotkeysGui.AddText("x244 y" y " w56 h18 +Center", "Default")
    HotkeysGui.AddText("x306 y" y " w62 h18 +Center", "Unbind")
    HotkeysGui.AddText("x374 y" y " w114 h18 +Center", "Target")
    y += 21

    for accountIndex, account in SandboxieAccounts
    {
        accountName := Trim(account.name)
        if accountName = ""
            continue
        if !AccountSwapKeys.Has(accountIndex)
            AccountSwapKeys[accountIndex] := ""

        label := "Swap to " accountIndex
        btn := HotkeysGui.AddButton("x12 y" y " w226 h28", label " | " DisplayNameForHotkeyString(AccountSwapKeys[accountIndex]))
        btn.OnEvent("Click", MakeAccountSwapRebindHandler(accountIndex))
        AccountSwapButtons[accountIndex] := btn
        RegisterTooltip(btn, "Bind " label ". Account mode follows " accountName "; slot mode always activates slot " accountIndex ".")

        resetBtn := HotkeysGui.AddButton("x244 y" y " w56 h28", "Reset")
        resetBtn.OnEvent("Click", MakeAccountSwapActionHandler(ResetAccountSwapHotkey, accountIndex))
        RegisterTooltip(resetBtn, "Reset " label " to its default: Unbound.")

        unbindBtn := HotkeysGui.AddButton("x306 y" y " w62 h28", "Unbind")
        unbindBtn.OnEvent("Click", MakeAccountSwapActionHandler(UnbindAccountSwapHotkey, accountIndex))
        RegisterTooltip(unbindBtn, "Remove the current binding for " label ".")

        targetText := Settings["SwapByAccount"] ? accountName : "Slot " accountIndex
        targetCtrl := HotkeysGui.AddText("x374 y" (y + 5) " w114 h20 +Center", targetText)
        AccountSwapTargetLabels[accountIndex] := targetCtrl
        y += 34
    }

    SwapByAccountCheck := HotkeysGui.AddCheckBox("x12 y" y " w250 h24", "Swap by Account?")
    SwapByAccountCheck.Value := Settings["SwapByAccount"] ? 1 : 0
    SwapByAccountCheck.OnEvent("Click", SwapByAccountChanged)
    RegisterTooltip(SwapByAccountCheck, "On: Swap to N follows account row N wherever that account currently is. Off: Swap to N always activates Foxhole slot N.")
    return y + 34
}

MakeHotkeysSectionToggleHandler(sectionKey)
{
    return (*) => ToggleHotkeysSection(sectionKey)
}

ToggleHotkeysSection(sectionKey)
{
    global HotkeysExpandedSections, CurrentMainPage
    current := HotkeysExpandedSections.Has(sectionKey) ? HotkeysExpandedSections[sectionKey] : false
    HotkeysExpandedSections[sectionKey] := !current
    BuildHotkeysGui()
    if CurrentMainPage = "Hotkeys"
        SwitchMainPage("Hotkeys")
}

GetNamedAccountHotkeyCount()
{
    global SandboxieAccounts
    count := 0
    for account in SandboxieAccounts
        if Trim(account.name) != ""
            count++
    return count
}

GetHotkeysGuiRequiredHeight()
{
    global HotkeysExpandedSections
    height := 38
    height += 32
    if HotkeysExpandedSections.Has("Game") && HotkeysExpandedSections["Game"]
        height += 21 + (7 * 34) + 34
    height += 32
    if HotkeysExpandedSections.Has("Manage") && HotkeysExpandedSections["Manage"]
        height += 21 + (6 * 34) + 4
    height += 32
    if HotkeysExpandedSections.Has("Swap") && HotkeysExpandedSections["Swap"]
        height += 23 + 21 + (GetNamedAccountHotkeyCount() * 34) + 34
    return height + 8
}

RefreshAccountSwapHotkeysGui()
{
    global CurrentMainPage
    BuildHotkeysGui()
    if CurrentMainPage = "Hotkeys"
        SwitchMainPage("Hotkeys")
}

UpdateAccountSwapTargetLabels()
{
    global AccountSwapTargetLabels, SandboxieAccounts, Settings
    for accountIndex, ctrl in AccountSwapTargetLabels
    {
        accountName := accountIndex <= SandboxieAccounts.Length ? Trim(SandboxieAccounts[accountIndex].name) : ""
        ctrl.Text := Settings["SwapByAccount"] ? accountName : "Slot " accountIndex
    }
}

SwapByAccountChanged(ctrl, *)
{
    global Settings, StatusText
    Settings["SwapByAccount"] := ctrl.Value = 1
    UpdateAccountSwapTargetLabels()
    SaveConfig()
    StatusText.Text := "Status: Swap-to hotkeys now target " (Settings["SwapByAccount"] ? "accounts." : "fixed slot numbers.")
}

ToggleChangeOutputKeys(ctrl, *)
{
    global Settings, OutputKeyButtons
    Settings["ChangeOutputKeys"] := ctrl.Value = 1
    for action, button in OutputKeyButtons
        button.Visible := Settings["ChangeOutputKeys"]
    SaveConfig()
}

BuildSBGui()
{
    global SBGui, SandboxieRowCountEdit, SandboxieRowCount, MainGui
    global SandboxieSteamAllButton, SandboxieFoxholeAllButton

    SBGui := Gui("+Parent" MainGui.Hwnd " -Caption +0x04000000", "Accounts & Sandboxes")
    SBGui.SetFont("s9", "Segoe UI")
    SBGui.MarginX := 12
    SBGui.MarginY := 10

    SandboxieRowCountEdit := SBGui.AddEdit("x12 y8 w55 h24 Number", String(SandboxieRowCount))
    RegisterTooltip(SandboxieRowCountEdit, (*) => SandboxieSummaryTooltip("RowsEdit"))
    rowsBtn := RegisterTooltip(SBGui.AddButton("x72 y8 w55 h24", "Rows"), (*) => SandboxieSummaryTooltip("Rows"))
    rowsBtn.OnEvent("Click", ApplySandboxieRowCount)
    sbSettingsBtn := RegisterTooltip(SBGui.AddButton("x135 y8 w32 h24", "⚙"), "Configure the paths to SandMan.exe, Steam.exe, and the Foxhole executable.")
    sbSettingsBtn.OnEvent("Click", OpenSandboxieSettings)
    SBGui.AddText("x12 y46 w20 h20", "#")
    SBGui.AddText("x40 y46 w125 h20", "Account")
    SandboxieSteamAllButton := SBGui.AddButton("x173 y42 w70 h28", "Steam")
    SandboxieSteamAllButton.OnEvent("Click", StartSelectedSandboxieSteamLaunches)
    RegisterTooltip(SandboxieSteamAllButton, (*) => SandboxieSummaryTooltip("Steam"))
    credHeader := RegisterTooltip(SBGui.AddText("x251 y46 w42 h20 +0x200 Center", "Cred."), "Open, edit, or clear the Windows Credential Manager entry used to log this account into Steam.")
    SandboxieFoxholeAllButton := SBGui.AddButton("x299 y42 w70 h28", "Foxhole")
    SandboxieFoxholeAllButton.OnEvent("Click", StartSelectedFoxholeLaunches)
    RegisterTooltip(SandboxieFoxholeAllButton, (*) => SandboxieSummaryTooltip("Foxhole"))
    mainHeader := RegisterTooltip(SBGui.AddText("x377 y46 w55 h20", "Main"), "Exactly one account can be Main. It uses unsandboxed Steam and Foxhole and does not use Sandboxie credentials.")
    selectedHeader := RegisterTooltip(SBGui.AddText("x437 y46 w65 h20", "Included"), "Included accounts are used by bulk Steam, Foxhole, and Relaunch Steam actions.")

    SBGui.OnEvent("Close", CloseSBGui)
    SBGui.OnEvent("Escape", (*) => SwitchMainPage("Main"))

    RebuildSandboxieRows(SandboxieRowCount)
    StartSandboxieStatusWatcher()
}

CloseSBGui(*)
{
    SaveSandboxieVisibleRows()
    SaveConfig()
    SwitchMainPage("Main")
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
    RefreshAccountSwapHotkeysGui()
    SwitchMainPage("Accounts")
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

    rowY := 74
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

    height := rowY + 14
    if height < 150
        height := 150
    SBGui.Move(, , 535, height)
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
    RefreshAccountSwapHotkeysGui()
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

StartSelectedSandboxieSteamLaunches(accountIndices := "", minimizeSteam := true, *)
{
    global SandboxieAccounts, SandboxieSteamAllButton, StatusText, Settings

    if SandboxieSteamAllButton && !SandboxieSteamAllButton.Enabled
        return

    SaveSandboxieVisibleRows()
    selected := []
    if accountIndices is Array
    {
        for index in accountIndices
            selected.Push(index)
    }
    else
    {
        for index, account in SandboxieAccounts
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
                if minimizeSteam
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


SetCombinedLaunchButtonsEnabled(enabled)
{
    global MainLaunchSteamButton, MainRelaunchSteamButton, MainLaunchSteamFoxholeButton
    global MainLaunchFoxholeButton, SandboxieSteamAllButton, SandboxieFoxholeAllButton

    for ctrl in [MainLaunchSteamButton, MainRelaunchSteamButton, MainLaunchSteamFoxholeButton, MainLaunchFoxholeButton, SandboxieSteamAllButton, SandboxieFoxholeAllButton]
    {
        if IsObject(ctrl)
            ctrl.Enabled := enabled
    }
}

IsUnsandboxedProcessRunning(processName)
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
        query := "SELECT ProcessId FROM Win32_Process WHERE Name='" StrReplace(processName, "'", "''") "'"
        for process in wmi.ExecQuery(query)
        {
            pid := Integer(process.ProcessId)
            if pid > 0 && !sandboxedPids.Has(pid)
                return true
        }
    }
    catch
    {
        return false
    }
    return false
}

IsCombinedSteamAccountReady(item)
{
    global CombinedSteamPaths

    if item.main
        return IsUnsandboxedProcessRunning("steam.exe") && IsUnsandboxedProcessRunning("steamwebhelper.exe")

    running := GetSandboxieProcessNames(item.name)
    return IsObject(running) && running.Has("steam.exe") && running.Has("steamwebhelper.exe")
}

AbortCombinedSteamFoxholeLaunch(message, showPopup := true)
{
    global CombinedLaunchActive, CombinedLaunchAccounts, CombinedSteamReadyPolls, CombinedSteamPaths, StatusText, WorkflowRunning

    SetTimer(CheckCombinedSteamReadiness, 0)
    CombinedLaunchActive := false
    CombinedLaunchAccounts := []
    CombinedSteamReadyPolls := Map()
    CombinedSteamPaths := ""
    SetCombinedLaunchButtonsEnabled(true)
    StatusText.Text := "Status: " message
    if WorkflowRunning
        FinishWorkflow(message)
    if showPopup
        MsgBox(message, "Launch Steam & Foxhole", "Icon!")
}

StartCombinedSteamFoxholeLaunch(accountIndices := "", minimizeSteam := true, *)
{
    global SandboxieAccounts, SequentialLaunchActive, CombinedLaunchActive
    global CombinedLaunchAccounts, CombinedSteamReadyPolls, CombinedSteamLaunchStartedAt
    global CombinedSteamPaths, StatusText, Instances, Settings

    if CombinedLaunchActive || SequentialLaunchActive
        return

    SaveSandboxieVisibleRows()
    selected := []
    if accountIndices is Array
    {
        for index in accountIndices
            selected.Push(index)
    }
    else
    {
        for index, account in SandboxieAccounts
            if account.selected
                selected.Push(index)
    }

    if selected.Length = 0
    {
        StatusText.Text := "Status: No accounts selected."
        return
    }

    paths := TryRepairSteamLaunchPaths()
    problems := []
    needsSandboxie := false
    for index in selected
    {
        if !SandboxieAccounts[index].main
        {
            needsSandboxie := true
            break
        }
    }
    if !paths.steamOk
        problems.Push("Steam.exe could not be found.")
    if needsSandboxie && !paths.sandmanOk
        problems.Push("Sandboxie Plus SandMan.exe could not be found.")
    foxholeExe := Trim(Settings["SandboxieFoxholeExe"])
    if foxholeExe = "" || !FileExist(foxholeExe)
        problems.Push("The Foxhole executable could not be found.")

    launchItems := []
    accounts := []
    for index in selected
    {
        account := SandboxieAccounts[index]
        accountName := Trim(account.name)
        displayName := accountName != "" ? accountName : "Row " index

        if account.main
        {
            accounts.Push({ index: index, name: displayName, main: true })
            if paths.steamOk && !IsUnsandboxedSteamRunning()
                launchItems.Push({ index: index, name: displayName, main: true })
            continue
        }

        if !IsValidSandboxieName(accountName)
        {
            problems.Push(displayName ": invalid or blank account name.")
            continue
        }

        if paths.sandmanOk && !GetSandboxieBoxExists(accountName)
        {
            createResult := CreateSandboxieSandbox(accountName)
            if !createResult.ok
            {
                problems.Push(accountName ": sandbox creation failed — " createResult.message)
                continue
            }
        }

        accounts.Push({ index: index, name: accountName, main: false })
        if paths.steamOk && paths.sandmanOk && !IsSteamRunningInSandbox(accountName, paths.steamExe)
        {
            username := Trim(account.steamUsername)
            password := GetSteamCredentialPassword(accountName)
            if username = "" || password = ""
            {
                problems.Push(accountName ": Steam credentials are missing.")
                password := ""
                continue
            }
            password := ""
            launchItems.Push({ index: index, name: accountName, main: false })
        }
    }

    if problems.Length
    {
        text := "The combined launch cannot start until every selected account is ready:`n`n"
        for problem in problems
            text .= "• " problem "`n"
        AbortCombinedSteamFoxholeLaunch(RTrim(text, "`n"))
        return
    }

    CombinedLaunchActive := true
    CombinedLaunchAccounts := accounts
    CombinedSteamReadyPolls := Map()
    CombinedSteamPaths := paths
    CombinedSteamLaunchStartedAt := A_TickCount
    SetCombinedLaunchButtonsEnabled(false)

    failed := []
    for item in launchItems
    {
        account := SandboxieAccounts[item.index]
        try
        {
            if item.main
                Run(QuoteWindowsCommandLineArg(paths.steamExe))
            else
            {
                username := Trim(account.steamUsername)
                password := GetSteamCredentialPassword(item.name)
                command := QuoteWindowsCommandLineArg(paths.sandman) " /box:" item.name " " QuoteWindowsCommandLineArg(paths.steamExe) " -silent -nochatui -nofriendsui -login " QuoteWindowsCommandLineArg(username) " " QuoteWindowsCommandLineArg(password)
                Run(command)
                if minimizeSteam
                    BeginSandboxieSteamMinimizeWatch(item.name)
                password := ""
                command := ""
            }
        }
        catch as e
            failed.Push({ name: item.name, message: e.Message })
    }

    if failed.Length
    {
        AbortCombinedSteamFoxholeLaunch("Steam could not be launched for:`n" JoinSteamLaunchAccountNames(failed))
        return
    }

    StatusText.Text := "Status: Waiting for Steam to fully load — 0 of " accounts.Length " ready..."
    SetTimer(CheckCombinedSteamReadiness, 500)
    CheckCombinedSteamReadiness()
}

CheckCombinedSteamReadiness(*)
{
    global CombinedLaunchActive, CombinedLaunchAccounts, CombinedSteamReadyPolls
    global CombinedSteamLaunchStartedAt, CombinedSteamTimeoutMs, StatusText

    if !CombinedLaunchActive
    {
        SetTimer(CheckCombinedSteamReadiness, 0)
        return
    }

    if A_TickCount - CombinedSteamLaunchStartedAt > CombinedSteamTimeoutMs
    {
        notReady := []
        for item in CombinedLaunchAccounts
        {
            if !CombinedSteamReadyPolls.Has(item.index) || CombinedSteamReadyPolls[item.index] < 8
                notReady.Push({ name: item.name })
        }
        AbortCombinedSteamFoxholeLaunch("Steam did not fully load before the timeout for:`n" JoinSteamLaunchAccountNames(notReady))
        return
    }

    readyCount := 0
    for item in CombinedLaunchAccounts
    {
        polls := CombinedSteamReadyPolls.Has(item.index) ? CombinedSteamReadyPolls[item.index] : 0
        if IsCombinedSteamAccountReady(item)
            polls++
        else
            polls := 0
        CombinedSteamReadyPolls[item.index] := polls
        if polls >= 8
            readyCount++
    }

    StatusText.Text := "Status: Waiting for Steam to fully load — " readyCount " of " CombinedLaunchAccounts.Length " ready..."
    if readyCount < CombinedLaunchAccounts.Length
        return

    SetTimer(CheckCombinedSteamReadiness, 0)
    StatusText.Text := "Status: All selected Steam accounts are fully loaded. Starting Foxhole..."
    indices := []
    for item in CombinedLaunchAccounts
        indices.Push(item.index)
    if !StartFoxholeLaunchesForIndices(indices, true)
        AbortCombinedSteamFoxholeLaunch("Steam loaded, but the Foxhole launch sequence could not start.", false)
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

    ScanWindows(false)
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
    global SandboxieAccounts, StatusText

    SaveSandboxieVisibleRows()
    selected := []
    for index, account in SandboxieAccounts
    {
        if account.selected
            selected.Push(index)
    }
    StartFoxholeLaunchesForIndices(selected, false)
}

IsFoxholeAccountAlreadyOpen(accountIndex, account)
{
    global Instances
    accountName := Trim(account.name)
    for inst in Instances
    {
        if !IsWindowAlive(inst.hwnd)
            continue
        existingName := GetAccountNameForInstance(inst)
        if accountName != "" && existingName != "" && StrLower(existingName) = StrLower(accountName)
            return true
        if inst.slot = accountIndex
            return true
    }
    return false
}

StartFoxholeLaunchesForIndices(selected, fromCombined := false)
{
    global SandboxieAccounts, SequentialLaunchActive, SequentialLaunchQueue, Settings
    global SequentialLaunchPosition, SequentialLaunchExpectedSlot, SequentialLaunchSkipped
    global SandboxieFoxholeAllButton, MainLaunchSteamButton, MainLaunchSteamFoxholeButton, MainLaunchFoxholeButton
    global StatusText, Instances, CombinedLaunchActive, WorkflowRunning

    if SequentialLaunchActive
        return false

    SequentialLaunchQueue := []
    SequentialLaunchSkipped := 0
    alreadyOpen := 0
    ScanWindows()

    for index in selected
    {
        if index < 1 || index > SandboxieAccounts.Length
        {
            SequentialLaunchSkipped++
            continue
        }
        account := SandboxieAccounts[index]
        if IsFoxholeAccountAlreadyOpen(index, account)
        {
            alreadyOpen++
            continue
        }
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
        if alreadyOpen
        {
            StatusText.Text := "Status: All " alreadyOpen " selected Foxhole account(s) are already open."
            if WorkflowRunning
                FinishWorkflow("Workflow completed. All selected Foxhole accounts were already open.")
            return true
        }
        StatusText.Text := SequentialLaunchSkipped ? "Status: No selected Foxhole executables found. Skipped " SequentialLaunchSkipped " account(s)." : "Status: No accounts selected."
        return false
    }

    if fromCombined
        CombinedLaunchActive := true
    SequentialLaunchActive := true
    SequentialLaunchPosition := 1
    SequentialLaunchExpectedSlot := 1
    CleanupInvalidTitleOverlays()
    if IsObject(SandboxieFoxholeAllButton)
        SandboxieFoxholeAllButton.Enabled := false
    if IsObject(MainLaunchSteamButton)
        MainLaunchSteamButton.Enabled := false
    if IsObject(MainLaunchSteamFoxholeButton)
        MainLaunchSteamFoxholeButton.Enabled := false
    if IsObject(MainLaunchFoxholeButton)
        MainLaunchFoxholeButton.Enabled := false
    StatusText.Text := "Status: Starting " SequentialLaunchQueue.Length " selected Foxhole account(s)..."
    LaunchNextSelectedFoxhole()
    return true
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

    CreateTitleOverlay(inst, true)
    UpdateTitleOverlay(inst)
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
    global SequentialLaunchActive, SequentialLaunchQueue, SequentialLaunchSkipped, SandboxieFoxholeAllButton, MainLaunchSteamButton, MainLaunchSteamFoxholeButton, MainLaunchFoxholeButton, CombinedLaunchActive, StatusText, WorkflowRunning

    SetTimer(WaitForSequentialFoxholeWindow, 0)
    SequentialLaunchActive := false

    RebuildAllTitleOverlays()
    RefreshList()
    MaybeAutoResetSlots()

    if IsObject(SandboxieFoxholeAllButton)
        SandboxieFoxholeAllButton.Enabled := true
    if IsObject(MainLaunchSteamButton)
        MainLaunchSteamButton.Enabled := true
    if IsObject(MainLaunchSteamFoxholeButton)
        MainLaunchSteamFoxholeButton.Enabled := true
    if IsObject(MainLaunchFoxholeButton)
        MainLaunchFoxholeButton.Enabled := true
    CombinedLaunchActive := false
    if WorkflowRunning
        FinishWorkflow("Workflow completed. Finished launching Foxhole.")
    suffix := SequentialLaunchSkipped ? " Skipped " SequentialLaunchSkipped " selected account(s) without a valid executable." : ""
    StatusText.Text := "Status: Finished launching " SequentialLaunchQueue.Length " Foxhole account(s)." suffix
}

StopSequentialFoxholeLaunches(*)
{
    global SequentialLaunchActive, SandboxieFoxholeAllButton, MainLaunchSteamButton, MainLaunchSteamFoxholeButton, MainLaunchFoxholeButton, CombinedLaunchActive

    SetTimer(WaitForSequentialFoxholeWindow, 0)
    SequentialLaunchActive := false
    RebuildAllTitleOverlays()
    if IsObject(SandboxieFoxholeAllButton)
        SandboxieFoxholeAllButton.Enabled := true
    if IsObject(MainLaunchSteamButton)
        MainLaunchSteamButton.Enabled := true
    if IsObject(MainLaunchSteamFoxholeButton)
        MainLaunchSteamFoxholeButton.Enabled := true
    if IsObject(MainLaunchFoxholeButton)
        MainLaunchFoxholeButton.Enabled := true
    CombinedLaunchActive := false
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
    foregroundHwnd := WinExist("A")
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
            inst.clickInterval := LoadAccountInterval(slot, "AutoClick", Settings["ClickInterval"])
            inst.trainSlowInterval := LoadAccountInterval(slot, "TrainSlow", Settings["TrainSlowInterval"])
            inst.autoClickPaused := false
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
                clickInterval: LoadAccountInterval(slot, "AutoClick", Settings["ClickInterval"]),
                trainSlowInterval: LoadAccountInterval(slot, "TrainSlow", Settings["TrainSlowInterval"]),
                autoClickPaused: false,
                autoClick: false,
                autoWalk: false,
                autoReverse: false,
                clickHold: false,
                rightHold: false,
                vSpam: false,
                trainSlow: false,
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

    if !SequentialLaunchActive
        RefreshList()
    RestoreForegroundWindow(foregroundHwnd)
}

RestoreForegroundWindow(hwnd)
{
    if !hwnd || !WinExist("ahk_id " hwnd)
        return
    if WinExist("A") = hwnd
        return
    try DllCall("SetForegroundWindow", "Ptr", hwnd)
    if WinExist("A") != hwnd
        try WinActivate("ahk_id " hwnd)
}

RestoreMainGuiAfterStartup(*)
{
    global MainGui
    if !IsObject(MainGui) || !MainGui.Hwnd
        return
    MainGui.Show()
    try DllCall("SetForegroundWindow", "Ptr", MainGui.Hwnd)
    if WinExist("A") != MainGui.Hwnd
        try WinActivate("ahk_id " MainGui.Hwnd)
}

InitialWindowDiscovery(*)
{
    EnsureFoxholeInstances(6, 250)
    RestoreMainGuiAfterStartup()
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

EnsureUniqueInstanceSlots()
{
    global Instances, MaxPracticalInstances
    used := Map()
    changed := []
    for inst in Instances
    {
        if !IsWindowAlive(inst.hwnd)
            continue
        slot := Integer(inst.slot)
        if slot < 1 || slot > MaxPracticalInstances || used.Has(slot)
        {
            replacement := 1
            while replacement <= MaxPracticalInstances && used.Has(replacement)
                replacement++
            if replacement > MaxPracticalInstances
                continue
            inst.slot := replacement
            changed.Push(inst)
            slot := replacement
        }
        used[slot] := inst.hwnd
    }
    for inst in changed
        RenameInstance(inst)
}

RefreshList()
{
    EnsureUniqueInstanceSlots()
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


AutoResetSlotsChanged(ctrl, *)
{
    global Settings
    Settings["AutoResetSlots"] := ctrl.Value = 1
    SaveConfig()
    if Settings["AutoResetSlots"]
    {
        ScanWindows()
        MaybeAutoResetSlots(true)
    }
}

MaybeAutoResetSlots(force := false)
{
    global Settings, Instances, SequentialLaunchActive
    if !Settings["AutoResetSlots"] || SequentialLaunchActive
        return false

    live := []
    hasEmpty := false
    for inst in Instances
    {
        if IsWindowAlive(inst.hwnd)
            live.Push(inst)
        else
            hasEmpty := true
    }
    SortInstancesBySlot(live)

    needsReset := force || hasEmpty
    for index, inst in live
    {
        if inst.slot != index
        {
            needsReset := true
            break
        }
        expectedPrefix := "War " index
        try title := WinGetTitle("ahk_id " inst.hwnd)
        catch
        {
            title := ""
        }
        if !RegExMatch(title, "i)^" expectedPrefix "(?:\s+-|$)")
        {
            needsReset := true
            break
        }
    }

    if !needsReset
        return false
    ResetInstanceSlots(false)
    return true
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

ResetInstanceSlots(scanFirst := true, *)
{
    global Instances, SelectedIndex, StatusText

    if scanFirst
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
    global SwapWindowMenuTargetHwnd, SwapWindowMenuEntries, SwapWindowMenuEntrySlots, SwapWindowMenuDismissTimer
    global Instances

    CloseWindowSwapMenu()
    if !inst || !IsWindowAlive(inst.hwnd)
        return

    entries := []
    SwapWindowMenuEntries := []
    SwapWindowMenuEntrySlots := []
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
        SwapWindowMenuEntrySlots.Push(candidate.slot)
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
    EnableWindowSwapNumberHotkeys()
}

WindowSwapListChanged(ctrl, *)
{
    if ctrl.Value > 0
        SwapSelectedWindow(ctrl.Value)
}

WindowSwapMenuKeyDown(wParam, lParam, msg, hwnd)
{
    global SwapWindowMenuGui, SwapWindowMenuList, SwapWindowMenuEntries, SwapWindowMenuEntrySlots
    global SwapWindowMenuTargetHwnd
    if !IsObject(SwapWindowMenuGui) || !SwapWindowMenuGui.Hwnd || !IsObject(SwapWindowMenuList)
        return

    if wParam >= 0x31 && wParam <= 0x39
        requestedSlot := wParam - 0x30
    else if wParam >= 0x61 && wParam <= 0x69
        requestedSlot := wParam - 0x60
    else
        requestedSlot := 0

    if requestedSlot
    {
        SelectWindowSwapSlot(requestedSlot)
        return 0
    }

    if wParam = 0x1B
    {
        CloseWindowSwapMenu()
        return 0
    }
}


SelectWindowSwapSlot(requestedSlot)
{
    global SwapWindowMenuGui, SwapWindowMenuList, SwapWindowMenuEntries, SwapWindowMenuEntrySlots
    global SwapWindowMenuTargetHwnd

    if !IsObject(SwapWindowMenuGui) || !SwapWindowMenuGui.Hwnd
        return

    entry := 0
    for index, slotNumber in SwapWindowMenuEntrySlots
    {
        if slotNumber = requestedSlot
        {
            entry := index
            break
        }
    }

    if !entry
        return


    if SwapWindowMenuEntries[entry] = SwapWindowMenuTargetHwnd
    {
        CloseWindowSwapMenu()
        return
    }

    if IsObject(SwapWindowMenuList)
        SwapWindowMenuList.Value := entry
    SwapSelectedWindow(entry)
}

MakeWindowSwapNumberHandler(slotNumber, physicalKeyName)
{
    return (*) => HandleWindowSwapNumberHotkey(slotNumber, physicalKeyName)
}

HandleWindowSwapNumberHotkey(slotNumber, physicalKeyName)
{


    try KeyWait(physicalKeyName)
    SelectWindowSwapSlot(slotNumber)
}

EnableWindowSwapNumberHotkeys()
{
    global SwapWindowMenuNumberHotkeys

    DisableWindowSwapNumberHotkeys()
    SwapWindowMenuNumberHotkeys := []

    Loop 9
    {
        slotNumber := A_Index
        for physicalKeyName in [String(slotNumber), "Numpad" slotNumber]
        {
            hotkeyName := "*" physicalKeyName
            try
            {
                Hotkey(hotkeyName, MakeWindowSwapNumberHandler(slotNumber, physicalKeyName), "On")
                SwapWindowMenuNumberHotkeys.Push(hotkeyName)
            }
            catch
            {
            }
        }
    }
}

DisableWindowSwapNumberHotkeys()
{
    global SwapWindowMenuNumberHotkeys

    for keyName in SwapWindowMenuNumberHotkeys
        try Hotkey(keyName, "Off")
    SwapWindowMenuNumberHotkeys := []
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

GetEffectiveLayoutSlotForInstance(inst)
{
    global LayoutTemporarySlotOverrides
    return LayoutTemporarySlotOverrides.Has(inst.hwnd)
        ? LayoutTemporarySlotOverrides[inst.hwnd]
        : inst.slot
}

SetSlotInOverrideMap(overrideMap, hwnd, permanentSlot, desiredSlot)
{
    if desiredSlot = permanentSlot
    {
        if overrideMap.Has(hwnd)
            overrideMap.Delete(hwnd)
    }
    else
        overrideMap[hwnd] := desiredSlot
}

CloneTemporaryLayoutOverrides()
{
    global LayoutTemporarySlotOverrides
    clone := Map()
    for hwnd, slotNumber in LayoutTemporarySlotOverrides
        if IsWindowAlive(hwnd)
            clone[hwnd] := slotNumber
    return clone
}

OverrideMapHasDuplicateEffectiveSlots(overrideMap)
{
    global Instances
    occupied := Map()
    for _, inst in Instances
    {
        if !IsWindowAlive(inst.hwnd)
            continue
        slotNumber := overrideMap.Has(inst.hwnd) ? overrideMap[inst.hwnd] : inst.slot
        if occupied.Has(slotNumber)
            return true
        occupied[slotNumber] := inst.hwnd
    }
    return false
}

HasDuplicateEffectiveLayoutSlots()
{
    global Instances
    occupied := Map()
    for _, inst in Instances
    {
        if !IsWindowAlive(inst.hwnd)
            continue
        slot := GetEffectiveLayoutSlotForInstance(inst)
        if occupied.Has(slot)
            return true
        occupied[slot] := inst.hwnd
    }
    return false
}

SwapFoxholeWindowRectangles(sourceHwnd, targetHwnd)
{
    global Instances, LayoutWindowPositions
    global LayoutSwapInProgress, LayoutReapplyPending, LayoutTemporarySlotOverrides

    if !IsWindowAlive(sourceHwnd) || !IsWindowAlive(targetHwnd)
        return false

    sourceIdx := FindInstanceByHwnd(sourceHwnd)
    targetIdx := FindInstanceByHwnd(targetHwnd)
    if !sourceIdx || !targetIdx
        return false

    if HasDuplicateEffectiveLayoutSlots()
        LayoutTemporarySlotOverrides := Map()

    sourceSlot := GetEffectiveLayoutSlotForInstance(Instances[sourceIdx])
    targetSlot := GetEffectiveLayoutSlotForInstance(Instances[targetIdx])
    if sourceSlot = targetSlot
        return false

    replacementOverrides := CloneTemporaryLayoutOverrides()
    SetSlotInOverrideMap(replacementOverrides, sourceHwnd, Instances[sourceIdx].slot, targetSlot)
    SetSlotInOverrideMap(replacementOverrides, targetHwnd, Instances[targetIdx].slot, sourceSlot)
    if OverrideMapHasDuplicateEffectiveSlots(replacementOverrides)
        return false

    try
    {
        WinGetPos(&sourceX, &sourceY, &sourceW, &sourceH, "ahk_id " sourceHwnd)
        WinGetPos(&targetX, &targetY, &targetW, &targetH, "ahk_id " targetHwnd)
    }
    catch
    {
        return false
    }

    oldOverrides := CloneTemporaryLayoutOverrides()
    LayoutSwapInProgress := true
    SetTimer(ReapplyLayoutAfterWindowMove, 0)
    LayoutReapplyPending := false
    movedSource := false
    movedTarget := false
    success := false

    try
    {
        WinMove(targetX, targetY, targetW, targetH, "ahk_id " sourceHwnd)
        movedSource := true
        WinMove(sourceX, sourceY, sourceW, sourceH, "ahk_id " targetHwnd)
        movedTarget := true


        LayoutTemporarySlotOverrides := replacementOverrides

        Instances[sourceIdx].x := targetX
        Instances[sourceIdx].y := targetY
        Instances[sourceIdx].width := targetW
        Instances[sourceIdx].height := targetH
        Instances[targetIdx].x := sourceX
        Instances[targetIdx].y := sourceY
        Instances[targetIdx].width := sourceW
        Instances[targetIdx].height := sourceH
        success := true
    }
    catch
    {

        if movedSource && IsWindowAlive(sourceHwnd)
            try WinMove(sourceX, sourceY, sourceW, sourceH, "ahk_id " sourceHwnd)
        if movedTarget && IsWindowAlive(targetHwnd)
            try WinMove(targetX, targetY, targetW, targetH, "ahk_id " targetHwnd)
        LayoutTemporarySlotOverrides := oldOverrides
        success := false
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
    global SwapWindowMenuTargetHwnd, SwapWindowMenuEntries, SwapWindowMenuEntrySlots, SwapWindowMenuDismissTimer
    wasOpen := IsObject(SwapWindowMenuGui) && SwapWindowMenuHwnd
    SetTimer(CheckWindowSwapMenuDismissal, 0)
    SwapWindowMenuDismissTimer := false
    OnMessage(0x0100, WindowSwapMenuKeyDown, 0)
    DisableWindowSwapNumberHotkeys()
    SwapWindowMenuList := ""
    SwapWindowMenuHwnd := 0
    SwapWindowMenuTargetHwnd := 0
    SwapWindowMenuEntries := []
    SwapWindowMenuEntrySlots := []
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


}

SwapFocusedWindowToFirstLayoutSpot(sourceInst)
{
    global Instances, LayoutWindowPositions
    global LayoutSwapInProgress, LayoutReapplyPending, LayoutTemporarySlotOverrides

    if !IsObject(sourceInst) || !IsWindowAlive(sourceInst.hwnd)
        return false

    if HasDuplicateEffectiveLayoutSlots()
        LayoutTemporarySlotOverrides := Map()

    liveInstances := []
    positionRects := Map()
    positionNumbers := []

    for _, candidate in Instances
    {
        if !IsWindowAlive(candidate.hwnd)
            continue

        effectiveSlot := GetEffectiveLayoutSlotForInstance(candidate)
        try WinGetPos(&x, &y, &w, &h, "ahk_id " candidate.hwnd)
        catch
            continue

        liveInstances.Push(candidate)
        positionRects[effectiveSlot] := {x: x, y: y, width: w, height: h}
        positionNumbers.Push(effectiveSlot)
    }

    if !positionRects.Has(1)
    {
        ShowHotkeyTooltip("No Foxhole window occupies layout position 1.")
        return false
    }

    if liveInstances.Length < 1 || liveInstances.Length != positionNumbers.Length
        return false


    Loop positionNumbers.Length - 1
    {
        i := A_Index + 1
        current := positionNumbers[i]
        j := i - 1
        while j >= 1 && positionNumbers[j] > current
        {
            positionNumbers[j + 1] := positionNumbers[j]
            j -= 1
        }
        positionNumbers[j + 1] := current
    }


    SortInstancesBySlot(liveInstances)
    orderedInstances := [sourceInst]
    for _, candidate in liveInstances
    {
        if candidate.hwnd != sourceInst.hwnd
            orderedInstances.Push(candidate)
    }

    LayoutSwapInProgress := true
    SetTimer(ReapplyLayoutAfterWindowMove, 0)
    LayoutReapplyPending := false
    success := false

    oldOverrides := CloneTemporaryLayoutOverrides()
    movedAssignments := []
    try
    {


        replacementOverrides := Map()
        assignments := []
        for index, candidate in orderedInstances
        {
            desiredSlot := positionNumbers[index]
            if !positionRects.Has(desiredSlot)
                throw Error("Missing layout position " desiredSlot ".")
            SetSlotInOverrideMap(replacementOverrides, candidate.hwnd, candidate.slot, desiredSlot)
            assignments.Push({inst: candidate, desiredSlot: desiredSlot, rect: positionRects[desiredSlot]})
        }

        if OverrideMapHasDuplicateEffectiveSlots(replacementOverrides)
            throw Error("Swap to First produced duplicate layout destinations.")


        for assignment in assignments
        {
            candidate := assignment.inst
            rect := assignment.rect
            WinMove(rect.x, rect.y, rect.width, rect.height, "ahk_id " candidate.hwnd)
            movedAssignments.Push(assignment)
        }
        LayoutTemporarySlotOverrides := replacementOverrides

        for assignment in assignments
        {
            candidate := assignment.inst
            rect := assignment.rect
            candidate.x := rect.x
            candidate.y := rect.y
            candidate.width := rect.width
            candidate.height := rect.height
        }
        success := true
    }
    catch
    {


        for assignment in movedAssignments
        {
            candidate := assignment.inst
            originalSlot := GetEffectiveLayoutSlotForInstance(candidate)
            if positionRects.Has(originalSlot) && IsWindowAlive(candidate.hwnd)
            {
                originalRect := positionRects[originalSlot]
                try WinMove(originalRect.x, originalRect.y, originalRect.width, originalRect.height, "ahk_id " candidate.hwnd)
            }
        }
        LayoutTemporarySlotOverrides := oldOverrides
        success := false
    }
    finally
    {
        LayoutWindowPositions := CaptureFoxholeWindowPositions()
        LayoutSwapInProgress := false
        LayoutReapplyPending := false
    }

    if success
    {
        RefreshList()
        ShowHotkeyTooltip("Moved to layout position 1 and reordered the other windows.")
        if IsWindowAlive(sourceInst.hwnd)
            ForceForegroundWindow(sourceInst.hwnd)
    }
    return success
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

CreateTitleOverlay(inst, forceCreate := false)
{
    global TitleOverlays, Settings
    global SequentialLaunchActive, SequentialLaunchBaseline

    if !Settings["ShowOverlay"]
        return
    if !IsValidTitleOverlayTarget(inst.hwnd)
        return
    if SequentialLaunchActive && !forceCreate && !SequentialLaunchBaseline.Has(inst.hwnd)
        return
    if TitleOverlays.Has(inst.hwnd)
    {
        if ValidateTitleOverlayOwnership(inst.hwnd, TitleOverlays[inst.hwnd])
            return
        RemoveTitleOverlay(inst.hwnd)
    }

    targetPid := 0
    try targetPid := WinGetPID("ahk_id " inst.hwnd)
    if !targetPid
        return

    overlay := Gui("-Caption +ToolWindow +AlwaysOnTop +E0x20", "")
    overlay.BackColor := "000000"
    overlay.SetFont("s10 bold", "Segoe UI")
    text := overlay.AddText("x6 y3 w180 h24 cFFFFFF +0x200", "")

    overlay.Show("Hide w200 h30")
    try WinSetTransColor("000000 0", "ahk_id " . overlay.Hwnd)
    try WinSetTransparent(200, "ahk_id " . overlay.Hwnd)

    TitleOverlays[inst.hwnd] := {
        gui: overlay,
        text: text,
        targetHwnd: inst.hwnd,
        targetPid: targetPid,
        overlayHwnd: overlay.Hwnd
    }
}

IsValidTitleOverlayTarget(hwnd)
{
    if !hwnd || !WinExist("ahk_id " hwnd)
        return false
    try
        return StrLower(WinGetProcessName("ahk_id " hwnd)) = "war-win64-shipping.exe"
    catch
        return false
}

ValidateTitleOverlayOwnership(hwnd, overlayRecord)
{
    if !IsObject(overlayRecord)
        return false
    if !overlayRecord.HasOwnProp("gui") || !IsObject(overlayRecord.gui)
        return false
    if !overlayRecord.HasOwnProp("targetHwnd") || overlayRecord.targetHwnd != hwnd
        return false
    if !overlayRecord.HasOwnProp("targetPid") || !overlayRecord.targetPid
        return false
    if !overlayRecord.HasOwnProp("overlayHwnd") || !overlayRecord.overlayHwnd
        return false
    if !IsValidTitleOverlayTarget(hwnd) || !WinExist("ahk_id " overlayRecord.overlayHwnd)
        return false
    try
        return WinGetPID("ahk_id " hwnd) = overlayRecord.targetPid
    catch
        return false
}

CleanupInvalidTitleOverlays()
{
    global TitleOverlays
    stale := []
    for hwnd, overlayRecord in TitleOverlays
    {
        if !ValidateTitleOverlayOwnership(hwnd, overlayRecord)
            stale.Push(hwnd)
    }
    for hwnd in stale
        RemoveTitleOverlay(hwnd)
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

    if !IsValidTitleOverlayTarget(inst.hwnd)
    {
        RemoveTitleOverlay(inst.hwnd)
        return
    }

    if TitleOverlays.Has(inst.hwnd) && !ValidateTitleOverlayOwnership(inst.hwnd, TitleOverlays[inst.hwnd])
        RemoveTitleOverlay(inst.hwnd)

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

    CleanupInvalidTitleOverlays()

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
        if IsValidTitleOverlayTarget(inst.hwnd)
        {
            live[inst.hwnd] := true
            UpdateTitleOverlay(inst)
        }
    }

    stale := []
    for hwnd, _ in TitleOverlays
    {
        if !live.Has(hwnd)
            stale.Push(hwnd)
    }
    for hwnd in stale
        RemoveTitleOverlay(hwnd)
}

RebuildAllTitleOverlays()
{
    global Instances, TitleOverlays, Settings

    ScanWindows()
    for hwnd, overlay in TitleOverlays
    {
        try overlay.gui.Destroy()
    }
    TitleOverlays := Map()

    if !Settings["ShowOverlay"]
        return

    for inst in Instances
    {
        if !IsValidTitleOverlayTarget(inst.hwnd)
            continue
        CreateTitleOverlay(inst, true)
        UpdateTitleOverlay(inst)
    }
}

MaintainTitleOverlays(*)
{
    global SequentialLaunchActive
    if SequentialLaunchActive
        return
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
            if inst.trainSlow
                StopAction(inst, "TrainSlow")
            inst.autoWalk := !inst.autoWalk
            if inst.autoWalk
                StartAction(inst, "AutoWalk")
            else
                StopAction(inst, "AutoWalk")

        case "AutoReverse":
            if inst.autoWalk
                StopAction(inst, "AutoWalk")
            if inst.trainSlow
                StopAction(inst, "TrainSlow")
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

        case "TrainSlow":
            if inst.autoWalk
                StopAction(inst, "AutoWalk")
            if inst.autoReverse
                StopAction(inst, "AutoReverse")
            inst.trainSlow := !inst.trainSlow
            if inst.trainSlow
                StartAction(inst, "TrainSlow")
            else
                StopAction(inst, "TrainSlow")
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
            SetInstanceTimer(inst, "AutoWalk", (*) => SendBackgroundW(inst), 50)
            SendBackgroundW(inst)

        case "AutoReverse":
            SetInstanceTimer(inst, "AutoReverse", (*) => SendBackgroundS(inst), 50)
            SendBackgroundS(inst)

        case "ClickHold":
            SendBackgroundHold(inst)

        case "RightHold":
            SendBackgroundRightHold(inst)

        case "VSpam":
            SendBackgroundV(inst)
            SetInstanceTimer(inst, "VSpam", (*) => SendBackgroundV(inst), 50)

        case "TrainSlow":
            SendBackgroundTrainSlow(inst)
            SetInstanceTimer(inst, "TrainSlow", (*) => SendBackgroundTrainSlow(inst), inst.trainSlowInterval)
    }
}

StopAction(inst, action)
{
    global CurrentOutputKeys
    RemoveInstanceTimer(inst, action)

    alive := IsWindowAlive(inst.hwnd)

    switch action
    {
        case "AutoClick":
            inst.autoClick := false
            inst.autoClickPaused := false
            if alive
                PostMouseUp(inst.hwnd, inst.clickX, inst.clickY)

        case "AutoWalk":
            inst.autoWalk := false
            if alive
                PostBackgroundKeyUpForInstance(inst, CurrentOutputKeys["AutoWalk"])

        case "AutoReverse":
            inst.autoReverse := false
            if alive
                PostBackgroundKeyUpForInstance(inst, CurrentOutputKeys["AutoReverse"])

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
                PostBackgroundKeyUpForInstance(inst, CurrentOutputKeys["VSpam"])

        case "TrainSlow":
            inst.trainSlow := false
            if alive
                PostBackgroundKeyUpForInstance(inst, CurrentOutputKeys["TrainSlow"])
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
    for action in ["AutoClick", "AutoWalk", "AutoReverse", "ClickHold", "RightHold", "VSpam", "TrainSlow"]
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
    restoreLp := GetCurrentCursorClientLParam(inst.hwnd)
    target := "ahk_id " inst.hwnd
    PostMessage(0x0201, 0x0001, lp, , target)
    PostMessage(0x0202, 0, lp, , target)
    if restoreLp != ""
        PostMessage(0x0200, 0, restoreLp, , target)
}

GetCurrentCursorClientLParam(hwnd)
{
    point := Buffer(8, 0)
    if !DllCall("GetCursorPos", "Ptr", point.Ptr) || !DllCall("ScreenToClient", "Ptr", hwnd, "Ptr", point.Ptr)
        return ""
    x := NumGet(point, 0, "Int")
    y := NumGet(point, 4, "Int")
    rect := Buffer(16, 0)
    if DllCall("GetClientRect", "Ptr", hwnd, "Ptr", rect.Ptr)
    {
        w := NumGet(rect, 8, "Int")
        h := NumGet(rect, 12, "Int")
        if w > 0
            x := Max(0, Min(w - 1, x))
        if h > 0
            y := Max(0, Min(h - 1, y))
    }
    return MakeLParam(x, y)
}

PostBackgroundKeyDownForInstance(inst, keyName)
{
    if !IsWindowAlive(inst.hwnd) || !IsValidOutputKey(keyName)
        return false
    vk := GetKeyVK(keyName), sc := GetKeySC(keyName)
    for targetHwnd in GetHotkeysTargets(inst.hwnd)
        PostMessage(0x0100, vk, BuildKeyboardLParam(sc, false, IsExtendedOutputKey(keyName)), , "ahk_id " targetHwnd)
    return true
}

PostBackgroundKeyUpForInstance(inst, keyName)
{
    if !IsWindowAlive(inst.hwnd) || !IsValidOutputKey(keyName)
        return false
    vk := GetKeyVK(keyName), sc := GetKeySC(keyName)
    for targetHwnd in GetHotkeysTargets(inst.hwnd)
        PostMessage(0x0101, vk, BuildKeyboardLParam(sc, true, IsExtendedOutputKey(keyName)), , "ahk_id " targetHwnd)
    return true
}

SendBackgroundW(inst)
{
    global CurrentOutputKeys
    PostBackgroundKeyDownForInstance(inst, CurrentOutputKeys["AutoWalk"])
}

SendBackgroundS(inst)
{
    global CurrentOutputKeys
    PostBackgroundKeyDownForInstance(inst, CurrentOutputKeys["AutoReverse"])
}

SendBackgroundHold(inst)
{
    if !IsWindowAlive(inst.hwnd)
        return
    lp := MakeLParam(inst.clickX, inst.clickY)
    restoreLp := GetCurrentCursorClientLParam(inst.hwnd)
    target := "ahk_id " inst.hwnd
    PostMessage(0x0201, 0x0001, lp, , target)
    if restoreLp != ""
        PostMessage(0x0200, 0, restoreLp, , target)
}

SendBackgroundRightHold(inst)
{
    if IsWindowAlive(inst.hwnd)
        ControlClick(, "ahk_id " inst.hwnd, , "RIGHT", 1, "NA D{Blind}")
}

SendBackgroundV(inst)
{
    global CurrentOutputKeys
    keyName := CurrentOutputKeys["VSpam"]
    if PostBackgroundKeyDownForInstance(inst, keyName)
        PostBackgroundKeyUpForInstance(inst, keyName)
}

PostMouseUp(hwnd, x, y)
{
    lp := MakeLParam(x, y)
    restoreLp := GetCurrentCursorClientLParam(hwnd)
    target := "ahk_id " hwnd
    PostMessage(0x0202, 0, lp, , target)
    if restoreLp != ""
        PostMessage(0x0200, 0, restoreLp, , target)
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

SendBackgroundTrainSlow(inst)
{
    global CurrentOutputKeys, TrainSlowHoldDuration
    if !IsWindowAlive(inst.hwnd) || !inst.trainSlow
        return
    if PostBackgroundKeyDownForInstance(inst, CurrentOutputKeys["TrainSlow"])
    {
        release := (*) => PostBackgroundKeyUpForInstance(inst, CurrentOutputKeys["TrainSlow"])
        SetTimer(release, -TrainSlowHoldDuration)
    }
}

GetFocusedActionInstance(action)
{
    global Instances
    idx := GetActiveFoxholeInstanceIndex()
    if !idx
        return 0
    inst := Instances[idx]
    return IsHotkeysActionEnabled(inst, action) ? inst : 0
}

IsFocusedAutoClickActive()
{
    return IsObject(GetFocusedActionInstance("AutoClick"))
}

IsFocusedTrainSlowActive()
{
    return IsObject(GetFocusedActionInstance("TrainSlow"))
}

#HotIf IsFocusedTrainSlowActive()
+WheelUp::AdjustFocusedTrainSlowInterval(25)
+WheelDown::AdjustFocusedTrainSlowInterval(-25)
#HotIf

#HotIf IsFocusedAutoClickActive()
+WheelUp::AdjustFocusedAutoClickInterval(10)
+WheelDown::AdjustFocusedAutoClickInterval(-10)
#HotIf

AdjustFocusedAutoClickInterval(change)
{
    inst := GetFocusedActionInstance("AutoClick")
    if !IsObject(inst)
        return

    if inst.autoClickPaused
    {
        if change < 0
        {
            inst.autoClickPaused := false
            inst.clickInterval := 500
            SaveAccountInterval(inst.slot, "AutoClick", inst.clickInterval)
            SetInstanceTimer(inst, "AutoClick", (*) => SendBackgroundClick(inst), inst.clickInterval)
            ShowHotkeyTooltip("Auto-Click interval: 500 ms")
        }
        return
    }

    if change > 0 && inst.clickInterval >= 500
    {
        inst.autoClickPaused := true
        RemoveInstanceTimer(inst, "AutoClick")
        ShowHotkeyTooltip("Auto-Click PAUSED")
        return
    }

    inst.clickInterval := Max(10, Min(500, inst.clickInterval + change))
    SaveAccountInterval(inst.slot, "AutoClick", inst.clickInterval)
    SetInstanceTimer(inst, "AutoClick", (*) => SendBackgroundClick(inst), inst.clickInterval)
    ShowHotkeyTooltip("Auto-Click interval: " inst.clickInterval " ms")
}

AdjustFocusedTrainSlowInterval(change)
{
    inst := GetFocusedActionInstance("TrainSlow")
    if !IsObject(inst)
        return
    inst.trainSlowInterval := Max(10, Min(3000, inst.trainSlowInterval + change))
    SaveAccountInterval(inst.slot, "TrainSlow", inst.trainSlowInterval)
    SetInstanceTimer(inst, "TrainSlow", (*) => SendBackgroundTrainSlow(inst), inst.trainSlowInterval)
    ShowHotkeyTooltip("Train Slow interval: " inst.trainSlowInterval " ms")
}

LoadAccountInterval(slot, action, fallback)
{
    global CONFIG_FILE
    key := "Slot" slot action "Interval"
    try
    {
        value := Integer(IniRead(CONFIG_FILE, "AccountIntervals", key, String(fallback)))
    }
    catch
    {
        value := fallback
    }
    if action = "AutoClick"
        return Max(10, Min(500, value))
    return Max(10, Min(3000, value))
}

SaveAccountInterval(slot, action, interval)
{
    global CONFIG_FILE
    IniWrite(interval, CONFIG_FILE, "AccountIntervals", "Slot" slot action "Interval")
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

    interval := action = "AutoClick" ? Min(500, interval) : Min(3000, interval)
    ctrl.Value := String(interval)
    settingName := IntervalSettings[action]
    Settings[settingName] := interval

    target := GetActiveFoxholeInstanceIndex()
    if target
    {
        inst := Instances[target]
        if action = "AutoClick"
            inst.clickInterval := Min(500, interval)
        else if action = "TrainSlow"
            inst.trainSlowInterval := Min(3000, interval)
        SaveAccountInterval(inst.slot, action, interval)
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
        else if action = "SwapFirst"
        {
            if !idx
                idx := GetActiveFoxholeInstanceIndex()
            if !idx
                continue
            SwapFocusedWindowToFirstLayoutSpot(Instances[idx])
        }
        else if action = "ShowFoxhole"
        {
            ToggleAllFoxholeWindows()
        }
        else if action = "ShowSteam"
        {
            ToggleSelectedSteamWindows()
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

    for accountIndex, accountKey in AccountSwapKeys
    {
        if accountKey != "" && StrLower(accountKey) = normalizedKey
            ActivateAccountSwapTarget(accountIndex)
    }

    RefreshList()
}

ActivateAccountSwapTarget(accountIndex)
{
    global Settings, SandboxieAccounts, Instances, StatusText

    ScanWindows()
    targetInst := ""
    targetDescription := "slot " accountIndex

    if Settings["SwapByAccount"]
    {
        if accountIndex < 1 || accountIndex > SandboxieAccounts.Length
            return
        accountName := Trim(SandboxieAccounts[accountIndex].name)
        if accountName = ""
            return
        targetDescription := accountName
        for inst in Instances
        {
            if StrLower(Trim(GetAccountNameForInstance(inst))) = StrLower(accountName)
            {
                targetInst := inst
                break
            }
        }
    }
    else
    {
        for inst in Instances
        {
            if inst.slot = accountIndex
            {
                targetInst := inst
                break
            }
        }
    }

    if !IsObject(targetInst) || !IsWindowAlive(targetInst.hwnd)
    {
        StatusText.Text := "Status: No Foxhole window found for " targetDescription "."
        ShowHotkeyTooltip("No Foxhole window found for " targetDescription ".")
        return
    }

    try WinRestore("ahk_id " targetInst.hwnd)
    try WinActivate("ahk_id " targetInst.hwnd)
    try WinWaitActive("ahk_id " targetInst.hwnd, , 1)
    StatusText.Text := "Status: Activated " targetDescription "."
}

MakeSharedHotkeyHandler(keyName)
{
    return (*) => GlobalSharedHotkey(keyName)
}

HotkeysGuiMouseMove(wParam, lParam, msg, hwnd)
{
    global HotkeysGui, RebindButtons, CurrentKeys, Settings

    if !Settings["ShowUiTooltips"]
    {
        ToolTip("", , , 2)
        return
    }

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
    global HotkeyTooltipTimer, Settings

    if !Settings["ShowHotkeyTooltips"]
        return

    if !inst || !IsWindowAlive(inst.hwnd)
        return

    warTitle := "War " inst.slot
    actionName := Map(
        "AutoClick", "Auto Click",
        "AutoWalk", "Forward",
        "AutoReverse", "Reverse",
        "ClickHold", "Left Click Hold",
        "RightHold", "Right Click Hold",
        "VSpam", "V Spam",
        "TrainSlow", "Train Slow"
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
        case "TrainSlow":
            return inst.trainSlow
    }
    return false
}

ShowHotkeyTooltip(text)
{
    global Settings
    if !Settings["ShowHotkeyTooltips"]
        return
    ToolTip(text, , , 1)
    SetTimer(HideHotkeysHotkeyTooltip, 0)
    SetTimer(HideHotkeysHotkeyTooltip, -1500)
}

HideHotkeysHotkeyTooltip()
{
    ToolTip("", , , 1)
}

ToggleMouseFocus()
{
    global MouseFocusEnabled
    SetMouseFocusEnabled(!MouseFocusEnabled, true)
}

SetMouseFocusEnabled(enabled, showFeedback := true)
{
    global MouseFocusEnabled, HoverFocusedHwnd, StatusText, Settings, MouseFocusCheck

    MouseFocusEnabled := !!enabled
    Settings["MouseFocusOn"] := MouseFocusEnabled
    HoverFocusedHwnd := 0
    SetTimer(FocusHoveredFoxholeWindow, 0)
    if MouseFocusEnabled
        SetTimer(FocusHoveredFoxholeWindow, 50)

    if IsObject(MouseFocusCheck)
        MouseFocusCheck.Value := MouseFocusEnabled ? 1 : 0

    if showFeedback
    {
        StatusText.Text := "Status: Mouse Focus " (MouseFocusEnabled ? "ON." : "OFF.")
        ShowMouseFocusTooltip()
    }
    SaveConfig()
}

MouseFocusSettingChanged(ctrl, *)
{
    SetMouseFocusEnabled(ctrl.Value = 1, true)
}

ShowMouseFocusTooltip()
{
    global MouseFocusEnabled, Settings

    if !Settings["ShowHotkeyTooltips"]
        return

    state := MouseFocusEnabled ? "ON" : "OFF"
    ToolTip("Mouse Focus " state, , , 1)
    SetTimer(HideHotkeysHotkeyTooltip, 0)
    SetTimer(HideHotkeysHotkeyTooltip, -1500)
}

FocusHoveredFoxholeWindow()
{
    global MouseFocusEnabled, HoverFocusedHwnd

    if !MouseFocusEnabled
        return

    mouseHwnd := 0
    try MouseGetPos(,, &mouseHwnd)

    rootHwnd := 0
    if mouseHwnd
        rootHwnd := DllCall("GetAncestor", "Ptr", mouseHwnd, "UInt", 2, "Ptr")

    if !rootHwnd || !FindInstanceByHwnd(rootHwnd)
    {
        HoverFocusedHwnd := 0
        return
    }

    if rootHwnd = HoverFocusedHwnd
        return

    HoverFocusedHwnd := rootHwnd
    if !WinActive("ahk_id " rootHwnd)
        try WinActivate("ahk_id " rootHwnd)
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

ToggleAllFoxholeWindows()
{
    global ShowFoxholeWindowsVisible, StatusText

    windows := WinGetList("ahk_exe War-Win64-Shipping.exe")
    shouldMinimize := ShowFoxholeWindowsVisible
    changed := 0
    showCommand := shouldMinimize ? 6 : 3
    for hwnd in windows
    {
        if IsWindowAlive(hwnd)
        {
            DllCall("ShowWindowAsync", "Ptr", hwnd, "Int", showCommand)
            changed++
        }
    }

    if changed
        ShowFoxholeWindowsVisible := !shouldMinimize
    StatusText.Text := "Status: " (shouldMinimize ? "Minimized " : "Maximized ") changed " Foxhole window(s)."
}

ToggleSelectedSteamWindows()
{
    global SandboxieAccounts, ShowSteamWindowsVisible, StatusText

    SaveSandboxieVisibleRows()
    shouldCloseToTray := ShowSteamWindowsVisible
    targetPids := Map()
    sandboxedPids := Map()
    includeMain := false

    for account in SandboxieAccounts
    {
        if !account.selected
            continue
        if account.main
        {
            includeMain := true
            continue
        }

        boxName := Trim(account.name)
        if !IsValidSandboxieName(boxName)
            continue
        for pid in GetSandboxieBoxPids(boxName)
        {
            sandboxedPids[pid] := true
            try
            {
                processName := StrLower(ProcessGetName(pid))
                if processName = "steam.exe" || processName = "steamwebhelper.exe"
                    targetPids[pid] := true
            }
        }
    }

    if includeMain
    {
        try
        {
            wmi := ComObjGet("winmgmts:")
            for process in wmi.ExecQuery("SELECT ProcessId, Name FROM Win32_Process WHERE Name='steam.exe' OR Name='steamwebhelper.exe'")
            {
                pid := Integer(process.ProcessId)
                if pid > 0 && !sandboxedPids.Has(pid)
                    targetPids[pid] := true
            }
        }
    }

    changed := 0
    seenWindows := Map()
    oldDetectHidden := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    try
    {
        for pid, _ in targetPids
        {
            try windows := WinGetList("ahk_pid " pid)
            catch
                continue
            for hwnd in windows
            {
                if seenWindows.Has(hwnd)
                    continue
                seenWindows[hwnd] := true
                try
                {
                    if !WinExist("ahk_id " hwnd)
                        continue
                    style := WinGetStyle("ahk_id " hwnd)
                    if !(style & 0x10000000) && shouldCloseToTray
                        continue

                    if shouldCloseToTray
                    {

                        PostMessage(0x0010, 0, 0, , "ahk_id " hwnd)
                    }
                    else
                    {

                        DllCall("ShowWindowAsync", "Ptr", hwnd, "Int", 9)
                    }
                    changed++
                }
            }
        }
    }
    finally
    {
        DetectHiddenWindows(oldDetectHidden)
    }

    if changed
        ShowSteamWindowsVisible := !shouldCloseToTray
    StatusText.Text := "Status: " (shouldCloseToTray ? "Closed " : "Restored ") changed " Steam window(s) " (shouldCloseToTray ? "to the system tray." : "without maximizing.")
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
    global ActionNames, CurrentKeys, AccountSwapKeys

    disabled := Map()

    allKeys := []
    for action in ActionNames
        allKeys.Push(CurrentKeys[action])
    for _, key in AccountSwapKeys
        allKeys.Push(key)

    for key in allKeys
    {
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
    global ActionNames, CurrentKeys, AccountSwapKeys

    registered := Map()

    allKeys := []
    for action in ActionNames
        allKeys.Push(CurrentKeys[action])
    for _, key in AccountSwapKeys
        allKeys.Push(key)

    for key in allKeys
    {
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

MakeAccountSwapRebindHandler(accountIndex)
{
    return (ctrl, *) => StartAccountSwapRebind(accountIndex, ctrl)
}

MakeAccountSwapActionHandler(callback, accountIndex)
{
    return (*) => callback(accountIndex)
}

StartAccountSwapRebind(accountIndex, btn)
{
    global RebindingAction, PollKeyList, StatusText
    if RebindingAction != ""
        return
    if PollKeyList.Length = 0
        InitPollKeyList()
    DisableAllHotkeys()
    RebindingAction := "AccountSwap:" accountIndex
    btn.Text := "Press any key..."
    StatusText.Text := "Status: Listening for Swap to " accountIndex " (Esc to cancel)..."
    SetTimer(PollForAccountSwapRebind, 20)

    PollForAccountSwapRebind()
    {
        global RebindingAction, PollKeyList
        if !InStr(RebindingAction, "AccountSwap:")
        {
            SetTimer(PollForAccountSwapRebind, 0)
            return
        }
        for keyName in PollKeyList
        {
            if IsModifierKeyName(keyName)
                continue
            if GetKeyState(keyName, "P")
            {
                SetTimer(PollForAccountSwapRebind, 0)
                modPrefix := BuildHeldModifierPrefix()
                BeginRebindReleaseWatch(keyName)
                FinishAccountSwapRebind(accountIndex, btn, modPrefix, keyName)
                return
            }
        }
    }
}

FinishAccountSwapRebind(accountIndex, btn, modPrefix, keyName)
{
    global RebindingAction, AccountSwapKeys, AccountSwapButtons, CurrentKeys, ActionNames, RebindButtons, DefaultKeys, StatusText
    RebindingAction := ""
    if keyName = "Escape" && modPrefix = ""
    {
        btn.Text := "Swap to " accountIndex " | " DisplayNameForHotkeyString(AccountSwapKeys[accountIndex])
        StatusText.Text := "Status: Rebind cancelled."
        return
    }

    fullKey := modPrefix . keyName
    for action in ActionNames
    {
        if CurrentKeys[action] != "" && StrLower(CurrentKeys[action]) = StrLower(fullKey)
        {
            CurrentKeys[action] := DefaultKeys[action]
            if RebindButtons.Has(action)
                RebindButtons[action].Text := ActionButtonText(action, CurrentKeys[action])
        }
    }
    for otherIndex, otherKey in AccountSwapKeys
    {
        if otherIndex != accountIndex && otherKey != "" && StrLower(otherKey) = StrLower(fullKey)
        {
            AccountSwapKeys[otherIndex] := ""
            if AccountSwapButtons.Has(otherIndex)
                AccountSwapButtons[otherIndex].Text := "Swap to " otherIndex " | Unbound"
        }
    }

    AccountSwapKeys[accountIndex] := fullKey
    btn.Text := "Swap to " accountIndex " | " DisplayNameForHotkeyString(fullKey)
    SaveConfig()
    StatusText.Text := "Status: Swap to " accountIndex " = " DisplayNameForHotkeyString(fullKey)
}

ResetAccountSwapHotkey(accountIndex)
{
    UnbindAccountSwapHotkey(accountIndex)
}

UnbindAccountSwapHotkey(accountIndex)
{
    global AccountSwapKeys, AccountSwapButtons, StatusText
    DisableAllHotkeys()
    AccountSwapKeys[accountIndex] := ""
    if AccountSwapButtons.Has(accountIndex)
        AccountSwapButtons[accountIndex].Text := "Swap to " accountIndex " | Unbound"
    SaveConfig()
    EnableAllHotkeys()
    StatusText.Text := "Status: Swap to " accountIndex " is unbound."
}

MakeOutputKeyHandler(action)
{
    return (ctrl, *) => StartOutputKeyListening(action, ctrl)
}

StartOutputKeyListening(action, btn)
{
    global RebindingAction, OutputCaptureHook, CurrentOutputKeys, StatusText, ActionLabels
    if RebindingAction != ""
        return
    DisableAllHotkeys()
    RebindingAction := "Output:" action
    btn.Text := "Press..."
    StatusText.Text := "Status: Press the output key for " ActionLabels[action] " (Esc cancels)..."
    OutputCaptureHook := InputHook("L0")
    OutputCaptureHook.KeyOpt("{All}", "ES")
    OutputCaptureHook.OnEnd := (*) => FinishOutputKeyListening(action, btn, OutputCaptureHook.EndKey)
    OutputCaptureHook.Start()
}

FinishOutputKeyListening(action, btn, keyName)
{
    global RebindingAction, OutputCaptureHook, CurrentOutputKeys, StatusText, ActionLabels, CONFIG_FILE
    RebindingAction := ""
    OutputCaptureHook := ""
    if keyName = "Escape" || keyName = ""
    {
        btn.Text := DisplayNameForOutputKey(CurrentOutputKeys[action])
        StatusText.Text := "Status: Output-key change cancelled."
        EnableAllHotkeys()
        return
    }
    if !IsValidOutputKey(keyName)
    {
        btn.Text := DisplayNameForOutputKey(CurrentOutputKeys[action])
        StatusText.Text := "Status: That key cannot be sent in the background."
        EnableAllHotkeys()
        return
    }
    StopOutputActionForAllInstances(action)
    CurrentOutputKeys[action] := keyName
    IniWrite(keyName, CONFIG_FILE, "OutputKeys", action)
    btn.Text := DisplayNameForOutputKey(keyName)
    StatusText.Text := "Status: " ActionLabels[action] " now sends " DisplayNameForOutputKey(keyName) "."
    EnableAllHotkeys()
}

StopOutputActionForAllInstances(action)
{
    global Instances
    for inst in Instances
    {
        if action = "AutoWalk" && inst.autoWalk
            StopAction(inst, "AutoWalk")
        else if action = "AutoReverse" && inst.autoReverse
            StopAction(inst, "AutoReverse")
        else if action = "VSpam" && inst.vSpam
            StopAction(inst, "VSpam")
        else if action = "TrainSlow" && inst.trainSlow
            StopAction(inst, "TrainSlow")
    }
}

IsMouseKeyName(keyName)
{
    return keyName = "MButton" || keyName = "XButton1" || keyName = "XButton2"
}

IsValidOutputKey(keyName)
{
    if keyName = "" || keyName = "Escape" || IsModifierKeyName(keyName) || IsMouseKeyName(keyName)
        return false
    try return GetKeyVK(keyName) > 0 && GetKeySC(keyName) > 0
    catch
        return false
}

DisplayNameForOutputKey(keyName)
{
    if RegExMatch(keyName, "i)^[a-z]$")
        return StrUpper(keyName)
    return keyName
}

BuildKeyboardLParam(scanCode, isKeyUp := false, isExtended := false)
{
    lParam := 1 | ((scanCode & 0xFF) << 16)
    if isExtended
        lParam |= (1 << 24)
    if isKeyUp
        lParam |= (1 << 30) | (1 << 31)
    return lParam
}

IsExtendedOutputKey(keyName)
{
    static extendedKeys := Map("Insert", true, "Delete", true, "Home", true, "End", true, "PgUp", true, "PgDn", true, "Up", true, "Down", true, "Left", true, "Right", true, "RControl", true, "RAlt", true, "NumpadDiv", true, "NumpadEnter", true, "LWin", true, "RWin", true, "AppsKey", true)
    return extendedKeys.Has(keyName)
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
    global AccountSwapKeys, AccountSwapButtons

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

    for accountIndex, accountKey in AccountSwapKeys
    {
        if accountKey != "" && StrLower(accountKey) = StrLower(fullKey)
        {
            AccountSwapKeys[accountIndex] := ""
            if AccountSwapButtons.Has(accountIndex)
                AccountSwapButtons[accountIndex].Text := "Swap to " accountIndex " | Unbound"
        }
    }

    CurrentKeys[action] := fullKey

    SaveConfig()

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
    global DefaultOutputKeys, CurrentOutputKeys, OutputKeyButtons

    DisableAllHotkeys()

    CurrentKeys[action] := DefaultKeys[action]
    if RebindButtons.Has(action)
        RebindButtons[action].Text := ActionButtonText(action, CurrentKeys[action])
    if DefaultOutputKeys.Has(action)
    {
        StopOutputActionForAllInstances(action)
        CurrentOutputKeys[action] := DefaultOutputKeys[action]
        if OutputKeyButtons.Has(action)
            OutputKeyButtons[action].Text := DisplayNameForOutputKey(CurrentOutputKeys[action])
    }

    EnableAllHotkeys()
    SaveConfig()
    StatusText.Text := "Status: " ActionLabels[action] " hotkey reset to default."
}

UnbindSingleHotkey(action)
{
    global CurrentKeys, RebindButtons, ActionLabels, StatusText

    DisableAllHotkeys()
    CurrentKeys[action] := ""
    if RebindButtons.Has(action)
        RebindButtons[action].Text := ActionButtonText(action, "")
    EnableAllHotkeys()
    SaveConfig()
    StatusText.Text := "Status: " ActionLabels[action] " hotkey unbound."
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

    target := GetActiveFoxholeInstanceIndex()
    if target
    {
        inst := Instances[target]
        if action = "AutoClick"
        {
            inst.clickInterval := interval
            inst.autoClickPaused := false
        }
        else if action = "TrainSlow"
            inst.trainSlowInterval := interval
        SaveAccountInterval(inst.slot, action, interval)
        if IsHotkeysActionEnabled(inst, action)
        {
            StopAction(inst, action)
            StartAction(inst, action)
        }
    }

    SaveConfig()
    StatusText.Text := "Status: " ActionLabels[action] " interval reset to default."
}

ShowHotkeyTooltipsChanged(ctrl, *)
{
    global Settings
    Settings["ShowHotkeyTooltips"] := ctrl.Value = 1
    if !Settings["ShowHotkeyTooltips"]
        ToolTip("", , , 1)
    SaveConfig()
}

ShowUiTooltipsChanged(ctrl, *)
{
    global Settings, GuiLastTooltipHwnd
    Settings["ShowUiTooltips"] := ctrl.Value = 1
    if !Settings["ShowUiTooltips"]
    {
        ToolTip("", , , 2)
        ToolTip("", , , 20)
        GuiLastTooltipHwnd := 0
    }
    SaveConfig()
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

ApplyGuiAlwaysOnTop(guiObj, enabled)
{
    if !IsObject(guiObj)
        return
    try WinSetAlwaysOnTop(enabled ? 1 : 0, "ahk_id " guiObj.Hwnd)
}

SwitchMainPage(page, *)
{
    global MainGui, MainPageControls, SBGui, HotkeysGui, LayoutEditorGui, CurrentMainPage
    global MainNavButtons, LayoutEditorEditingActive, LayoutWindowPositions, LayoutReapplyPending
    global LayoutEditorRequiredHeight, WorkflowEditorExpanded, WorkflowEditorControls
    global SettingsSectionExpanded, SettingsSectionControls

    if !IsObject(MainGui)
        return
    CurrentMainPage := page
    SetGuiRedraw(MainGui, false)
    for ctrl in MainPageControls
        try ctrl.Visible := page = "Main"
    if page = "Main" && !WorkflowEditorExpanded
    {
        for ctrl in WorkflowEditorControls
            try ctrl.Visible := false
    }
    if page = "Main" && !SettingsSectionExpanded
    {
        for ctrl in SettingsSectionControls
            try ctrl.Visible := false
    }
    for name, btn in MainNavButtons
        try btn.Enabled := name != page

    for guiObj in [SBGui, HotkeysGui, LayoutEditorGui]
    {
        if !IsObject(guiObj) || !guiObj.Hwnd
            continue
        try guiObj.Hide()
        try WinHide("ahk_id " guiObj.Hwnd)
    }

    if page = "Accounts"
    {
        LayoutEditorEditingActive := false
        UpdateWorkflowAccountSummary()
        StartSandboxieStatusWatcher()
        pageY := GetEmbeddedPageY()
        SBGui.Show("x12 y" pageY " w535 NoActivate")
        MainGui.Show("w559 h" GetEmbeddedGuiBottom(SBGui, 470))
    }
    else if page = "Hotkeys"
    {
        StopSandboxieStatusWatcher()
        LayoutEditorEditingActive := false
        pageY := GetEmbeddedPageY()
        hotkeysHeight := GetHotkeysGuiRequiredHeight()
        HotkeysGui.Show("x12 y" pageY " w500 h" hotkeysHeight " NoActivate")
        MainGui.Show("w559 h" GetEmbeddedGuiBottom(HotkeysGui, hotkeysHeight))
    }
    else if page = "Layouts"
    {
        StopSandboxieStatusWatcher()
        LayoutEditorEditingActive := true
        LayoutReapplyPending := false
        LayoutWindowPositions := CaptureFoxholeWindowPositions()
        EnsureLastSelectedLayout()
        RefreshLayoutEditorGui()
        pageY := GetEmbeddedPageY()
        LayoutEditorGui.Show("x0 y" pageY " w559 h" LayoutEditorRequiredHeight " NoActivate")
        MainGui.Show("w559 h" (pageY + LayoutEditorRequiredHeight + 12))
    }
    else
    {
        StopSandboxieStatusWatcher()
        LayoutEditorEditingActive := false
        LayoutWindowPositions := CaptureFoxholeWindowPositions()
        UpdateWorkflowAccountSummary()
        MainGui.Show("w559 h" GetMainPageRequiredHeight())
    }

    SetGuiRedraw(MainGui, true)
    DllCall("RedrawWindow", "Ptr", MainGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0085)
}


GetMainPageRequiredHeight()
{
    global MainPageControls

    bottom := 0
    for ctrl in MainPageControls
    {
        if !IsObject(ctrl) || !ctrl.Hwnd
            continue
        try
        {
            if !ctrl.Visible
                continue
            ctrl.GetPos(&x, &y, &w, &h)
            bottom := Max(bottom, y + h)
        }
    }
    return Max(440, bottom + 44)
}

GetEmbeddedPageY()
{
    global BannerVisible
    return BannerVisible ? 235 : 44
}

GetEmbeddedGuiBottom(guiObj, fallbackHeight)
{
    pageY := GetEmbeddedPageY()
    try
    {
        guiObj.GetPos(,,, &h)
        if h > 0
            return pageY + h + 12
    }
    return pageY + fallbackHeight + 12
}

ReflowCurrentPageAfterBannerChange()
{
    global MainGui, CurrentMainPage, SBGui, HotkeysGui, LayoutEditorGui
    global LayoutEditorRequiredHeight
    if !IsObject(MainGui) || !MainGui.Hwnd
        return

    pageY := GetEmbeddedPageY()
    if CurrentMainPage = "Accounts" && IsObject(SBGui) && SBGui.Hwnd
    {
        SBGui.Show("x12 y" pageY " w535 NoActivate")
        MainGui.Show("w559 h" GetEmbeddedGuiBottom(SBGui, 470))
    }
    else if CurrentMainPage = "Hotkeys" && IsObject(HotkeysGui) && HotkeysGui.Hwnd
    {
        hotkeysHeight := GetHotkeysGuiRequiredHeight()
        HotkeysGui.Show("x12 y" pageY " w500 h" hotkeysHeight " NoActivate")
        MainGui.Show("w559 h" GetEmbeddedGuiBottom(HotkeysGui, hotkeysHeight))
    }
    else if CurrentMainPage = "Layouts" && IsObject(LayoutEditorGui) && LayoutEditorGui.Hwnd
    {
        LayoutEditorGui.Show("x0 y" pageY " w559 h" LayoutEditorRequiredHeight " NoActivate")
        MainGui.Show("w559 h" (pageY + LayoutEditorRequiredHeight + 12))
    }
    else
        MainGui.Show("w559 h" GetMainPageRequiredHeight())
}

GetSelectedAccountIndices()
{
    global SandboxieAccounts
    SaveSandboxieVisibleRows()
    result := []
    for index, account in SandboxieAccounts
        if account.selected
            result.Push(index)
    return result
}

GetIncludedAccountIndices()
{
    global SandboxieAccounts, WorkflowIncludedAccountNames
    selected := GetSelectedAccountIndices()
    selectedNames := Map()
    for index in selected
    {
        name := Trim(SandboxieAccounts[index].name)
        selectedNames[StrLower(name != "" ? name : "#row" index)] := index
    }

    if WorkflowIncludedAccountNames.Length = 0
    {
        for index in selected
        {
            name := Trim(SandboxieAccounts[index].name)
            WorkflowIncludedAccountNames.Push(name != "" ? name : "#row" index)
        }
    }

    result := []
    retained := []
    for savedName in WorkflowIncludedAccountNames
    {
        key := StrLower(savedName)
        if selectedNames.Has(key)
        {
            result.Push(selectedNames[key])
            retained.Push(savedName)
        }
    }
    WorkflowIncludedAccountNames := retained
    return result
}

ShowWorkflowAccountPicker(*)
{
    global WorkflowAccountPickerGui, WorkflowAccountPickerChecks, WorkflowIncludedAccountNames
    global SandboxieAccounts, MainGui

    selected := GetSelectedAccountIndices()
    if selected.Length = 0
    {
        MsgBox("No accounts are currently marked Selected on the Accounts & Sandboxes page.", "Choose Workflow Accounts", "Icon!")
        return
    }

    included := Map()
    for name in WorkflowIncludedAccountNames
        included[StrLower(name)] := true

    WorkflowAccountPickerGui := Gui("+Owner" MainGui.Hwnd, "Choose Workflow Accounts")
    WorkflowAccountPickerGui.SetFont("s9", "Segoe UI")
    WorkflowAccountPickerGui.AddText("x12 y10 w336 h48 +Wrap", "Choose which currently Selected accounts this workflow should use. New workflows include all Selected accounts by default.")
    WorkflowAccountPickerChecks := []
    y := 66
    for index in selected
    {
        account := SandboxieAccounts[index]
        name := Trim(account.name)
        key := name != "" ? name : "#row" index
        label := name != "" ? name : "Row " index
        if account.main
            label .= " (Main)"
        check := WorkflowAccountPickerGui.AddCheckBox("x16 y" y " w300 h24", label)
        check.Value := WorkflowIncludedAccountNames.Length = 0 || included.Has(StrLower(key)) ? 1 : 0
        WorkflowAccountPickerChecks.Push({control:check, key:key})
        y += 27
    }
    allBtn := WorkflowAccountPickerGui.AddButton("x12 y" (y+4) " w82 h27", "Select All")
    allBtn.OnEvent("Click", SetAllWorkflowAccountPickerChecks.Bind(true))
    noneBtn := WorkflowAccountPickerGui.AddButton("x100 y" (y+4) " w82 h27", "Clear All")
    noneBtn.OnEvent("Click", SetAllWorkflowAccountPickerChecks.Bind(false))
    cancelBtn := WorkflowAccountPickerGui.AddButton("x202 y" (y+4) " w70 h27", "Cancel")
    cancelBtn.OnEvent("Click", (*) => WorkflowAccountPickerGui.Destroy())
    okBtn := WorkflowAccountPickerGui.AddButton("x278 y" (y+4) " w70 h27 Default", "OK")
    okBtn.OnEvent("Click", SaveWorkflowAccountPicker)
    WorkflowAccountPickerGui.OnEvent("Close", (*) => WorkflowAccountPickerGui.Destroy())
    WorkflowAccountPickerGui.Show("w360 h" (y+47))
}

SetAllWorkflowAccountPickerChecks(value, *)
{
    global WorkflowAccountPickerChecks
    for item in WorkflowAccountPickerChecks
        item.control.Value := value ? 1 : 0
}

SaveWorkflowAccountPicker(*)
{
    global WorkflowAccountPickerGui, WorkflowAccountPickerChecks, WorkflowIncludedAccountNames
    WorkflowIncludedAccountNames := []
    for item in WorkflowAccountPickerChecks
        if item.control.Value = 1
            WorkflowIncludedAccountNames.Push(item.key)
    WorkflowAccountPickerGui.Destroy()
    UpdateWorkflowAccountSummary()
}

UpdateWorkflowAccountSummary(*)
{
    global WorkflowAccountSummary, WorkflowAccountSummaryHeight, SandboxieAccounts
    global MainPageControls, MainGui, CurrentMainPage
    if !IsObject(WorkflowAccountSummary)
        return

    indices := GetIncludedAccountIndices()
    names := []
    for index in indices
    {
        name := Trim(SandboxieAccounts[index].name)
        names.Push(name != "" ? name : "Row " index)
    }

    summaryText := indices.Length ? "Accounts: " indices.Length " included — " JoinText(names, ", ") : "Accounts: none included"
    WorkflowAccountSummary.Text := summaryText
    WorkflowAccountSummary.GetPos(&summaryX, &summaryY, &summaryW, &oldHeight)
    newHeight := Max(22, MeasureWrappedControlTextHeight(WorkflowAccountSummary, summaryText, summaryW, 22))
    deltaY := newHeight - oldHeight

    if Abs(deltaY) > 1
    {
        SetGuiRedraw(MainGui, false)
        try
        {
            WorkflowAccountSummary.Move(, , , newHeight)
            for ctrl in MainPageControls
            {
                if !IsObject(ctrl) || !ctrl.Hwnd || ctrl.Hwnd = WorkflowAccountSummary.Hwnd
                    continue
                ctrl.GetPos(&x, &y, &w, &h)
                if y > summaryY
                    ctrl.Move(, y + deltaY)
            }
            WorkflowAccountSummaryHeight := newHeight
            if CurrentMainPage = "Main"
                MainGui.Move(, , , GetMainPageRequiredHeight())
        }
        finally
        {
            SetGuiRedraw(MainGui, true)
            DllCall("RedrawWindow", "Ptr", MainGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0085)
        }
    }
}

MeasureWrappedControlTextHeight(ctrl, text, width, minimumHeight := 22)
{
    if !IsObject(ctrl) || !ctrl.Hwnd || width <= 0
        return minimumHeight

    hdc := DllCall("GetDC", "Ptr", ctrl.Hwnd, "Ptr")
    if !hdc
        return minimumHeight

    oldFont := 0
    try
    {
        fontHandle := SendMessage(0x0031, 0, 0, ctrl)
        if fontHandle
            oldFont := DllCall("SelectObject", "Ptr", hdc, "Ptr", fontHandle, "Ptr")
        rect := Buffer(16, 0)
        NumPut("Int", width, rect, 8)
        flags := 0x00000400 | 0x00000010 | 0x00000800
        DllCall("DrawTextW", "Ptr", hdc, "Str", text, "Int", -1, "Ptr", rect.Ptr, "UInt", flags)
        return Max(minimumHeight, NumGet(rect, 12, "Int") - NumGet(rect, 4, "Int") + 4)
    }
    finally
    {
        if oldFont
            DllCall("SelectObject", "Ptr", hdc, "Ptr", oldFont, "Ptr")
        DllCall("ReleaseDC", "Ptr", ctrl.Hwnd, "Ptr", hdc)
    }
}

JoinText(items, separator)
{
    text := ""
    for item in items
        text .= (text = "" ? "" : separator) item
    return text
}

GetCurrentWorkflowDefinition(name := "")
{
    global WorkflowResetFoxholeCheck, WorkflowLaunchFoxholeCheck, WorkflowResetSteamCheck, WorkflowLaunchSteamCheck
    global WorkflowResetSandboxesCheck, WorkflowVerifySandboxesCheck, WorkflowLaunchSteamMinimizedCheck, WorkflowIncludedAccountNames
    accountNames := []
    for accountName in WorkflowIncludedAccountNames
        accountNames.Push(accountName)
    return {name:name, accountNames:accountNames, launchSteamMinimized:WorkflowLaunchSteamMinimizedCheck.Value=1, resetFoxhole:WorkflowResetFoxholeCheck.Value=1, launchFoxhole:WorkflowLaunchFoxholeCheck.Value=1,
        resetSteam:WorkflowResetSteamCheck.Value=1, launchSteam:WorkflowLaunchSteamCheck.Value=1,
        resetSandboxes:WorkflowResetSandboxesCheck.Value=1, verifySandboxes:WorkflowVerifySandboxesCheck.Value=1}
}

ApplyWorkflowDefinition(def)
{
    global WorkflowResetFoxholeCheck, WorkflowLaunchFoxholeCheck, WorkflowResetSteamCheck, WorkflowLaunchSteamCheck
    global WorkflowResetSandboxesCheck, WorkflowVerifySandboxesCheck, WorkflowLaunchSteamMinimizedCheck, WorkflowIncludedAccountNames
    WorkflowIncludedAccountNames := []
    if def.HasOwnProp("accountNames")
        for accountName in def.accountNames
            WorkflowIncludedAccountNames.Push(accountName)
    WorkflowLaunchSteamMinimizedCheck.Value := !def.HasOwnProp("launchSteamMinimized") || def.launchSteamMinimized ? 1 : 0
    WorkflowResetFoxholeCheck.Value := def.resetFoxhole ? 1 : 0
    WorkflowLaunchFoxholeCheck.Value := def.launchFoxhole ? 1 : 0
    WorkflowResetSteamCheck.Value := def.resetSteam ? 1 : 0
    WorkflowLaunchSteamCheck.Value := def.launchSteam ? 1 : 0
    WorkflowResetSandboxesCheck.Value := def.resetSandboxes ? 1 : 0
    WorkflowVerifySandboxesCheck.Value := def.verifySandboxes ? 1 : 0
    UpdateWorkflowAccountSummary()
    UpdateWorkflowSequencePreview()
}

UpdateWorkflowSequencePreview(*)
{
    global WorkflowSequenceText
    if !IsObject(WorkflowSequenceText)
        return
    def := GetCurrentWorkflowDefinition()
    steps := []
    if def.resetFoxhole
        steps.Push("Close Foxhole")
    if def.resetSteam
        steps.Push("Close Steam")
    if def.resetSandboxes
        steps.Push("Reset sandboxes")
    if def.verifySandboxes
        steps.Push("Create/verify sandboxes")
    if def.launchSteam
        steps.Push("Launch Steam")
    if def.launchFoxhole
        steps.Push("Launch Foxhole")
    WorkflowSequenceText.Text := steps.Length ? "Next run: " JoinText(steps, " → ") : "Next run: No operations selected."
}

RefreshWorkflowPresetControls()
{
    global WorkflowPresets, WorkflowFavorites, WorkflowPresetCombo, WorkflowFavoriteButtons, WorkflowFavoriteSlotCombo
    if !IsObject(WorkflowPresetCombo)
        return
    names := []
    for preset in WorkflowPresets
        names.Push(preset.name)
    WorkflowPresetCombo.Delete()
    if names.Length
        WorkflowPresetCombo.Add(names)
    WorkflowPresetCombo.Value := 0
    WorkflowFavoriteSlotCombo.Value := 1
    Loop 8
    {
        idx := WorkflowFavorites[A_Index]
        btn := WorkflowFavoriteButtons[A_Index]
        if idx >= 1 && idx <= WorkflowPresets.Length
        {
            btn.Text := WorkflowPresets[idx].name
            btn.Enabled := true
        }
        else
        {
            btn.Text := ""
            btn.Enabled := false
            WorkflowFavorites[A_Index] := 0
        }
    }
}

WorkflowPresetChanged(ctrl, *)
{
    global WorkflowPresets, WorkflowFavoriteSlotCombo, WorkflowFavorites
    idx := ctrl.Value
    if idx < 1 || idx > WorkflowPresets.Length
        return
    ApplyWorkflowDefinition(WorkflowPresets[idx])
    slot := 0
    Loop 8
        if WorkflowFavorites[A_Index] = idx
            slot := A_Index
    WorkflowFavoriteSlotCombo.Value := slot + 1
}

LoadWorkflowFavorite(slot, *)
{
    global WorkflowFavorites, WorkflowPresets
    idx := WorkflowFavorites[slot]
    if idx < 1 || idx > WorkflowPresets.Length
        return
    RunWorkflowDefinition(WorkflowPresets[idx])
}

SaveNewWorkflowPreset(*)
{
    global WorkflowPresets, WorkflowPresetCombo
    result := InputBox("Enter a name for this workflow preset:", "Save Workflow", "w380 h140")
    if result.Result != "OK" || Trim(result.Value) = ""
        return
    name := Trim(result.Value)
    for preset in WorkflowPresets
        if StrLower(preset.name) = StrLower(name)
        {
            MsgBox("A workflow preset with that name already exists.", "Workflows", "Icon!")
            return
        }
    WorkflowPresets.Push(GetCurrentWorkflowDefinition(name))
    SaveWorkflowPresetsConfig()
    RefreshWorkflowPresetControls()
    WorkflowPresetCombo.Value := WorkflowPresets.Length
}

UpdateWorkflowPreset(*)
{
    global WorkflowPresets, WorkflowPresetCombo
    idx := WorkflowPresetCombo.Value
    if idx < 1 || idx > WorkflowPresets.Length
    {
        MsgBox("Select a workflow preset first.", "Workflows", "Icon!")
        return
    }
    WorkflowPresets[idx] := GetCurrentWorkflowDefinition(WorkflowPresets[idx].name)
    SaveWorkflowPresetsConfig()
    RefreshWorkflowPresetControls()
    WorkflowPresetCombo.Value := idx
}


RenameWorkflowPreset(*)
{
    global WorkflowPresets, WorkflowPresetCombo
    idx := WorkflowPresetCombo.Value
    if idx < 1 || idx > WorkflowPresets.Length
    {
        MsgBox("Select a workflow preset first.", "Workflows", "Icon!")
        return
    }

    oldName := WorkflowPresets[idx].name
    result := InputBox("Enter a new name for this workflow preset:", "Rename Workflow", "w380 h140", oldName)
    if result.Result != "OK"
        return
    newName := Trim(result.Value)
    if newName = "" || newName = oldName
        return

    for otherIndex, preset in WorkflowPresets
    {
        if otherIndex != idx && StrLower(preset.name) = StrLower(newName)
        {
            MsgBox("A workflow preset with that name already exists.", "Workflows", "Icon!")
            return
        }
    }

    WorkflowPresets[idx].name := newName
    SaveWorkflowPresetsConfig()
    RefreshWorkflowPresetControls()
    WorkflowPresetCombo.Value := idx
}

DeleteWorkflowPreset(*)
{
    global WorkflowPresets, WorkflowPresetCombo, WorkflowFavorites
    idx := WorkflowPresetCombo.Value
    if idx < 1 || idx > WorkflowPresets.Length
        return
    if MsgBox("Delete workflow preset " Chr(34) WorkflowPresets[idx].name Chr(34) "?", "Workflows", "YesNo Icon!") != "Yes"
        return
    WorkflowPresets.RemoveAt(idx)
    Loop 8
    {
        if WorkflowFavorites[A_Index] = idx
            WorkflowFavorites[A_Index] := 0
        else if WorkflowFavorites[A_Index] > idx
            WorkflowFavorites[A_Index]--
    }
    SaveWorkflowPresetsConfig()
    RefreshWorkflowPresetControls()
}

WorkflowFavoriteSlotChanged(ctrl, *)
{
    global WorkflowPresetCombo, WorkflowFavorites
    idx := WorkflowPresetCombo.Value
    if idx < 1
    {
        ctrl.Value := 1
        return
    }
    Loop 8
        if WorkflowFavorites[A_Index] = idx
            WorkflowFavorites[A_Index] := 0
    slot := ctrl.Value - 1
    if slot >= 1 && slot <= 8
        WorkflowFavorites[slot] := idx
    SaveWorkflowPresetsConfig()
    RefreshWorkflowPresetControls()
    WorkflowPresetCombo.Value := idx
    ctrl.Value := slot + 1
}

SplitWorkflowAccountNames(text)
{
    result := []
    for name in StrSplit(text, "|")
        if Trim(name) != ""
            result.Push(Trim(name))
    return result
}

LoadWorkflowPresetsConfig()
{
    global CONFIG_FILE, WorkflowPresets, WorkflowFavorites
    WorkflowPresets := []
    count := Max(0, Integer(IniRead(CONFIG_FILE, "WorkflowPresets", "Count", "0")))
    Loop count
    {
        section := "WorkflowPreset" A_Index
        name := Trim(IniRead(CONFIG_FILE, section, "Name", ""))
        if name = ""
            continue
        WorkflowPresets.Push({name:name,
            resetFoxhole:IniRead(CONFIG_FILE, section, "ResetFoxhole", "0")="1",
            launchFoxhole:IniRead(CONFIG_FILE, section, "LaunchFoxhole", "0")="1",
            resetSteam:IniRead(CONFIG_FILE, section, "ResetSteam", "0")="1",
            launchSteam:IniRead(CONFIG_FILE, section, "LaunchSteam", "0")="1",
            resetSandboxes:IniRead(CONFIG_FILE, section, "ResetSandboxes", "0")="1",
            verifySandboxes:IniRead(CONFIG_FILE, section, "VerifySandboxes", "0")="1",
            launchSteamMinimized:IniRead(CONFIG_FILE, section, "LaunchSteamMinimized", "1")="1",
            accountNames:SplitWorkflowAccountNames(IniRead(CONFIG_FILE, section, "AccountNames", ""))})
    }
    WorkflowFavorites := []
    Loop 8
        WorkflowFavorites.Push(Max(0, Integer(IniRead(CONFIG_FILE, "WorkflowPresets", "Favorite" A_Index, "0"))))
}

SaveWorkflowPresetsConfig()
{
    global CONFIG_FILE, WorkflowPresets, WorkflowFavorites
    oldCount := Max(0, Integer(IniRead(CONFIG_FILE, "WorkflowPresets", "Count", "0")))
    Loop Max(oldCount, WorkflowPresets.Length)
    {
        section := "WorkflowPreset" A_Index
        if A_Index > WorkflowPresets.Length
        {
            IniDelete(CONFIG_FILE, section)
            continue
        }
        p := WorkflowPresets[A_Index]
        text := "Name=" p.name "`nResetFoxhole=" (p.resetFoxhole?1:0) "`nLaunchFoxhole=" (p.launchFoxhole?1:0)
        text .= "`nResetSteam=" (p.resetSteam?1:0) "`nLaunchSteam=" (p.launchSteam?1:0)
        text .= "`nResetSandboxes=" (p.resetSandboxes?1:0) "`nVerifySandboxes=" (p.verifySandboxes?1:0)
        text .= "`nLaunchSteamMinimized=" ((!p.HasOwnProp("launchSteamMinimized") || p.launchSteamMinimized)?1:0)
        text .= "`nAccountNames=" JoinText(p.HasOwnProp("accountNames") ? p.accountNames : [], "|")
        IniWrite(text, CONFIG_FILE, section)
    }
    IniWrite(WorkflowPresets.Length, CONFIG_FILE, "WorkflowPresets", "Count")
    Loop 8
        IniWrite(WorkflowFavorites[A_Index], CONFIG_FILE, "WorkflowPresets", "Favorite" A_Index)
}

RunSelectedWorkflow(*)
{
    RunWorkflowDefinition(GetCurrentWorkflowDefinition())
}

RunWorkflowDefinition(def)
{
    global WorkflowRunning, WorkflowRunButton, WorkflowStopButton, StatusText, WorkflowIncludedAccountNames
    if WorkflowRunning
        return
    if def.HasOwnProp("accountNames")
    {
        WorkflowIncludedAccountNames := []
        for accountName in def.accountNames
            WorkflowIncludedAccountNames.Push(accountName)
    }
    accounts := GetIncludedAccountIndices()
    if accounts.Length = 0
    {
        StatusText.Text := "Status: No accounts included."
        return
    }
    if !(def.resetFoxhole || def.launchFoxhole || def.resetSteam || def.launchSteam || def.resetSandboxes || def.verifySandboxes)
    {
        StatusText.Text := "Status: No workflow operations selected."
        return
    }
    WorkflowRunning := true
    WorkflowRunButton.Enabled := false
    WorkflowStopButton.Enabled := true
    try
    {
        if def.resetFoxhole
            WorkflowCloseSelectedFoxhole(accounts)
        if def.resetSteam
            WorkflowCloseSelectedSteam(accounts)
        if def.resetSandboxes
            WorkflowResetSelectedSandboxes(accounts)
        if def.verifySandboxes
            WorkflowVerifySelectedSandboxes(accounts)

        if def.launchSteam && def.launchFoxhole
        {
            StatusText.Text := "Status: Launching Steam, waiting for readiness, then launching Foxhole..."
            StartCombinedSteamFoxholeLaunch(accounts, !def.HasOwnProp("launchSteamMinimized") || def.launchSteamMinimized)
        }
        else if def.launchSteam
        {
            StartSelectedSandboxieSteamLaunches(accounts, !def.HasOwnProp("launchSteamMinimized") || def.launchSteamMinimized)
            FinishWorkflow("Workflow completed. Steam launch commands were started.")
        }
        else if def.launchFoxhole
            StartFoxholeLaunchesForIndices(accounts, false)
        else
            FinishWorkflow("Workflow completed.")
    }
    catch as e
        FinishWorkflow("Workflow failed — " e.Message)
}

FinishWorkflow(message)
{
    global WorkflowRunning, WorkflowRunButton, WorkflowStopButton, StatusText
    WorkflowRunning := false
    if IsObject(WorkflowRunButton)
        WorkflowRunButton.Enabled := true
    if IsObject(WorkflowStopButton)
        WorkflowStopButton.Enabled := false
    StatusText.Text := "Status: " message
}

StopWorkflow(*)
{
    global CombinedLaunchActive
    if CombinedLaunchActive
        AbortCombinedSteamFoxholeLaunch("Workflow stopped.", false)
    StopSequentialFoxholeLaunches()
    FinishWorkflow("Workflow stopped.")
}

WorkflowCloseSelectedFoxhole(indices)
{
    global Instances, SandboxieAccounts, TitleOverlays
    selected := Map()
    for idx in indices
        selected[idx] := true
    closed := 0
    for inst in Instances
    {
        match := selected.Has(inst.slot)
        if !match
        {
            title := ""
            try title := WinGetTitle("ahk_id " inst.hwnd)
            for idx in indices
                if Trim(SandboxieAccounts[idx].name) != "" && InStr(title, SandboxieAccounts[idx].name)
                    match := true
        }
        if match && IsWindowAlive(inst.hwnd)
        {
            try WinClose("ahk_id " inst.hwnd)
            closed++
            RemoveTitleOverlay(inst.hwnd)
        }
    }
    Sleep(500)
    ScanWindows()
}

WorkflowCloseSelectedSteam(indices)
{
    global SandboxieAccounts, SandboxieSteamMinimizeBoxes
    for idx in indices
    {
        account := SandboxieAccounts[idx]
        boxName := Trim(account.name)
        if account.main || !IsValidSandboxieName(boxName)
            continue
        for pid in GetSandboxieBoxPids(boxName)
            try ProcessClose(pid)
        if SandboxieSteamMinimizeBoxes.Has(boxName)
            SandboxieSteamMinimizeBoxes.Delete(boxName)
    }
    Sleep(500)
}

WorkflowResetSelectedSandboxes(indices)
{
    global SandboxieAccounts
    boxes := []
    for idx in indices
    {
        account := SandboxieAccounts[idx]
        if !account.main && IsValidSandboxieName(Trim(account.name))
            boxes.Push(Trim(account.name))
    }
    if boxes.Length
        DeleteSandboxieContentsFast(boxes)
}

WorkflowVerifySelectedSandboxes(indices)
{
    global SandboxieAccounts
    failures := []
    for idx in indices
    {
        account := SandboxieAccounts[idx]
        name := Trim(account.name)
        if account.main || !IsValidSandboxieName(name)
            continue
        if !GetSandboxieBoxExists(name)
        {
            result := CreateSandboxieSandbox(name)
            if !result.ok
                failures.Push(name)
        }
    }
    if failures.Length
        throw Error("Could not create/verify: " JoinText(failures, ", "))
}

LoadConfig()
{
    global CONFIG_FILE, ActionNames, DefaultKeys, CurrentKeys, Settings
    global OutputActionNames, DefaultOutputKeys, CurrentOutputKeys
    global SandboxieRowCount, SandboxieAccounts, MaxSandboxieRows, Layouts, AccountSwapKeys
    global LayoutEditorSelectedLayout, LayoutFavorites

    missingHotkey := "__HOTKEY_SETTING_MISSING__"
    switchSlotRaw := IniRead(CONFIG_FILE, "Hotkeys", "SwitchSlot", missingHotkey)
    swapRaw := IniRead(CONFIG_FILE, "Hotkeys", "Swap", missingHotkey)

    if switchSlotRaw = missingHotkey
    {
        CurrentKeys["SwitchSlot"] := (swapRaw != missingHotkey && swapRaw != "") ? swapRaw : DefaultKeys["SwitchSlot"]
        CurrentKeys["Swap"] := DefaultKeys["Swap"]
    }
    else
    {
        CurrentKeys["SwitchSlot"] := switchSlotRaw
        CurrentKeys["Swap"] := swapRaw = missingHotkey ? DefaultKeys["Swap"] : swapRaw
    }

    for action in ActionNames
    {
        if action = "SwitchSlot" || action = "Swap"
            continue
        savedKey := IniRead(CONFIG_FILE, "Hotkeys", action, missingHotkey)
        CurrentKeys[action] := savedKey = missingHotkey ? DefaultKeys[action] : savedKey
    }

    for action in OutputActionNames
    {
        savedOutput := IniRead(CONFIG_FILE, "OutputKeys", action, DefaultOutputKeys[action])
        CurrentOutputKeys[action] := IsValidOutputKey(savedOutput) ? savedOutput : DefaultOutputKeys[action]
    }

    Settings["ClickInterval"] := Max(10, Min(500, Integer(IniRead(CONFIG_FILE, "Settings", "ClickInterval", "50"))))
    Settings["TrainSlowInterval"] := Max(10, Min(3000, Integer(IniRead(CONFIG_FILE, "Settings", "TrainSlowInterval", "300"))))
    Settings["DefaultClickX"] := Integer(IniRead(CONFIG_FILE, "Settings", "DefaultClickX", "0"))
    Settings["DefaultClickY"] := Integer(IniRead(CONFIG_FILE, "Settings", "DefaultClickY", "0"))
    Settings["MainAlwaysOnTop"] := IniRead(CONFIG_FILE, "Settings", "MainAlwaysOnTop", "0") = "1"
    Settings["ShowOverlay"] := IniRead(CONFIG_FILE, "Settings", "ShowOverlay", "1") = "1"
    Settings["ShowHotkeyTooltips"] := IniRead(CONFIG_FILE, "Settings", "ShowHotkeyTooltips", "1") = "1"
    Settings["ShowUiTooltips"] := IniRead(CONFIG_FILE, "Settings", "ShowUiTooltips", "1") = "1"
    Settings["MouseFocusOn"] := IniRead(CONFIG_FILE, "Settings", "MouseFocusOn", "1") = "1"
    Settings["AutoResetSlots"] := IniRead(CONFIG_FILE, "Settings", "AutoResetSlots", "0") = "1"
    Settings["ChangeOutputKeys"] := IniRead(CONFIG_FILE, "Settings", "ChangeOutputKeys", "0") = "1"
    Settings["SwapByAccount"] := IniRead(CONFIG_FILE, "Settings", "SwapByAccount", "1") = "1"
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
                height: Max(100, Integer(IniRead(CONFIG_FILE, section, "Slot" slotNo "_H", "540"))),
                keepAspect: IniRead(CONFIG_FILE, section, "Slot" slotNo "_KeepAspect", "0") = "1",
                aspectRatio: Float(IniRead(CONFIG_FILE, section, "Slot" slotNo "_AspectRatio", "0"))
            }
            if slot.aspectRatio <= 0
                slot.aspectRatio := slot.height > 0 ? slot.width / slot.height : 1.0
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

    LayoutFavorites := []
    Loop 4
    {
        favoriteName := Trim(IniRead(CONFIG_FILE, "Layouts", "Favorite" A_Index "Name", ""))
        favoriteIndex := 0
        if favoriteName != ""
        {
            for index, layout in Layouts
            {
                if StrLower(layout.name) = StrLower(favoriteName)
                {
                    favoriteIndex := index
                    break
                }
            }
        }
        if !favoriteIndex
        {
            legacyIndex := Max(0, Integer(IniRead(CONFIG_FILE, "Layouts", "Favorite" A_Index, "0")))
            if legacyIndex >= 1 && legacyIndex <= Layouts.Length
                favoriteIndex := legacyIndex
        }
        LayoutFavorites.Push(favoriteIndex)
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

    LoadWorkflowPresetsConfig()

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

    AccountSwapKeys := Map()
    for index, account in SandboxieAccounts
        AccountSwapKeys[index] := IniRead(CONFIG_FILE, "AccountSwapHotkeys", "Slot" index, "")
}

SaveLayoutsConfig()
{
    global CONFIG_FILE, Layouts, LayoutFavorites, Settings

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
            sectionText .= "`n" prefix "KeepAspect=" ((HasProp(slot, "keepAspect") && slot.keepAspect) ? 1 : 0)
            sectionText .= "`n" prefix "AspectRatio=" (HasProp(slot, "aspectRatio") && slot.aspectRatio > 0 ? slot.aspectRatio : (slot.height > 0 ? slot.width / slot.height : 1.0))
        }
        IniWrite(sectionText, CONFIG_FILE, section)
    }

    IniWrite(Layouts.Length, CONFIG_FILE, "Layouts", "Count")
    Loop 4
    {
        favoriteIndex := LayoutFavorites[A_Index]
        favoriteName := (favoriteIndex >= 1 && favoriteIndex <= Layouts.Length) ? Layouts[favoriteIndex].name : ""
        IniWrite(favoriteIndex, CONFIG_FILE, "Layouts", "Favorite" A_Index)
        IniWrite(favoriteName, CONFIG_FILE, "Layouts", "Favorite" A_Index "Name")
    }
    IniWrite(Settings["LastLayoutName"], CONFIG_FILE, "Settings", "LastLayoutName")
}

SaveConfig()
{
    global CONFIG_FILE, ActionNames, CurrentKeys, Settings
    global OutputActionNames, CurrentOutputKeys
    global SandboxieRowCount, SandboxieAccounts, MaxSandboxieRows, Layouts, AccountSwapKeys
    for action in ActionNames
        IniWrite(CurrentKeys[action], CONFIG_FILE, "Hotkeys", action)
    for action in OutputActionNames
        IniWrite(CurrentOutputKeys[action], CONFIG_FILE, "OutputKeys", action)

    IniWrite(Settings["ClickInterval"], CONFIG_FILE, "Settings", "ClickInterval")
    IniWrite(Settings["TrainSlowInterval"], CONFIG_FILE, "Settings", "TrainSlowInterval")
    IniWrite(Settings["DefaultClickX"], CONFIG_FILE, "Settings", "DefaultClickX")
    IniWrite(Settings["DefaultClickY"], CONFIG_FILE, "Settings", "DefaultClickY")

    IniDelete(CONFIG_FILE, "Settings", "AutoRename")
    IniWrite(Settings["MainAlwaysOnTop"] ? "1" : "0", CONFIG_FILE, "Settings", "MainAlwaysOnTop")
    IniWrite(Settings["ShowOverlay"] ? "1" : "0", CONFIG_FILE, "Settings", "ShowOverlay")
    IniWrite(Settings["ShowHotkeyTooltips"] ? "1" : "0", CONFIG_FILE, "Settings", "ShowHotkeyTooltips")
    IniWrite(Settings["ShowUiTooltips"] ? "1" : "0", CONFIG_FILE, "Settings", "ShowUiTooltips")
    IniWrite(Settings["MouseFocusOn"] ? "1" : "0", CONFIG_FILE, "Settings", "MouseFocusOn")
    IniWrite(Settings["AutoResetSlots"] ? "1" : "0", CONFIG_FILE, "Settings", "AutoResetSlots")
    IniWrite(Settings["ChangeOutputKeys"] ? "1" : "0", CONFIG_FILE, "Settings", "ChangeOutputKeys")
    IniWrite(Settings["SwapByAccount"] ? "1" : "0", CONFIG_FILE, "Settings", "SwapByAccount")
    IniWrite(Settings["HotkeysAlwaysOnTop"] ? "1" : "0", CONFIG_FILE, "Settings", "HotkeysAlwaysOnTop")
    IniWrite(Settings["SandboxieAlwaysOnTop"] ? "1" : "0", CONFIG_FILE, "Settings", "SandboxieAlwaysOnTop")
    IniWrite(Settings["LayoutEditorAlwaysOnTop"] ? "1" : "0", CONFIG_FILE, "Settings", "LayoutEditorAlwaysOnTop")
    IniWrite(Settings["LastLayoutName"], CONFIG_FILE, "Settings", "LastLayoutName")
    IniWrite(Settings["BannerSelection"], CONFIG_FILE, "Settings", "BannerSelection")
    IniWrite(Settings["SandboxieSandManExe"], CONFIG_FILE, "SandboxiePaths", "SandManExe")
    IniWrite(Settings["SandboxieSteamExe"], CONFIG_FILE, "SandboxiePaths", "SteamExe")
    IniWrite(Settings["SandboxieFoxholeExe"], CONFIG_FILE, "SandboxiePaths", "FoxholeExe")

    IniDelete(CONFIG_FILE, "AccountSwapHotkeys")
    for accountIndex, key in AccountSwapKeys
        if key != ""
            IniWrite(key, CONFIG_FILE, "AccountSwapHotkeys", "Slot" accountIndex)

    SaveLayoutsConfig()
    SaveWorkflowPresetsConfig()

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
    SetTimer(RestoreMainGuiAfterStartup, 0)
    SetTimer(MaintainTitleOverlays, 0)
    SetTimer(MonitorSandboxieSupporterPopup, 0)
    SetTimer(RotateMainTip, 0)
    StopLayoutPositionWatcher()
    StopFoxholeWindowWatcher()
    CloseSwitchSlotAccountMenu()
    CloseWindowSwapMenu()
    for hwnd, overlay in TitleOverlays
    {
        try overlay.gui.Destroy()
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
