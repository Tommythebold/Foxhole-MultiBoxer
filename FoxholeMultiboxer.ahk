#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2
Persistent

global FoxholeMultiboxerInstanceMutex := 0
for attempt in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
{
    FoxholeMultiboxerInstanceMutex := DllCall("Kernel32\CreateMutexW", "Ptr", 0, "Int", 0, "Str", "Local\Tommythebold_FoxholeMultiboxer_SingleInstance", "Ptr")
    if !FoxholeMultiboxerInstanceMutex
        break
    if A_LastError != 183
        break
    DllCall("Kernel32\CloseHandle", "Ptr", FoxholeMultiboxerInstanceMutex)
    FoxholeMultiboxerInstanceMutex := 0
    if oldWindow := WinExist("Foxhole Multiboxer ahk_class AutoHotkeyGUI")
        try WinClose("ahk_id " oldWindow)
    Sleep(350)
}
if !FoxholeMultiboxerInstanceMutex
{
    MsgBox("Could not close the previous Foxhole Multiboxer instance. Close it manually and retry.", "Foxhole Multiboxer", "Icon!")
    ExitApp()
}

;@Ahk2Exe-SetMainIcon Bin\FoxholeMultiBoxerIcon.ico

global MainScrollOffset := 0
global MainScrollBase := Map()
global MainScrollContentHeight := 0
global MainScrollViewportHeight := 0

global APP_NAME := "Foxhole Multiboxer"
global APP_VERSION := "1.1.0"
global APP_TITLE := APP_NAME " v" APP_VERSION
global CONFIG_DIR := A_AppData "\" APP_NAME
global CONFIG_FILE := CONFIG_DIR "\Settings.ini"
global GitHubLatestReleaseApi := "https://api.github.com/repos/Tommythebold/Foxhole-MultiBoxer/releases/latest"
global GitHubReleasesUrl := "https://github.com/Tommythebold/Foxhole-MultiBoxer/releases"
global LatestVersion := ""
global UpdateAvailable := false
global UpdateCheckComplete := false
global UpdateLinkControl := ""
global UpdateLinkVisible := false
global UpdateLinkShift := 24

global ActionNames := ["AutoClick", "AutoWalk", "AutoReverse", "ClickHold", "RightHold", "VSpam", "TrainSlow", "MouseFocus", "LastGame", "NextGame", "SwitchSlot", "Swap", "SwapFirst", "ShowFoxhole", "ShowSteam", "TogglePreviews"]
global ActionLabels := Map(
    "AutoClick", "Auto-Click",
    "AutoWalk", "Forward / W",
    "AutoReverse", "Reverse / S",
    "ClickHold", "Left Click Hold",
    "RightHold", "Right Click Hold",
    "VSpam", "V Spam",
    "TrainSlow", "Train Slow",
    "MouseFocus", "Mouse Focus",
    "LastGame", "Last Game",
    "NextGame", "Next Game",
    "SwitchSlot", "Switch Slot",
    "Swap", "Swap",
    "SwapFirst", "Swap to First",
    "ShowFoxhole", "Show Foxhole",
    "ShowSteam", "Show Steam",
    "TogglePreviews", "Toggle Previews"
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
    "LastGame", "",
    "NextGame", "",
    "SwitchSlot", "",
    "Swap", "",
    "SwapFirst", "",
    "ShowFoxhole", "",
    "ShowSteam", "",
    "TogglePreviews", ""
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
global GameHotkeysEnabledCheck := ""
global SwapByAccountCheck := ""
global BringSwapToFrontCheck := ""
global AccountSwapKeys := Map()
global AccountSwapButtons := Map()
global AccountSwapTargetLabels := Map()
global HotkeysExpandedSections := Map("Game", false, "Manage", false, "Swap", false)
global HotkeysSectionHeaders := Map()
global LayoutEditorContentInitialized := false

global PreviewSettingsGui := ""
global PreviewConfigs := Map()
global PreviewWindows := Map()
global PreviewEnableChecks := Map()
global PreviewOpacitySliders := Map()
global PreviewOpacityLabels := Map()
global PreviewOpacitySlider := ""
global PreviewOpacityLabel := ""
global PreviewSizeSlider := ""
global PreviewSizeLabel := ""
global PreviewShowActiveHotkeysCheck := ""
global PreviewHoverBringToFrontCheck := ""
global LastPreviewHoverFrontSlot := 0
global PreviewShowWhenUnfocusedCheck := ""
global PreviewHoverHotkeysCheck := ""
global PreviewAccountPickerGui := ""
global PreviewAccountPickerChecks := []
global PreviewAccountSummary := ""
global PreviewPositionOverlays := Map()
global IdentityShowSlotCheck := ""
global IdentityShowAccountCheck := ""
global PreviewIdentityPositionDropDown := ""
global PreviewIdentityHorizontalDropDown := ""
global PreviewIdentitySizeSlider := ""
global PreviewIdentitySizeLabel := ""
global GameIdentityShowCheck := ""
global GameIdentityVerticalDropDown := ""
global GameIdentityHorizontalDropDown := ""
global GameIdentitySizeSlider := ""
global GameIdentitySizeLabel := ""
global PreviewIdentityOverlays := Map()
global GameOverlayOffsets := Map()
global PreviewMasterVisibleCheck := ""
global PreviewEditModeCheck := ""
global PreviewResizeAllEqualCheck := ""
global PreviewMoveAllTogetherCheck := ""
global PreviewSnapTogetherCheck := ""
global PreviewLayouts := []
global PreviewLayoutDropDown := ""
global PreviewLinkedResizeBusy := false
global PreviewLinkedMoveBusy := false
global PreviewMoveStartPositions := Map()
global PreviewMoveAnchorSlot := 0
global PreviewMoveAnchorX := 0
global PreviewMoveAnchorY := 0
global PreviewSyncBusy := false
global PreviewSnapBusy := false
global PreviewDefaultWidth := 320
global PreviewDefaultHeight := 180
global PreviewUnsetCoordinate := 2147483647
global LayoutEditorNeedsRefresh := true
global UiTransitionInProgress := false

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
global FocusFlashCache := Map()
global FocusFlashActiveKey := ""
global MaxPracticalInstances := 32

global SandboxiePopupWatcherIntervalMs := 250
global SandboxiePopupLastHandledHwnd := 0
global SandboxiePopupLastHandledAt := 0
global CertifiedSandboxieSteamBoxes := Map()

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
global MainGuiFixedWidth := 559
global EmbeddedPageScrollOffsets := Map()
global EmbeddedPageContentHeights := Map()
global EmbeddedPageViewportHeights := Map()
global EmbeddedPageBasePositions := Map()
global HotkeysGui := ""
global LV := ""
global StatusText := ""
global MainTipText := ""
global MainTipIndex := 1
global MainDynamicControls := []
global MainLayoutBase := Map()
global MainLayoutBaseBannerVisible := false
global MainLayoutTableBaseY := 0
global MainLayoutTableBaseHeight := 200
global MainLayoutCurrentTableHeight := 200
global MainLayoutSummaryBaseY := 0
global MainLayoutSummaryBaseHeight := 22
global MainLayoutCurrentSummaryHeight := 22
global MainLayoutWorkflowEditorEndY := 0
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
global SandboxieSavedAccounts := Map()
global SandboxieSavedRowCount := 1
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
global CombinedSteamTimeoutMs := 900000
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
    "TrainSlow", 3400
)
global TrainSlowDefaultHoldDuration := 2000
global TrainSlowHoldDuration := 2000
global TrainSlowHoldEdit := ""
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
global LayoutEditorNoOverlapCheck := ""
global LayoutEditorSplitMonitorCombo := ""
global LayoutEditorSplitSlotsButton := ""
global LayoutEditorSplitCountCombo := ""
global LayoutEditorSplitSelectedSlots := []
global LayoutEditorSplitPickerGui := ""
global LayoutEditorSplitPickerChecks := []
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
global RegisteredHotkeyKeys := Map()
global PollKeyList := []
global ModifierKeyDefs := [
    { symbol: "^", keys: ["LControl", "RControl"] },
    { symbol: "+", keys: ["LShift", "RShift"] },
    { symbol: "!", keys: ["LAlt", "RAlt"] },
    { symbol: "#", keys: ["LWin", "RWin"] }
]

global MainNavButtons := Map()
global LogsGui := ""
global LogsEdit := ""
global LogHistory := []
global LogFile := ""
global LastLogMessage := ""
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
global WorkflowSequentialLoginCheck := ""
global WorkflowSequentialCountCombo := ""
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
global WorkflowBelowEditorBaseY := Map()
global WorkflowBelowEditorPositionExpanded := true
global WorkflowEditorCollapseHeight := 0
global SettingsSectionExpanded := false
global SettingsSectionHeader := ""
global SettingsSectionControls := []
global WorkflowPendingFoxholeAfterSteam := false
global SequentialLoginActive := false
global SequentialLoginAccounts := []
global SequentialLoginMaxOnline := 1
global SequentialLoginNextPosition := 1
global SequentialLoginRefillPending := false
global WorkflowStatusMessage := ""
global StatusOverlayGui := ""
global StatusOverlayText := ""
global ShowStatusOverlayCheck := ""
global FoxholeHiddenTaskbars := Map()
global FoxholeTaskbarMonitor := 0
global FocusFlashGui := ""
global FocusFlashSlotText := ""
global FocusFlashAccountText := ""
global FocusFlashStartedAt := 0
global FocusFlashDurationMs := 1000
global FocusFlashMemDC := 0
global FocusFlashBitmap := 0
global FocusFlashOldBitmap := 0
global FocusFlashX := 0
global FocusFlashY := 0
global FocusFlashW := 0
global FocusFlashH := 0
global LastFocusedFoxholeHwnd := 0
global RequestedFoxholeHwnd := 0
global RequestedFoxholeAt := 0
global FoxholeActivationGraceMs := 300
global CycleDesiredHwnd := 0
global CycleDesiredUntil := 0
global CycleDesiredDirection := 0
global CycleCursorHwnd := 0
global CycleCursorAt := 0
global CycleInputQueue := []
global CycleInputWorkerScheduled := false
global MouseFocusSwitchLock := false
global MouseFocusSwitchX := 0
global MouseFocusSwitchY := 0

global Settings := Map(
    "ClickInterval", 50,
    "TrainSlowInterval", 3400,
    "TrainSlowHoldDuration", 2000,
    "DefaultClickX", 0,
    "DefaultClickY", 0,
    "MainAlwaysOnTop", false,
    "ShowOverlay", true,
    "ShowStatusOverlay", true,
    "ShowHotkeyTooltips", true,
    "ShowUiTooltips", true,
    "MouseFocusOn", true,
    "AutoResetSlots", false,
    "ChangeOutputKeys", false,
    "GameHotkeysEnabled", true,
    "SwapByAccount", true,
    "BringSwapToFront", false,
    "PreviewsVisible", true,
    "PreviewEditMode", false,
    "PreviewResizeAllEqual", false,
    "PreviewMoveAllTogether", false,
    "PreviewSnapTogether", true,
    "PreviewHorizontalGap", 0,
    "PreviewVerticalGap", 0,
    "IdentityShowSlot", true,
    "IdentityShowAccount", true,
    "PreviewShowActiveHotkeys", true,
    "PreviewShowWhenFoxholeUnfocused", true,
    "PreviewHoverHotkeys", false,
    "PreviewHoverBringToFront", false,
    "PreviewIdentityPosition", "Top",
    "PreviewIdentityHorizontal", "Center",
    "PreviewIdentityTextSize", 16,
    "GameIdentityVertical", "Top",
    "GameIdentityHorizontal", "Left",
    "GameIdentityTextSize", 18,
    "MainGuiX", 2147483647,
    "MainGuiY", 2147483647,
    "FlashGameIdentity", false,
    "PreviewOpacity", 75,
    "HotkeysAlwaysOnTop", false,
    "SandboxieAlwaysOnTop", false,
    "SandboxieStartExe", "C:\Program Files\Sandboxie-Plus\Start.exe",
    "SandboxieSteamExe", "C:\Program Files (x86)\Steam\steam.exe",
    "SandboxieFoxholeExe", "",
    "LayoutEditorAlwaysOnTop", false,
    "LastLayoutName", "",
    "LastPreviewLayoutName", "",
    "BannerSelection", "Random"
)

if !DirExist(CONFIG_DIR)
    DirCreate(CONFIG_DIR)

BackupExistingConfigBeforeUpgrade()
PrepareBannerAssets()
SetApplicationIcon()
LoadConfig()
BuildMainGui()
SetMouseFocusEnabled(Settings["MouseFocusOn"], false)
ApplyAllHotkeys()
ScanWindows()
WarmFoxholeFocusIdentityCache()
MaybeAutoResetSlots()

if LayoutEditorSelectedLayout >= 1 && LayoutEditorSelectedLayout <= Layouts.Length
    ApplySelectedLayout(false)
InitializeFoxholeWindowWatcher()
InitializeLayoutPositionWatcher()

OnMessage(0x84, LayoutPreviewHitTest, -1)
OnMessage(0x84, FoxholePreviewHitTest, -1)
OnMessage(0x0005, FoxholePreviewSizeChanged, -1)
OnMessage(0x0202, FoxholePreviewLeftButtonUp, -1)
OnMessage(0x0231, FoxholePreviewEnterSizeMove, -1)
OnMessage(0x0232, FoxholePreviewExitSizeMove, -1)
OnMessage(0x0216, FoxholePreviewMoving, -1)
SetTimer(InitialWindowDiscovery, -1500)
SetTimer(RestoreMainGuiAfterStartup, -1900)
SetTimer(MaintainTitleOverlays, 350)
SetTimer(MaintainPreviewIdentityOverlays, 40)
SetTimer(MaintainPreviewFocusVisibility, 120)
SetTimer(MaintainPreviewHoverFront, 80)
SetTimer(MonitorFoxholeFocusIdentity, 35)
OnExit(CleanupAll)
EnsureWindowsTaskbarsVisible()
SetTimer(MaintainFoxholeTaskbarCover, 50)
SetTimer(WarmFoxholeFocusIdentityCache, 700)
SetTimer(UpdateStatusOverlay, 350)

SetTimer(MonitorSandboxieSupporterPopup, SandboxiePopupWatcherIntervalMs)
SetTimer(MonitorGuiTooltips, 80)
SetTimer(UpdateFloatingTooltips, 50)
SetTimer(CheckForUpdate, -1000)
SetTimer(RetryUpdateCheckIfNeeded, -6000)
SetTimer(CheckForUpdate, 1800000)

LayoutPreviewHitTest(wParam, lParam, msg, hwnd)
{
    global LayoutEditorOverlays

    if IsObject(LayoutEditorOverlays) && LayoutEditorOverlays.Has(hwnd)
        return -1
}

CheckForUpdate()
{
    global APP_VERSION, GitHubLatestReleaseApi, LatestVersion, UpdateAvailable, UpdateCheckComplete

    try
    {
        request := ComObject("WinHttp.WinHttpRequest.5.1")
        request.SetTimeouts(3000, 3000, 5000, 5000)
        cacheBustedUrl := GitHubLatestReleaseApi (InStr(GitHubLatestReleaseApi, "?") ? "&" : "?") "_=" A_TickCount
        request.Open("GET", cacheBustedUrl, false)
        request.SetRequestHeader("Accept", "application/vnd.github+json")
        request.SetRequestHeader("User-Agent", "Foxhole-Multiboxer/" APP_VERSION)
        request.SetRequestHeader("X-GitHub-Api-Version", "2022-11-28")
        request.SetRequestHeader("Cache-Control", "no-cache, no-store, must-revalidate")
        request.SetRequestHeader("Pragma", "no-cache")
        request.Send()

        if request.Status != 200
            return
        if !RegExMatch(request.ResponseText, '"tag_name"\s*:\s*"([^"]+)"', &tagMatch)
            return

        checkedVersion := NormalizeVersion(tagMatch[1])
        if checkedVersion = ""
            return

        LatestVersion := checkedVersion
        UpdateAvailable := IsVersionNewer(LatestVersion, APP_VERSION)
        UpdateCheckComplete := true
        ApplyUpdateState()
    }
    catch
    {
    }
}

RetryUpdateCheckIfNeeded()
{
    global UpdateCheckComplete
    if !UpdateCheckComplete
        CheckForUpdate()
}

ApplyUpdateState()
{
    global MainGui, UpdateAvailable, UpdateLinkControl, LatestVersion, GitHubReleasesUrl
    if !IsObject(MainGui) || !MainGui.Hwnd || !IsObject(UpdateLinkControl)
        return

    if UpdateAvailable
    {
        label := LatestVersion != "" ? "Update Available — v" LatestVersion : "Update Available"
        try UpdateLinkControl.Text := '<a href="' GitHubReleasesUrl '">' label '</a>'
    }
    SetUpdateLinkVisibility(UpdateAvailable)
}

SetUpdateLinkVisibility(visible)
{
    global MainGui, UpdateLinkControl, UpdateLinkVisible

    visible := visible ? true : false
    if !IsObject(MainGui) || !MainGui.Hwnd || !IsObject(UpdateLinkControl) || visible = UpdateLinkVisible
        return

    SetGuiRedraw(MainGui, false)
    try
    {
        UpdateLinkVisible := visible
        UpdateLinkControl.Visible := visible
        ReflowMainPageLayout()
        ReflowCurrentPageAfterBannerChange()
        KeepMainGuiInsideWorkArea()
    }
    finally
    {
        SetGuiRedraw(MainGui, true)
        try DllCall("RedrawWindow", "Ptr", MainGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0085)
    }
}

NormalizeVersion(versionText)
{
    versionText := Trim(versionText)
    versionText := RegExReplace(versionText, "i)^v")
    if !RegExMatch(versionText, "^\d+(?:\.\d+)*", &versionMatch)
        return ""
    return versionMatch[0]
}

IsVersionNewer(candidateVersion, currentVersion)
{
    candidateParts := StrSplit(candidateVersion, ".")
    currentParts := StrSplit(currentVersion, ".")
    partCount := Max(candidateParts.Length, currentParts.Length)

    Loop partCount
    {
        candidatePart := A_Index <= candidateParts.Length ? Integer(candidateParts[A_Index]) : 0
        currentPart := A_Index <= currentParts.Length ? Integer(currentParts[A_Index]) : 0
        if candidatePart > currentPart
            return true
        if candidatePart < currentPart
            return false
    }
    return false
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

ClearGuiTooltipsForGui(guiObj)
{
    global GuiTooltips, GuiLastTooltipHwnd
    if !IsObject(guiObj) || !guiObj.Hwnd
        return
    try
    {
        for hwnd in WinGetControlsHwnd("ahk_id " guiObj.Hwnd)
        {
            if GuiTooltips.Has(hwnd)
                GuiTooltips.Delete(hwnd)
            if GuiLastTooltipHwnd = hwnd
            {
                ToolTip("", , , 20)
                GuiLastTooltipHwnd := 0
            }
        }
    }
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
    global GuiTooltips, GuiLastTooltipHwnd, Settings, UiTransitionInProgress

    if UiTransitionInProgress
        return

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


UpdateFloatingTooltips(*)
{
    static tooltipClass := "ahk_class tooltips_class32 ahk_pid " DllCall("GetCurrentProcessId", "UInt")
    try
    {
        for hwnd in WinGetList(tooltipClass)
        {
            if !DllCall("IsWindowVisible", "Ptr", hwnd)
                continue
            exStyle := DllCall("GetWindowLongPtr", "Ptr", hwnd, "Int", -20, "Ptr")
            if !(exStyle & 0x20) || !(exStyle & 0x08000000)
                DllCall("SetWindowLongPtr", "Ptr", hwnd, "Int", -20, "Ptr", exStyle | 0x20 | 0x08000000, "Ptr")
        }
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
        "AutoWalk", "Toggle holding the configured Forward output key. The key-down is refreshed every 50 ms, matching the standalone autoclicker.",
        "AutoReverse", "Toggle holding the configured Reverse output key. The key-down is refreshed every 50 ms, matching the standalone autoclicker.",
        "ClickHold", "Toggle holding the left mouse button. The button-down is refreshed every 50 ms, matching the standalone autoclicker.",
        "RightHold", "Toggle holding the right mouse button. The button-down is refreshed every 200 ms, matching the standalone autoclicker.",
        "VSpam", "Toggle repeated presses of the configured Submit Large Item output key every 50 ms.",
        "TrainSlow", "Periodically holds the configured Train Slow output key. Shift+Scroll changes the global interval; Alt+Scroll changes the global hold duration. Both values apply to every account.",
        "MouseFocus", "Toggle mouse-hover focus mode for controlled Foxhole windows.",
        "LastGame", "Instantly bring the previous open Foxhole slot to the foreground. Cycling starts from whichever Foxhole window is currently focused and skips closed slots.",
        "NextGame", "Instantly bring the next open Foxhole slot to the foreground. Cycling starts from whichever Foxhole window is currently focused and skips closed slots.",
        "SwitchSlot", "Assign the focused Foxhole window to another numbered slot without moving it.",
        "Swap", "Swap positions and sizes with another Foxhole window without changing slot assignments.",
        "SwapFirst", "Swap the focused Foxhole window with the window currently occupying the first layout position.",
        "ShowFoxhole", "Toggle all open Foxhole game windows between minimized and maximized. The first press minimizes them.",
        "ShowSteam", "Toggle Steam windows for all Included accounts between closed-to-tray and restored. Steam windows are restored without being maximized.",
        "TogglePreviews", "Show or hide all enabled Foxhole preview windows without changing their saved positions or per-slot settings."
    )
    text := "Current key: " DisplayNameForHotkeyString(CurrentKeys[action]) "`nClick to rebind.`n" descriptions[action]
    if IntervalSettings.Has(action)
    {
        if action = "TrainSlow"
            text .= "`nTrain Slow timing is global for all accounts. Shift+Scroll adjusts interval; Alt+Scroll adjusts hold duration while Train Slow is active."
        else
            text .= "`nInterval is saved separately for each account. Use Shift+Scroll while this action is active."
    }
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
    if action = "TrainSlow"
        return "Delay between Train Slow pulses: " current " ms.`nRange: 10-5000 ms. This value is shared by every account.`nShift+Scroll adjusts it while Train Slow is active; Alt+Scroll adjusts hold duration."
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
        return account.main ? "Launch normal unsandboxed Steam for " display ".`nIf already open, it will not be brought forward." : "Launch Steam inside sandbox '" display "' using Start.exe.`nCredentials saved: " ((account.steamUsername != "" && name != "" && GetSteamCredentialPassword(name) != "") ? "Yes" : "No")
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
    global MainGui, BannerPicture, BannerVisible

    visible := visible ? true : false
    if visible = BannerVisible || !IsObject(BannerPicture)
        return

    SetGuiRedraw(MainGui, false)
    try
    {
        BannerVisible := visible
        BannerPicture.Visible := visible
        ReflowMainPageLayout()
        ReflowCurrentPageAfterBannerChange()
    }
    finally
    {
        SetGuiRedraw(MainGui, true)
        try DllCall("RedrawWindow", "Ptr", MainGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0085)
    }
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
    global UpdateLinkControl, UpdateLinkVisible, GitHubReleasesUrl
    global WorkflowFavoriteButtons, WorkflowPresetCombo, WorkflowFavoriteSlotCombo
    global LayoutFavoriteButtons
    global WorkflowResetFoxholeCheck, WorkflowLaunchFoxholeCheck, WorkflowResetSteamCheck, WorkflowLaunchSteamCheck
    global WorkflowResetSandboxesCheck, WorkflowVerifySandboxesCheck, WorkflowSequentialLoginCheck, WorkflowSequentialCountCombo, WorkflowAccountSummary, WorkflowSequenceText
    global WorkflowRunButton, WorkflowStopButton
    global WorkflowEditorExpanded, WorkflowEditorHeader, WorkflowEditorControls, WorkflowBelowEditorControls, WorkflowBelowEditorBaseY, WorkflowEditorCollapseHeight
    global SettingsSectionExpanded, SettingsSectionHeader, SettingsSectionControls, ShowStatusOverlayCheck

    LogEvent("Application interface initializing (" APP_VERSION ")")
    MainGui := Gui("+0x02000000", APP_TITLE)
    MainGui.SetFont("s9", "Segoe UI")
    SetGuiIcon(MainGui)
    OnMessage(0x020A, EmbeddedPageMouseWheel)
    OnMessage(0x0115, EmbeddedPageVerticalScroll)
    OnMessage(0x0021, MainGuiMouseActivate)
    OnMessage(0x0201, MainNavMouseDown)

    contentW := 535
    navY := 8
    navDefs := [["Main", 12, 63], ["Accounts", 79, 88], ["Hotkeys", 171, 72], ["Layouts", 247, 72], ["Previews", 323, 94]]
    MainNavButtons := Map()
    for def in navDefs
    {
        btn := MainGui.AddButton("x" def[2] " y" navY " w" def[3] " h28", def[1])
        btn.OnEvent("Click", SwitchMainPage.Bind(def[1]))
        MainNavButtons[def[1]] := btn
    }
    logsBtn := RegisterTooltip(MainGui.AddButton("x421 y8 w35 h28", "≡"), "Show timestamped application and workflow logs. Logs are also saved to disk.")
    logsBtn.OnEvent("Click", OpenLogWindow)
    sandboxManagerBtn := RegisterTooltip(MainGui.AddButton("x460 y8 w35 h28", "▣"), "Open the Sandboxie Plus management window (SandMan.exe).")
    sandboxManagerBtn.OnEvent("Click", OpenSandboxieManager)
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
    UpdateLinkControl := MainGui.Add("Link", "x12 y" tipY " w" contentW " h20 Center", '<a href="' GitHubReleasesUrl '">Update Available</a>')
    UpdateLinkControl.SetFont("s9 Bold", "Segoe UI")
    RegisterTooltip(UpdateLinkControl, "A newer Foxhole Multiboxer release is available. Open the GitHub releases page.")
    UpdateLinkVisible := false
    UpdateLinkControl.Visible := false
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
    WorkflowSequentialLoginCheck := MainGui.AddCheckBox("x252 y" y " w145 h24", "Sequential Login?")
    WorkflowSequentialLoginCheck.OnEvent("Click", WorkflowSequentialLoginChanged)
    WorkflowSequentialCountCombo := MainGui.AddDropDownList("x405 y" (y-1) " w52 r10", ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"])
    WorkflowSequentialCountCombo.Choose(1)
    WorkflowSequentialCountCombo.OnEvent("Change", UpdateWorkflowSequencePreview)
    MainGui.AddText("x463 y" (y+3) " w72 h22", "at once")
    RegisterTooltip(WorkflowSequentialLoginCheck, "Continuously keep the chosen number of workflow accounts in Foxhole. When one closes, the next included account launches in account-row order, then the sequence loops.")
    RegisterTooltip(WorkflowSequentialCountCombo, "Maximum number of included workflow accounts kept online at the same time.")
    y += 28
    MainGui.AddText("x12 y" y " w92 h24", "Steam")
    WorkflowResetSteamCheck := MainGui.AddCheckBox("x132 y" y " w25 h24")
    WorkflowLaunchSteamCheck := MainGui.AddCheckBox("x194 y" y " w25 h24")
    y += 28
    MainGui.AddText("x12 y" y " w92 h24", "Sandboxes")
    WorkflowResetSandboxesCheck := MainGui.AddCheckBox("x132 y" y " w25 h24")
    WorkflowVerifySandboxesCheck := MainGui.AddCheckBox("x194 y" y " w25 h24")
    for ctrl in [WorkflowResetFoxholeCheck, WorkflowLaunchFoxholeCheck, WorkflowResetSteamCheck, WorkflowLaunchSteamCheck, WorkflowResetSandboxesCheck, WorkflowVerifySandboxesCheck]
        ctrl.OnEvent("Click", WorkflowOperationCheckboxChanged)
    RegisterTooltip(WorkflowLaunchSteamCheck, "Steam launch can be started, but successful sign-in and readiness cannot be guaranteed. It cannot be followed by Foxhole launch in one workflow.")
    RegisterTooltip(WorkflowResetSteamCheck, "Steam is told to close; the close step does not verify that every account finished shutting down.")
    RegisterTooltip(WorkflowResetFoxholeCheck, "Foxhole windows are asked to close; this step does not verify full process exit.")

    y += 34
    WorkflowSequenceText := MainGui.AddText("x12 y" y " w315 h30 +Wrap +0x200", "Next run: No operations selected.")
    WorkflowRunButton := MainGui.AddButton("x337 y" y " w110 h28 Default", "Run Workflow")
    WorkflowRunButton.OnEvent("Click", RunSelectedWorkflow)
    WorkflowStopButton := MainGui.AddButton("x457 y" y " w80 h28", "Stop")
    WorkflowStopButton.Enabled := false
    WorkflowStopButton.OnEvent("Click", StopWorkflow)
    UpdateWorkflowSequencePreview()

    y += 40
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
    ShowStatusOverlayCheck := MainGui.AddCheckBox("x273 y" y " w132 h24", "Status Overlay?")
    ShowStatusOverlayCheck.Value := Settings["ShowStatusOverlay"] ? 1 : 0
    ShowStatusOverlayCheck.OnEvent("Click", ShowStatusOverlayChanged)
    ShowUiTooltipsCheck := MainGui.AddCheckBox("x410 y" y " w127 h24", "UI Tooltips?")
    ShowUiTooltipsCheck.Value := Settings["ShowUiTooltips"] ? 1 : 0
    ShowUiTooltipsCheck.OnEvent("Click", ShowUiTooltipsChanged)

    y += 26
    MouseFocusCheck := MainGui.AddCheckBox("x12 y" y " w160 h24", "Mouse Focus On?")
    MouseFocusCheck.Value := Settings["MouseFocusOn"] ? 1 : 0
    MouseFocusCheck.OnEvent("Click", MouseFocusSettingChanged)
    ShowTooltipsCheck := MainGui.AddCheckBox("x180 y" y " w125 h24", "Hotkey Tooltips?")
    ShowTooltipsCheck.Value := Settings["ShowHotkeyTooltips"] ? 1 : 0
    ShowTooltipsCheck.OnEvent("Click", ShowHotkeyTooltipsChanged)
    FlashGameIdentityCheck := MainGui.AddCheckBox("x315 y" y " w222 h24", "Flash Slot / Account on Switch?")
    FlashGameIdentityCheck.Value := Settings["FlashGameIdentity"] ? 1 : 0
    FlashGameIdentityCheck.OnEvent("Click", FlashGameIdentityChanged)
    RegisterTooltip(FlashGameIdentityCheck, "Briefly shows the slot number and account name in the center of a Foxhole window whenever that game becomes foreground.")
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

    WorkflowBelowEditorBaseY := Map()
    for ctrl in WorkflowBelowEditorControls
    {
        try
        {
            ctrl.GetPos(&workflowCtrlX, &workflowCtrlY, &workflowCtrlW, &workflowCtrlH)
            WorkflowBelowEditorBaseY[ctrl.Hwnd] := workflowCtrlY
        }
    }

    CaptureMainPageBaseLayout(workflowEditorEndY)

    if !WorkflowEditorExpanded
    {
        for ctrl in WorkflowEditorControls
            ctrl.Visible := false
        PositionWorkflowBelowControls(false)
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
        if isNavigation || ctrl.Hwnd = settingsBtn.Hwnd || ctrl.Hwnd = logsBtn.Hwnd || ctrl.Hwnd = sandboxManagerBtn.Hwnd || (IsObject(BannerPicture) && ctrl.Hwnd = BannerPicture.Hwnd) || (IsObject(UpdateLinkControl) && ctrl.Hwnd = UpdateLinkControl.Hwnd) || (IsObject(MainTipText) && ctrl.Hwnd = MainTipText.Hwnd)
            continue

        MainPageControls.Push(ctrl)
        try ctrl.Opt("+0x04000000")
        try
        {
            ctrl.GetPos(&ctrlX, &ctrlY, &ctrlW, &ctrlH)
            if ctrlY > tableY + 200
                MainDynamicControls.Push(ctrl)
        }
    }
    MainVisibleTableRows := 0
    ReflowMainPageLayout()

    MainGui.OnEvent("Close", (*) => ExitApp())
    MainGui.OnEvent("Escape", (*) => ExitApp())
    MainGui.OnEvent("Size", MainGuiResize)

    BuildHotkeysGui()
    BuildSBGui()
    BuildLayoutEditorGui()
    BuildPreviewSettingsGui()
    RefreshWorkflowPresetControls()
    RefreshLayoutFavoriteControls()
    UpdateWorkflowAccountSummary()
    UpdateWorkflowSequencePreview()
    if Settings["MainGuiX"] != 2147483647 && Settings["MainGuiY"] != 2147483647
        MainGui.Show("x" Settings["MainGuiX"] " y" Settings["MainGuiY"] " w559 h" Min(740, GetMainPageRequiredHeight()))
    else
        MainGui.Show("w559 h" Min(740, GetMainPageRequiredHeight()))
    ResizeMainGuiToContentHeight(GetMainPageRequiredHeight())
    ApplyGuiAlwaysOnTop(MainGui, Settings["MainAlwaysOnTop"])
    SwitchMainPage("Main")
}

SaveMainGuiPosition()
{
    global MainGui, Settings
    if !IsObject(MainGui) || !MainGui.Hwnd
        return
    try
    {
        WinGetPos(&x, &y, , , "ahk_id " MainGui.Hwnd)
        Settings["MainGuiX"] := x
        Settings["MainGuiY"] := y
        SaveConfig()
    }
}

CaptureMainPageBaseLayout(workflowEditorEndY)
{
    global MainGui, MainLayoutBase, MainLayoutBaseBannerVisible, BannerVisible
    global LV, WorkflowAccountSummary
    global MainLayoutTableBaseY, MainLayoutTableBaseHeight, MainLayoutCurrentTableHeight
    global MainLayoutSummaryBaseY, MainLayoutSummaryBaseHeight, MainLayoutCurrentSummaryHeight
    global MainLayoutWorkflowEditorEndY

    MainLayoutBase := Map()
    for ctrlHwnd, ctrl in MainGui
    {
        if !IsObject(ctrl) || !ctrl.Hwnd
            continue
        try
        {
            ctrl.GetPos(&x, &y, &w, &h)
            MainLayoutBase[ctrl.Hwnd] := {x:x, y:y, w:w, h:h}
        }
    }

    MainLayoutBaseBannerVisible := BannerVisible
    if IsObject(LV) && LV.Hwnd && MainLayoutBase.Has(LV.Hwnd)
    {
        rec := MainLayoutBase[LV.Hwnd]
        MainLayoutTableBaseY := rec.y
        MainLayoutTableBaseHeight := rec.h
        MainLayoutCurrentTableHeight := rec.h
    }
    if IsObject(WorkflowAccountSummary) && WorkflowAccountSummary.Hwnd && MainLayoutBase.Has(WorkflowAccountSummary.Hwnd)
    {
        rec := MainLayoutBase[WorkflowAccountSummary.Hwnd]
        MainLayoutSummaryBaseY := rec.y
        MainLayoutSummaryBaseHeight := rec.h
        MainLayoutCurrentSummaryHeight := rec.h
    }
    MainLayoutWorkflowEditorEndY := workflowEditorEndY
}

ReflowMainPageLayout()
{
    global MainGui, MainLayoutBase, MainLayoutBaseBannerVisible, BannerVisible
    global UpdateLinkVisible, UpdateLinkShift, UpdateLinkControl, BannerPicture
    global MainNavButtons, LV, WorkflowAccountSummary
    global MainLayoutTableBaseY, MainLayoutTableBaseHeight, MainLayoutCurrentTableHeight
    global MainLayoutSummaryBaseY, MainLayoutSummaryBaseHeight, MainLayoutCurrentSummaryHeight
    global MainLayoutWorkflowEditorEndY, WorkflowEditorExpanded, WorkflowEditorCollapseHeight
    global MainScrollOffset, CurrentMainPage

    if !IsObject(MainGui) || !MainGui.Hwnd || MainLayoutBase.Count = 0
        return
    if MainScrollOffset
        SetMainPageScroll(0)

    bannerDelta := (BannerVisible ? 187 : 0) - (MainLayoutBaseBannerVisible ? 187 : 0)
    updateDelta := UpdateLinkVisible ? UpdateLinkShift : 0
    tableDelta := MainLayoutCurrentTableHeight - MainLayoutTableBaseHeight
    summaryDelta := MainLayoutCurrentSummaryHeight - MainLayoutSummaryBaseHeight
    workflowDelta := WorkflowEditorExpanded ? 0 : -WorkflowEditorCollapseHeight
    baseTableBottom := MainLayoutTableBaseY + MainLayoutTableBaseHeight

    navHwnds := Map()
    for name, btn in MainNavButtons
        if IsObject(btn) && btn.Hwnd
            navHwnds[btn.Hwnd] := true

    for ctrlHwnd, ctrl in MainGui
    {
        if !IsObject(ctrl) || !ctrl.Hwnd || !MainLayoutBase.Has(ctrl.Hwnd)
            continue
        rec := MainLayoutBase[ctrl.Hwnd]

        if navHwnds.Has(ctrl.Hwnd) || (IsObject(BannerPicture) && ctrl.Hwnd = BannerPicture.Hwnd) || rec.y < 40
            continue

        targetY := rec.y + bannerDelta
        if IsObject(UpdateLinkControl) && ctrl.Hwnd = UpdateLinkControl.Hwnd
        {
            ctrl.Move(, targetY)
            continue
        }

        targetY += updateDelta
        if rec.y > baseTableBottom
            targetY += tableDelta
        if rec.y > MainLayoutSummaryBaseY
            targetY += summaryDelta
        if rec.y >= MainLayoutWorkflowEditorEndY
            targetY += workflowDelta

        if IsObject(LV) && ctrl.Hwnd = LV.Hwnd
            ctrl.Move(, targetY, , MainLayoutCurrentTableHeight)
        else if IsObject(WorkflowAccountSummary) && ctrl.Hwnd = WorkflowAccountSummary.Hwnd
            ctrl.Move(, targetY, , MainLayoutCurrentSummaryHeight)
        else
            ctrl.Move(, targetY)
    }
    if CurrentMainPage = "Main"
        ClipMainPageScrollControls(MainScrollOffset)
}

ToggleWorkflowEditorSection(*)
{
    global WorkflowEditorExpanded, WorkflowEditorHeader, WorkflowEditorControls
    global MainGui, CurrentMainPage

    if !IsObject(WorkflowEditorHeader) || !WorkflowEditorHeader.Hwnd
        return

    SetGuiRedraw(MainGui, false)
    WorkflowEditorExpanded := !WorkflowEditorExpanded
    PositionWorkflowBelowControls(WorkflowEditorExpanded)

    if WorkflowEditorExpanded
    {
        for ctrl in WorkflowEditorControls
            try ctrl.Visible := CurrentMainPage = "Main"
    }
    else
    {
        for ctrl in WorkflowEditorControls
            try ctrl.Visible := false
    }

    WorkflowEditorHeader.Text := (WorkflowEditorExpanded ? "▼  " : "▶  ") "EDIT WORKFLOWS"
    if CurrentMainPage = "Main"
        ResizeMainGuiToContentHeight(GetMainPageRequiredHeight())
    SetGuiRedraw(MainGui, true)
    DllCall("RedrawWindow", "Ptr", MainGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0085)
}

PositionWorkflowBelowControls(expanded)
{
    global WorkflowBelowEditorPositionExpanded
    WorkflowBelowEditorPositionExpanded := expanded ? true : false
    ReflowMainPageLayout()
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
        ResizeMainGuiToContentHeight(GetMainPageRequiredHeight())
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
    global MainGui, LV, MainVisibleTableRows, MainResizePendingRows, MainLayoutCurrentTableHeight, CurrentMainPage

    if CurrentMainPage != "Main"
        return
    if !IsObject(MainGui) || !MainGui.Hwnd || !IsObject(LV) || !LV.Hwnd
        return

    visibleRows := MainResizePendingRows
    if visibleRows < 1 || visibleRows = MainVisibleTableRows
        return

    newTableH := GetListViewHeightForRows(LV, visibleRows)
    if newTableH < 1
        return

    SetGuiRedraw(MainGui, false)
    try
    {
        MainLayoutCurrentTableHeight := newTableH
        MainVisibleTableRows := visibleRows
        ReflowMainPageLayout()
        ResizeMainGuiToContentHeight(GetMainPageRequiredHeight())
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
            if !TryGetWindowRectSafe(inst.hwnd, &x, &y, &w, &h)
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

TryGetWindowRectSafe(hwnd, &x, &y, &w, &h)
{
    x := 0, y := 0, w := 0, h := 0
    if !hwnd
        return false

    if !DllCall("IsWindow", "Ptr", hwnd, "Int")
        return false

    rect := Buffer(16, 0)
    if !DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rect.Ptr, "Int")
        return false

    left := NumGet(rect, 0, "Int")
    top := NumGet(rect, 4, "Int")
    right := NumGet(rect, 8, "Int")
    bottom := NumGet(rect, 12, "Int")
    width := right - left
    height := bottom - top
    if width <= 0 || height <= 0
        return false

    if !DllCall("IsWindow", "Ptr", hwnd, "Int")
        return false

    x := left, y := top, w := width, h := height
    return true
}

CaptureFoxholeWindowPositions()
{
    global Instances
    positions := Map()
    for _, inst in Instances
    {
        try
        {
            hwnd := inst.hwnd
            if TryGetWindowRectSafe(hwnd, &x, &y, &w, &h)
                positions[hwnd] := {x: x, y: y, w: w, h: h}
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
    global LayoutEditorGui, LayoutEditorCombo, LayoutEditorFavoriteSlotCombo, LayoutEditorNoOverlapCheck, MainGui
    global LayoutEditorSplitMonitorCombo, LayoutEditorSplitSlotsButton, LayoutEditorSplitCountCombo

    LayoutEditorGui := Gui("+Parent" MainGui.Hwnd " -Caption -Border +0x04000000", "Layout Editor")
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

    allPreviewBtn := RegisterTooltip(LayoutEditorGui.AddButton("x68 y66 w80 h25", "Preview"), (*) => LayoutManagerTooltip("Preview"))
    allPreviewBtn.OnEvent("Click", ToggleAllLayoutPreviews)
    LayoutEditorGui.AddText("x156 y70 w55 h20 +Right", "Favorite:")
    LayoutEditorFavoriteSlotCombo := LayoutEditorGui.AddDropDownList("x216 y66 w128 r5", ["Not Favorite", "Favorite 1", "Favorite 2", "Favorite 3", "Favorite 4"])
    LayoutEditorFavoriteSlotCombo.OnEvent("Change", LayoutFavoriteSlotChanged)
    RegisterTooltip(LayoutEditorFavoriteSlotCombo, "Assign the selected saved layout to one of the four favorite buttons on the Main page.")
    LayoutEditorNoOverlapCheck := LayoutEditorGui.AddCheckBox("x352 y66 w100 h25", "No Overlap?")
    LayoutEditorNoOverlapCheck.Value := 0
    RegisterTooltip(LayoutEditorNoOverlapCheck, "When enabled, X and Y moves stop at the nearest slot on the same monitor instead of overlapping or passing through it.")

    LayoutEditorGui.AddText("x12 y100 w48 h24 +0x200", "Split:")
    LayoutEditorSplitMonitorCombo := LayoutEditorGui.AddDropDownList("x61 y98 w105 r5", GetMonitorDisplayNames())
    LayoutEditorSplitMonitorCombo.Value := MonitorGetPrimary()
    RegisterTooltip(LayoutEditorSplitMonitorCombo, "Monitor to fill with evenly sized horizontal slot columns.")
    LayoutEditorGui.AddText("x173 y100 w36 h24 +0x200", "Slots:")
    LayoutEditorSplitSlotsButton := LayoutEditorGui.AddButton("x210 y98 w105 h24", "Choose Slots")
    LayoutEditorSplitSlotsButton.OnEvent("Click", ShowLayoutSplitSlotPicker)
    RegisterTooltip(LayoutEditorSplitSlotsButton, "Choose layout slots with checkboxes. No typing is required.")
    LayoutEditorGui.AddText("x322 y100 w38 h24 +0x200", "Count:")
    splitCounts := []
    Loop 32
        splitCounts.Push(String(A_Index))
    LayoutEditorSplitCountCombo := LayoutEditorGui.AddDropDownList("x361 y98 w65 r10", splitCounts)
    LayoutEditorSplitCountCombo.Value := 4
    RegisterTooltip(LayoutEditorSplitCountCombo, "How many of the selected slots to split evenly across the monitor.")
    splitApplyBtn := LayoutEditorGui.AddButton("x433 y98 w104 h24", "Apply Split")
    splitApplyBtn.OnEvent("Click", ApplyLayoutMonitorSplit)
    RegisterTooltip(splitApplyBtn, "Arrange the first selected slots in a balanced playable grid across the chosen monitor.")

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
    global LayoutEditorContentInitialized, LayoutEditorNeedsRefresh

    if !IsObject(LayoutEditorGui)
        BuildLayoutEditorGui()

    EnsureLastSelectedLayout()
    ResetEmbeddedPageScroll(LayoutEditorGui)
    SetGuiRedraw(LayoutEditorGui, false)
    DestroyLayoutEditorRows()
    ForgetEmbeddedPageGeometry(LayoutEditorGui)
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
    LayoutEditorContentInitialized := true
    LayoutEditorNeedsRefresh := false
    SetGuiRedraw(LayoutEditorGui, true)
}

SetGuiRedraw(guiObj, enabled)
{
    ; WM_SETREDRAW changes WS_VISIBLE. Keep hidden pages hidden, including
    ; nested redraw suspensions during page switches and layout rebuilds.
    static suspended := Map()
    if !IsObject(guiObj) || !guiObj.Hwnd
        return
    hwnd := guiObj.Hwnd
    if !enabled
    {
        if suspended.Has(hwnd)
        {
            suspended[hwnd].depth += 1
            return
        }
        visible := !!(DllCall("GetWindowLong", "Ptr", hwnd, "Int", -16, "Int") & 0x10000000)
        suspended[hwnd] := {depth: 1, visible: visible}
        DllCall("SendMessage", "Ptr", hwnd, "UInt", 0x000B, "Ptr", 0, "Ptr", 0)
        return
    }
    if !suspended.Has(hwnd)
        return
    rec := suspended[hwnd]
    rec.depth -= 1
    if rec.depth > 0
        return
    suspended.Delete(hwnd)
    DllCall("SendMessage", "Ptr", hwnd, "UInt", 0x000B, "Ptr", 1, "Ptr", 0)
    if !rec.visible
        guiObj.Hide()
    DllCall("RedrawWindow", "Ptr", hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0485)
}

AddUiSectionHeading(guiObj, title, y)
{
    guiObj.SetFont("s9 Bold", "Segoe UI")
    guiObj.AddText("x12 y" y " w499 h22 +0x200", title)
    guiObj.SetFont("s9 Norm", "Segoe UI")
}

DisposeEmbeddedPage(guiObj)
{
    if !GetGuiHwndSafe(guiObj)
        return
    ClearGuiTooltipsForGui(guiObj)
    ForgetEmbeddedPageGeometry(guiObj)
    guiObj.Destroy()
}

ForgetEmbeddedPageGeometry(guiObj)
{
    global EmbeddedPageBasePositions, EmbeddedPageScrollOffsets, EmbeddedPageContentHeights, EmbeddedPageViewportHeights
    hwnd := guiObj.Hwnd
    for cache in [EmbeddedPageBasePositions, EmbeddedPageScrollOffsets, EmbeddedPageContentHeights, EmbeddedPageViewportHeights]
        if cache.Has(hwnd)
            cache.Delete(hwnd)
}

UpdateEmbeddedPageScrollBar(guiObj)
{
    global EmbeddedPageContentHeights, EmbeddedPageViewportHeights, EmbeddedPageScrollOffsets
    hwnd := guiObj.Hwnd
    if !EmbeddedPageContentHeights.Has(hwnd) || !EmbeddedPageViewportHeights.Has(hwnd)
        return
    content := EmbeddedPageContentHeights[hwnd], viewport := EmbeddedPageViewportHeights[hwnd]
    DllCall("ShowScrollBar", "Ptr", hwnd, "Int", 1, "Int", content > viewport)
    info := Buffer(28, 0)
    NumPut("UInt", 28, "UInt", 7, "Int", 0, "Int", Max(0, content - 1), "UInt", viewport,
        "Int", EmbeddedPageScrollOffsets.Has(hwnd) ? EmbeddedPageScrollOffsets[hwnd] : 0, info)
    DllCall("SetScrollInfo", "Ptr", hwnd, "Int", 1, "Ptr", info, "Int", true)
}

EmbeddedPageVerticalScroll(wParam, lParam, msg, hwnd)
{
    global MainGui, CurrentMainPage, MainScrollOffset, MainScrollContentHeight, MainScrollViewportHeight
    if IsObject(MainGui) && hwnd = MainGui.Hwnd && CurrentMainPage = "Main"
    {
        code := wParam & 0xFFFF
        if code = 0
            SetMainPageScroll(MainScrollOffset - 42)
        else if code = 1
            SetMainPageScroll(MainScrollOffset + 42)
        else if code = 2
            SetMainPageScroll(MainScrollOffset - MainScrollViewportHeight)
        else if code = 3
            SetMainPageScroll(MainScrollOffset + MainScrollViewportHeight)
        else if code = 4 || code = 5
            SetMainPageScroll((wParam >> 16) & 0xFFFF)
        return 0
    }
    global SBGui, HotkeysGui, LayoutEditorGui, PreviewSettingsGui
    global EmbeddedPageScrollOffsets, EmbeddedPageViewportHeights, EmbeddedPageContentHeights
    if lParam
        return
    for pageGui in [SBGui, HotkeysGui, LayoutEditorGui, PreviewSettingsGui]
    {
        if !IsObject(pageGui) || pageGui.Hwnd != hwnd || !EmbeddedPageViewportHeights.Has(hwnd)
            continue
        offset := EmbeddedPageScrollOffsets.Has(hwnd) ? EmbeddedPageScrollOffsets[hwnd] : 0
        code := wParam & 0xFFFF
        switch code
        {
            case 0: offset -= 34
            case 1: offset += 34
            case 2: offset -= EmbeddedPageViewportHeights[hwnd]
            case 3: offset += EmbeddedPageViewportHeights[hwnd]
            case 4, 5:
                info := Buffer(28, 0)
                NumPut("UInt", 28, "UInt", 0x10, info)
                DllCall("GetScrollInfo", "Ptr", hwnd, "Int", 1, "Ptr", info)
                offset := NumGet(info, 24, "Int")
            case 6: offset := 0
            case 7: offset := EmbeddedPageContentHeights[hwnd]
            default: return 0
        }
        SetEmbeddedPageScroll(pageGui, offset)
        return 0
    }
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

    ResetEmbeddedPageScroll(LayoutEditorGui)
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

    y := 132
    for slotIndex, slot in LayoutEditorSlots
    {
        expanded := LayoutEditorExpandedSlots.Has(slot.slot) ? LayoutEditorExpandedSlots[slot.slot] : false
        toggleText := (expanded ? "▼ " : "▶ ") "SLOT " slot.slot
        toggleBtn := LayoutEditorGui.AddButton("x12 y" y " w82 h24", toggleText)
        toggleBtn.OnEvent("Click", MakeLayoutExpandHandler(slotIndex))

        monitorLabel := LayoutEditorGui.AddText("x100 y" y " w50 h24 +0x200", "Monitor:")
        monitorCombo := LayoutEditorGui.AddDropDownList("x151 y" y " w112 r5", GetMonitorDisplayNames())
        monitorCombo.Value := ResolveLayoutMonitorNumber(slot)
        monitorCombo.OnEvent("Change", MakeLayoutMonitorHandler(slotIndex))
        aspectCheck := LayoutEditorGui.AddCheckBox("x269 y" y " w92 h24", "Keep Ratio")
        aspectCheck.Value := HasProp(slot, "keepAspect") && slot.keepAspect ? 1 : 0
        aspectCheck.OnEvent("Click", MakeLayoutAspectHandler(slotIndex))
        fitRestBtn := LayoutEditorGui.AddButton("x363 y" y " w62 h24", "Fit Rest")
        removeBtn := LayoutEditorGui.AddButton("x428 y" y " w58 h24", "Remove")
        matchBtn := LayoutEditorGui.AddButton("x489 y" y " w48 h24", "Match")
        fitRestBtn.OnEvent("Click", MakeLayoutFitRestHandler(slotIndex))
        removeBtn.OnEvent("Click", MakeLayoutRemoveHandler(slotIndex))
        matchBtn.OnEvent("Click", MakeLayoutMatchBelowHandler(slotIndex))

        RegisterLayoutEditorTooltip(toggleBtn, LayoutSlotTooltip.Bind(slotIndex, "Header"))
        RegisterLayoutEditorTooltip(monitorCombo, LayoutSlotTooltip.Bind(slotIndex, "Monitor"))
        RegisterLayoutEditorTooltip(aspectCheck, "Keep this slot's current width-to-height ratio while resizing either dimension.")
        RegisterLayoutEditorTooltip(fitRestBtn, "Keep Slot " slot.slot " fixed and fit every other slot assigned to this monitor into equal playable windows around it without overlap.")
        RegisterLayoutEditorTooltip(removeBtn, LayoutSlotTooltip.Bind(slotIndex, "Remove"))
        RegisterLayoutEditorTooltip(matchBtn, LayoutSlotTooltip.Bind(slotIndex, "Match"))

        controls := [toggleBtn, monitorLabel, monitorCombo, aspectCheck, fitRestBtn, removeBtn, matchBtn]
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

    LayoutEditorRequiredHeight := MeasureGuiVisibleContentHeight(LayoutEditorGui, 12, Max(140, y + 12))
    LayoutEditorGui.Move(, , 559, LayoutEditorRequiredHeight)
}

ShowLayoutSplitSlotPicker(*)
{
    global LayoutEditorGui, LayoutEditorSlots, LayoutEditorSplitSelectedSlots
    global LayoutEditorSplitPickerGui, LayoutEditorSplitPickerChecks

    try LayoutEditorSplitPickerGui.Destroy()

    LayoutEditorSplitPickerGui := Gui("+Owner" LayoutEditorGui.Hwnd " +AlwaysOnTop", "Choose Split Slots")
    LayoutEditorSplitPickerGui.SetFont("s9", "Segoe UI")
    LayoutEditorSplitPickerGui.MarginX := 14
    LayoutEditorSplitPickerGui.MarginY := 12
    LayoutEditorSplitPickerGui.AddText("xm ym w310", "Choose slots in the order shown. The split count uses the first selected slots.")

    selected := Map()
    for _, slotNumber in LayoutEditorSplitSelectedSlots
        selected[slotNumber] := true

    LayoutEditorSplitPickerChecks := []
    columns := 4
    boxWidth := 76
    startY := 42
    for index, slot in LayoutEditorSlots
    {
        column := Mod(index - 1, columns)
        row := Floor((index - 1) / columns)
        check := LayoutEditorSplitPickerGui.AddCheckBox("x" (14 + column * boxWidth) " y" (startY + row * 28) " w70 h22", "Slot " slot.slot)
        check.Value := selected.Has(slot.slot) ? 1 : 0
        LayoutEditorSplitPickerChecks.Push({ctrl: check, slot: slot.slot})
    }

    rows := Max(1, Ceil(LayoutEditorSlots.Length / columns))
    buttonY := startY + rows * 28 + 8
    allBtn := LayoutEditorSplitPickerGui.AddButton("x14 y" buttonY " w72 h25", "Select All")
    noneBtn := LayoutEditorSplitPickerGui.AddButton("x91 y" buttonY " w72 h25", "Clear")
    applyBtn := LayoutEditorSplitPickerGui.AddButton("x183 y" buttonY " w66 h25 Default", "Apply")
    cancelBtn := LayoutEditorSplitPickerGui.AddButton("x254 y" buttonY " w66 h25", "Cancel")
    allBtn.OnEvent("Click", SetAllLayoutSplitPickerChecks.Bind(true))
    noneBtn.OnEvent("Click", SetAllLayoutSplitPickerChecks.Bind(false))
    applyBtn.OnEvent("Click", SaveLayoutSplitSlotPicker)
    cancelBtn.OnEvent("Click", CloseLayoutSplitSlotPicker)
    LayoutEditorSplitPickerGui.OnEvent("Close", CloseLayoutSplitSlotPicker)
    LayoutEditorSplitPickerGui.OnEvent("Escape", CloseLayoutSplitSlotPicker)
    LayoutEditorSplitPickerGui.Show("AutoSize Center")
}

SetAllLayoutSplitPickerChecks(value, *)
{
    global LayoutEditorSplitPickerChecks
    for item in LayoutEditorSplitPickerChecks
        item.ctrl.Value := value ? 1 : 0
}

SaveLayoutSplitSlotPicker(*)
{
    global LayoutEditorSplitSelectedSlots, LayoutEditorSplitPickerChecks
    LayoutEditorSplitSelectedSlots := []
    for item in LayoutEditorSplitPickerChecks
        if item.ctrl.Value
            LayoutEditorSplitSelectedSlots.Push(item.slot)
    UpdateLayoutSplitSlotsButton()
    CloseLayoutSplitSlotPicker()
}

CloseLayoutSplitSlotPicker(*)
{
    global LayoutEditorSplitPickerGui, LayoutEditorSplitPickerChecks
    try LayoutEditorSplitPickerGui.Destroy()
    LayoutEditorSplitPickerGui := ""
    LayoutEditorSplitPickerChecks := []
}

UpdateLayoutSplitSlotsButton()
{
    global LayoutEditorSplitSlotsButton, LayoutEditorSplitSelectedSlots
    if !IsObject(LayoutEditorSplitSlotsButton)
        return
    count := LayoutEditorSplitSelectedSlots.Length
    LayoutEditorSplitSlotsButton.Text := count ? count " Selected" : "Choose Slots"
}

ApplyLayoutMonitorSplit(*)
{
    global LayoutEditorSlots, LayoutEditorSplitMonitorCombo, LayoutEditorSplitSlotsButton, LayoutEditorSplitCountCombo
    global LayoutEditorSplitSelectedSlots, LayoutEditorOverlays

    if !IsObject(LayoutEditorSplitMonitorCombo) || !IsObject(LayoutEditorSplitSlotsButton) || !IsObject(LayoutEditorSplitCountCombo)
        return

    monitorNumber := LayoutEditorSplitMonitorCombo.Value
    splitCount := LayoutEditorSplitCountCombo.Value
    if monitorNumber < 1 || monitorNumber > MonitorGetCount() || splitCount < 1
        return

    if LayoutEditorSplitSelectedSlots.Length = 0
    {
        MsgBox("Choose at least one slot first.", "Layout Editor", "Icon!")
        return
    }

    selectedIndexes := []
    for _, requestedSlot in LayoutEditorSplitSelectedSlots
    {
        for index, slot in LayoutEditorSlots
        {
            if slot.slot = requestedSlot
            {
                selectedIndexes.Push(index)
                break
            }
        }
        if selectedIndexes.Length >= splitCount
            break
    }

    if selectedIndexes.Length < splitCount
    {
        MsgBox("Only " selectedIndexes.Length " selected slots exist in this layout. Select more slots or lower the split count.", "Layout Editor", "Icon!")
        return
    }

    MonitorGet(monitorNumber, &left, &top, &right, &bottom)
    monitorWidth := Max(1, right - left)
    monitorHeight := Max(1, bottom - top)
    grid := ChoosePlayableLayoutGrid(splitCount, monitorWidth, monitorHeight)
    rows := grid.rows
    columns := grid.columns

    position := 1
    baseRowHeight := Floor(monitorHeight / rows)
    rowRemainder := Mod(monitorHeight, rows)
    nextY := 0

    Loop rows
    {
        row := A_Index
        remaining := splitCount - position + 1
        rowsLeft := rows - row + 1
        slotsInRow := Min(columns, Ceil(remaining / rowsLeft))
        rowHeight := baseRowHeight + (row <= rowRemainder ? 1 : 0)
        baseWidth := Floor(monitorWidth / slotsInRow)
        widthRemainder := Mod(monitorWidth, slotsInRow)
        nextX := 0

        Loop slotsInRow
        {
            slotIndex := selectedIndexes[position]
            slot := LayoutEditorSlots[slotIndex]
            width := baseWidth + (A_Index <= widthRemainder ? 1 : 0)
            slot.monitor := monitorNumber
            slot.monitorWidth := monitorWidth
            slot.monitorHeight := monitorHeight
            slot.x := nextX
            slot.y := nextY
            slot.width := Max(1, width)
            slot.height := Max(1, rowHeight)
            slot.keepAspect := false
            slot.aspectRatio := slot.width / slot.height
            nextX += width
            position++
            ApplyLayoutSlotToWindow(slot)
            if LayoutEditorOverlays.Has(slot.slot)
                UpdateLayoutPreview(slotIndex)
        }
        nextY += rowHeight
    }

    RefreshLayoutEditorRowsOnly()
}

ChoosePlayableLayoutGrid(slotCount, monitorWidth, monitorHeight)
{
    monitorRatio := monitorWidth / Max(1, monitorHeight)
    bestRows := 1
    bestColumns := slotCount
    bestScore := 1000000
    targetRatio := 1.55

    Loop slotCount
    {
        rows := A_Index
        columns := Ceil(slotCount / rows)
        cellRatio := monitorRatio * rows / columns
        emptyCells := rows * columns - slotCount
        score := Abs(Log(cellRatio / targetRatio)) + emptyCells * 0.12
        if cellRatio < 1.05
            score += (1.05 - cellRatio) * 2.5
        if score < bestScore
        {
            bestScore := score
            bestRows := rows
            bestColumns := columns
        }
    }
    return {rows: bestRows, columns: bestColumns}
}

ParseLayoutSlotSelection(text)
{
    result := []
    seen := Map()
    normalized := StrReplace(StrReplace(Trim(text), ";", ","), " ", "")

    for _, token in StrSplit(normalized, ",")
    {
        token := Trim(token)
        if token = ""
            continue

        if RegExMatch(token, "^(\d+)\s*-\s*(\d+)$", &match)
        {
            startSlot := Integer(match[1])
            endSlot := Integer(match[2])
            step := startSlot <= endSlot ? 1 : -1
            current := startSlot
            Loop
            {
                if current >= 1 && !seen.Has(current)
                {
                    result.Push(current)
                    seen[current] := true
                }
                if current = endSlot
                    break
                current += step
            }
        }
        else if RegExMatch(token, "^\d+$")
        {
            slotNumber := Integer(token)
            if slotNumber >= 1 && !seen.Has(slotNumber)
            {
                result.Push(slotNumber)
                seen[slotNumber] := true
            }
        }
        else
            return []
    }
    return result
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
    {
        value := ClampLayoutCoordinate(slot, prop, value)
        slot.%prop% := ResolveLayoutNoOverlapMove(index, prop, value)
    }
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
    ApplyLayoutSlotToWindow(slot, false)
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

ResolveLayoutNoOverlapMove(index, prop, desiredValue)
{
    global LayoutEditorSlots, LayoutEditorNoOverlapCheck

    if !IsObject(LayoutEditorNoOverlapCheck) || LayoutEditorNoOverlapCheck.Value != 1
        return desiredValue
    if index < 1 || index > LayoutEditorSlots.Length
        return desiredValue

    moving := LayoutEditorSlots[index]
    currentValue := moving.%prop%
    if desiredValue = currentValue
        return desiredValue

    movingMonitor := ResolveLayoutMonitorNumber(moving)
    if prop = "x"
    {
        movingCrossStart := moving.y
        movingCrossEnd := moving.y + moving.height
        movingSize := moving.width
    }
    else
    {
        movingCrossStart := moving.x
        movingCrossEnd := moving.x + moving.width
        movingSize := moving.height
    }

    resolved := desiredValue
    movingNegative := desiredValue < currentValue

    for otherIndex, other in LayoutEditorSlots
    {
        if otherIndex = index || ResolveLayoutMonitorNumber(other) != movingMonitor
            continue

        if prop = "x"
        {
            otherCrossStart := other.y
            otherCrossEnd := other.y + other.height
            otherStart := other.x
            otherEnd := other.x + other.width
        }
        else
        {
            otherCrossStart := other.x
            otherCrossEnd := other.x + other.width
            otherStart := other.y
            otherEnd := other.y + other.height
        }

        if movingCrossStart >= otherCrossEnd || movingCrossEnd <= otherCrossStart
            continue

        if movingNegative
        {
            if otherEnd <= currentValue && desiredValue < otherEnd
                resolved := Max(resolved, otherEnd)
        }
        else
        {
            currentEnd := currentValue + movingSize
            boundary := otherStart - movingSize
            if otherStart >= currentEnd && desiredValue > boundary
                resolved := Min(resolved, boundary)
        }
    }

    return resolved
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

    hasSavedMonitorPosition := HasProp(slot, "monitorLeft") && HasProp(slot, "monitorTop")
    hasSavedMonitorPosition := hasSavedMonitorPosition && slot.monitorLeft != 2147483647
    hasSavedMonitorPosition := hasSavedMonitorPosition && slot.monitorTop != 2147483647
    if hasSavedMonitorPosition
    {
        Loop monitorCount
        {
            left := 0
            top := 0
            right := 0
            bottom := 0
            MonitorGet(A_Index, &left, &top, &right, &bottom)
            if left = slot.monitorLeft && top = slot.monitorTop
            {
                if !HasProp(slot, "monitorWidth") || !HasProp(slot, "monitorHeight")
                    return A_Index
                if right - left = slot.monitorWidth && bottom - top = slot.monitorHeight
                    return A_Index
            }
        }
    }

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
        monitorLeft: left,
        monitorTop: top,
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
        monitorLeft: left,
        monitorTop: top,
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
    bounds := GetLayoutMonitorBounds(slot)

    requestedWidth := Max(1, Integer(slot.width))
    requestedHeight := Max(1, Integer(slot.height))

    appliedWidth := Min(requestedWidth, Max(1, bounds.width))
    appliedHeight := Min(requestedHeight, Max(1, bounds.height))

    appliedX := Min(Max(Integer(slot.x), 0), Max(0, bounds.width - appliedWidth))
    appliedY := Min(Max(Integer(slot.y), 0), Max(0, bounds.height - appliedHeight))

    return {
        x: bounds.left + appliedX,
        y: bounds.top + appliedY,
        width: appliedWidth,
        height: appliedHeight
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
    slot.monitorLeft := left
    slot.monitorTop := top
    ClampLayoutSlotToAssignedMonitor(slot)

    if LayoutEditorValueCtrls.Length >= index
    {
        values := LayoutEditorValueCtrls[index]
        for _, field in ["x", "y", "width", "height"]
            if values.Has(field)
                values[field].Value := String(slot.%field%)
    }

    ApplyLayoutSlotToWindow(slot, false)
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
        ShowAllLayoutPreviews()
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

    overlay := Gui("-Caption +ToolWindow", "Slot " slot.slot " Preview")
    overlay.BackColor := "00AEEF"
    overlay.SetFont("s16 bold", "Segoe UI")
    text := overlay.AddText("x0 y0 w" slot.width " h" slot.height " Center +0x200 +Border", "SLOT " slot.slot)

    overlay.Show("Hide w" slot.width " h" slot.height)

    previewExStyle := 0x00080000 | 0x00000020 | 0x08000000 | 0x00000080
    try WinSetExStyle(previewExStyle, "ahk_id " overlay.Hwnd)

    try DllCall("SetLayeredWindowAttributes", "Ptr", overlay.Hwnd, "UInt", 0, "UChar", 40, "UInt", 0x2)

    HWND_BOTTOM := 1
    SWP_NOACTIVATE := 0x0010
    SWP_SHOWWINDOW := 0x0040
    rect := GetLayoutSlotAbsoluteRect(slot)
    try DllCall("SetWindowPos", "Ptr", overlay.Hwnd, "Ptr", HWND_BOTTOM,
        "Int", rect.x, "Int", rect.y, "Int", rect.width, "Int", rect.height,
        "UInt", SWP_NOACTIVATE | SWP_SHOWWINDOW)

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
        try WinSetExStyle(0x00080000 | 0x00000020 | 0x08000000 | 0x00000080, "ahk_id " GetGuiHwndSafe(preview.gui))
        try DllCall("SetLayeredWindowAttributes", "Ptr", GetGuiHwndSafe(preview.gui), "UInt", 0, "UChar", 40, "UInt", 0x2)
        rect := GetLayoutSlotAbsoluteRect(slot)
        try DllCall("SetWindowPos", "Ptr", GetGuiHwndSafe(preview.gui), "Ptr", 1,
            "Int", rect.x, "Int", rect.y, "Int", rect.width, "Int", rect.height,
            "UInt", 0x0010 | 0x0040)
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

MakeLayoutFitRestHandler(index)
{
    return (*) => FitRemainingLayoutSlots(index)
}

FitRemainingLayoutSlots(anchorIndex)
{
    global LayoutEditorSlots, LayoutEditorOverlays

    if anchorIndex < 1 || anchorIndex > LayoutEditorSlots.Length
        return

    anchor := LayoutEditorSlots[anchorIndex]
    monitorNumber := ResolveLayoutMonitorNumber(anchor)
    targetIndexes := []
    for index, slot in LayoutEditorSlots
        if index != anchorIndex && ResolveLayoutMonitorNumber(slot) = monitorNumber
            targetIndexes.Push(index)

    if targetIndexes.Length = 0
    {
        MsgBox("There are no other layout slots assigned to Monitor " monitorNumber ".", "Fit Rest", "Icon!")
        return
    }

    MonitorGet(monitorNumber, &monitorLeft, &monitorTop, &monitorRight, &monitorBottom)
    try MonitorGetWorkArea(monitorNumber, &workLeft, &workTop, &workRight, &workBottom)
    catch
    {
        workLeft := monitorLeft
        workTop := monitorTop
        workRight := monitorRight
        workBottom := monitorBottom
    }

    anchorRect := GetLayoutSlotAbsoluteRect(anchor)
    anchorLeft := Max(workLeft, anchorRect.x)
    anchorTop := Max(workTop, anchorRect.y)
    anchorRight := Min(workRight, anchorRect.x + anchorRect.width)
    anchorBottom := Min(workBottom, anchorRect.y + anchorRect.height)

    if anchorRight <= anchorLeft || anchorBottom <= anchorTop
    {
        MsgBox("The anchor slot does not overlap the usable work area of its assigned monitor.", "Fit Rest", "Icon!")
        return
    }

    plan := FindBestFitRestPlan(workLeft, workTop, workRight, workBottom,
        anchorLeft, anchorTop, anchorRight, anchorBottom, targetIndexes.Length)
    if !IsObject(plan) || plan.Length < targetIndexes.Length
    {
        MsgBox("The remaining usable monitor space is too small to fit all other slots around this anchor.", "Fit Rest", "Icon!")
        return
    }

    monitorWidth := Max(1, monitorRight - monitorLeft)
    monitorHeight := Max(1, monitorBottom - monitorTop)
    previewsWereVisible := LayoutEditorOverlays.Count > 0

    for order, targetIndex in targetIndexes
    {
        rect := plan[order]
        slot := LayoutEditorSlots[targetIndex]
        slot.monitor := monitorNumber
        slot.monitorWidth := monitorWidth
        slot.monitorHeight := monitorHeight
        slot.x := rect.x - monitorLeft
        slot.y := rect.y - monitorTop
        slot.width := rect.width
        slot.height := rect.height
        slot.keepAspect := false
        slot.aspectRatio := slot.width / Max(1, slot.height)
        ApplyLayoutSlotToWindow(slot, false)
    }

    RefreshList()
    RefreshLayoutEditorRowsOnly()
    if previewsWereVisible
        ShowAllLayoutPreviews()
}

FindBestFitRestPlan(workLeft, workTop, workRight, workBottom, anchorLeft, anchorTop, anchorRight, anchorBottom, needed)
{
    modes := []
    middleTop := Max(workTop, anchorTop)
    middleBottom := Min(workBottom, anchorBottom)
    middleHeight := Max(0, middleBottom - middleTop)
    anchorBandLeft := Max(workLeft, anchorLeft)
    anchorBandRight := Min(workRight, anchorRight)
    anchorBandWidth := Max(0, anchorBandRight - anchorBandLeft)

    modes.Push([
        {x: workLeft, y: workTop, width: workRight - workLeft, height: Max(0, anchorTop - workTop)},
        {x: workLeft, y: anchorBottom, width: workRight - workLeft, height: Max(0, workBottom - anchorBottom)},
        {x: workLeft, y: middleTop, width: Max(0, anchorLeft - workLeft), height: middleHeight},
        {x: anchorRight, y: middleTop, width: Max(0, workRight - anchorRight), height: middleHeight}
    ])
    modes.Push([
        {x: workLeft, y: workTop, width: Max(0, anchorLeft - workLeft), height: workBottom - workTop},
        {x: anchorRight, y: workTop, width: Max(0, workRight - anchorRight), height: workBottom - workTop},
        {x: anchorBandLeft, y: workTop, width: anchorBandWidth, height: Max(0, anchorTop - workTop)},
        {x: anchorBandLeft, y: anchorBottom, width: anchorBandWidth, height: Max(0, workBottom - anchorBottom)}
    ])

    bestPlan := []
    bestScore := -1
    for regions in modes
    {
        widths := Map()
        heights := Map()
        for region in regions
        {
            if region.width < 1 || region.height < 1
                continue
            Loop needed
            {
                candidateWidth := Floor(region.width / A_Index)
                candidateHeight := Floor(region.height / A_Index)
                if candidateWidth >= 80
                    widths[candidateWidth] := true
                if candidateHeight >= 60
                    heights[candidateHeight] := true
            }
        }

        for candidateWidth, _ in widths
        {
            for candidateHeight, _ in heights
            {
                placements := BuildFitRestPlacements(regions, candidateWidth, candidateHeight, needed)
                if placements.Length < needed
                    continue
                ratio := candidateWidth / Max(1, candidateHeight)
                ratioFactor := ratio < 1.10 ? Max(0.20, ratio / 1.10) : 1.0
                if ratio > 2.60
                    ratioFactor *= Max(0.55, 2.60 / ratio)
                score := candidateWidth * candidateHeight * ratioFactor
                if score > bestScore
                {
                    bestScore := score
                    bestPlan := placements
                }
            }
        }
    }
    return bestPlan
}

BuildFitRestPlacements(regions, cellWidth, cellHeight, needed)
{
    placements := []
    for region in regions
    {
        columns := Floor(region.width / cellWidth)
        rows := Floor(region.height / cellHeight)
        if columns < 1 || rows < 1
            continue

        usedWidth := columns * cellWidth
        usedHeight := rows * cellHeight
        startX := region.x + Floor((region.width - usedWidth) / 2)
        startY := region.y + Floor((region.height - usedHeight) / 2)
        Loop rows
        {
            row := A_Index - 1
            Loop columns
            {
                column := A_Index - 1
                placements.Push({
                    x: startX + column * cellWidth,
                    y: startY + row * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                })
                if placements.Length >= needed
                    return placements
            }
        }
    }
    return placements
}

ShowAllLayoutPreviews()
{
    global LayoutEditorSlots, LayoutEditorOverlays
    for index, slot in LayoutEditorSlots
    {
        if LayoutEditorOverlays.Has(slot.slot)
            UpdateLayoutPreview(index)
        else
            ShowLayoutPreview(index)
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

    previewsWereVisible := LayoutEditorOverlays.Count > 0
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

    if previewsWereVisible
        ShowAllLayoutPreviews()
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
    global LayoutEditorSlots, Layouts, LayoutEditorSelectedLayout, Settings, LayoutEditorNeedsRefresh
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
    LayoutEditorNeedsRefresh := true
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
    global Layouts, LayoutEditorSelectedLayout, Settings, LayoutFavorites, LayoutEditorNeedsRefresh
    if LayoutEditorSelectedLayout < 1 || LayoutEditorSelectedLayout > Layouts.Length
        return
    name := Layouts[LayoutEditorSelectedLayout].name
    If MsgBox("Delete layout " . Chr(34) . name . Chr(34) . "?", "Layout Editor", "YesNo Icon!") != "Yes"
        return
    deletedIndex := LayoutEditorSelectedLayout
    Layouts.RemoveAt(deletedIndex)
    LayoutEditorNeedsRefresh := true
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
    global Layouts, LayoutEditorSelectedLayout, LayoutEditorSlots, LayoutTemporarySlotOverrides, LayoutEditorNeedsRefresh
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

JoinLogNumbers(values)
{
    result := ""
    for value in values
        result .= (result = "" ? "" : ", ") value
    return result = "" ? "(none)" : result
}

LogEvent(message, level := "INFO")
{
    global CONFIG_DIR, LogHistory, LogFile, LogsGui, LogsEdit
    stamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    line := "[" stamp "] [" level "] " StrReplace(StrReplace(String(message), "`r", " "), "`n", " ")
    LogHistory.Push(line)
    if LogHistory.Length > 800
        LogHistory.RemoveAt(1)
    try
    {
        logDir := CONFIG_DIR "\Logs"
        if !DirExist(logDir)
            DirCreate(logDir)
        if LogFile = ""
            LogFile := logDir "\FoxholeMultiboxer-" FormatTime(, "yyyy-MM-dd") ".log"
        FileAppend(line "`r`n", LogFile, "UTF-8")
    }
    catch
    {
    }
    if IsObject(LogsGui) && LogsGui.Hwnd && IsObject(LogsEdit)
        try RefreshLogWindow()
}

RefreshLogWindow(*)
{
    global LogHistory, LogsEdit
    if !IsObject(LogsEdit)
        return
    contents := ""
    for line in LogHistory
        contents .= line "`r`n"
    LogsEdit.Value := contents
    try SendMessage(0xB7, 0, -1, LogsEdit.Hwnd)
}

OpenLogWindow(*)
{
    global LogsGui, LogsEdit, LogFile
    if IsObject(LogsGui) && LogsGui.Hwnd
    {
        LogsGui.Show()
        RefreshLogWindow()
        return
    }
    LogsGui := Gui("+Resize +MinSize500x250", "Foxhole Multiboxer - Logs")
    LogsGui.SetFont("s9", "Consolas")
    LogsEdit := LogsGui.AddEdit("x10 y10 w680 h350 ReadOnly -Wrap +VScroll")
    openBtn := LogsGui.AddButton("x10 y368 w105 h27", "Open Log File")
    openBtn.OnEvent("Click", (*) => OpenLogFile())
    clearBtn := LogsGui.AddButton("x121 y368 w100 h27", "Clear View")
    clearBtn.OnEvent("Click", (*) => ClearLogView())
    LogsGui.OnEvent("Size", ResizeLogWindow)
    LogsGui.OnEvent("Close", (*) => LogsGui.Hide())
    LogsGui.OnEvent("Escape", (*) => LogsGui.Hide())
    LogsGui.Show("w700 h405")
    RefreshLogWindow()
    LogEvent("Log viewer opened")
}

ResizeLogWindow(guiObj, minMax, width, height)
{
    global LogsEdit
    if minMax = -1 || !IsObject(LogsEdit)
        return
    LogsEdit.Move(, , Max(200, width - 20), Max(80, height - 55))
}

ClearLogView(*)
{
    global LogHistory
    LogHistory := []
    RefreshLogWindow()
}

OpenLogFile(*)
{
    global LogFile
    if LogFile != "" && FileExist(LogFile)
        try Run('notepad.exe "' LogFile '"')
}

OpenSandboxieManager(*)
{
    global Settings
    configured := Trim(Settings["SandboxieStartExe"])
    candidates := []
    if configured != ""
    {
        SplitPath(configured, , &sandboxieDir)
        candidates.Push(sandboxieDir "\SandMan.exe")
    }
    candidates.Push("C:\Program Files\Sandboxie-Plus\SandMan.exe")
    candidates.Push("C:\Program Files\Sandboxie\SandMan.exe")
    for candidate in candidates
    {
        if FileExist(candidate)
        {
            try
            {
                Run('"' candidate '"')
                LogEvent("Opened Sandboxie Plus manager")
                return
            }
            catch as e
                LogEvent("Unable to open Sandboxie manager: " e.Message, "ERROR")
        }
    }
    LogEvent("Sandboxie Plus manager not found", "WARN")
    MsgBox("Couldn't locate SandMan.exe. Check your Sandboxie Plus installation path.", "Sandboxie Plus", "Icon!")
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
    global TrainSlowHoldEdit, TrainSlowHoldDuration
    global SandboxieAccounts, AccountSwapKeys, AccountSwapButtons, AccountSwapTargetLabels
    global SwapByAccountCheck, CurrentMainPage, HotkeysExpandedSections
    global HotkeysSectionHeaders
    global EmbeddedPageBasePositions, EmbeddedPageScrollOffsets, EmbeddedPageContentHeights, EmbeddedPageViewportHeights

    oldGui := HotkeysGui

    RebindButtons := Map()
    IntervalEdits := Map()
    OutputKeyButtons := Map()
    AccountSwapButtons := Map()
    AccountSwapTargetLabels := Map()
    HotkeysSectionHeaders := Map()

    newGui := Gui("+Parent" MainGui.Hwnd " -Caption +0x04000000", "Hotkeys")
    newGui.SetFont("s9", "Segoe UI")
    HotkeysGui := newGui
    OnMessage(0x0200, HotkeysGuiMouseMove)

    HotkeysGui.AddText("x12 y10 w476 h22 +0x200", "HOTKEYS")
    y := 38
    y := BuildHotkeySection("Game", "GAME KEYS", ["AutoClick", "AutoWalk", "AutoReverse", "ClickHold", "RightHold", "VSpam", "TrainSlow"], y)
    y := BuildHotkeySection("Manage", "MANAGE GAMES", ["MouseFocus", "LastGame", "NextGame", "SwitchSlot", "Swap", "SwapFirst", "ShowFoxhole", "ShowSteam", "TogglePreviews"], y)
    y := BuildAccountSwapSection(y)

    HotkeysGui.OnEvent("Close", (*) => SwitchMainPage("Main"))
    HotkeysGui.OnEvent("Escape", (*) => SwitchMainPage("Main"))

    DisposeEmbeddedPage(oldGui)

}

BuildHotkeySection(sectionKey, title, actions, y)
{
    global HotkeysGui, HotkeysExpandedSections, RebindButtons, CurrentKeys, IntervalEdits, Settings
    global HotkeysSectionHeaders
    global IntervalSettings, DefaultOutputKeys, CurrentOutputKeys, OutputKeyButtons, ChangeOutputKeysCheck
    global GameHotkeysEnabledCheck
    global TrainSlowHoldEdit, TrainSlowHoldDuration, TrainSlowDefaultHoldDuration

    expanded := HotkeysExpandedSections.Has(sectionKey) && HotkeysExpandedSections[sectionKey]
    header := HotkeysGui.AddButton("x12 y" y " w476 h28 +Left", (expanded ? "▼  " : "▶  ") title)
    HotkeysSectionHeaders[sectionKey] := header
    header.OnEvent("Click", MakeHotkeysSectionToggleHandler(sectionKey))
    RegisterTooltip(header, (expanded ? "Collapse " : "Expand ") title ".")
    y += 32

    if !expanded
        return y

    HotkeysGui.AddText("x12 y" y " w220 h18 +Center", "Hotkey / Current Binding")
    HotkeysGui.AddText("x238 y" y " w60 h18 +Center", "Default")
    HotkeysGui.AddText("x304 y" y " w64 h18 +Center", "Unbind")
    HotkeysGui.AddText("x374 y" y " w114 h18 +Center", "Output")
    y += 21

    for action in actions
    {
        RebindButtons[action] := HotkeysGui.AddButton("x12 y" y " w220 h28", ActionButtonText(action, CurrentKeys[action]))
        RebindButtons[action].OnEvent("Click", MakeHotkeysRebindHandler(action))
        RegisterTooltip(RebindButtons[action], HotkeyActionTooltip.Bind(action))

        resetBtn := HotkeysGui.AddButton("x238 y" y " w60 h28", "Reset")
        resetBtn.OnEvent("Click", MakeActionClickHandler(ResetSingleHotkey, action))
        RegisterTooltip(resetBtn, HotkeyResetTooltip.Bind(action))

        unbindBtn := HotkeysGui.AddButton("x304 y" y " w64 h28", "Unbind")
        unbindBtn.OnEvent("Click", MakeActionClickHandler(UnbindSingleHotkey, action))
        RegisterTooltip(unbindBtn, MakeUnbindTooltipProvider(action))

        if DefaultOutputKeys.Has(action)
        {
            outputBtn := HotkeysGui.AddButton("x374 y" y " w114 h28", DisplayNameForOutputKey(CurrentOutputKeys[action]))
            outputBtn.OnEvent("Click", MakeOutputKeyHandler(action))
            outputBtn.Visible := Settings["ChangeOutputKeys"]
            OutputKeyButtons[action] := outputBtn
            RegisterTooltip(outputBtn, "Choose the keyboard key this action sends to Foxhole. Useful for AZERTY and other keyboard layouts.")
        }
        else
            HotkeysGui.AddText("x374 y" (y + 5) " w114 h20 +Center", "—")

        y += 34
    }

    if sectionKey = "Game"
    {
        GameHotkeysEnabledCheck := HotkeysGui.AddCheckBox("x12 y" y " w250 h24", "Enable Game Keys")
        GameHotkeysEnabledCheck.Value := Settings["GameHotkeysEnabled"] ? 1 : 0
        GameHotkeysEnabledCheck.OnEvent("Click", ToggleGameHotkeysEnabled)
        RegisterTooltip(GameHotkeysEnabledCheck, "Enable or disable all GAME KEYS hotkeys without changing or erasing any saved keybinds.")
        y += 30

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
    global HotkeysSectionHeaders
    global AccountSwapButtons, AccountSwapTargetLabels, SwapByAccountCheck, BringSwapToFrontCheck, Settings

    expanded := HotkeysExpandedSections.Has("Swap") && HotkeysExpandedSections["Swap"]
    header := HotkeysGui.AddButton("x12 y" y " w476 h28 +Left", (expanded ? "▼  " : "▶  ") "SWAP TO ACCOUNT")
    HotkeysSectionHeaders["Swap"] := header
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

    SwapByAccountCheck := HotkeysGui.AddCheckBox("x12 y" y " w220 h24", "Swap by Account?")
    SwapByAccountCheck.Value := Settings["SwapByAccount"] ? 1 : 0
    SwapByAccountCheck.OnEvent("Click", SwapByAccountChanged)
    RegisterTooltip(SwapByAccountCheck, "On: Swap to N follows account row N wherever that account currently is. Off: Swap to N always activates Foxhole slot N.")

    BringSwapToFrontCheck := HotkeysGui.AddCheckBox("x244 y" y " w244 h24", "Bring Swapped Account to Front?")
    BringSwapToFrontCheck.Value := Settings["BringSwapToFront"] ? 1 : 0
    BringSwapToFrontCheck.OnEvent("Click", BringSwapToFrontChanged)
    RegisterTooltip(BringSwapToFrontCheck, "When enabled, Swap to Account hotkeys explicitly raise the target Foxhole window above the other stacked game windows after focusing it.")
    return y + 34
}


MakeHotkeysSectionToggleHandler(sectionKey)
{
    return (*) => ToggleHotkeysSection(sectionKey)
}

ToggleHotkeysSection(sectionKey)
{
    global HotkeysExpandedSections, CurrentMainPage, MainGui, HotkeysGui
    current := HotkeysExpandedSections.Has(sectionKey) ? HotkeysExpandedSections[sectionKey] : false
    HotkeysExpandedSections[sectionKey] := !current

    BuildHotkeysGui()
    if CurrentMainPage = "Hotkeys"
        FitEmbeddedPageToContent(HotkeysGui, 12, 500, 140, true)
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
    global HotkeysGui
    return MeasureGuiVisibleContentHeight(HotkeysGui, 8, 140)
}

RefreshAccountSwapHotkeysGui()
{
    global CurrentMainPage, MainGui, HotkeysGui
    BuildHotkeysGui()
    if CurrentMainPage = "Hotkeys"
        FitEmbeddedPageToContent(HotkeysGui, 12, 500, 140, true)
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

BringSwapToFrontChanged(ctrl, *)
{
    global Settings, StatusText
    Settings["BringSwapToFront"] := ctrl.Value = 1
    SaveConfig()
    StatusText.Text := "Status: Swap-to foreground raising " (Settings["BringSwapToFront"] ? "enabled." : "disabled.")
}

ToggleGameHotkeysEnabled(ctrl, *)
{
    global Settings, StatusText
    Settings["GameHotkeysEnabled"] := ctrl.Value = 1
    SyncHotkeyRegistrations()
    SaveConfig()
    StatusText.Text := "Status: Game Keys hotkeys " (Settings["GameHotkeysEnabled"] ? "enabled." : "disabled. Saved keybinds were kept.")
}

ToggleChangeOutputKeys(ctrl, *)
{
    global Settings, OutputKeyButtons
    Settings["ChangeOutputKeys"] := ctrl.Value = 1
    for action, button in OutputKeyButtons
        button.Visible := Settings["ChangeOutputKeys"]
    SaveConfig()
}

FlashGameIdentityChanged(ctrl, *)
{
    global Settings, LastFocusedFoxholeHwnd
    Settings["FlashGameIdentity"] := ctrl.Value = 1
    if !Settings["FlashGameIdentity"]
    {
        HideFoxholeFocusIdentity()
        LastFocusedFoxholeHwnd := 0
    }
    SaveConfig()
}

BuildPreviewSettingsGui()
{
    global PreviewSettingsGui, MainGui, SandboxieAccounts, SandboxieRowCount, Instances
    global PreviewConfigs, PreviewEnableChecks
    global PreviewOpacitySlider, PreviewOpacityLabel, PreviewSizeSlider, PreviewSizeLabel
    global PreviewShowActiveHotkeysCheck, PreviewShowWhenUnfocusedCheck, PreviewHoverHotkeysCheck, PreviewHoverBringToFrontCheck, PreviewAccountSummary
    global IdentityShowSlotCheck, IdentityShowAccountCheck, PreviewIdentityPositionDropDown, PreviewIdentityHorizontalDropDown
    global PreviewIdentitySizeSlider, PreviewIdentitySizeLabel
    global GameIdentityShowCheck, GameIdentityVerticalDropDown, GameIdentityHorizontalDropDown
    global GameIdentitySizeSlider, GameIdentitySizeLabel
    global PreviewMasterVisibleCheck, PreviewEditModeCheck, PreviewResizeAllEqualCheck, PreviewMoveAllTogetherCheck, PreviewSnapTogetherCheck, Settings
    global PreviewLayouts, PreviewLayoutDropDown, PreviewPositionOverlays

    oldGui := PreviewSettingsGui
    PreviewEnableChecks := Map()

    PreviewSettingsGui := Gui("+Parent" MainGui.Hwnd " -Caption +0x04000000", "Previews")
    PreviewSettingsGui.SetFont("s9", "Segoe UI")
    PreviewSettingsGui.AddText("x12 y10 w499 h22 +0x200", "Preview settings")


    PreviewSettingsGui.AddText("x12 y40 w499 h20 +0x200", "Visibility and arrangement")
    PreviewSettingsGui.AddText("x12 y190 w499 h20 +0x200", "Accounts and appearance")
    PreviewSettingsGui.AddText("x12 y324 w499 h20 +0x200", "Saved preview layouts")
    PreviewSettingsGui.AddText("x12 y421 w499 h20 +0x200", "Identity labels")
    PreviewSettingsGui.AddText("x12 y581 w499 h20 +0x200", "Focus and mouse behavior")
    PreviewSettingsGui.AddText("x12 y539 w92 h22 +0x200", "Game ID:")

    PreviewMasterVisibleCheck := PreviewSettingsGui.AddCheckBox("x12 y64 w240 h24", "Show Previews")
    PreviewMasterVisibleCheck.Value := Settings["PreviewsVisible"] ? 1 : 0
    PreviewMasterVisibleCheck.OnEvent("Click", PreviewMasterVisibleChanged)
    RegisterTooltip(PreviewMasterVisibleCheck, "Master show/hide switch. Preview positions and settings are preserved while hidden.")

    PreviewEditModeCheck := PreviewSettingsGui.AddCheckBox("x271 y64 w240 h24", "Edit Mode")
    PreviewEditModeCheck.Value := Settings["PreviewEditMode"] ? 1 : 0
    PreviewEditModeCheck.OnEvent("Click", PreviewEditModeChanged)
    RegisterTooltip(PreviewEditModeCheck, "Edit Mode keeps previews borderless and lets you drag them to reposition. Turn it off to make clicks switch to that game.")

    PreviewResizeAllEqualCheck := PreviewSettingsGui.AddCheckBox("x12 y91 w240 h24", "Resize All Equally")
    PreviewResizeAllEqualCheck.Value := Settings["PreviewResizeAllEqual"] ? 1 : 0
    PreviewResizeAllEqualCheck.OnEvent("Click", PreviewResizeAllEqualChanged)
    RegisterTooltip(PreviewResizeAllEqualCheck, "When enabled, the Preview Size slider resizes every visible preview to the same size. When disabled, it resizes the focused game preview.")

    PreviewMoveAllTogetherCheck := PreviewSettingsGui.AddCheckBox("x271 y91 w240 h24", "Move All Together")
    PreviewMoveAllTogetherCheck.Value := Settings["PreviewMoveAllTogether"] ? 1 : 0
    PreviewMoveAllTogetherCheck.OnEvent("Click", PreviewMoveAllTogetherChanged)
    RegisterTooltip(PreviewMoveAllTogetherCheck, "Dragging one preview moves all visible previews by the same amount, preserving their layout.")

    PreviewSnapTogetherCheck := PreviewSettingsGui.AddCheckBox("x12 y118 w240 h24", "Snap / Prevent Overlap")
    PreviewSnapTogetherCheck.Value := Settings["PreviewSnapTogether"] ? 1 : 0
    PreviewSnapTogetherCheck.OnEvent("Click", PreviewSnapTogetherChanged)
    RegisterTooltip(PreviewSnapTogetherCheck, "Keeps previews from overlapping and snaps nearby preview edges together for quick clean layouts.")

    showAll := PreviewSettingsGui.AddButton("x12 y147 w90 h28", "Show All")
    showAll.OnEvent("Click", ShowAllFoxholePreviews)
    hideAll := PreviewSettingsGui.AddButton("x110 y147 w90 h28", "Hide All")
    hideAll.OnEvent("Click", HideAllFoxholePreviews)
    resetAll := PreviewSettingsGui.AddButton("x208 y147 w90 h28", "Reset")
    resetAll.OnEvent("Click", ResetAllFoxholePreviews)

    verticalArrangeBtn := PreviewSettingsGui.AddButton("x306 y147 w96 h28", "Vertical")
    verticalArrangeBtn.OnEvent("Click", AutoArrangeFoxholePreviews)
    RegisterTooltip(verticalArrangeBtn, "Vertical Arrange: stacks previews downward first, then starts a new column if needed.")

    horizontalArrangeBtn := PreviewSettingsGui.AddButton("x410 y147 w101 h28", "Horizontal")
    horizontalArrangeBtn.OnEvent("Click", HorizontalArrangeFoxholePreviews)
    RegisterTooltip(horizontalArrangeBtn, "Horizontal Arrange: places previews left-to-right first, then starts a new row if needed.")

    PreviewSettingsGui.AddText("x12 y351 w100 h22 +0x200", "Preview Layout:")
    layoutNames := []
    for layout in PreviewLayouts
        layoutNames.Push(layout.name)

    PreviewLayoutDropDown := PreviewSettingsGui.AddDropDownList("x118 y349 w393 r8", layoutNames)
    if layoutNames.Length
    {
        previewLayoutChoice := 1
        if Settings["LastPreviewLayoutName"] != ""
        {
            for index, layout in PreviewLayouts
            {
                if StrLower(layout.name) = StrLower(Settings["LastPreviewLayoutName"])
                {
                    previewLayoutChoice := index
                    break
                }
            }
        }
        PreviewLayoutDropDown.Choose(previewLayoutChoice)
    }
    PreviewLayoutDropDown.OnEvent("Change", PreviewLayoutSelectionChanged)
    saveLayoutBtn := PreviewSettingsGui.AddButton("x118 y380 w90 h28", "Save")
    saveLayoutBtn.OnEvent("Click", SaveCurrentPreviewLayout)
    updateLayoutBtn := PreviewSettingsGui.AddButton("x216 y380 w90 h28", "Update")
    updateLayoutBtn.OnEvent("Click", UpdateSelectedPreviewLayout)
    RegisterTooltip(updateLayoutBtn, "Overwrite the selected saved preview layout with the previews exactly as they are now.")
    loadLayoutBtn := PreviewSettingsGui.AddButton("x314 y380 w90 h28", "Load")
    loadLayoutBtn.OnEvent("Click", LoadSelectedPreviewLayout)
    deleteLayoutBtn := PreviewSettingsGui.AddButton("x412 y380 w99 h28", "Delete")
    deleteLayoutBtn.OnEvent("Click", DeleteSelectedPreviewLayout)

    PreviewSettingsGui.AddText("x12 y266 w104 h22 +0x200", "Transparency:")
    PreviewOpacitySlider := PreviewSettingsGui.AddSlider("x118 y266 w310 h24 Range20-100 ToolTip", Settings["PreviewOpacity"])
    PreviewOpacitySlider.OnEvent("Change", SetAllFoxholePreviewOpacity)
    PreviewOpacityLabel := PreviewSettingsGui.AddText("x438 y266 w73 h22 +Center", Settings["PreviewOpacity"] "%")
    RegisterTooltip(PreviewOpacitySlider, "One shared transparency value for every Foxhole preview.")

    initialPreviewWidth := GetPreviewSizeSliderWidth()
    PreviewSettingsGui.AddText("x12 y295 w104 h22 +0x200", "Preview Size:")
    PreviewSizeSlider := PreviewSettingsGui.AddSlider("x118 y295 w310 h24 Range160-640 ToolTip", initialPreviewWidth)
    PreviewSizeSlider.OnEvent("Change", SetFoxholePreviewSizeFromSlider)
    PreviewSizeLabel := PreviewSettingsGui.AddText("x438 y295 w73 h22 +Center", initialPreviewWidth " px")
    RegisterTooltip(PreviewSizeSlider, "Resize previews without changing their window style. With Resize All Equally enabled, all visible previews match this width; otherwise the focused game's preview is resized.")

    PreviewSettingsGui.AddText("x12 y449 w92 h22 +0x200", "ID Text:")
    IdentityShowSlotCheck := PreviewSettingsGui.AddCheckBox("x106 y447 w82 h24", "Slot #")
    IdentityShowSlotCheck.Value := Settings["IdentityShowSlot"] ? 1 : 0
    IdentityShowSlotCheck.OnEvent("Click", IdentityDisplayChanged)
    IdentityShowAccountCheck := PreviewSettingsGui.AddCheckBox("x194 y447 w116 h24", "Account Name")
    IdentityShowAccountCheck.Value := Settings["IdentityShowAccount"] ? 1 : 0
    IdentityShowAccountCheck.OnEvent("Click", IdentityDisplayChanged)
    PreviewShowActiveHotkeysCheck := PreviewSettingsGui.AddCheckBox("x316 y447 w195 h24", "Active Hotkeys (green)")
    PreviewShowActiveHotkeysCheck.Value := Settings["PreviewShowActiveHotkeys"] ? 1 : 0
    PreviewShowActiveHotkeysCheck.OnEvent("Click", PreviewActiveHotkeysDisplayChanged)

    PreviewSettingsGui.AddText("x12 y480 w92 h22 +0x200", "Preview ID:")
    PreviewIdentityPositionDropDown := PreviewSettingsGui.AddDropDownList("x106 y478 w88 r3", ["Top", "Middle", "Bottom"])
    PreviewIdentityPositionDropDown.Choose(Settings["PreviewIdentityPosition"] = "Middle" ? 2 : (Settings["PreviewIdentityPosition"] = "Bottom" ? 3 : 1))
    PreviewIdentityPositionDropDown.OnEvent("Change", PreviewIdentityDisplayChanged)
    PreviewIdentityHorizontalDropDown := PreviewSettingsGui.AddDropDownList("x200 y478 w92 r3", ["Left", "Center", "Right"])
    PreviewIdentityHorizontalDropDown.Choose(Settings["PreviewIdentityHorizontal"] = "Left" ? 1 : (Settings["PreviewIdentityHorizontal"] = "Right" ? 3 : 2))
    PreviewIdentityHorizontalDropDown.OnEvent("Change", PreviewIdentityDisplayChanged)
    PreviewIdentitySizeSlider := PreviewSettingsGui.AddSlider("x300 y480 w130 h24 Range10-40 ToolTip", Settings["PreviewIdentityTextSize"])
    PreviewIdentitySizeSlider.OnEvent("Change", PreviewIdentityDisplayChanged)
    PreviewIdentitySizeLabel := PreviewSettingsGui.AddText("x438 y480 w73 h22 +Center", Settings["PreviewIdentityTextSize"] " pt")

    GameIdentityShowCheck := PreviewSettingsGui.AddCheckBox("x12 y509 w240 h24", "Show Game IDs")
    GameIdentityShowCheck.Value := Settings["ShowOverlay"] ? 1 : 0
    GameIdentityShowCheck.OnEvent("Click", GameIdentityShowChanged)
    GameIdentityVerticalDropDown := PreviewSettingsGui.AddDropDownList("x106 y539 w88 r3", ["Top", "Middle", "Bottom"])
    GameIdentityVerticalDropDown.Choose(Settings["GameIdentityVertical"] = "Middle" ? 2 : (Settings["GameIdentityVertical"] = "Bottom" ? 3 : 1))
    GameIdentityVerticalDropDown.OnEvent("Change", GameIdentityPositionChanged)
    GameIdentityHorizontalDropDown := PreviewSettingsGui.AddDropDownList("x200 y539 w92 r3", ["Left", "Center", "Right"])
    GameIdentityHorizontalDropDown.Choose(Settings["GameIdentityHorizontal"] = "Center" ? 2 : (Settings["GameIdentityHorizontal"] = "Right" ? 3 : 1))
    GameIdentityHorizontalDropDown.OnEvent("Change", GameIdentityPositionChanged)
    GameIdentitySizeSlider := PreviewSettingsGui.AddSlider("x300 y541 w130 h24 Range10-48 ToolTip", Settings["GameIdentityTextSize"])
    GameIdentitySizeSlider.OnEvent("Change", GameIdentitySizeChanged)
    GameIdentitySizeLabel := PreviewSettingsGui.AddText("x438 y541 w73 h22 +Center", Settings["GameIdentityTextSize"] " pt")

    PreviewSettingsGui.AddText("x12 y216 w94 h22 +0x200", "Preview Accounts:")
    PreviewAccountSummary := PreviewSettingsGui.AddText("x110 y216 w265 h44 +Wrap", "")
    choosePreviewAccountsBtn := PreviewSettingsGui.AddButton("x385 y216 w126 h28", "Choose Accounts")
    choosePreviewAccountsBtn.OnEvent("Click", ShowPreviewAccountPicker)
    mockPreviewCheck := PreviewSettingsGui.AddCheckBox("x271 y118 w240 h24", "Preview Positions")
    mockPreviewCheck.Value := PreviewPositionOverlays.Count ? 1 : 0
    mockPreviewCheck.OnEvent("Click", TogglePreviewPositionOverlays)
    RegisterTooltip(mockPreviewCheck, "Show draggable blue mock previews using saved positions, even while Foxhole is closed.")

    PreviewShowWhenUnfocusedCheck := PreviewSettingsGui.AddCheckBox("x12 y608 w499 h24", "Show previews when Foxhole is unfocused")
    PreviewShowWhenUnfocusedCheck.Value := Settings["PreviewShowWhenFoxholeUnfocused"] ? 1 : 0
    PreviewShowWhenUnfocusedCheck.OnEvent("Click", PreviewShowWhenUnfocusedChanged)
    RegisterTooltip(PreviewShowWhenUnfocusedCheck, "When unchecked, live previews automatically hide whenever no Foxhole game window is focused, then return when Foxhole regains focus.")

    PreviewHoverHotkeysCheck := PreviewSettingsGui.AddCheckBox("x12 y635 w499 h24", "Mouse Focus: game hotkeys target hovered preview")
    PreviewHoverHotkeysCheck.Value := Settings["PreviewHoverHotkeys"] ? 1 : 0
    PreviewHoverHotkeysCheck.OnEvent("Click", PreviewHoverHotkeysChanged)
    RegisterTooltip(PreviewHoverHotkeysCheck, "When Mouse Focus is enabled, hovering a preview makes game hotkeys target that preview's Foxhole window. The real game window does not need to be brought to the front.")

    PreviewHoverBringToFrontCheck := PreviewSettingsGui.AddCheckBox("x12 y662 w499 h24", "Mouse Focus: hovered preview brings game to front")
    PreviewHoverBringToFrontCheck.Value := Settings["PreviewHoverBringToFront"] ? 1 : 0
    PreviewHoverBringToFrontCheck.OnEvent("Click", PreviewHoverBringToFrontChanged)
    RegisterTooltip(PreviewHoverBringToFrontCheck, "When Mouse Focus is enabled, moving the mouse onto a preview brings that preview's Foxhole window to the front, like Next/Last Game.")
    UpdatePreviewAccountSummary()

    PreviewSettingsGui.OnEvent("Close", (*) => SwitchMainPage("Main"))
    PreviewSettingsGui.OnEvent("Escape", (*) => SwitchMainPage("Main"))

    DisposeEmbeddedPage(oldGui)
}
UpdatePreviewAccountSummary(*)
{
    global PreviewAccountSummary, PreviewConfigs, SandboxieAccounts
    if !IsObject(PreviewAccountSummary)
        return
    names := []
    for index, account in SandboxieAccounts
    {
        if !account.selected
            continue
        EnsureFoxholePreviewConfig(index)
        if PreviewConfigs[index].enabled
            names.Push(GetSandboxieDisplayName(index))
    }
    PreviewAccountSummary.Text := names.Length ? names.Length " selected — " JoinText(names, ", ") : "None selected"
}

ShowPreviewAccountPicker(*)
{
    global PreviewAccountPickerGui, PreviewAccountPickerChecks, PreviewConfigs, SandboxieAccounts, MainGui
    selected := GetSelectedAccountIndices()
    if selected.Length = 0
    {
        MsgBox("No accounts are currently marked Selected on the Accounts & Sandboxes page.", "Choose Preview Accounts", "Icon!")
        return
    }
    PreviewAccountPickerGui := Gui("+Owner" MainGui.Hwnd, "Choose Preview Accounts")
    PreviewAccountPickerGui.SetFont("s9", "Segoe UI")
    PreviewAccountPickerGui.AddText("x12 y10 w336 h42 +Wrap", "Choose which Selected accounts should have Foxhole previews.")
    PreviewAccountPickerChecks := []
    y := 58
    for index in selected
    {
        EnsureFoxholePreviewConfig(index)
        account := SandboxieAccounts[index]
        label := Trim(account.name) != "" ? Trim(account.name) : "Row " index
        if account.main
            label .= " (Main)"
        check := PreviewAccountPickerGui.AddCheckBox("x16 y" y " w300 h24", label)
        check.Value := PreviewConfigs[index].enabled ? 1 : 0
        PreviewAccountPickerChecks.Push({control: check, slot: index})
        y += 27
    }
    allBtn := PreviewAccountPickerGui.AddButton("x12 y" (y+4) " w82 h27", "Select All")
    allBtn.OnEvent("Click", SetAllPreviewAccountPickerChecks.Bind(true))
    noneBtn := PreviewAccountPickerGui.AddButton("x100 y" (y+4) " w82 h27", "Clear All")
    noneBtn.OnEvent("Click", SetAllPreviewAccountPickerChecks.Bind(false))
    cancelBtn := PreviewAccountPickerGui.AddButton("x202 y" (y+4) " w70 h27", "Cancel")
    cancelBtn.OnEvent("Click", (*) => PreviewAccountPickerGui.Destroy())
    okBtn := PreviewAccountPickerGui.AddButton("x278 y" (y+4) " w70 h27 Default", "OK")
    okBtn.OnEvent("Click", SavePreviewAccountPicker)
    PreviewAccountPickerGui.OnEvent("Close", (*) => PreviewAccountPickerGui.Destroy())
    PreviewAccountPickerGui.Show("w360 h" (y+47))
}

SetAllPreviewAccountPickerChecks(value, *)
{
    global PreviewAccountPickerChecks
    for item in PreviewAccountPickerChecks
        item.control.Value := value ? 1 : 0
}

SavePreviewAccountPicker(*)
{
    global PreviewAccountPickerGui, PreviewAccountPickerChecks, PreviewConfigs, Settings, PreviewMasterVisibleCheck
    for item in PreviewAccountPickerChecks
    {
        EnsureFoxholePreviewConfig(item.slot)
        PreviewConfigs[item.slot].enabled := item.control.Value = 1
        SaveFoxholePreviewConfig(item.slot)
    }
    PreviewAccountPickerGui.Destroy()
    if !Settings["PreviewsVisible"]
    {
        for item in PreviewAccountPickerChecks
            if PreviewConfigs[item.slot].enabled
            {
                Settings["PreviewsVisible"] := true
                if IsObject(PreviewMasterVisibleCheck)
                    PreviewMasterVisibleCheck.Value := 1
                SaveConfig()
                break
            }
    }
    UpdatePreviewAccountSummary()
    SyncFoxholePreviews()
    RefreshPreviewPositionOverlays()
}

FindPreviewPositionMockSlotByHwnd(hwnd)
{
    global PreviewPositionOverlays
    for slot, rec in PreviewPositionOverlays
    {
        guiHwnd := IsObject(rec) && rec.HasOwnProp("gui") ? GetGuiHwndSafe(rec.gui) : 0
        textHwnd := IsObject(rec) && rec.HasOwnProp("text") ? GetGuiHwndSafe(rec.text) : 0
        if (guiHwnd && guiHwnd = hwnd) || (textHwnd && textHwnd = hwnd)
            return slot
    }
    return 0
}

TogglePreviewPositionOverlays(*)
{
    global PreviewPositionOverlays
    if PreviewPositionOverlays.Count
        DestroyPreviewPositionOverlays()
    else
        ShowPreviewPositionOverlays()
}

ShowPreviewPositionOverlays()
{
    global PreviewPositionOverlays, PreviewConfigs, SandboxieAccounts, PreviewUnsetCoordinate
    DestroyPreviewPositionOverlays()
    for index, account in SandboxieAccounts
    {
        if !account.selected
            continue
        EnsureFoxholePreviewConfig(index)
        cfg := PreviewConfigs[index]
        if !cfg.enabled
            continue
        if cfg.x = PreviewUnsetCoordinate || cfg.y = PreviewUnsetCoordinate
        {
            rect := GetFoxholePreviewInitialRect(index, cfg.width, cfg.height)
            cfg.x := rect.x, cfg.y := rect.y, cfg.width := rect.width, cfg.height := rect.height
            SaveFoxholePreviewConfig(index)
        }
        g := Gui("+AlwaysOnTop -Caption +ToolWindow", "Preview Position " index)
        g.BackColor := "1976D2"
        g.SetFont("s12 cFFFFFF Bold", "Segoe UI")
        t := g.AddText("x0 y0 w" cfg.width " h" cfg.height " Center +0x200 +Border", "PREVIEW " index)
        try WinSetExStyle("+0x20", "ahk_id " t.Hwnd)
        g.Show("NA x" cfg.x " y" cfg.y " w" cfg.width " h" cfg.height)
        try WinSetTransparent(70, "ahk_id " g.Hwnd)
        PreviewPositionOverlays[index] := {gui: g, text: t}
    }
}

RefreshPreviewPositionOverlays()
{
    global PreviewPositionOverlays
    if PreviewPositionOverlays.Count
        ShowPreviewPositionOverlays()
}

DestroyPreviewPositionOverlays()
{
    global PreviewPositionOverlays
    for _, rec in PreviewPositionOverlays
        try rec.gui.Destroy()
    PreviewPositionOverlays := Map()
}

SavePreviewPositionMock(slot)
{
    global PreviewPositionOverlays, PreviewConfigs
    if !PreviewPositionOverlays.Has(slot)
        return
    rec := PreviewPositionOverlays[slot]
    guiHwnd := IsObject(rec) && rec.HasOwnProp("gui") ? GetGuiHwndSafe(rec.gui) : 0
    if !guiHwnd || !DllCall("IsWindow", "Ptr", guiHwnd, "Int")
        return
    try WinGetPos(&x, &y, &w, &h, "ahk_id " guiHwnd)
    catch
        return
    rect := ClampFoxholePreviewRect(x, y, w, h)
    EnsureFoxholePreviewConfig(slot)
    PreviewConfigs[slot].x := rect.x
    PreviewConfigs[slot].y := rect.y
    PreviewConfigs[slot].width := rect.width
    PreviewConfigs[slot].height := rect.height
    SaveFoxholePreviewConfig(slot)
    try WinMove(rect.x, rect.y, rect.width, rect.height, "ahk_id " guiHwnd)
}

PreviewResizeAllEqualChanged(ctrl, *)
{
    global Settings
    Settings["PreviewResizeAllEqual"] := ctrl.Value = 1
    SaveConfig()
}

PreviewMoveAllTogetherChanged(ctrl, *)
{
    global Settings
    Settings["PreviewMoveAllTogether"] := ctrl.Value = 1
    SaveConfig()
}

IdentityDisplayChanged(ctrl, *)
{
    global Settings, IdentityShowSlotCheck, IdentityShowAccountCheck
    Settings["IdentityShowSlot"] := IsObject(IdentityShowSlotCheck) && IdentityShowSlotCheck.Value = 1
    Settings["IdentityShowAccount"] := IsObject(IdentityShowAccountCheck) && IdentityShowAccountCheck.Value = 1
    SaveConfig()
    RefreshAllPreviewIdentityOverlays(true)
    RebuildAllTitleOverlays()
    InvalidateFocusFlashCache()
}

PreviewActiveHotkeysDisplayChanged(ctrl, *)
{
    global Settings
    Settings["PreviewShowActiveHotkeys"] := ctrl.Value = 1
    SaveConfig()
    RefreshAllPreviewIdentityOverlays(true)
}

PreviewShowWhenUnfocusedChanged(ctrl, *)
{
    global Settings
    Settings["PreviewShowWhenFoxholeUnfocused"] := ctrl.Value = 1
    SaveConfig()
    SyncFoxholePreviews()
}

PreviewHoverHotkeysChanged(ctrl, *)
{
    global Settings
    Settings["PreviewHoverHotkeys"] := ctrl.Value = 1
    SaveConfig()
}

PreviewHoverBringToFrontChanged(ctrl, *)
{
    global Settings, LastPreviewHoverFrontSlot
    Settings["PreviewHoverBringToFront"] := ctrl.Value = 1
    LastPreviewHoverFrontSlot := 0
    SaveConfig()
}

PreviewIdentityDisplayChanged(ctrl, *)
{
    global Settings, PreviewIdentityPositionDropDown, PreviewIdentityHorizontalDropDown
    global PreviewIdentitySizeSlider, PreviewIdentitySizeLabel

    if IsObject(PreviewIdentityPositionDropDown)
        Settings["PreviewIdentityPosition"] := PreviewIdentityPositionDropDown.Text
    if IsObject(PreviewIdentityHorizontalDropDown)
        Settings["PreviewIdentityHorizontal"] := PreviewIdentityHorizontalDropDown.Text
    if IsObject(PreviewIdentitySizeSlider)
        Settings["PreviewIdentityTextSize"] := Max(10, Min(40, Round(PreviewIdentitySizeSlider.Value)))
    if IsObject(PreviewIdentitySizeLabel)
        PreviewIdentitySizeLabel.Text := Settings["PreviewIdentityTextSize"] " pt"

    SaveConfig()
    RefreshAllPreviewIdentityOverlays(true)
}

GameIdentityShowChanged(ctrl, *)
{
    global Settings, ShowOverlayCheck
    Settings["ShowOverlay"] := ctrl.Value = 1
    if IsObject(ShowOverlayCheck)
        ShowOverlayCheck.Value := ctrl.Value
    SaveConfig()
    UpdateAllTitleOverlays()
}

GameIdentityPositionChanged(ctrl, *)
{
    global Settings, GameIdentityVerticalDropDown, GameIdentityHorizontalDropDown

    if IsObject(GameIdentityVerticalDropDown)
        Settings["GameIdentityVertical"] := GameIdentityVerticalDropDown.Text
    if IsObject(GameIdentityHorizontalDropDown)
        Settings["GameIdentityHorizontal"] := GameIdentityHorizontalDropDown.Text

    SaveConfig()
    UpdateAllTitleOverlays()
}

GameIdentitySizeChanged(ctrl, *)
{
    global Settings, GameIdentitySizeLabel
    Settings["GameIdentityTextSize"] := Max(10, Min(48, Round(ctrl.Value)))
    if IsObject(GameIdentitySizeLabel)
        GameIdentitySizeLabel.Text := Settings["GameIdentityTextSize"] " pt"

    SaveConfig()
    RebuildAllTitleOverlays()
}

PreviewSnapTogetherChanged(ctrl, *)
{
    global Settings
    Settings["PreviewSnapTogether"] := ctrl.Value = 1
    SaveConfig()
    if Settings["PreviewSnapTogether"]
        NormalizeFoxholePreviewLayout()
}

RefreshPreviewLayoutDropDown(selectedName := "")
{
    global PreviewLayoutDropDown, PreviewLayouts
    if !IsObject(PreviewLayoutDropDown)
        return
    names := []
    selectedIndex := 0
    for index, layout in PreviewLayouts
    {
        names.Push(layout.name)
        if selectedName != "" && StrLower(layout.name) = StrLower(selectedName)
            selectedIndex := index
    }
    PreviewLayoutDropDown.Delete()
    if names.Length
    {
        PreviewLayoutDropDown.Add(names)
        PreviewLayoutDropDown.Choose(selectedIndex ? selectedIndex : 1)
    }
}

PreviewLayoutSelectionChanged(ctrl, *)
{
    global PreviewLayouts, Settings
    if ctrl.Value >= 1 && ctrl.Value <= PreviewLayouts.Length
        Settings["LastPreviewLayoutName"] := PreviewLayouts[ctrl.Value].name
    else
        Settings["LastPreviewLayoutName"] := ""
    SaveConfig()
}

SaveCurrentPreviewLayout(*)
{
    global PreviewLayouts, PreviewConfigs, MaxPracticalInstances, StatusText, Settings
    result := InputBox("Enter a name for this preview layout.", "Save Preview Layout", "w360 h135")
    if result.Result != "OK"
        return
    name := Trim(result.Value)
    if name = ""
        return

    slots := []
    Loop MaxPracticalInstances
    {
        slot := A_Index
        EnsureFoxholePreviewConfig(slot)
        cfg := PreviewConfigs[slot]
        slots.Push({slot: slot, enabled: cfg.enabled, x: cfg.x, y: cfg.y, width: cfg.width, height: cfg.height})
    }

    replaceIndex := 0
    for index, layout in PreviewLayouts
    {
        if StrLower(layout.name) = StrLower(name)
        {
            replaceIndex := index
            break
        }
    }
    newLayout := {name: name, opacity: Settings["PreviewOpacity"], horizontalGap: 0, verticalGap: 0, slots: slots}
    if replaceIndex
        PreviewLayouts[replaceIndex] := newLayout
    else
        PreviewLayouts.Push(newLayout)
    SavePreviewLayoutsConfig()
    RefreshPreviewLayoutDropDown(name)
    StatusText.Text := "Status: Saved preview layout '" name "'."
}

UpdateSelectedPreviewLayout(*)
{
    global PreviewLayoutDropDown, PreviewLayouts, PreviewConfigs, MaxPracticalInstances, Settings, StatusText
    if !IsObject(PreviewLayoutDropDown) || PreviewLayoutDropDown.Value < 1 || PreviewLayoutDropDown.Value > PreviewLayouts.Length
        return

    index := PreviewLayoutDropDown.Value
    name := PreviewLayouts[index].name
    slots := []
    Loop MaxPracticalInstances
    {
        slot := A_Index
        EnsureFoxholePreviewConfig(slot)
        cfg := PreviewConfigs[slot]
        slots.Push({slot: slot, enabled: cfg.enabled, x: cfg.x, y: cfg.y, width: cfg.width, height: cfg.height})
    }

    PreviewLayouts[index] := {name: name, opacity: Settings["PreviewOpacity"], horizontalGap: 0, verticalGap: 0, slots: slots}
    SavePreviewLayoutsConfig()
    RefreshPreviewLayoutDropDown(name)
    StatusText.Text := "Status: Updated preview layout '" name "'."
}

LoadSelectedPreviewLayout(*)
{
    global PreviewLayoutDropDown, PreviewLayouts, PreviewConfigs, PreviewWindows, PreviewEnableChecks
    global PreviewOpacitySlider, PreviewOpacityLabel, Settings, PreviewMasterVisibleCheck, StatusText
    if !IsObject(PreviewLayoutDropDown) || PreviewLayoutDropDown.Value < 1 || PreviewLayoutDropDown.Value > PreviewLayouts.Length
        return
    layout := PreviewLayouts[PreviewLayoutDropDown.Value]
    Settings["LastPreviewLayoutName"] := layout.name
    for slot, cfg in PreviewConfigs
        cfg.enabled := false
    for saved in layout.slots
    {
        EnsureFoxholePreviewConfig(saved.slot)
        cfg := PreviewConfigs[saved.slot]
        cfg.enabled := saved.enabled
        cfg.x := saved.x
        cfg.y := saved.y
        cfg.width := saved.width
        cfg.height := saved.height
        SaveFoxholePreviewConfig(saved.slot)
        if PreviewEnableChecks.Has(saved.slot)
            PreviewEnableChecks[saved.slot].Value := cfg.enabled ? 1 : 0
    }
    slotsToDestroy := []
    for slot, _ in PreviewWindows
        slotsToDestroy.Push(slot)
    for slot in slotsToDestroy
        DestroyFoxholePreview(slot)
    Settings["PreviewsVisible"] := true
    if HasProp(layout, "opacity")
        Settings["PreviewOpacity"] := Max(20, Min(100, Integer(layout.opacity)))
    if IsObject(PreviewMasterVisibleCheck)
        PreviewMasterVisibleCheck.Value := 1
    if IsObject(PreviewOpacitySlider)
        PreviewOpacitySlider.Value := Settings["PreviewOpacity"]
    if IsObject(PreviewOpacityLabel)
        PreviewOpacityLabel.Text := Settings["PreviewOpacity"] "%"
    SaveConfig()
    SyncFoxholePreviews()
    UpdatePreviewAccountSummary()
    RefreshPreviewPositionOverlays()
    StatusText.Text := "Status: Loaded preview layout '" layout.name "'."
}

DeleteSelectedPreviewLayout(*)
{
    global PreviewLayoutDropDown, PreviewLayouts, StatusText
    if !IsObject(PreviewLayoutDropDown) || PreviewLayoutDropDown.Value < 1 || PreviewLayoutDropDown.Value > PreviewLayouts.Length
        return
    name := PreviewLayouts[PreviewLayoutDropDown.Value].name
    PreviewLayouts.RemoveAt(PreviewLayoutDropDown.Value)
    SavePreviewLayoutsConfig()
    RefreshPreviewLayoutDropDown()
    StatusText.Text := "Status: Deleted preview layout '" name "'."
}

LoadPreviewLayoutsConfig()
{
    global CONFIG_FILE, PreviewLayouts
    PreviewLayouts := []
    count := Max(0, Integer(IniRead(CONFIG_FILE, "PreviewLayouts", "Count", "0")))
    Loop count
    {
        section := "PreviewLayout" A_Index
        name := Trim(IniRead(CONFIG_FILE, section, "Name", ""))
        if name = ""
            continue
        slotCount := Max(0, Integer(IniRead(CONFIG_FILE, section, "SlotCount", "0")))
        savedOpacityRaw := Integer(IniRead(CONFIG_FILE, section, "Opacity", "-1"))
        legacyOpacity := -1
        slots := []
        Loop slotCount
        {
            slot := A_Index
            prefix := "Slot" slot "_"
            oldOpacity := Max(20, Min(100, Integer(IniRead(CONFIG_FILE, section, prefix "Opacity", "75"))))
            if legacyOpacity < 0
                legacyOpacity := oldOpacity
            slots.Push({
                slot: slot,
                enabled: IniRead(CONFIG_FILE, section, prefix "Enabled", "0") = "1",
                x: Integer(IniRead(CONFIG_FILE, section, prefix "X", "2147483647")),
                y: Integer(IniRead(CONFIG_FILE, section, prefix "Y", "2147483647")),
                width: Max(120, Integer(IniRead(CONFIG_FILE, section, prefix "W", "320"))),
                height: Max(68, Integer(IniRead(CONFIG_FILE, section, prefix "H", "180")))
            })
        }
        layoutOpacity := savedOpacityRaw >= 20 && savedOpacityRaw <= 100 ? savedOpacityRaw : (legacyOpacity >= 20 ? legacyOpacity : 75)
        layoutHorizontalGap := Max(0, Min(64, Integer(IniRead(CONFIG_FILE, section, "HorizontalGap", "0"))))
        layoutVerticalGap := Max(0, Min(64, Integer(IniRead(CONFIG_FILE, section, "VerticalGap", "0"))))
        PreviewLayouts.Push({name: name, opacity: layoutOpacity, horizontalGap: layoutHorizontalGap, verticalGap: layoutVerticalGap, slots: slots})
    }
}
SavePreviewLayoutsConfig()
{
    global CONFIG_FILE, PreviewLayouts
    oldCount := Max(0, Integer(IniRead(CONFIG_FILE, "PreviewLayouts", "Count", "0")))
    maxCount := Max(oldCount, PreviewLayouts.Length)
    Loop maxCount
    {
        section := "PreviewLayout" A_Index
        if A_Index > PreviewLayouts.Length
        {
            IniDelete(CONFIG_FILE, section)
            continue
        }
        layout := PreviewLayouts[A_Index]
        opacity := HasProp(layout, "opacity") ? Max(20, Min(100, Integer(layout.opacity))) : 75
        horizontalGap := HasProp(layout, "horizontalGap") ? Max(0, Min(64, Integer(layout.horizontalGap))) : 0
        verticalGap := HasProp(layout, "verticalGap") ? Max(0, Min(64, Integer(layout.verticalGap))) : 0
        sectionText := "Name=" layout.name "`nSlotCount=" layout.slots.Length "`nOpacity=" opacity
            . "`nHorizontalGap=" horizontalGap "`nVerticalGap=" verticalGap
        for saved in layout.slots
        {
            prefix := "Slot" saved.slot "_"
            sectionText .= "`n" prefix "Enabled=" (saved.enabled ? 1 : 0)
            sectionText .= "`n" prefix "X=" Round(saved.x)
            sectionText .= "`n" prefix "Y=" Round(saved.y)
            sectionText .= "`n" prefix "W=" Round(saved.width)
            sectionText .= "`n" prefix "H=" Round(saved.height)
        }
        IniWrite(sectionText, CONFIG_FILE, section)
    }
    IniWrite(PreviewLayouts.Length, CONFIG_FILE, "PreviewLayouts", "Count")
}
EnsureFoxholePreviewConfig(slot)
{
    global PreviewConfigs, PreviewDefaultWidth, PreviewDefaultHeight, PreviewUnsetCoordinate
    if PreviewConfigs.Has(slot)
        return PreviewConfigs[slot]
    PreviewConfigs[slot] := {
        enabled: false,
        x: PreviewUnsetCoordinate,
        y: PreviewUnsetCoordinate,
        width: PreviewDefaultWidth,
        height: PreviewDefaultHeight,
        opacity: 75
    }
    return PreviewConfigs[slot]
}

LoadFoxholePreviewConfig()
{
    global CONFIG_FILE, PreviewConfigs, MaxPracticalInstances, PreviewDefaultWidth, PreviewDefaultHeight, PreviewUnsetCoordinate
    PreviewConfigs := Map()
    Loop MaxPracticalInstances
    {
        slot := A_Index
        section := "PreviewSlot" slot
        PreviewConfigs[slot] := {
            enabled: IniRead(CONFIG_FILE, section, "Enabled", "0") = "1",
            x: Integer(IniRead(CONFIG_FILE, section, "X", String(PreviewUnsetCoordinate))),
            y: Integer(IniRead(CONFIG_FILE, section, "Y", String(PreviewUnsetCoordinate))),
            width: Max(120, Integer(IniRead(CONFIG_FILE, section, "W", String(PreviewDefaultWidth)))),
            height: Max(68, Integer(IniRead(CONFIG_FILE, section, "H", String(PreviewDefaultHeight)))),
            opacity: Max(20, Min(100, Integer(IniRead(CONFIG_FILE, section, "Opacity", "75"))))
        }
    }
}

SaveFoxholePreviewConfig(slot)
{
    global CONFIG_FILE, PreviewConfigs
    if !PreviewConfigs.Has(slot)
        return
    cfg := PreviewConfigs[slot]
    section := "PreviewSlot" slot
    IniWrite(cfg.enabled ? "1" : "0", CONFIG_FILE, section, "Enabled")
    IniWrite(Round(cfg.x), CONFIG_FILE, section, "X")
    IniWrite(Round(cfg.y), CONFIG_FILE, section, "Y")
    IniWrite(Round(cfg.width), CONFIG_FILE, section, "W")
    IniWrite(Round(cfg.height), CONFIG_FILE, section, "H")
    IniWrite(Round(cfg.opacity), CONFIG_FILE, section, "Opacity")
}

MakePreviewEnabledHandler(slot)
{
    return (ctrl, *) => SetFoxholePreviewEnabled(slot, ctrl.Value = 1)
}

MakePreviewOpacityHandler(slot)
{
    return (ctrl, *) => SetFoxholePreviewOpacity(slot, ctrl.Value)
}

MakePreviewResetHandler(slot)
{
    return (*) => ResetFoxholePreview(slot)
}

SetFoxholePreviewEnabled(slot, enabled)
{
    global PreviewConfigs, Settings, PreviewMasterVisibleCheck
    EnsureFoxholePreviewConfig(slot)
    PreviewConfigs[slot].enabled := enabled
    SaveFoxholePreviewConfig(slot)
    if enabled && !Settings["PreviewsVisible"]
    {
        Settings["PreviewsVisible"] := true
        if IsObject(PreviewMasterVisibleCheck)
            PreviewMasterVisibleCheck.Value := 1
        SaveConfig()
    }
    SyncFoxholePreviews()
}

SetAllFoxholePreviewOpacity(ctrl, *)
{
    global Settings, PreviewOpacityLabel, PreviewWindows
    value := IsObject(ctrl) ? ctrl.Value : ctrl
    opacity := Max(20, Min(100, Integer(value)))
    Settings["PreviewOpacity"] := opacity
    if IsObject(PreviewOpacityLabel)
        PreviewOpacityLabel.Text := opacity "%"
    SaveConfig()
    for slot, _ in PreviewWindows
        UpdateFoxholePreviewThumbnail(slot)
}

SetFoxholePreviewOpacity(slot, value)
{

    SetAllFoxholePreviewOpacity(value)
}
GetPreviewSizeSliderWidth()
{
    global PreviewWindows, PreviewConfigs, LastFocusedFoxholeHwnd, PreviewDefaultWidth

    if LastFocusedFoxholeHwnd
    {
        for slot, preview in PreviewWindows
        {
            if preview.sourceHwnd = LastFocusedFoxholeHwnd
            {
                try WinGetPos(, , &w, , "ahk_id " GetGuiHwndSafe(preview.gui))
                catch
                    w := 0
                if w > 0
                    return Max(160, Min(640, Round(w)))
            }
        }
    }

    for _, preview in PreviewWindows
    {
        try WinGetPos(, , &w, , "ahk_id " GetGuiHwndSafe(preview.gui))
        catch
            w := 0
        if w > 0
            return Max(160, Min(640, Round(w)))
    }

    for _, cfg in PreviewConfigs
        if cfg.enabled && cfg.width > 0
            return Max(160, Min(640, Round(cfg.width)))

    return Max(160, Min(640, PreviewDefaultWidth))
}

SetFoxholePreviewSizeFromSlider(ctrl, *)
{
    global PreviewSizeLabel, PreviewWindows, PreviewConfigs, Settings, LastFocusedFoxholeHwnd

    width := Max(160, Min(640, Round(ctrl.Value)))
    if IsObject(PreviewSizeLabel)
        PreviewSizeLabel.Text := width " px"

    targets := []
    if Settings["PreviewResizeAllEqual"]
    {
        for slot, preview in PreviewWindows
            targets.Push(slot)
    }
    else
    {
        focusedSlot := 0
        if LastFocusedFoxholeHwnd
        {
            for slot, preview in PreviewWindows
            {
                if preview.sourceHwnd = LastFocusedFoxholeHwnd
                {
                    focusedSlot := slot
                    break
                }
            }
        }
        if focusedSlot
            targets.Push(focusedSlot)
        else
        {
            for slot, _ in PreviewWindows
            {
                targets.Push(slot)
                break
            }
        }
    }

    if !targets.Length
        return

    for slot in targets
    {
        if !PreviewWindows.Has(slot) || !PreviewConfigs.Has(slot)
            continue
        preview := PreviewWindows[slot]
        sourceSize := GetFoxholeSourceSize(preview.sourceHwnd)
        aspect := (sourceSize.width > 0 && sourceSize.height > 0) ? (sourceSize.width / sourceSize.height) : (16 / 9)
        height := Max(68, Round(width / aspect))

        try WinGetPos(&x, &y, , , "ahk_id " GetGuiHwndSafe(preview.gui))
        catch
            continue

        clamped := ClampFoxholePreviewRect(x, y, width, height)
        try WinMove(clamped.x, clamped.y, clamped.width, clamped.height, "ahk_id " GetGuiHwndSafe(preview.gui))

        cfg := PreviewConfigs[slot]
        cfg.x := clamped.x
        cfg.y := clamped.y
        cfg.width := clamped.width
        cfg.height := clamped.height
        SaveFoxholePreviewConfig(slot)
        UpdateFoxholePreviewThumbnail(slot)
    }

    if Settings["PreviewSnapTogether"]
    {
        NormalizeFoxholePreviewLayout()
        SetTimer(FixBorderlessPreviewOverlaps, -1)
    }
}

PreviewMasterVisibleChanged(ctrl, *)
{
    global Settings, StatusText
    Settings["PreviewsVisible"] := ctrl.Value = 1
    SaveConfig()
    SyncFoxholePreviews()
    StatusText.Text := "Status: Foxhole previews " (Settings["PreviewsVisible"] ? "shown." : "hidden.")
}

PreviewEditModeChanged(ctrl, *)
{
    global Settings, StatusText
    Settings["PreviewEditMode"] := ctrl.Value = 1
    SaveConfig()
    RefreshFoxholePreviewEditState()
    StatusText.Text := "Status: Preview Edit Mode " (Settings["PreviewEditMode"] ? "enabled." : "disabled.")
}

ShowAllFoxholePreviews(*)
{
    global Instances, PreviewConfigs, PreviewEnableChecks, Settings, PreviewMasterVisibleCheck
    Settings["PreviewsVisible"] := true
    if IsObject(PreviewMasterVisibleCheck)
        PreviewMasterVisibleCheck.Value := 1
    seen := Map()
    for inst in Instances
    {
        if !IsWindowAlive(inst.hwnd) || seen.Has(inst.slot)
            continue
        seen[inst.slot] := true
        EnsureFoxholePreviewConfig(inst.slot)
        PreviewConfigs[inst.slot].enabled := true
        SaveFoxholePreviewConfig(inst.slot)
        if PreviewEnableChecks.Has(inst.slot)
            PreviewEnableChecks[inst.slot].Value := 1
    }
    SaveConfig()
    SyncFoxholePreviews()
    UpdatePreviewAccountSummary()
    RefreshPreviewPositionOverlays()
}

HideAllFoxholePreviews(*)
{
    global PreviewConfigs, PreviewEnableChecks
    for slot, cfg in PreviewConfigs
    {
        if cfg.enabled
        {
            cfg.enabled := false
            SaveFoxholePreviewConfig(slot)
        }
        if PreviewEnableChecks.Has(slot)
            PreviewEnableChecks[slot].Value := 0
    }
    SyncFoxholePreviews()
    UpdatePreviewAccountSummary()
    RefreshPreviewPositionOverlays()
}

ResetAllFoxholePreviews(*)
{
    global PreviewConfigs, PreviewWindows, PreviewUnsetCoordinate, PreviewDefaultWidth, PreviewDefaultHeight
    for slot, cfg in PreviewConfigs
    {
        cfg.x := PreviewUnsetCoordinate
        cfg.y := PreviewUnsetCoordinate
        cfg.width := PreviewDefaultWidth
        cfg.height := PreviewDefaultHeight
        SaveFoxholePreviewConfig(slot)
        if PreviewWindows.Has(slot)
            DestroyFoxholePreview(slot)
    }
    SyncFoxholePreviews()
}

ResetFoxholePreview(slot)
{
    global PreviewConfigs, PreviewUnsetCoordinate, PreviewDefaultWidth, PreviewDefaultHeight
    EnsureFoxholePreviewConfig(slot)
    cfg := PreviewConfigs[slot]
    cfg.x := PreviewUnsetCoordinate
    cfg.y := PreviewUnsetCoordinate
    cfg.width := PreviewDefaultWidth
    cfg.height := PreviewDefaultHeight
    SaveFoxholePreviewConfig(slot)
    DestroyFoxholePreview(slot)
    SyncFoxholePreviews()
}

ToggleFoxholePreviews(*)
{
    global Settings, PreviewMasterVisibleCheck, StatusText
    Settings["PreviewsVisible"] := !Settings["PreviewsVisible"]
    if IsObject(PreviewMasterVisibleCheck)
        PreviewMasterVisibleCheck.Value := Settings["PreviewsVisible"] ? 1 : 0
    SaveConfig()
    SyncFoxholePreviews()
    StatusText.Text := "Status: Foxhole previews " (Settings["PreviewsVisible"] ? "shown." : "hidden.")
}

SyncFoxholePreviews(*)
{
    global PreviewSyncBusy, Settings, PreviewWindows, PreviewConfigs, Instances
    if PreviewSyncBusy
        return
    PreviewSyncBusy := true
    try
    {
        if !Settings["PreviewsVisible"]
        {
            DestroyAllFoxholePreviews()
            return
        }

        if !Settings["PreviewShowWhenFoxholeUnfocused"] && !GetActiveFoxholeInstanceIndex()
        {
            DestroyAllFoxholePreviews()
            return
        }

        liveBySlot := Map()
        for inst in Instances
        {
            if IsWindowAlive(inst.hwnd)
                liveBySlot[inst.slot] := inst
        }

        stale := []
        for slot, preview in PreviewWindows
        {
            if !PreviewConfigs.Has(slot) || !PreviewConfigs[slot].enabled || !liveBySlot.Has(slot) || preview.sourceHwnd != liveBySlot[slot].hwnd
                stale.Push(slot)
        }
        for slot in stale
            DestroyFoxholePreview(slot)

        for slot, inst in liveBySlot
        {
            EnsureFoxholePreviewConfig(slot)
            if PreviewConfigs[slot].enabled && !PreviewWindows.Has(slot)
                CreateFoxholePreview(inst)
            else if PreviewWindows.Has(slot)
                UpdateFoxholePreviewThumbnail(slot)
        }
    }
    finally
    {
        PreviewSyncBusy := false
    }
}

MaintainPreviewFocusVisibility(*)
{
    global Settings
    if !Settings["PreviewsVisible"] || Settings["PreviewShowWhenFoxholeUnfocused"]
        return
    SyncFoxholePreviews()
}

GetHoveredPreviewInstanceIndex()
{
    global PreviewWindows, PreviewIdentityOverlays, Instances

    mouseHwnd := 0
    try MouseGetPos(,, &mouseHwnd)
    if !mouseHwnd
        return 0

    rootHwnd := DllCall("GetAncestor", "Ptr", mouseHwnd, "UInt", 2, "Ptr")
    if !rootHwnd
        rootHwnd := mouseHwnd

    hoveredSlot := 0
    for slot, preview in PreviewWindows
    {
        previewHwnd := GetGuiHwndSafe(preview.gui)
        if previewHwnd && (rootHwnd = previewHwnd || mouseHwnd = previewHwnd)
        {
            hoveredSlot := slot
            break
        }
    }

    if !hoveredSlot
    {
        for slot, rec in PreviewIdentityOverlays
        {
            recHwnd := IsObject(rec) ? GetGuiHwndSafe(rec.gui) : 0
            if recHwnd && (rootHwnd = recHwnd || mouseHwnd = recHwnd)
            {
                hoveredSlot := slot
                break
            }
        }
    }

    if !hoveredSlot
        return 0

    for index, inst in Instances
        if inst.slot = hoveredSlot && IsWindowAlive(inst.hwnd)
            return index
    return 0
}

MaintainPreviewHoverFront(*)
{
    global Settings, MouseFocusEnabled, LastPreviewHoverFrontSlot, Instances
    if !Settings["PreviewHoverBringToFront"] || !MouseFocusEnabled || !Settings["PreviewsVisible"] || Settings["PreviewEditMode"]
    {
        LastPreviewHoverFrontSlot := 0
        return
    }

    idx := GetHoveredPreviewInstanceIndex()
    if !idx || idx > Instances.Length
    {
        LastPreviewHoverFrontSlot := 0
        return
    }

    inst := Instances[idx]
    if !IsWindowAlive(inst.hwnd)
    {
        LastPreviewHoverFrontSlot := 0
        return
    }

    if LastPreviewHoverFrontSlot = inst.slot
        return

    LastPreviewHoverFrontSlot := inst.slot
    BringFoxholeWindowToFront(inst.hwnd)
}

CreateFoxholePreview(inst)
{
    global PreviewWindows, PreviewConfigs, Settings
    slot := inst.slot
    EnsureFoxholePreviewConfig(slot)
    cfg := PreviewConfigs[slot]

    guiObj := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000", "Foxhole Preview " slot)
    guiObj.BackColor := "000000"
    guiObj.SetFont("s8 cFFFFFF", "Segoe UI Semibold")
    slotLabel := guiObj.AddText("x4 y4 w72 h19 +0x200", " Slot " slot " ")
    slotLabel.Visible := Settings["PreviewEditMode"]
    slotLabel.Enabled := false

    sourceSize := GetFoxholeSourceSize(inst.hwnd)
    if sourceSize.width > 0 && sourceSize.height > 0
    {
        aspect := sourceSize.width / sourceSize.height
        if cfg.width <= 0
            cfg.width := 320
        cfg.height := Max(68, Round(cfg.width / aspect))
    }

    pos := GetFoxholePreviewInitialRect(slot, cfg.width, cfg.height)
    if cfg.x = 2147483647 || cfg.y = 2147483647
    {
        cfg.x := pos.x
        cfg.y := pos.y
        cfg.width := pos.width
        cfg.height := pos.height
        SaveFoxholePreviewConfig(slot)
    }
    else
    {
        clamped := ClampFoxholePreviewRect(cfg.x, cfg.y, cfg.width, cfg.height)
        cfg.x := clamped.x
        cfg.y := clamped.y
        cfg.width := clamped.width
        cfg.height := clamped.height
    }

    guiObj.Show("NA x" cfg.x " y" cfg.y " w" cfg.width " h" cfg.height)

    thumb := 0
    hr := DllCall("dwmapi\DwmRegisterThumbnail", "Ptr", guiObj.Hwnd, "Ptr", inst.hwnd, "Ptr*", &thumb, "Int")
    if hr != 0 || !thumb
    {
        try guiObj.Destroy()
        return false
    }

    PreviewWindows[slot] := {gui: guiObj, thumbnail: thumb, sourceHwnd: inst.hwnd, label: slotLabel}
    UpdateFoxholePreviewThumbnail(slot)
    EnsurePreviewIdentityOverlay(slot, inst)
    return true
}

DestroyFoxholePreview(slot)
{
    global PreviewWindows
    if !PreviewWindows.Has(slot)
        return
    preview := PreviewWindows[slot]
    PreviewWindows.Delete(slot)
    DestroyPreviewIdentityOverlay(slot)
    if preview.thumbnail
        try DllCall("dwmapi\DwmUnregisterThumbnail", "Ptr", preview.thumbnail, "Int")
    if IsObject(preview.gui)
        try preview.gui.Destroy()
}

DestroyAllFoxholePreviews()
{
    global PreviewWindows
    slots := []
    for slot, _ in PreviewWindows
        slots.Push(slot)
    for slot in slots
        DestroyFoxholePreview(slot)
}

GetIdentityAccountName(inst)
{
    accountName := GetSandboxieDisplayName(inst.slot)
    if accountName = ""
        accountName := GetAccountNameFromTitle(WinGetTitle("ahk_id " inst.hwnd))
    if accountName = ""
        accountName := "Account " inst.slot
    return accountName
}

BuildIdentityText(inst)
{
    global Settings
    showSlot := Settings["IdentityShowSlot"]
    showAccount := Settings["IdentityShowAccount"]

    if !showSlot && !showAccount
        return ""
    if showSlot && showAccount
        return inst.slot " - " GetIdentityAccountName(inst)
    if showSlot
        return String(inst.slot)
    return GetIdentityAccountName(inst)
}

BuildActiveHotkeyText(inst)
{
    global Settings
    if !Settings["PreviewShowActiveHotkeys"]
        return ""
    labels := Map(
        "AutoClick", "Auto Click",
        "AutoWalk", "Forward",
        "AutoReverse", "Reverse",
        "ClickHold", "Left Hold",
        "RightHold", "Right Hold",
        "VSpam", "V Spam",
        "TrainSlow", "Train Slow"
    )
    active := []
    for action in ["AutoClick", "AutoWalk", "AutoReverse", "ClickHold", "RightHold", "VSpam", "TrainSlow"]
        if IsHotkeysActionEnabled(inst, action)
            active.Push(labels[action])
    return active.Length ? "  [" JoinText(active, ", ") "]" : ""
}

CreateLayeredIdentityOverlay(identityText, fontSize, windowTitle := "Foxhole Identity", accentText := "")
{
    if identityText = "" && accentText = ""
        return ""

    if !CreateLayeredIdentityBitmap(identityText, fontSize, &memDC, &hBitmap, &oldBitmap, &bmpW, &bmpH, accentText)
        return ""

    g := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +E0x80000", windowTitle)
    g.Show("Hide w1 h1")

    return {
        gui: g,
        overlayHwnd: g.Hwnd,
        memDC: memDC,
        bitmap: hBitmap,
        oldBitmap: oldBitmap,
        width: bmpW,
        height: bmpH,
        identityText: identityText,
        fontSize: fontSize,
        accentText: accentText,
        visible: false,
        lastX: -2147483648,
        lastY: -2147483648
    }
}

CreateLayeredIdentityBitmap(identityText, fontSize, &memDC, &hBitmap, &oldBitmap, &bmpW, &bmpH, accentText := "")
{
    screenDC := DllCall("GetDC", "Ptr", 0, "Ptr")
    if !screenDC
        return false

    memDC := DllCall("gdi32\CreateCompatibleDC", "Ptr", screenDC, "Ptr")
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", screenDC)
    if !memDC
        return false

    pixelFontHeight := -Max(12, Round(fontSize * 96 / 72))
    font := DllCall("gdi32\CreateFontW",
        "Int", pixelFontHeight, "Int", 0, "Int", 0, "Int", 0,
        "Int", 600, "UInt", 0, "UInt", 0, "UInt", 0,
        "UInt", 1, "UInt", 0, "UInt", 0, "UInt", 5,
        "UInt", 0, "WStr", "Segoe UI", "Ptr")

    if !font
    {
        DllCall("gdi32\DeleteDC", "Ptr", memDC)
        memDC := 0
        return false
    }

    oldFont := DllCall("gdi32\SelectObject", "Ptr", memDC, "Ptr", font, "Ptr")

    extent := Buffer(8, 0)
    if !DllCall("gdi32\GetTextExtentPoint32W",
        "Ptr", memDC,
        "WStr", identityText,
        "Int", StrLen(identityText),
        "Ptr", extent.Ptr,
        "Int")
    {
        DllCall("gdi32\SelectObject", "Ptr", memDC, "Ptr", oldFont, "Ptr")
        DllCall("gdi32\DeleteObject", "Ptr", font)
        DllCall("gdi32\DeleteDC", "Ptr", memDC)
        memDC := 0
        return false
    }

    textW := NumGet(extent, 0, "Int")
    textH := NumGet(extent, 4, "Int")
    accentW := 0
    if accentText != ""
    {
        accentExtent := Buffer(8, 0)
        if DllCall("gdi32\GetTextExtentPoint32W", "Ptr", memDC, "WStr", accentText, "Int", StrLen(accentText), "Ptr", accentExtent.Ptr, "Int")
            accentW := NumGet(accentExtent, 0, "Int")
    }
    bmpW := Max(24, textW + accentW + 10)
    bmpH := Max(20, textH + 8)

    bmi := Buffer(40, 0)
    NumPut("UInt", 40, bmi, 0)
    NumPut("Int", bmpW, bmi, 4)
    NumPut("Int", -bmpH, bmi, 8)
    NumPut("UShort", 1, bmi, 12)
    NumPut("UShort", 32, bmi, 14)

    bits := 0
    hBitmap := DllCall("gdi32\CreateDIBSection",
        "Ptr", memDC,
        "Ptr", bmi.Ptr,
        "UInt", 0,
        "Ptr*", &bits,
        "Ptr", 0,
        "UInt", 0,
        "Ptr")

    if !hBitmap || !bits
    {
        DllCall("gdi32\SelectObject", "Ptr", memDC, "Ptr", oldFont, "Ptr")
        DllCall("gdi32\DeleteObject", "Ptr", font)
        DllCall("gdi32\DeleteDC", "Ptr", memDC)
        memDC := 0
        hBitmap := 0
        return false
    }

    oldBitmap := DllCall("gdi32\SelectObject", "Ptr", memDC, "Ptr", hBitmap, "Ptr")
    DllCall("gdi32\SetBkMode", "Ptr", memDC, "Int", 1)
    DllCall("gdi32\SetTextColor", "Ptr", memDC, "UInt", 0xFFFFFF)

    rect := Buffer(16, 0)
    NumPut("Int", 5, rect, 0)
    NumPut("Int", 3, rect, 4)
    NumPut("Int", 5 + textW, rect, 8)
    NumPut("Int", bmpH - 3, rect, 12)

    DllCall("user32\DrawTextW",
        "Ptr", memDC,
        "WStr", identityText,
        "Int", -1,
        "Ptr", rect.Ptr,
        "UInt", 0x0001 | 0x0004 | 0x0020 | 0x0800)

    if accentText != ""
    {
        DllCall("gdi32\SetTextColor", "Ptr", memDC, "UInt", 0x00FF00)
        accentRect := Buffer(16, 0)
        NumPut("Int", 5 + textW, accentRect, 0)
        NumPut("Int", 3, accentRect, 4)
        NumPut("Int", bmpW - 5, accentRect, 8)
        NumPut("Int", bmpH - 3, accentRect, 12)
        DllCall("user32\DrawTextW", "Ptr", memDC, "WStr", accentText, "Int", -1, "Ptr", accentRect.Ptr, "UInt", 0x0001 | 0x0004 | 0x0020 | 0x0800)
    }

    DllCall("gdi32\SelectObject", "Ptr", memDC, "Ptr", oldFont, "Ptr")
    DllCall("gdi32\DeleteObject", "Ptr", font)

    pixelCount := bmpW * bmpH
    Loop pixelCount
    {
        offset := (A_Index - 1) * 4
        pixel := NumGet(bits + offset, "UInt")
        b := pixel & 0xFF
        g := (pixel >> 8) & 0xFF
        r := (pixel >> 16) & 0xFF
        a := Max(r, g, b)
        if a
        {

            NumPut("UInt", (a << 24) | (r << 16) | (g << 8) | b, bits + offset)
        }
        else
            NumPut("UInt", 0, bits + offset)
    }

    return true
}

UpdateLayeredIdentityOverlay(rec, x, y, alpha := 255)
{
    if !IsObject(rec) || !IsObject(rec.gui) || !rec.memDC
        return
    overlayHwnd := GetGuiHwndSafe(rec.gui)
    if !overlayHwnd || !DllCall("IsWindow", "Ptr", overlayHwnd, "Int")
        return

    screenDC := DllCall("GetDC", "Ptr", 0, "Ptr")
    if !screenDC
        return

    ptDst := Buffer(8, 0)
    NumPut("Int", Round(x), ptDst, 0)
    NumPut("Int", Round(y), ptDst, 4)

    size := Buffer(8, 0)
    NumPut("Int", rec.width, size, 0)
    NumPut("Int", rec.height, size, 4)

    ptSrc := Buffer(8, 0)

    blend := Buffer(4, 0)
    NumPut("UChar", 0, blend, 0)
    NumPut("UChar", 0, blend, 1)
    NumPut("UChar", Max(0, Min(255, alpha)), blend, 2)
    NumPut("UChar", 1, blend, 3)

    try DllCall("user32\UpdateLayeredWindow",
        "Ptr", overlayHwnd,
        "Ptr", screenDC,
        "Ptr", ptDst.Ptr,
        "Ptr", size.Ptr,
        "Ptr", rec.memDC,
        "Ptr", ptSrc.Ptr,
        "UInt", 0,
        "Ptr", blend.Ptr,
        "UInt", 2)

    DllCall("ReleaseDC", "Ptr", 0, "Ptr", screenDC)
    DllCall("ShowWindow", "Ptr", overlayHwnd, "Int", 4)
    rec.visible := true
    rec.lastX := Round(x)
    rec.lastY := Round(y)
}

HideLayeredIdentityOverlay(rec)
{
    if IsObject(rec) && IsObject(rec.gui)
        try rec.gui.Hide()
    if IsObject(rec)
        rec.visible := false
}

DestroyLayeredIdentityOverlay(rec)
{
    if !IsObject(rec)
        return

    if rec.HasOwnProp("memDC") && rec.memDC
    {
        if rec.HasOwnProp("oldBitmap") && rec.oldBitmap
            try DllCall("gdi32\SelectObject", "Ptr", rec.memDC, "Ptr", rec.oldBitmap, "Ptr")
        if rec.HasOwnProp("bitmap") && rec.bitmap
            try DllCall("gdi32\DeleteObject", "Ptr", rec.bitmap)
        try DllCall("gdi32\DeleteDC", "Ptr", rec.memDC)
        rec.memDC := 0
    }

    if rec.HasOwnProp("gui") && IsObject(rec.gui)
        try rec.gui.Destroy()
}

GetAnchoredIdentityPosition(parentX, parentY, parentW, parentH, overlayW, overlayH, vertical, horizontal, margin := 6)
{
    if horizontal = "Right"
        x := parentX + parentW - overlayW - margin
    else if horizontal = "Center"
        x := parentX + Round((parentW - overlayW) / 2)
    else
        x := parentX + margin

    if vertical = "Bottom"
        y := parentY + parentH - overlayH - margin
    else if vertical = "Middle"
        y := parentY + Round((parentH - overlayH) / 2)
    else
        y := parentY + margin

    return {x: x, y: y}
}

FindInstanceForPreviewSlot(slot)
{
    global Instances
    for inst in Instances
        if inst.slot = slot
            return inst
    return ""
}

EnsurePreviewIdentityOverlay(slot, inst := "")
{
    global PreviewIdentityOverlays, Settings

    if !IsObject(inst)
        inst := FindInstanceForPreviewSlot(slot)
    if !IsObject(inst)
        return

    identityText := BuildIdentityText(inst)
    hotkeyText := BuildActiveHotkeyText(inst)
    if identityText = "" && hotkeyText = ""
    {
        DestroyPreviewIdentityOverlay(slot)
        return
    }

    fontSize := Settings["PreviewIdentityTextSize"]

    if PreviewIdentityOverlays.Has(slot)
    {
        rec := PreviewIdentityOverlays[slot]
        if rec.identityText = identityText && rec.fontSize = fontSize && rec.accentText = hotkeyText
            return
        DestroyPreviewIdentityOverlay(slot)
    }

    rec := CreateLayeredIdentityOverlay(identityText, fontSize, "Preview Identity " slot, hotkeyText)
    if !IsObject(rec)
        return

    rec.slot := slot
    PreviewIdentityOverlays[slot] := rec
}

DestroyPreviewIdentityOverlay(slot)
{
    global PreviewIdentityOverlays
    if !PreviewIdentityOverlays.Has(slot)
        return

    rec := PreviewIdentityOverlays[slot]
    PreviewIdentityOverlays.Delete(slot)
    DestroyLayeredIdentityOverlay(rec)
}

UpdatePreviewIdentityOverlayPosition(slot, force := false)
{
    global PreviewIdentityOverlays, PreviewWindows, Settings

    if !PreviewIdentityOverlays.Has(slot) || !PreviewWindows.Has(slot)
        return


    rec := PreviewIdentityOverlays[slot]
    preview := PreviewWindows[slot]
    previewHwnd := GetGuiHwndSafe(preview.gui)
    if !previewHwnd || !DllCall("IsWindow", "Ptr", previewHwnd, "Int")
    {
        HideLayeredIdentityOverlay(rec)
        return
    }

    if !DllCall("IsWindowVisible", "Ptr", previewHwnd, "Int")
    {
        HideLayeredIdentityOverlay(rec)
        return
    }

    try WinGetPos(&px, &py, &pw, &ph, "ahk_id " previewHwnd)
    catch
        return

    pos := GetAnchoredIdentityPosition(
        px, py, pw, ph,
        rec.width, rec.height,
        Settings["PreviewIdentityPosition"],
        Settings["PreviewIdentityHorizontal"],
        4)

    if force || !rec.visible || rec.lastX != Round(pos.x) || rec.lastY != Round(pos.y)
        UpdateLayeredIdentityOverlay(rec, pos.x, pos.y)

    if rec.visible
    {
        overlayHwnd := GetGuiHwndSafe(rec.gui)
        if overlayHwnd
            try DllCall("SetWindowPos", "Ptr", overlayHwnd, "Ptr", -1,
                "Int", 0, "Int", 0, "Int", 0, "Int", 0,
                "UInt", 0x0013, "Int")
    }
}

MaintainPreviewIdentityOverlays(*)
{
    global PreviewWindows, PreviewIdentityOverlays

    for slot, _ in PreviewWindows
    {
        inst := FindInstanceForPreviewSlot(slot)
        if IsObject(inst)
            EnsurePreviewIdentityOverlay(slot, inst)
        UpdatePreviewIdentityOverlayPosition(slot)
    }

    stale := []
    for slot, _ in PreviewIdentityOverlays
        if !PreviewWindows.Has(slot)
            stale.Push(slot)

    for slot in stale
        DestroyPreviewIdentityOverlay(slot)
}

RefreshAllPreviewIdentityOverlays(rebuild := false)
{
    global PreviewWindows

    for slot, _ in PreviewWindows
    {
        if rebuild
            DestroyPreviewIdentityOverlay(slot)

        inst := FindInstanceForPreviewSlot(slot)
        if IsObject(inst)
            EnsurePreviewIdentityOverlay(slot, inst)

        UpdatePreviewIdentityOverlayPosition(slot, true)
    }
}

GetFoxholeSourceSize(hwnd)
{
    rect := Buffer(16, 0)
    if DllCall("GetClientRect", "Ptr", hwnd, "Ptr", rect.Ptr, "Int")
    {
        w := NumGet(rect, 8, "Int") - NumGet(rect, 0, "Int")
        h := NumGet(rect, 12, "Int") - NumGet(rect, 4, "Int")
        if w > 0 && h > 0
            return {width: w, height: h}
    }
    return {width: 16, height: 9}
}

GetFoxholePreviewInitialRect(slot, width, height)
{
    primary := MonitorGetPrimary()
    MonitorGetWorkArea(primary, &left, &top, &right, &bottom)
    gap := 10
    margin := 16
    rowsPerColumn := Max(1, Floor((bottom - top - margin * 2 + gap) / (height + gap)))
    row := Mod(slot - 1, rowsPerColumn)
    col := Floor((slot - 1) / rowsPerColumn)
    x := right - margin - width - col * (width + gap)
    y := top + margin + row * (height + gap)
    return ClampFoxholePreviewRect(x, y, width, height)
}

ClampFoxholePreviewRect(x, y, width, height)
{
    width := Max(120, Round(width))
    height := Max(68, Round(height))
    bestMonitor := MonitorGetPrimary()
    bestArea := -1
    Loop MonitorGetCount()
    {
        mon := A_Index
        MonitorGetWorkArea(mon, &l, &t, &r, &b)
        overlapW := Max(0, Min(x + width, r) - Max(x, l))
        overlapH := Max(0, Min(y + height, b) - Max(y, t))
        area := overlapW * overlapH
        if area > bestArea
        {
            bestArea := area
            bestMonitor := mon
        }
    }
    MonitorGetWorkArea(bestMonitor, &left, &top, &right, &bottom)
    width := Min(width, Max(120, right - left))
    height := Min(height, Max(68, bottom - top))
    x := Min(Max(x, left), right - width)
    y := Min(Max(y, top), bottom - height)
    return {x: Round(x), y: Round(y), width: Round(width), height: Round(height)}
}

UpdateFoxholePreviewThumbnail(slot)
{
    global PreviewWindows, PreviewConfigs, Settings, LastFocusedFoxholeHwnd
    if !PreviewWindows.Has(slot) || !PreviewConfigs.Has(slot)
        return
    preview := PreviewWindows[slot]
    previewHwnd := GetGuiHwndSafe(preview.gui)
    if !preview.thumbnail || !previewHwnd || !DllCall("IsWindow", "Ptr", previewHwnd, "Int")
        return

    rect := Buffer(16, 0)
    if !DllCall("GetClientRect", "Ptr", previewHwnd, "Ptr", rect.Ptr, "Int")
        return
    w := Max(1, NumGet(rect, 8, "Int"))
    h := Max(1, NumGet(rect, 12, "Int"))
    isActive := LastFocusedFoxholeHwnd && preview.sourceHwnd = LastFocusedFoxholeHwnd
    border := isActive ? Min(5, Max(2, Floor(Min(w, h) / 45))) : 0

    try preview.gui.BackColor := isActive ? "FFFFFF" : "000000"

    opacity := Round(255 * Settings["PreviewOpacity"] / 100)
    try
    {
        if opacity >= 255
            WinSetTransparent("Off", "ahk_id " previewHwnd)
        else
            WinSetTransparent(opacity, "ahk_id " previewHwnd)
    }

    props := Buffer(48, 0)
    NumPut("UInt", 0x1 | 0x4 | 0x8 | 0x10, props, 0)
    NumPut("Int", border, props, 4)
    NumPut("Int", border, props, 8)
    NumPut("Int", Max(border + 1, w - border), props, 12)
    NumPut("Int", Max(border + 1, h - border), props, 16)
    NumPut("UChar", 255, props, 36)
    NumPut("Int", 1, props, 40)
    NumPut("Int", 1, props, 44)
    try DllCall("dwmapi\DwmUpdateThumbnailProperties", "Ptr", preview.thumbnail, "Ptr", props.Ptr, "Int")
}

RefreshActiveFoxholePreviewHighlight()
{
    global PreviewWindows
    for slot, _ in PreviewWindows
        UpdateFoxholePreviewThumbnail(slot)
}

GetGuiHwndSafe(guiObj)
{
    if !IsObject(guiObj)
        return 0
    try return guiObj.Hwnd
    catch
        return 0
}

FindFoxholePreviewSlotByHwnd(hwnd)
{
    global PreviewWindows
    for slot, preview in PreviewWindows
    {
        previewHwnd := GetGuiHwndSafe(preview.gui)
        if previewHwnd && previewHwnd = hwnd
            return slot
        labelHwnd := GetGuiHwndSafe(preview.label)
        if labelHwnd && labelHwnd = hwnd
            return slot
    }
    return 0
}

FoxholePreviewHitTest(wParam, lParam, msg, hwnd)
{
    global Settings, PreviewWindows
    mockSlot := FindPreviewPositionMockSlotByHwnd(hwnd)
    if mockSlot
        return 2
    slot := FindFoxholePreviewSlotByHwnd(hwnd)
    if !slot || !Settings["PreviewEditMode"]
        return

    return 2
}

FoxholePreviewSizeChanged(wParam, lParam, msg, hwnd)
{
    slot := FindFoxholePreviewSlotByHwnd(hwnd)
    if !slot
        return
    UpdateFoxholePreviewThumbnail(slot)
}

FoxholePreviewEnterSizeMove(wParam, lParam, msg, hwnd)
{
    global Settings, PreviewWindows
    global PreviewMoveStartPositions, PreviewMoveAnchorSlot, PreviewMoveAnchorX, PreviewMoveAnchorY

    slot := FindFoxholePreviewSlotByHwnd(hwnd)
    if !slot || !Settings["PreviewEditMode"] || !Settings["PreviewMoveAllTogether"] || !PreviewWindows.Has(slot)
        return

    PreviewMoveStartPositions := Map()
    PreviewMoveAnchorSlot := slot

    for otherSlot, preview in PreviewWindows
    {
        if !IsObject(preview.gui) || !GetGuiHwndSafe(preview.gui)
            continue
        try
        {
            WinGetPos(&x, &y, &w, &h, "ahk_id " GetGuiHwndSafe(preview.gui))
            PreviewMoveStartPositions[otherSlot] := {x: x, y: y, w: w, h: h}
            if otherSlot = slot
            {
                PreviewMoveAnchorX := x
                PreviewMoveAnchorY := y
            }
        }
    }
}

FoxholePreviewMoving(wParam, lParam, msg, hwnd)
{
    global Settings, PreviewWindows, PreviewLinkedMoveBusy
    global PreviewMoveStartPositions, PreviewMoveAnchorSlot, PreviewMoveAnchorX, PreviewMoveAnchorY

    slot := FindFoxholePreviewSlotByHwnd(hwnd)
    if !slot || PreviewLinkedMoveBusy || !Settings["PreviewEditMode"] || !PreviewWindows.Has(slot)
        return

    newX := NumGet(lParam, 0, "Int")
    newY := NumGet(lParam, 4, "Int")
    newR := NumGet(lParam, 8, "Int")
    newB := NumGet(lParam, 12, "Int")
    w := newR - newX
    h := newB - newY

    if Settings["PreviewSnapTogether"] && !Settings["PreviewMoveAllTogether"]
    {
        snapped := SnapPreviewRect(slot, newX, newY, w, h)
        resolved := ResolvePreviewOverlap(slot, snapped.x, snapped.y, w, h)
        newX := resolved.x
        newY := resolved.y
        NumPut("Int", newX, lParam, 0)
        NumPut("Int", newY, lParam, 4)
        NumPut("Int", newX + w, lParam, 8)
        NumPut("Int", newY + h, lParam, 12)
    }

    if !Settings["PreviewMoveAllTogether"]
        return

    if PreviewMoveAnchorSlot != slot || !PreviewMoveStartPositions.Has(slot)
        FoxholePreviewEnterSizeMove(0, 0, 0, hwnd)

    if PreviewMoveAnchorSlot != slot || !PreviewMoveStartPositions.Has(slot)
        return

    dx := newX - PreviewMoveAnchorX
    dy := newY - PreviewMoveAnchorY
    if !dx && !dy
        return

    count := Max(0, PreviewMoveStartPositions.Count - 1)
    if count = 0
        return

    hdwp := DllCall("BeginDeferWindowPos", "Int", count, "Ptr")
    if !hdwp
        return

    PreviewLinkedMoveBusy := true
    try
    {
        for otherSlot, pos in PreviewMoveStartPositions
        {
            if otherSlot = slot || !PreviewWindows.Has(otherSlot)
                continue
            preview := PreviewWindows[otherSlot]
            if !IsObject(preview.gui) || !GetGuiHwndSafe(preview.gui)
                continue

            nextHdwp := DllCall("DeferWindowPos",
                "Ptr", hdwp,
                "Ptr", GetGuiHwndSafe(preview.gui),
                "Ptr", 0,
                "Int", pos.x + dx,
                "Int", pos.y + dy,
                "Int", 0,
                "Int", 0,
                "UInt", 0x0015,
                "Ptr")
            if nextHdwp
                hdwp := nextHdwp
        }
        DllCall("EndDeferWindowPos", "Ptr", hdwp, "Int")
    }
    finally
    {
        PreviewLinkedMoveBusy := false
    }
}

ResolvePreviewOverlap(slot, x, y, w, h)
{
    global PreviewWindows, Settings
    hGap := Settings["PreviewHorizontalGap"]
    vGap := Settings["PreviewVerticalGap"]
    proposed := {x: x, y: y, width: w, height: h}
    Loop 24
    {
        collision := false
        for otherSlot, otherPreview in PreviewWindows
        {
            if otherSlot = slot || !IsObject(otherPreview.gui) || !GetGuiHwndSafe(otherPreview.gui)
                continue
            try WinGetPos(&ox, &oy, &ow, &oh, "ahk_id " GetGuiHwndSafe(otherPreview.gui))
            catch
                continue
            other := {x: ox, y: oy, width: ow, height: oh}
            if !RectsOverlap(proposed, other, 0)
                continue

            candidates := [
                {x: ox - w - hGap, y: proposed.y},
                {x: ox + ow + hGap, y: proposed.y},
                {x: proposed.x, y: oy - h - vGap},
                {x: proposed.x, y: oy + oh + vGap}
            ]
            best := candidates[1]
            bestDist := Abs(best.x - proposed.x) + Abs(best.y - proposed.y)
            for candidate in candidates
            {
                d := Abs(candidate.x - proposed.x) + Abs(candidate.y - proposed.y)
                if d < bestDist
                    best := candidate, bestDist := d
            }
            proposed.x := best.x
            proposed.y := best.y
            collision := true
            break
        }
        if !collision
            break
    }
    clamped := ClampFoxholePreviewRect(proposed.x, proposed.y, w, h)
    return {x: clamped.x, y: clamped.y, width: w, height: h}
}

FoxholePreviewLeftButtonUp(wParam, lParam, msg, hwnd)
{
    global Settings, PreviewWindows
    slot := FindFoxholePreviewSlotByHwnd(hwnd)
    if !slot || Settings["PreviewEditMode"] || !PreviewWindows.Has(slot)
        return
    BringFoxholeWindowToFront(PreviewWindows[slot].sourceHwnd)
}

FoxholePreviewExitSizeMove(wParam, lParam, msg, hwnd)
{
    global Settings, PreviewWindows, PreviewConfigs
    mockSlot := FindPreviewPositionMockSlotByHwnd(hwnd)
    if mockSlot
    {
        SavePreviewPositionMock(mockSlot)
        return
    }
    global PreviewMoveStartPositions, PreviewMoveAnchorSlot, PreviewMoveAnchorX, PreviewMoveAnchorY
    slot := FindFoxholePreviewSlotByHwnd(hwnd)
    if !slot || !PreviewWindows.Has(slot) || !Settings["PreviewEditMode"]
        return

    preview := PreviewWindows[slot]
    WinGetPos(&x, &y, &w, &h, "ahk_id " GetGuiHwndSafe(preview.gui))

    if Settings["PreviewSnapTogether"]
    {
        snapped := SnapPreviewRect(slot, x, y, w, h)
        resolved := ResolvePreviewOverlap(slot, snapped.x, snapped.y, w, h)
        x := resolved.x
        y := resolved.y
    }

    clamped := ClampFoxholePreviewRect(x, y, w, h)
    try WinMove(clamped.x, clamped.y, , , "ahk_id " GetGuiHwndSafe(preview.gui))

    cfg := PreviewConfigs[slot]
    cfg.x := clamped.x
    cfg.y := clamped.y
    cfg.width := w
    cfg.height := h
    SaveFoxholePreviewConfig(slot)

    if Settings["PreviewSnapTogether"]
        NormalizeFoxholePreviewLayout(slot)

    for otherSlot, otherPreview in PreviewWindows
    {
        if !PreviewConfigs.Has(otherSlot) || !IsObject(otherPreview.gui) || !GetGuiHwndSafe(otherPreview.gui)
            continue
        try WinGetPos(&ox, &oy, &ow, &oh, "ahk_id " GetGuiHwndSafe(otherPreview.gui))
        PreviewConfigs[otherSlot].x := ox
        PreviewConfigs[otherSlot].y := oy
        PreviewConfigs[otherSlot].width := ow
        PreviewConfigs[otherSlot].height := oh
        SaveFoxholePreviewConfig(otherSlot)
        UpdateFoxholePreviewThumbnail(otherSlot)
    }

    PreviewMoveStartPositions := Map()
    PreviewMoveAnchorSlot := 0
    PreviewMoveAnchorX := 0
    PreviewMoveAnchorY := 0
}

RectsOverlap(a, b, gap := 0)
{
    return a.x < b.x + b.width + gap && a.x + a.width + gap > b.x
        && a.y < b.y + b.height + gap && a.y + a.height + gap > b.y
}

SnapPreviewRect(slot, x, y, w, h)
{
    global PreviewWindows, Settings
    snap := 20
    hGap := Settings["PreviewHorizontalGap"]
    vGap := Settings["PreviewVerticalGap"]

    bestX := x
    bestY := y
    bestXDist := snap + 1
    bestYDist := snap + 1

    for otherSlot, otherPreview in PreviewWindows
    {
        if otherSlot = slot || !IsObject(otherPreview.gui) || !GetGuiHwndSafe(otherPreview.gui)
            continue
        try WinGetPos(&ox, &oy, &ow, &oh, "ahk_id " GetGuiHwndSafe(otherPreview.gui))
        catch
            continue

        verticalNear := (y < oy + oh + snap) && (y + h > oy - snap)
        if verticalNear
        {

            for candidateX in [ox + ow + hGap, ox - w - hGap]
            {
                d := Abs(candidateX - x)
                if d <= snap && d < bestXDist
                    bestXDist := d, bestX := candidateX
            }

            for candidateY in [oy, oy + oh - h]
            {
                d := Abs(candidateY - y)
                if d <= snap && d < bestYDist
                    bestYDist := d, bestY := candidateY
            }
        }

        horizontalNear := (x < ox + ow + snap) && (x + w > ox - snap)
        if horizontalNear
        {

            for candidateY in [oy + oh + vGap, oy - h - vGap]
            {
                d := Abs(candidateY - y)
                if d <= snap && d < bestYDist
                    bestYDist := d, bestY := candidateY
            }

            for candidateX in [ox, ox + ow - w]
            {
                d := Abs(candidateX - x)
                if d <= snap && d < bestXDist
                    bestXDist := d, bestX := candidateX
            }
        }
    }

    return {x: Round(bestX), y: Round(bestY), width: Round(w), height: Round(h)}
}

NormalizeFoxholePreviewLayout(anchorSlot := 0)
{
    global PreviewWindows, PreviewConfigs, PreviewSnapBusy, Settings
    hGap := Settings["PreviewHorizontalGap"]
    vGap := Settings["PreviewVerticalGap"]
    if PreviewSnapBusy || PreviewWindows.Count < 2
        return
    PreviewSnapBusy := true
    try
    {
        slots := []
        if anchorSlot && PreviewWindows.Has(anchorSlot)
            slots.Push(anchorSlot)
        for slot, _ in PreviewWindows
            if slot != anchorSlot
                slots.Push(slot)

        placed := []
        for slot in slots
        {
            preview := PreviewWindows[slot]
            if !IsObject(preview.gui) || !GetGuiHwndSafe(preview.gui)
                continue
            try WinGetPos(&x, &y, &w, &h, "ahk_id " GetGuiHwndSafe(preview.gui))
            catch
                continue
            rect := SnapPreviewRect(slot, x, y, w, h)
            attempts := 0
            while attempts < 64
            {
                collision := false
                for p in placed
                {
                    if RectsOverlap(rect, p, Max(hGap, vGap))
                    {
                        rect.x := p.x + p.width + hGap
                        rect.y := p.y
                        collision := true
                        break
                    }
                }
                if !collision
                    break
                attempts++
            }
            rect := ClampFoxholePreviewRect(rect.x, rect.y, rect.width, rect.height)
            try WinMove(rect.x, rect.y, rect.width, rect.height, "ahk_id " GetGuiHwndSafe(preview.gui))
            if PreviewConfigs.Has(slot)
            {
                PreviewConfigs[slot].x := rect.x, PreviewConfigs[slot].y := rect.y
                PreviewConfigs[slot].width := rect.width, PreviewConfigs[slot].height := rect.height
            }
            placed.Push(rect)
        }
    }
    finally
        PreviewSnapBusy := false
}

AutoArrangeFoxholePreviews(*)
{
    global PreviewWindows, PreviewConfigs, Settings
    if PreviewWindows.Count = 0
        return
    primary := MonitorGetPrimary()
    MonitorGetWorkArea(primary, &left, &top, &right, &bottom)
    slots := []
    for slot, _ in PreviewWindows
        slots.Push(slot)
    Loop slots.Length - 1
    {
        i := A_Index + 1
        value := slots[i]
        j := i - 1
        while j >= 1 && slots[j] > value
        {
            slots[j + 1] := slots[j]
            j--
        }
        slots[j + 1] := value
    }
    hGap := Settings["PreviewHorizontalGap"]
    vGap := Settings["PreviewVerticalGap"]
    margin := 12
    cursorX := right - margin
    cursorY := top + margin
    columnW := 0
    for slot in slots
    {
        preview := PreviewWindows[slot]
        try WinGetPos(&tmpX, &tmpY, &w, &h, "ahk_id " GetGuiHwndSafe(preview.gui))
        catch
            continue
        if cursorY + h > bottom - margin && cursorY > top + margin
        {
            cursorX -= columnW + hGap
            cursorY := top + margin
            columnW := 0
        }
        x := cursorX - w
        y := cursorY
        try WinMove(x, y, w, h, "ahk_id " GetGuiHwndSafe(preview.gui))
        if PreviewConfigs.Has(slot)
        {
            PreviewConfigs[slot].x := x, PreviewConfigs[slot].y := y
            PreviewConfigs[slot].width := w, PreviewConfigs[slot].height := h
            SaveFoxholePreviewConfig(slot)
        }
        cursorY += h + vGap
        columnW := Max(columnW, w)
    }
}

HorizontalArrangeFoxholePreviews(*)
{
    global PreviewWindows, PreviewConfigs, Settings
    if PreviewWindows.Count = 0
        return

    primary := MonitorGetPrimary()
    MonitorGetWorkArea(primary, &left, &top, &right, &bottom)

    slots := []
    for slot, _ in PreviewWindows
        slots.Push(slot)

    Loop slots.Length - 1
    {
        i := A_Index + 1
        value := slots[i]
        j := i - 1
        while j >= 1 && slots[j] > value
        {
            slots[j + 1] := slots[j]
            j--
        }
        slots[j + 1] := value
    }

    hGap := Settings["PreviewHorizontalGap"]
    vGap := Settings["PreviewVerticalGap"]
    margin := 12
    cursorX := left + margin
    cursorY := top + margin
    rowH := 0

    for slot in slots
    {
        preview := PreviewWindows[slot]
        try WinGetPos(&tmpX, &tmpY, &w, &h, "ahk_id " GetGuiHwndSafe(preview.gui))
        catch
            continue

        if cursorX + w > right - margin && cursorX > left + margin
        {
            cursorX := left + margin
            cursorY += rowH + vGap
            rowH := 0
        }

        x := cursorX
        y := cursorY
        try WinMove(x, y, w, h, "ahk_id " GetGuiHwndSafe(preview.gui))

        if PreviewConfigs.Has(slot)
        {
            PreviewConfigs[slot].x := x
            PreviewConfigs[slot].y := y
            PreviewConfigs[slot].width := w
            PreviewConfigs[slot].height := h
            SaveFoxholePreviewConfig(slot)
        }

        cursorX += w + hGap
        rowH := Max(rowH, h)
    }
}

RefreshFoxholePreviewEditState()
{
    global PreviewWindows, Settings
    for _, preview in PreviewWindows
    {
        if IsObject(preview.label)
            preview.label.Visible := Settings["PreviewEditMode"]

        try DllCall("SetWindowPos", "Ptr", GetGuiHwndSafe(preview.gui), "Ptr", -1,
            "Int", 0, "Int", 0, "Int", 0, "Int", 0,
            "UInt", 0x0037, "Int")
    }

    if Settings["PreviewSnapTogether"]
        SetTimer(FixBorderlessPreviewOverlaps, -1)
}

FixBorderlessPreviewOverlaps(*)
{
    global PreviewWindows, PreviewConfigs
    if PreviewWindows.Count < 2
        return

    Loop 5
    {
        movedAny := false
        rects := []

        for slot, preview in PreviewWindows
        {
            try WinGetPos(&x, &y, &w, &h, "ahk_id " GetGuiHwndSafe(preview.gui))
            catch
                continue
            rects.Push({slot: slot, x: x, y: y, w: w, h: h})
        }

        for i, a in rects
        {
            for j, b in rects
            {
                if j <= i
                    continue

                overlapX := Min(a.x + a.w, b.x + b.w) - Max(a.x, b.x)
                overlapY := Min(a.y + a.h, b.y + b.h) - Max(a.y, b.y)
                if overlapX <= 0 || overlapY <= 0
                    continue

                moveB := (b.x > a.x) || (b.x = a.x && b.y >= a.y)

                if overlapX <= overlapY
                {
                    if moveB
                        b.x += overlapX
                    else
                        a.x -= overlapX
                }
                else
                {
                    if b.y >= a.y
                        b.y += overlapY
                    else
                        a.y -= overlapY
                }

                target := moveB ? b : a
                if PreviewWindows.Has(target.slot)
                {
                    p := PreviewWindows[target.slot]
                    try WinMove(Round(target.x), Round(target.y), target.w, target.h, "ahk_id " GetGuiHwndSafe(p.gui))
                    if PreviewConfigs.Has(target.slot)
                    {
                        PreviewConfigs[target.slot].x := Round(target.x)
                        PreviewConfigs[target.slot].y := Round(target.y)
                        PreviewConfigs[target.slot].width := target.w
                        PreviewConfigs[target.slot].height := target.h
                        SaveFoxholePreviewConfig(target.slot)
                    }
                }
                movedAny := true
            }
        }

        if !movedAny
            break
    }
}

BringFoxholeWindowToFront(hwnd)
{
    if !hwnd || !DllCall("IsWindow", "Ptr", hwnd, "Int")
        return false

    NotifyFoxholeActivated(hwnd)

    if DllCall("IsIconic", "Ptr", hwnd, "Int")
        DllCall("ShowWindowAsync", "Ptr", hwnd, "Int", 9)

    DllCall("BringWindowToTop", "Ptr", hwnd, "Int")
    DllCall("SetForegroundWindow", "Ptr", hwnd, "Int")

    if DllCall("GetForegroundWindow", "Ptr") != hwnd
        ForceForegroundWindow(hwnd)

    return DllCall("GetForegroundWindow", "Ptr") = hwnd
}

FastActivateFoxholeWindow(hwnd)
{
    if !hwnd || !DllCall("IsWindow", "Ptr", hwnd, "Int")
        return false

    NotifyFoxholeActivated(hwnd)

    if DllCall("GetForegroundWindow", "Ptr") = hwnd
        return true

    if DllCall("IsIconic", "Ptr", hwnd, "Int")
        DllCall("ShowWindowAsync", "Ptr", hwnd, "Int", 9)

    DllCall("BringWindowToTop", "Ptr", hwnd, "Int")
    DllCall("SetForegroundWindow", "Ptr", hwnd, "Int")

    if DllCall("GetForegroundWindow", "Ptr") != hwnd
        ForceForegroundWindow(hwnd)

    return DllCall("GetForegroundWindow", "Ptr") = hwnd
}

CycleFoxholeGame(direction := 1)
{
    global Instances, CycleCursorHwnd

    baseHwnd := (CycleCursorHwnd && IsWindowAlive(CycleCursorHwnd))
        ? CycleCursorHwnd
        : GetTopFoxholeWindowHwnd()

    currentSlot := 0
    minSlot := 2147483647
    maxSlot := -1
    minHwnd := 0
    maxHwnd := 0

    for inst in Instances
    {
        hwnd := inst.hwnd
        if !hwnd || !IsWindowAlive(hwnd)
            continue

        slot := inst.slot
        if hwnd = baseHwnd
            currentSlot := slot
        if slot < minSlot
            minSlot := slot, minHwnd := hwnd
        if slot > maxSlot
            maxSlot := slot, maxHwnd := hwnd
    }

    if !minHwnd
        return

    targetHwnd := 0
    if !currentSlot
        targetHwnd := direction < 0 ? maxHwnd : minHwnd
    else
    {
        bestSlot := direction < 0 ? -1 : 2147483647
        for inst in Instances
        {
            hwnd := inst.hwnd
            if !hwnd || !IsWindowAlive(hwnd)
                continue

            slot := inst.slot
            if direction < 0
            {
                if slot < currentSlot && slot > bestSlot
                    bestSlot := slot, targetHwnd := hwnd
            }
            else
            {
                if slot > currentSlot && slot < bestSlot
                    bestSlot := slot, targetHwnd := hwnd
            }
        }

        if !targetHwnd
            targetHwnd := direction < 0 ? maxHwnd : minHwnd
    }

    if !targetHwnd
    {
        return
    }

    CycleCursorHwnd := targetHwnd

    if DllCall("IsIconic", "Ptr", targetHwnd, "Int")
        DllCall("ShowWindow", "Ptr", targetHwnd, "Int", 9)

    DllCall("SetWindowPos", "Ptr", targetHwnd, "Ptr", 0,
        "Int", 0, "Int", 0, "Int", 0, "Int", 0,
        "UInt", 0x0001 | 0x0002)
    DllCall("SetForegroundWindow", "Ptr", targetHwnd, "Int")

    NotifyFoxholeActivated(targetHwnd)
}

QueueFoxholeCycle(direction)
{
    global CycleInputQueue, CycleInputWorkerScheduled

    Critical "On"
    CycleInputQueue.Push(direction < 0 ? -1 : 1)
    if !CycleInputWorkerScheduled
    {
        CycleInputWorkerScheduled := true
        SetTimer(ProcessFoxholeCycleQueue, -1)
    }
    Critical "Off"
}

ProcessFoxholeCycleQueue(*)
{
    global CycleInputQueue, CycleInputWorkerScheduled

    Critical "On"
    if CycleInputQueue.Length = 0
    {
        CycleInputWorkerScheduled := false
        Critical "Off"
        return
    }
    direction := CycleInputQueue.RemoveAt(1)
    Critical "Off"

    CycleFoxholeGame(direction)

    SetTimer(ProcessFoxholeCycleQueue, -1)
}

EnforceDesiredFoxholeCycle(*)
{
    SetTimer(EnforceDesiredFoxholeCycle, 0)
}

CycleToNextFoxholeGame(*)
{
    QueueFoxholeCycle(1)
}

CycleToLastFoxholeGame(*)
{
    QueueFoxholeCycle(-1)
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
    sbSettingsBtn := RegisterTooltip(SBGui.AddButton("x135 y8 w32 h24", "⚙"), "Configure the paths to Start.exe, Steam.exe, and the Foxhole executable.")
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
    global SBGui, SandboxieRowCountEdit, SandboxieRowCount, MaxSandboxieRows, SandboxieRows, CurrentMainPage

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
    DisposeEmbeddedPage(SBGui)
    SBGui := ""
    SandboxieRows := []

    BuildSBGui()
    RefreshAccountSwapHotkeysGui()
    CurrentMainPage := ""
    SwitchMainPage("Accounts")
    LogEvent("Accounts rows changed to " count "; Accounts page refreshed")
}

RebuildSandboxieRows(count)
{
    global SBGui, SandboxieRows, SandboxieAccounts, EmbeddedPageBasePositions

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
    {
        index := SandboxieAccounts.Length + 1
        account := ReadSandboxieAccountRecord(CONFIG_FILE, index)
        SandboxieAccounts.Push({ name: account.name, selected: account.selected, main: account.main, steamUsername: account.steamUsername, displayName: account.displayName, useDisplayName: account.useDisplayName })
    }

    rowY := 74
    for index in Range(1, count)
    {
        account := SandboxieAccounts[index]
        rowNumber := SBGui.AddText("x12 y" rowY " w20 h24", String(index))
        nameEdit := SBGui.AddEdit("x40 y" rowY " w94 h24", account.name)
        aliasButton := SBGui.AddButton("x136 y" rowY " w29 h24", account.useDisplayName ? "★" : "✎")
        aliasButton.OnEvent("Click", OpenSandboxieDisplayNameEditor.Bind(index))
        RegisterTooltip(aliasButton, "Set an optional display name for this account. Does not rename the Sandboxie box or Steam login.")
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
        SandboxieRows.Push([rowNumber, nameEdit, steamButton, steamStatus, loginButton, foxholeButton, foxholeStatus, mainCheck, selectedCheck, aliasButton])
        rowY += 30
    }

    height := rowY + 14
    if height < 150
        height := 150
    SBGui.Move(, , 535, height)
    try EmbeddedPageBasePositions.Delete(SBGui.Hwnd)
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
    sandman := Trim(Settings["SandboxieStartExe"])
    if sandman = ""
        return ""
    dir := RegExReplace(sandman, "\\[^\\]+$", "")
    candidate := dir "\\SbieDll.dll"
    return FileExist(candidate) ? candidate : ""
}

SaveSandboxieVisibleRows()
{
    global SandboxieRows, SandboxieAccounts, CurrentMainPage

    if CurrentMainPage != "Accounts"
        return

    for index, row in SandboxieRows
    {
        if index > SandboxieAccounts.Length || !IsObject(row) || row.Length < 9
            continue
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

GetSandboxieSteamReadinessSnapshot(boxName)
{
    steamCount := 0
    helperCount := 0
    pidSum := 0
    normalSteamWindow := 0
    blockingWindow := false
    steamWindows := []

    oldDetectHidden := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    try
    {
        for pid in GetSandboxieBoxPids(boxName)
        {
            processName := ""
            try processName := StrLower(ProcessGetName(pid))
            catch
                continue

            if processName != "steam.exe" && processName != "steamwebhelper.exe"
                continue

            pidSum += pid
            if processName = "steam.exe"
                steamCount++
            else
                helperCount++

            try windows := WinGetList("ahk_pid " pid)
            catch
                continue

            for hwnd in windows
            {
                try
                {
                    if !WinExist("ahk_id " hwnd) || !WinGetStyle("ahk_id " hwnd)
                        continue

                    title := Trim(WinGetTitle("ahk_id " hwnd))
                    titleLower := StrLower(title)
                    WinGetPos(,, &windowWidth, &windowHeight, "ahk_id " hwnd)
                    if windowWidth < 200 || windowHeight < 120
                        continue

                    steamWindows.Push({ hwnd: hwnd, processName: processName, title: title })

                    if InStr(titleLower, "verify") || InStr(titleLower, "install")
                        || InStr(titleLower, "updating steam") || InStr(titleLower, "steam update")
                        || InStr(titleLower, "connecting steam account") || InStr(titleLower, "signing in")
                    {
                        blockingWindow := true
                        continue
                    }

                    if processName = "steam.exe"
                        normalSteamWindow := hwnd
                }
            }
        }
    }
    finally
    {
        DetectHiddenWindows(oldDetectHidden)
    }

    signature := steamCount "|" helperCount "|" pidSum "|" normalSteamWindow "|" (blockingWindow ? 1 : 0)
    structurallyReady := steamCount >= 1 && helperCount >= 2 && normalSteamWindow && !blockingWindow
    return {
        ready: structurallyReady,
        signature: signature,
        steamCount: steamCount,
        helperCount: helperCount,
        normalSteamWindow: normalSteamWindow,
        blockingWindow: blockingWindow,
        windows: steamWindows
    }
}

UpdateSandboxieSteamReadiness(boxName, state, requiredStableMs := 20000, snapshot := "")
{
    global CertifiedSandboxieSteamBoxes
    if !IsObject(snapshot)
        snapshot := GetSandboxieSteamReadinessSnapshot(boxName)
    now := A_TickCount

    if CertifiedSandboxieSteamBoxes.Has(boxName)
    {
        if snapshot.steamCount >= 1 && snapshot.helperCount >= 2 && !snapshot.blockingWindow
        {
            state.ready := true
            return true
        }
        CertifiedSandboxieSteamBoxes.Delete(boxName)
    }

    if !snapshot.ready
    {
        state.signature := ""
        state.stableSince := 0
        state.ready := false
        return false
    }

    if state.signature != snapshot.signature
    {
        state.signature := snapshot.signature
        state.stableSince := now
        state.ready := false
        return false
    }

    if !state.stableSince
        state.stableSince := now

    state.ready := now - state.stableSince >= requiredStableMs
    if state.ready
        CertifiedSandboxieSteamBoxes[boxName] := now
    return state.ready
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

GetSandboxieDisplayName(index)
{
    global SandboxieAccounts
    if index < 1 || index > SandboxieAccounts.Length
        return "Account " index
    account := SandboxieAccounts[index]
    if account.useDisplayName && Trim(account.displayName) != ""
        return Trim(account.displayName)
    return Trim(account.name) != "" ? Trim(account.name) : "Account " index
}

OpenSandboxieDisplayNameEditor(index, *)
{
    global SandboxieAccounts, MainGui, SandboxieRows
    if index < 1 || index > SandboxieAccounts.Length
        return
    account := SandboxieAccounts[index]
    editor := Gui("+Owner" MainGui.Hwnd " +AlwaysOnTop", "Account " index " — Display name")
    editor.SetFont("s9", "Segoe UI")
    editor.AddText("x12 y12 w325 h30", "Optional name shown in the multiboxer. The real Sandboxie account name and login stay unchanged.")
    editor.AddText("x12 y51 w100 h20", "Display name:")
    field := editor.AddEdit("x110 y47 w225 h24", account.displayName)
    useCheck := editor.AddCheckBox("x12 y84 w325 h22", "Use this name in displays")
    useCheck.Value := Trim(account.displayName) = "" ? 1 : (account.useDisplayName ? 1 : 0)
    ok := editor.AddButton("x175 y116 w75 h27 Default", "Save")
    cancel := editor.AddButton("x260 y116 w75 h27", "Cancel")
    ok.OnEvent("Click", (*) => SaveSandboxieDisplayNameEditor(index, field, useCheck, editor))
    cancel.OnEvent("Click", (*) => editor.Destroy())
    editor.OnEvent("Close", (*) => editor.Destroy())
    editor.Show("w348 h154")
}

SaveSandboxieDisplayNameEditor(index, field, useCheck, editor)
{
    global SandboxieAccounts, SandboxieRows
    name := Trim(field.Value)
    if useCheck.Value && name = ""
    {
        MsgBox("Enter a display name or uncheck 'Use this name in displays'.", "Display name", "Icon!")
        return
    }
    SandboxieAccounts[index].displayName := name
    SandboxieAccounts[index].useDisplayName := useCheck.Value = 1
    editor.Destroy()
    if index <= SandboxieRows.Length
        SandboxieRows[index][10].Text := SandboxieAccounts[index].useDisplayName ? "★" : "✎"
    SaveConfig()
    RefreshList()
    UpdateWorkflowAccountSummary()
    UpdatePreviewAccountSummary()
    RefreshAllPreviewIdentityOverlays(true)
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

    SandboxieSettingsGui.AddText("x12 y10 w590 h20", "Sandboxie Plus launcher — normally: C:\Program Files\Sandboxie-Plus\Start.exe")
    sandmanEdit := SandboxieSettingsGui.AddEdit("x12 y31 w550 h24", Settings["SandboxieStartExe"])
    RegisterTooltip(sandmanEdit, (*) => PathTooltip(sandmanEdit, "Sandboxie Plus launcher", "C:\Program Files\Sandboxie-Plus\Start.exe"))
    sandmanBrowse := RegisterTooltip(SandboxieSettingsGui.AddButton("x568 y31 w36 h24", "..."), "Browse for Sandboxie Plus Start.exe. Normal location: C:\Program Files\Sandboxie-Plus\Start.exe")
    sandmanBrowse.OnEvent("Click", (*) => SelectSandboxieSettingsPath(sandmanEdit, "SandboxieStartExe"))

    SandboxieSettingsGui.AddText("x12 y66 w590 h20", "Steam executable — normally: C:\Program Files (x86)\Steam\steam.exe")
    steamEdit := SandboxieSettingsGui.AddEdit("x12 y87 w550 h24", Settings["SandboxieSteamExe"])
    RegisterTooltip(steamEdit, (*) => PathTooltip(steamEdit, "Steam executable", "C:\Program Files (x86)\Steam\steam.exe"))
    steamBrowse := RegisterTooltip(SandboxieSettingsGui.AddButton("x568 y87 w36 h24", "..."), "Browse for Steam.exe. Normal location: C:\Program Files (x86)\Steam\steam.exe")
    steamBrowse.OnEvent("Click", (*) => SelectSandboxieSettingsPath(steamEdit, "SandboxieSteamExe"))

    SandboxieSettingsGui.AddText("x12 y122 w590 h20", "Foxhole game executable — normally under: C:\Program Files (x86)\Steam\steamapps\common\Foxhole")
    SandboxieSettingsGui.AddText("x12 y141 w590 h20", "Required file: Foxhole\War\Binaries\Win64\War-Win64-Shipping.exe")
    foxholeEdit := SandboxieSettingsGui.AddEdit("x12 y163 w550 h24", Settings["SandboxieFoxholeExe"])
    RegisterTooltip(foxholeEdit, (*) => PathTooltip(foxholeEdit, "Foxhole executable", "C:\Program Files (x86)\Steam\steamapps\common\Foxhole\War\Binaries\Win64\War-Win64-Shipping.exe"))
    foxholeBrowse := RegisterTooltip(SandboxieSettingsGui.AddButton("x568 y163 w36 h24", "..."), "Browse for War-Win64-Shipping.exe. Normal location: C:\Program Files (x86)\Steam\steamapps\common\Foxhole\War\Binaries\Win64\War-Win64-Shipping.exe")
    foxholeBrowse.OnEvent("Click", (*) => SelectSandboxieSettingsPath(foxholeEdit, "SandboxieFoxholeExe"))

    saveBtn := SandboxieSettingsGui.AddButton("x448 y202 w74 h26", "Save")
    cancelBtn := SandboxieSettingsGui.AddButton("x530 y202 w74 h26", "Cancel")
    saveBtn.OnEvent("Click", (*) => SaveSandboxieSettings(SandboxieSettingsGui, sandmanEdit, steamEdit, foxholeEdit))
    cancelBtn.OnEvent("Click", CloseSandboxieSettings)
    RegisterTooltip(saveBtn, "Save all three executable paths to Settings.ini.")
    RegisterTooltip(cancelBtn, "Close without saving changes made in this window.")
    SandboxieSettingsGui.OnEvent("Close", CloseSandboxieSettings)
    SandboxieSettingsGui.Show("w616 h242")
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
    if settingKey = "SandboxieStartExe"
        title := "Select Sandboxie Start.exe"
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
    Settings["SandboxieStartExe"] := Trim(sandmanEdit.Value)
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
    voiceConfigured := 0
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
            voiceResult := ConfigureSandboxieVoiceChatCompatibility(accountName)
            if voiceResult.ok
                voiceConfigured++
            else
                failed++
            continue
        }

        result := CreateSandboxieSandbox(accountName)
        if result.ok
        {
            created++
            voiceConfigured++
        }
        else
            failed++
    }

    ReloadSandboxieConfiguration()
    SaveConfig()
    summary := "Setup complete.`n`nCreated: " created "`nAlready existed: " existing "`nVoice compatibility applied: " voiceConfigured
    if invalid
        summary .= "`nInvalid account names: " invalid
    if failed
        summary .= "`nFailed: " failed

    if failed || invalid
        MsgBox(summary, "Sandboxie", "Icon!")
    else
        MsgBox(summary, "Sandboxie", "Iconi")
    StatusText.Text := "Status: Sandbox setup complete — voice compatibility applied to " voiceConfigured " sandbox(es)."
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
    sandman := Trim(Settings["SandboxieStartExe"])
    steamExe := Trim(Settings["SandboxieSteamExe"])

    if sandman = "" || !FileExist(sandman)
    {
        candidates := [
            "C:\Program Files\Sandboxie-Plus\Start.exe",
            "C:\Program Files\Sandboxie\Start.exe"
        ]
        for candidate in candidates
        {
            if FileExist(candidate)
            {
                Settings["SandboxieStartExe"] := candidate
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

    resolvedStartExe := GetSandboxieStartPath()
    return {
        sandman: resolvedStartExe,
        steamExe: steamExe,
        sandmanOk: resolvedStartExe != "" && FileExist(resolvedStartExe),
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

StartSelectedSandboxieSteamLaunches(accountIndices := "", *)
{
    global SandboxieAccounts, SandboxieSteamAllButton, StatusText, Settings

    if SandboxieSteamAllButton && !SandboxieSteamAllButton.Enabled
    {
        LogEvent("Steam launch ignored: launch button disabled", "WARN")
        return
    }

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
            pathFailures.Push("Sandboxie Plus Start.exe could not be found.")

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

IsCombinedSteamAccountReady(item, state := "")
{
    if item.main
        return IsUnsandboxedProcessRunning("steam.exe") && IsUnsandboxedProcessRunning("steamwebhelper.exe")

    if !IsObject(state)
        return false
    return UpdateSandboxieSteamReadiness(item.name, state, 20000)
}

AbortCombinedSteamFoxholeLaunch(message, showPopup := true)
{
    global CombinedLaunchActive, CombinedLaunchAccounts, CombinedSteamReadyPolls, CombinedSteamPaths, StatusText, WorkflowRunning

    LogEvent("Combined Steam/Foxhole launch aborted: " message, "WARN")
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

StartCombinedSteamFoxholeLaunch(accountIndices := "", *)
{
    global SandboxieAccounts, SequentialLaunchActive, CombinedLaunchActive
    global CombinedLaunchAccounts, CombinedSteamReadyPolls, CombinedSteamLaunchStartedAt
    global CombinedSteamPaths, StatusText, Instances, Settings

    if CombinedLaunchActive || SequentialLaunchActive
    {
        LogEvent("Combined launch ignored: another launch is active", "WARN")
        return
    }

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
        problems.Push("Sandboxie Plus Start.exe could not be found.")
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
            if !CombinedSteamReadyPolls.Has(item.index) || !CombinedSteamReadyPolls[item.index].ready
                notReady.Push({ name: item.name })
        }
        AbortCombinedSteamFoxholeLaunch("Steam did not fully load before the timeout for:`n" JoinSteamLaunchAccountNames(notReady))
        return
    }

    readyCount := 0
    for item in CombinedLaunchAccounts
    {
        if !CombinedSteamReadyPolls.Has(item.index)
            CombinedSteamReadyPolls[item.index] := { signature: "", stableSince: 0, ready: false }
        state := CombinedSteamReadyPolls[item.index]

        if item.main
        {
            if IsCombinedSteamAccountReady(item, state)
                state.ready := true
            else
                state.ready := false
        }
        else
            IsCombinedSteamAccountReady(item, state)

        if state.ready
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
    sandman := Trim(Settings["SandboxieStartExe"])
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
    sandman := Trim(Settings["SandboxieStartExe"])
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
        return { ok: false, message: "SbieIni.exe was not found beside Start.exe." }

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

        voiceResult := ConfigureSandboxieVoiceChatCompatibility(boxName)
        if !voiceResult.ok
            return voiceResult

        ReloadSandboxieConfiguration()
        if !GetSandboxieBoxExists(boxName)
            return { ok: false, message: "Sandboxie did not report the new sandbox after creation." }

        return { ok: true, message: "Sandbox created with Foxhole voice compatibility settings." }
    }
    catch as e
    {
        return { ok: false, message: e.Message }
    }
}

ConfigureSandboxieVoiceChatCompatibility(boxName)
{
    helper := GetSandboxieHelperPath()
    if helper = ""
        return { ok: false, message: "SbieIni.exe was not found beside Start.exe." }

    try
    {
        rc := RunWait(Format('"{1}" set "{2}" OriginalToken y', helper, boxName), , "Hide")
        if rc != 0
            return { ok: false, message: "OriginalToken could not be enabled (code " rc ")." }

        rc := RunWait(Format('"{1}" set "{2}" RpcMgmtSetComTimeout n', helper, boxName), , "Hide")
        if rc != 0
            return { ok: false, message: "RpcMgmtSetComTimeout could not be configured (code " rc ")." }

        RunWait(Format('"{1}" delete "{2}" Template OpenCOM', helper, boxName), , "Hide")
        rc := RunWait(Format('"{1}" append "{2}" Template OpenCOM', helper, boxName), , "Hide")
        if rc != 0
            return { ok: false, message: "OpenCOM template could not be enabled (code " rc ")." }

        voicePaths := [
            "\RPC Control\AudioSrv",
            "\RPC Control\AudioClientRpc",
            "*\BaseNamedObjects\SYSTEM_AUDIO_STREAM_*"
        ]
        for path in voicePaths
        {
            RunWait(Format('"{1}" delete "{2}" OpenIpcPath "{3}"', helper, boxName, path), , "Hide")
            rc := RunWait(Format('"{1}" append "{2}" OpenIpcPath "{3}"', helper, boxName, path), , "Hide")
            if rc != 0
                return { ok: false, message: "Voice IPC path could not be configured: " path " (code " rc ")." }
        }

        return { ok: true, message: "Foxhole voice compatibility settings applied." }
    }
    catch as e
    {
        return { ok: false, message: e.Message }
    }
}

GetSandboxieStartPath()
{
    global Settings

    configured := Trim(Settings["SandboxieStartExe"])
    if configured = ""
        return ""
    if FileExist(configured) && StrLower(RegExReplace(configured, ".*\\", "")) = "start.exe"
        return configured

    dir := RegExReplace(configured, "\\[^\\]+$", "")
    candidate := dir "\Start.exe"
    return FileExist(candidate) ? candidate : ""
}

DeleteSandboxieContentsFast(boxNames)
{
    startExe := GetSandboxieStartPath()
    if startExe = ""
        throw Error("Start.exe could not be found.")

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

    sandman := GetSandboxieStartPath()
    username := Trim(account.steamUsername)
    password := GetSteamCredentialPassword(accountName)

    if !IsValidSandboxieName(accountName)
    {
        MsgBox("Enter a valid account name first.", "Steam", "Icon!")
        return
    }
    if sandman = "" || !FileExist(sandman)
    {
        MsgBox("Select a valid Sandboxie Start.exe path first.", "Steam", "Icon!")
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
        password := ""
        command := ""
        StatusText.Text := "Status: Steam launched in sandbox " accountName "."
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

    sandman := GetSandboxieStartPath()

    if !IsValidSandboxieName(accountName)
    {
        MsgBox("Enter a valid account name first.", "Foxhole", "Icon!")
        return
    }
    if sandman = "" || !FileExist(sandman)
    {
        MsgBox("Select a valid Sandboxie Start.exe path first.", "Foxhole", "Icon!")
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
    {
        LogEvent("Foxhole launch ignored: sequential launch already active", "WARN")
        return false
    }

    LogEvent("Foxhole launch requested for account slots: " JoinLogNumbers(selected))
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
        sandman := GetSandboxieStartPath()
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
    global SequentialLoginActive, SequentialLoginRefillPending

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
    if SequentialLoginActive
    {
        SequentialLoginRefillPending := false
        SetTimer(MonitorSequentialLoginWorkflow, 750)
        UpdateSequentialLoginStatus()
        return
    }
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
    hadClosedWindow := false

    for inst in Instances
    {
        if inst.hwnd && !IsWindowAlive(inst.hwnd)
        {
            StopAllHotkeys(inst)
            RemoveTitleOverlay(inst.hwnd)
            inst.hwnd := 0
            inst.displayName := ""
            hadClosedWindow := true
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
            inst.trainSlowInterval := Settings["TrainSlowInterval"]
            inst.autoClickPaused := false
            inst.trainSlowHolding := false
            if !HasProp(inst, "trainSlowPulseId")
                inst.trainSlowPulseId := 0
            else
                inst.trainSlowPulseId += 1
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
                trainSlowInterval: Settings["TrainSlowInterval"],
                autoClickPaused: false,
                autoClick: false,
                autoWalk: false,
                autoReverse: false,
                clickHold: false,
                rightHold: false,
                vSpam: false,
                trainSlow: false,
                trainSlowHolding: false,
                trainSlowPulseId: 0,
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

    if hadClosedWindow && !SequentialLaunchActive
        CompactLiveInstanceSlots()

    if !SequentialLaunchActive
        RefreshList()
    SyncFoxholePreviews()
    RestoreForegroundWindow(foregroundHwnd)
}

CompactLiveInstanceSlots()
{
    global Instances

    live := []
    for inst in Instances
        if IsWindowAlive(inst.hwnd)
            live.Push(inst)

    SortInstancesBySlot(live)

    for slot, inst in live
    {
        if inst.slot = slot
            continue

        accountName := GetAccountNameForInstance(inst)
        inst.slot := slot
        RenameInstance(inst, accountName)
    }
}

RestoreForegroundWindow(hwnd)
{

    if !hwnd || !WinExist("ahk_id " hwnd)
        return

    current := WinExist("A")
    if current = hwnd
        return

    if !current
    {
        return
    }

    currentPid := 0
    try currentPid := WinGetPID("ahk_id " current)
    if currentPid != DllCall("GetCurrentProcessId", "UInt")
    {
        return
    }

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
    return hwnd && DllCall("IsWindow", "Ptr", hwnd, "Int")
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
    global LV, Instances, SelectedIndex, StatusText, SandboxieAccounts

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
            if inst.slot >= 1 && inst.slot <= SandboxieAccounts.Length && SandboxieAccounts[inst.slot].useDisplayName && Trim(SandboxieAccounts[inst.slot].displayName) != ""
                title := "War " inst.slot " - " GetSandboxieDisplayName(inst.slot)
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
    menuGui := Gui("+ToolWindow -Caption +AlwaysOnTop", "Swap")
    SwapWindowMenuGui := menuGui
    menuGui.SetFont("s9 c000000", "Segoe UI")
    menuGui.BackColor := "FFFFFF"
    menuGui.MarginX := 6
    menuGui.MarginY := 6
    menuGui.AddText("x6 y5 w270 h40 +0x200", "Swap with... (Can use # keys).")
    SwapWindowMenuList := menuGui.AddListBox("x6 y50 w270 r12", entries)
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

    menuGui.Show("x" mx " y" my " w" menuW " h" menuH)
    if !IsObject(menuGui) || !menuGui.Hwnd
    {
        CloseWindowSwapMenu()
        return
    }
    SwapWindowMenuHwnd := menuGui.Hwnd

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

    hadRect := false
    try
    {
        WinGetPos(&preserveX, &preserveY, &preserveW, &preserveH, "ahk_id " hwnd)
        hadRect := preserveW > 0 && preserveH > 0
    }

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

    if hadRect && IsWindowAlive(hwnd)
    {
        try
        {
            WinMove(preserveX, preserveY, preserveW, preserveH, "ahk_id " hwnd)
            WinGetPos(&actualX, &actualY, &actualW, &actualH, "ahk_id " hwnd)
            inst.x := actualX
            inst.y := actualY
            inst.width := actualW
            inst.height := actualH
        }
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

    identityText := BuildIdentityText(inst)
    if identityText = ""
        return

    targetPid := 0
    try targetPid := WinGetPID("ahk_id " inst.hwnd)
    if !targetPid
        return

    rec := CreateLayeredIdentityOverlay(identityText, Settings["GameIdentityTextSize"], "Game Identity " inst.slot)
    if !IsObject(rec)
        return

    rec.targetHwnd := inst.hwnd
    rec.targetPid := targetPid
    rec.slot := inst.slot
    rec.overlayHwnd := GetGuiHwndSafe(rec.gui)
    if !rec.overlayHwnd
    {
        DestroyLayeredIdentityOverlay(rec)
        return
    }
    TitleOverlays[inst.hwnd] := rec
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
        if !ValidateTitleOverlayOwnership(hwnd, overlayRecord)
            stale.Push(hwnd)

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

    identityText := BuildIdentityText(inst)
    if identityText = ""
    {
        if TitleOverlays.Has(inst.hwnd)
            RemoveTitleOverlay(inst.hwnd)
        return
    }

    if TitleOverlays.Has(inst.hwnd) && !ValidateTitleOverlayOwnership(inst.hwnd, TitleOverlays[inst.hwnd])
        RemoveTitleOverlay(inst.hwnd)

    if TitleOverlays.Has(inst.hwnd)
    {
        rec := TitleOverlays[inst.hwnd]
        if rec.identityText != identityText || rec.fontSize != Settings["GameIdentityTextSize"]
        {
            RemoveTitleOverlay(inst.hwnd)
            CreateTitleOverlay(inst)
        }
    }
    else
        CreateTitleOverlay(inst)

    if !TitleOverlays.Has(inst.hwnd)
        return

    rec := TitleOverlays[inst.hwnd]

    if DllCall("GetForegroundWindow", "Ptr") != inst.hwnd
    {
        HideLayeredIdentityOverlay(rec)
        return
    }

    if !TryGetWindowRectSafe(inst.hwnd, &x, &y, &w, &h)
    {
        RemoveTitleOverlay(inst.hwnd)
        return
    }

    pos := GetAnchoredIdentityPosition(
        x, y, w, h,
        rec.width, rec.height,
        Settings["GameIdentityVertical"],
        Settings["GameIdentityHorizontal"],
        10)

    if !rec.visible || rec.lastX != Round(pos.x) || rec.lastY != Round(pos.y)
        UpdateLayeredIdentityOverlay(rec, pos.x, pos.y)
}

RemoveTitleOverlay(hwnd)
{
    global TitleOverlays

    if !TitleOverlays.Has(hwnd)
        return

    rec := TitleOverlays[hwnd]
    try TitleOverlays.Delete(hwnd)
    DestroyLayeredIdentityOverlay(rec)
}

UpdateAllTitleOverlays()
{
    global Instances, TitleOverlays, Settings

    CleanupInvalidTitleOverlays()

    if !Settings["ShowOverlay"]
    {
        hwnds := []
        for hwnd, _ in TitleOverlays
            hwnds.Push(hwnd)
        for hwnd in hwnds
            RemoveTitleOverlay(hwnd)
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
        if !live.Has(hwnd)
            stale.Push(hwnd)

    for hwnd in stale
        RemoveTitleOverlay(hwnd)

    RaiseFocusedTitleOverlay()
}

RaiseFocusedTitleOverlay()
{
    activeHwnd := DllCall("GetForegroundWindow", "Ptr")
    if activeHwnd
        RaiseTitleOverlayForHwnd(activeHwnd)
}

RaiseTitleOverlayForHwnd(hwnd)
{
    global TitleOverlays, Instances

    for targetHwnd, rec in TitleOverlays
    {
        if targetHwnd != hwnd
            HideLayeredIdentityOverlay(rec)
    }

    if !TitleOverlays.Has(hwnd)
        return

    rec := TitleOverlays[hwnd]
    if !ValidateTitleOverlayOwnership(hwnd, rec)
        return

    for inst in Instances
    {
        if inst.hwnd = hwnd
        {
            UpdateTitleOverlay(inst)
            break
        }
    }

    try DllCall("SetWindowPos",
        "Ptr", rec.overlayHwnd,
        "Ptr", -1,
        "Int", 0, "Int", 0, "Int", 0, "Int", 0,
        "UInt", 0x0013,
        "Int")
}

RebuildAllTitleOverlays()
{
    global Instances, TitleOverlays, Settings

    ScanWindows()

    hwnds := []
    for hwnd, _ in TitleOverlays
        hwnds.Push(hwnd)
    for hwnd in hwnds
        RemoveTitleOverlay(hwnd)

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

NotifyFoxholeActivated(hwnd)
{
    global Settings, LastFocusedFoxholeHwnd, Instances, CycleCursorHwnd
    global RequestedFoxholeHwnd, RequestedFoxholeAt
    global MouseFocusSwitchLock, MouseFocusSwitchX, MouseFocusSwitchY, HoverFocusedHwnd

    if !hwnd
        return

    found := 0
    for inst in Instances
    {
        if inst.hwnd = hwnd
        {
            found := inst
            break
        }
    }
    if !found
        return

    CycleCursorHwnd := hwnd

    RequestedFoxholeHwnd := hwnd
    RequestedFoxholeAt := A_TickCount

    try MouseGetPos(&MouseFocusSwitchX, &MouseFocusSwitchY)
    MouseFocusSwitchLock := true
    HoverFocusedHwnd := hwnd

    if hwnd = LastFocusedFoxholeHwnd
    {
        RaiseTitleOverlayForHwnd(hwnd)
        SetTimer(RefreshActiveFoxholePreviewHighlight, -1)
        return
    }

    LastFocusedFoxholeHwnd := hwnd
    RaiseTitleOverlayForHwnd(hwnd)
    SetTimer(RefreshActiveFoxholePreviewHighlight, -1)

    if Settings["FlashGameIdentity"]
        ShowFoxholeFocusIdentity(found)
}

GetTopFoxholeWindowHwnd()
{
    global Instances

    try hwnds := WinGetList("ahk_exe War-Win64-Shipping.exe")
    catch
        hwnds := []

    for hwnd in hwnds
    {
        if !IsWindowAlive(hwnd) || !DllCall("IsWindowVisible", "Ptr", hwnd, "Int")
            continue
        for inst in Instances
            if inst.hwnd = hwnd
                return hwnd
    }

    for hwnd in hwnds
    {
        if !IsWindowAlive(hwnd)
            continue
        for inst in Instances
            if inst.hwnd = hwnd
                return hwnd
    }
    return 0
}

ApplyObservedFoxholeFocus(hwnd, flashIdentity := true)
{
    global Settings, LastFocusedFoxholeHwnd, Instances

    if !hwnd || hwnd = LastFocusedFoxholeHwnd
        return

    found := 0
    for inst in Instances
    {
        if inst.hwnd = hwnd && IsWindowAlive(hwnd)
        {
            found := inst
            break
        }
    }
    if !found
        return

    LastFocusedFoxholeHwnd := hwnd
    RaiseTitleOverlayForHwnd(hwnd)
    SetTimer(RefreshActiveFoxholePreviewHighlight, -1)

    if flashIdentity && Settings["FlashGameIdentity"]
        ShowFoxholeFocusIdentity(found)
}

MonitorFoxholeFocusIdentity(*)
{
    global LastFocusedFoxholeHwnd, Instances, CycleCursorHwnd
    static dbgLastForeground := -1
    global RequestedFoxholeHwnd, RequestedFoxholeAt, FoxholeActivationGraceMs
    global CycleDesiredHwnd, CycleDesiredUntil

    foreground := DllCall("GetForegroundWindow", "Ptr")
    if foreground != dbgLastForeground
    {
        dbgLastForeground := foreground
    }

    if CycleDesiredHwnd && A_TickCount < CycleDesiredUntil && IsWindowAlive(CycleDesiredHwnd)
    {
        if LastFocusedFoxholeHwnd != CycleDesiredHwnd
            ApplyObservedFoxholeFocus(CycleDesiredHwnd, false)
        return
    }

    if RequestedFoxholeHwnd
    {
        if foreground = RequestedFoxholeHwnd
        {
            RequestedFoxholeHwnd := 0
            RequestedFoxholeAt := 0
            ApplyObservedFoxholeFocus(foreground, false)
            return
        }

        elapsed := A_TickCount - RequestedFoxholeAt
        if elapsed >= 0 && elapsed < FoxholeActivationGraceMs
            return

        RequestedFoxholeHwnd := 0
        RequestedFoxholeAt := 0
    }

    for inst in Instances
    {
        if inst.hwnd = foreground && IsWindowAlive(foreground)
        {

            ApplyObservedFoxholeFocus(foreground)
            return
        }
    }

    topGame := GetTopFoxholeWindowHwnd()
    if topGame
        ApplyObservedFoxholeFocus(topGame, false)
}

GetFocusFlashCacheKey(inst, &accountName, &boxW, &boxH)
{
    accountName := GetIdentityAccountName(inst)
    try WinGetPos(, , &ww, &wh, "ahk_id " inst.hwnd)
    catch
        ww := 1920, wh := 1080
    boxW := Min(560, Max(360, Round(ww * 0.34)))
    boxH := 160
    return inst.slot "|" accountName "|" boxW "|" boxH
}

EnsureFocusFlashCacheEntry(inst)
{
    global FocusFlashCache
    key := GetFocusFlashCacheKey(inst, &accountName, &boxW, &boxH)
    if FocusFlashCache.Has(key)
        return FocusFlashCache[key]

    if !CreateFoxholeIdentityBitmap(inst.slot, accountName, boxW, boxH, &memDC, &hBitmap, &oldBitmap)
        return ""

    entry := {key: key, memDC: memDC, bitmap: hBitmap, oldBitmap: oldBitmap, width: boxW, height: boxH}
    FocusFlashCache[key] := entry
    return entry
}

WarmFoxholeFocusIdentityCache(*)
{
    global Settings, Instances
    if !Settings["FlashGameIdentity"]
        return
    for inst in Instances
        EnsureFocusFlashCacheEntry(inst)
}

InvalidateFocusFlashCache()
{
    global FocusFlashCache
    for _, entry in FocusFlashCache
    {
        if entry.memDC
        {
            if entry.oldBitmap
                try DllCall("gdi32\SelectObject", "Ptr", entry.memDC, "Ptr", entry.oldBitmap, "Ptr")
            if entry.bitmap
                try DllCall("gdi32\DeleteObject", "Ptr", entry.bitmap)
            try DllCall("gdi32\DeleteDC", "Ptr", entry.memDC)
        }
    }
    FocusFlashCache := Map()
}

ShowFoxholeFocusIdentity(inst)
{
    global FocusFlashGui, FocusFlashStartedAt, FocusFlashMemDC
    global FocusFlashX, FocusFlashY, FocusFlashW, FocusFlashH, FocusFlashActiveKey

    entry := EnsureFocusFlashCacheEntry(inst)
    if !IsObject(entry)
        return

    try WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " inst.hwnd)
    catch
        return

    if !IsObject(FocusFlashGui)
    {
        FocusFlashGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +E0x80000", "Foxhole Slot Identity")
        FocusFlashGui.Show("Hide w1 h1")
    }

    FocusFlashMemDC := entry.memDC
    FocusFlashActiveKey := entry.key
    FocusFlashW := entry.width
    FocusFlashH := entry.height
    FocusFlashX := wx + Round((ww - FocusFlashW) / 2)
    FocusFlashY := wy + Round((wh - FocusFlashH) / 2)
    FocusFlashStartedAt := A_TickCount

    UpdateFoxholeIdentityLayeredWindow(255)
    DllCall("ShowWindow", "Ptr", FocusFlashGui.Hwnd, "Int", 4)
    SetTimer(UpdateFoxholeFocusIdentityFade, 25)
}

CreateFoxholeIdentityBitmap(slotNumber, accountName, width, height, &memDC, &hBitmap, &oldBitmap)
{
    screenDC := DllCall("GetDC", "Ptr", 0, "Ptr")
    if !screenDC
        return false

    memDC := DllCall("gdi32\CreateCompatibleDC", "Ptr", screenDC, "Ptr")
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", screenDC)
    if !memDC
        return false

    bmi := Buffer(40, 0)
    NumPut("UInt", 40, bmi, 0)
    NumPut("Int", width, bmi, 4)
    NumPut("Int", -height, bmi, 8)
    NumPut("UShort", 1, bmi, 12)
    NumPut("UShort", 32, bmi, 14)
    NumPut("UInt", 0, bmi, 16)

    bits := 0
    hBitmap := DllCall("gdi32\CreateDIBSection",
        "Ptr", memDC,
        "Ptr", bmi.Ptr,
        "UInt", 0,
        "Ptr*", &bits,
        "Ptr", 0,
        "UInt", 0,
        "Ptr")

    if !hBitmap || !bits
    {
        DllCall("gdi32\DeleteDC", "Ptr", memDC)
        memDC := 0
        hBitmap := 0
        return false
    }

    oldBitmap := DllCall("gdi32\SelectObject", "Ptr", memDC, "Ptr", hBitmap, "Ptr")
    DllCall("gdi32\SetBkMode", "Ptr", memDC, "Int", 1)
    DllCall("gdi32\SetTextColor", "Ptr", memDC, "UInt", 0xFFFFFF)

    slotFont := DllCall("gdi32\CreateFontW",
        "Int", -72, "Int", 0, "Int", 0, "Int", 0,
        "Int", 700, "UInt", 0, "UInt", 0, "UInt", 0,
        "UInt", 1, "UInt", 0, "UInt", 0, "UInt", 5,
        "UInt", 0, "WStr", "Segoe UI", "Ptr")
    oldFont := DllCall("gdi32\SelectObject", "Ptr", memDC, "Ptr", slotFont, "Ptr")

    rect1 := Buffer(16, 0)
    NumPut("Int", 0, rect1, 0)
    NumPut("Int", 4, rect1, 4)
    NumPut("Int", width, rect1, 8)
    NumPut("Int", 96, rect1, 12)
    DllCall("user32\DrawTextW",
        "Ptr", memDC, "WStr", String(slotNumber), "Int", -1,
        "Ptr", rect1.Ptr,
        "UInt", 0x0001 | 0x0004 | 0x0020 | 0x0800)

    accountFont := DllCall("gdi32\CreateFontW",
        "Int", -31, "Int", 0, "Int", 0, "Int", 0,
        "Int", 600, "UInt", 0, "UInt", 0, "UInt", 0,
        "UInt", 1, "UInt", 0, "UInt", 0, "UInt", 5,
        "UInt", 0, "WStr", "Segoe UI", "Ptr")
    DllCall("gdi32\SelectObject", "Ptr", memDC, "Ptr", accountFont, "Ptr")

    rect2 := Buffer(16, 0)
    NumPut("Int", 6, rect2, 0)
    NumPut("Int", 98, rect2, 4)
    NumPut("Int", width - 6, rect2, 8)
    NumPut("Int", 150, rect2, 12)
    DllCall("user32\DrawTextW",
        "Ptr", memDC, "WStr", accountName, "Int", -1,
        "Ptr", rect2.Ptr,
        "UInt", 0x0001 | 0x0004 | 0x0020 | 0x0800 | 0x0004)

    DllCall("gdi32\SelectObject", "Ptr", memDC, "Ptr", oldFont, "Ptr")
    if slotFont
        DllCall("gdi32\DeleteObject", "Ptr", slotFont)
    if accountFont
        DllCall("gdi32\DeleteObject", "Ptr", accountFont)

    pixelCount := width * height
    Loop pixelCount
    {
        offset := (A_Index - 1) * 4
        pixel := NumGet(bits + offset, "UInt")
        b := pixel & 0xFF
        g := (pixel >> 8) & 0xFF
        r := (pixel >> 16) & 0xFF
        a := Max(r, g, b)
        if a
        {

            NumPut("UInt", (a << 24) | (r << 16) | (g << 8) | b, bits + offset)
        }
        else
            NumPut("UInt", 0, bits + offset)
    }

    return true
}

UpdateFoxholeIdentityLayeredWindow(alpha)
{
    global FocusFlashGui, FocusFlashMemDC
    global FocusFlashX, FocusFlashY, FocusFlashW, FocusFlashH

    if !IsObject(FocusFlashGui) || !FocusFlashMemDC
        return

    screenDC := DllCall("GetDC", "Ptr", 0, "Ptr")
    if !screenDC
        return

    ptDst := Buffer(8, 0)
    NumPut("Int", FocusFlashX, ptDst, 0)
    NumPut("Int", FocusFlashY, ptDst, 4)

    size := Buffer(8, 0)
    NumPut("Int", FocusFlashW, size, 0)
    NumPut("Int", FocusFlashH, size, 4)

    ptSrc := Buffer(8, 0)
    NumPut("Int", 0, ptSrc, 0)
    NumPut("Int", 0, ptSrc, 4)

    blend := Buffer(4, 0)
    NumPut("UChar", 0, blend, 0)
    NumPut("UChar", 0, blend, 1)
    NumPut("UChar", Max(0, Min(255, alpha)), blend, 2)
    NumPut("UChar", 1, blend, 3)

    try DllCall("user32\UpdateLayeredWindow",
        "Ptr", FocusFlashGui.Hwnd,
        "Ptr", screenDC,
        "Ptr", ptDst.Ptr,
        "Ptr", size.Ptr,
        "Ptr", FocusFlashMemDC,
        "Ptr", ptSrc.Ptr,
        "UInt", 0,
        "Ptr", blend.Ptr,
        "UInt", 2)

    DllCall("ReleaseDC", "Ptr", 0, "Ptr", screenDC)
}

UpdateFoxholeFocusIdentityFade(*)
{
    global FocusFlashGui, FocusFlashStartedAt, FocusFlashDurationMs
    if !IsObject(FocusFlashGui)
    {
        SetTimer(UpdateFoxholeFocusIdentityFade, 0)
        return
    }

    elapsed := A_TickCount - FocusFlashStartedAt
    if elapsed >= FocusFlashDurationMs
    {
        HideFoxholeFocusIdentity()
        return
    }

    alpha := Max(0, Round(255 * (1 - elapsed / FocusFlashDurationMs)))
    UpdateFoxholeIdentityLayeredWindow(alpha)
}

HideFoxholeFocusIdentity()
{
    global FocusFlashGui, FocusFlashMemDC, FocusFlashActiveKey
    SetTimer(UpdateFoxholeFocusIdentityFade, 0)
    if IsObject(FocusFlashGui)
        try FocusFlashGui.Hide()
    FocusFlashMemDC := 0
    FocusFlashActiveKey := ""
}

CleanupFocusFlashResources()
{
    global FocusFlashGui
    HideFoxholeFocusIdentity()
    InvalidateFocusFlashCache()
    if IsObject(FocusFlashGui)
        try FocusFlashGui.Destroy()
    FocusFlashGui := ""
}

MaintainTitleOverlays(*)
{
    global SequentialLaunchActive, UiTransitionInProgress
    if SequentialLaunchActive || UiTransitionInProgress
        return
    UpdateAllTitleOverlays()
    WarmFoxholeFocusIdentityCache()
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
    global CurrentOutputKeys

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
            SetInstanceTimer(inst, "ClickHold", (*) => SendBackgroundHold(inst), 50)
            RestoreGameCursorToPhysicalPositionForInstance(inst)

        case "RightHold":
            SendBackgroundRightHold(inst)
            SetInstanceTimer(inst, "RightHold", (*) => SendBackgroundRightHold(inst), 200)

        case "VSpam":
            SendBackgroundV(inst)
            SetInstanceTimer(inst, "VSpam", (*) => SendBackgroundV(inst), 50)

        case "TrainSlow":
            RemoveInstanceTimer(inst, "TrainSlowRelease")
            if !HasProp(inst, "trainSlowPulseId")
                inst.trainSlowPulseId := 0
            inst.trainSlowPulseId += 1
            inst.trainSlowHolding := false
            PostBackgroundKeyUpForInstance(inst, CurrentOutputKeys["TrainSlow"])
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
                SafeBackgroundPostMessage(0x0205, 0, 0, , "ahk_id " inst.hwnd)

        case "VSpam":
            inst.vSpam := false
            if alive
                PostBackgroundKeyUpForInstance(inst, CurrentOutputKeys["VSpam"])

        case "TrainSlow":
            RemoveInstanceTimer(inst, "TrainSlowRelease")
            if !HasProp(inst, "trainSlowPulseId")
                inst.trainSlowPulseId := 0
            inst.trainSlowPulseId += 1
            inst.trainSlow := false
            inst.trainSlowHolding := false
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

SafeBackgroundPostMessage(msg, wParam := 0, lParam := 0, control := "", winTitle := "")
{
    try
    {
        PostMessage(msg, wParam, lParam, , winTitle)
        return true
    }
    catch
    {
        return false
    }
}

SendBackgroundClick(inst)
{
    if !IsWindowAlive(inst.hwnd)
        return
    lp := MakeLParam(inst.clickX, inst.clickY)
    restoreLp := GetCurrentCursorClientLParam(inst.hwnd)
    target := "ahk_id " inst.hwnd
    SafeBackgroundPostMessage(0x0201, 0x0001, lp, , target)
    SafeBackgroundPostMessage(0x0202, 0, lp, , target)
    if restoreLp != ""
        SafeBackgroundPostMessage(0x0200, 0, restoreLp, , target)
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
    return SafeBackgroundPostMessage(0x0100, vk, BuildKeyboardLParam(sc, false, IsExtendedOutputKey(keyName)), , "ahk_id " inst.hwnd)
}

PostBackgroundKeyUpForInstance(inst, keyName)
{
    if !IsWindowAlive(inst.hwnd) || !IsValidOutputKey(keyName)
        return false
    vk := GetKeyVK(keyName), sc := GetKeySC(keyName)
    return SafeBackgroundPostMessage(0x0101, vk, BuildKeyboardLParam(sc, true, IsExtendedOutputKey(keyName)), , "ahk_id " inst.hwnd)
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
    if !IsWindowAlive(inst.hwnd) || !inst.clickHold
        return
    lp := MakeLParam(inst.clickX, inst.clickY)
    SafeBackgroundPostMessage(0x0201, 0x0001, lp, , "ahk_id " inst.hwnd)
}

RestoreGameCursorToPhysicalPositionForInstance(inst)
{
    if !IsWindowAlive(inst.hwnd)
        return
    restoreLp := GetCurrentCursorClientLParam(inst.hwnd)
    if restoreLp != ""
        SafeBackgroundPostMessage(0x0200, 0, restoreLp, , "ahk_id " inst.hwnd)
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
    SafeBackgroundPostMessage(0x0202, 0, lp, , target)
    if restoreLp != ""
        SafeBackgroundPostMessage(0x0200, 0, restoreLp, , target)
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

    if HasProp(inst, "trainSlowHolding") && inst.trainSlowHolding
        return

    if !HasProp(inst, "trainSlowPulseId")
        inst.trainSlowPulseId := 0
    inst.trainSlowPulseId += 1
    pulseId := inst.trainSlowPulseId

    if PostBackgroundKeyDownForInstance(inst, CurrentOutputKeys["TrainSlow"])
    {
        inst.trainSlowHolding := true
        release := (*) => ReleaseBackgroundTrainSlow(inst, pulseId)
        SetInstanceTimer(inst, "TrainSlowRelease", release, -TrainSlowHoldDuration)
    }
}

ReleaseBackgroundTrainSlow(inst, pulseId := 0)
{
    global CurrentOutputKeys

    if pulseId && HasProp(inst, "trainSlowPulseId") && pulseId != inst.trainSlowPulseId
        return

    if IsWindowAlive(inst.hwnd)
        PostBackgroundKeyUpForInstance(inst, CurrentOutputKeys["TrainSlow"])
    inst.trainSlowHolding := false
    if inst.timers.Has("TrainSlowRelease")
        inst.timers.Delete("TrainSlowRelease")
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
+WheelUp::AdjustFocusedTrainSlowInterval(50)
+WheelDown::AdjustFocusedTrainSlowInterval(-50)
!WheelUp::AdjustTrainSlowHoldDurationForAll(50)
!WheelDown::AdjustTrainSlowHoldDurationForAll(-50)
^WheelUp::AdjustTrainSlowHoldDurationForAll(50)
^WheelDown::AdjustTrainSlowHoldDurationForAll(-50)
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
    global Settings
    if !IsObject(GetFocusedActionInstance("TrainSlow"))
        return

    interval := Max(10, Min(5000, Settings["TrainSlowInterval"] + change))
    ApplyTrainSlowIntervalToAll(interval, true)
    ShowHotkeyTooltip("Train Slow interval (all accounts): " interval " ms")
}

ApplyTrainSlowIntervalToAll(interval, persist := true)
{
    global Settings, Instances, IntervalEdits, CONFIG_FILE
    interval := Max(10, Min(5000, Integer(interval)))
    Settings["TrainSlowInterval"] := interval
    if IntervalEdits.Has("TrainSlow")
        IntervalEdits["TrainSlow"].Value := String(interval)

    for inst in Instances
    {
        inst.trainSlowInterval := interval
        if inst.trainSlow && IsWindowAlive(inst.hwnd)
        {
            if inst.timers.Has("TrainSlow")
            {
                try SetTimer(inst.timers["TrainSlow"], interval)
            }
            else
            {
                SetInstanceTimer(inst, "TrainSlow", (*) => SendBackgroundTrainSlow(inst), interval)
            }
        }
    }

    if persist
        IniWrite(interval, CONFIG_FILE, "Settings", "TrainSlowInterval")
}

AdjustTrainSlowHoldDurationForAll(change)
{
    global TrainSlowHoldDuration
    SetTrainSlowHoldDuration(TrainSlowHoldDuration + change, true)
    ShowHotkeyTooltip("Train Slow hold duration (all accounts): " TrainSlowHoldDuration " ms")
}

SetTrainSlowHoldDuration(duration, persist := true)
{
    global TrainSlowHoldDuration, TrainSlowHoldEdit, Settings, CONFIG_FILE
    TrainSlowHoldDuration := Max(10, Min(5000, Integer(duration)))
    Settings["TrainSlowHoldDuration"] := TrainSlowHoldDuration
    if IsObject(TrainSlowHoldEdit)
        try TrainSlowHoldEdit.Value := String(TrainSlowHoldDuration)
    if persist
        IniWrite(TrainSlowHoldDuration, CONFIG_FILE, "Settings", "TrainSlowHoldDuration")
}

SaveTrainSlowHoldDurationFromGui(ctrl, *)
{
    global TrainSlowHoldDuration, StatusText
    try value := Integer(ctrl.Value)
    catch
    {
        ctrl.Value := String(TrainSlowHoldDuration)
        return
    }
    SetTrainSlowHoldDuration(value, true)
    StatusText.Text := "Status: Train Slow hold duration set to " TrainSlowHoldDuration " ms for all accounts."
}

ResetTrainSlowHoldDuration(*)
{
    global TrainSlowDefaultHoldDuration, StatusText
    SetTrainSlowHoldDuration(TrainSlowDefaultHoldDuration, true)
    StatusText.Text := "Status: Train Slow hold duration reset to " TrainSlowDefaultHoldDuration " ms for all accounts."
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
    return Max(10, Min(5000, value))
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
        interval := Max(IntervalMinimums[action], Integer(ctrl.Value))
    catch
    {
        return
    }

    interval := action = "AutoClick" ? Min(500, interval) : Min(5000, interval)
    ctrl.Value := String(interval)
    settingName := IntervalSettings[action]
    Settings[settingName] := interval

    if action = "TrainSlow"
    {
        ApplyTrainSlowIntervalToAll(interval, true)
        StatusText.Text := "Status: Train Slow interval set to " interval " ms for all accounts."
        return
    }

    target := GetActiveFoxholeInstanceIndex()
    if target
    {
        inst := Instances[target]
        inst.clickInterval := Min(500, interval)
        SaveAccountInterval(inst.slot, action, interval)
        if IsHotkeysActionEnabled(inst, action)
            SetInstanceTimer(inst, "AutoClick", (*) => SendBackgroundClick(inst), inst.clickInterval)
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
    global Instances, ActionNames, CurrentKeys, RebindingAction, MouseFocusEnabled, Settings

    if RebindingAction != ""
        return

    normalizedKey := StrLower(keyName)
    idx := 0

    if CurrentKeys["NextGame"] != "" && StrLower(CurrentKeys["NextGame"]) = normalizedKey
    {
        CycleToNextFoxholeGame()
        return
    }
    if CurrentKeys["LastGame"] != "" && StrLower(CurrentKeys["LastGame"]) = normalizedKey
    {
        CycleToLastFoxholeGame()
        return
    }

    for action in ActionNames
    {
        if IsGameHotkeyAction(action) && !Settings["GameHotkeysEnabled"]
            continue
        if CurrentKeys[action] = "" || StrLower(CurrentKeys[action]) != normalizedKey
            continue

        if action = "MouseFocus"
        {
            ToggleMouseFocus()
        }
        else if action = "LastGame"
        {
            CycleToLastFoxholeGame()
        }
        else if action = "NextGame"
        {
            CycleToNextFoxholeGame()
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
        else if action = "TogglePreviews"
        {
            ToggleFoxholePreviews()
        }
        else
        {
            if !idx
            {
                if MouseFocusEnabled && Settings["PreviewHoverHotkeys"]
                    idx := GetHoveredPreviewInstanceIndex()
                if !idx
                    idx := GetActiveFoxholeInstanceIndex()
            }
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
            if IsWindowAlive(inst.hwnd) && StrLower(Trim(GetAccountNameForInstance(inst))) = StrLower(accountName)
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
            if IsWindowAlive(inst.hwnd) && inst.slot = accountIndex
            {
                targetInst := inst
                break
            }
        }
    }

    if !IsObject(targetInst)
    {
        ScanWindows()
        for inst in Instances
        {
            if Settings["SwapByAccount"]
            {
                if StrLower(Trim(GetAccountNameForInstance(inst))) = StrLower(accountName)
                {
                    targetInst := inst
                    break
                }
            }
            else if inst.slot = accountIndex
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

    FastActivateFoxholeWindow(targetInst.hwnd)
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
    global MouseFocusSwitchLock

    MouseFocusEnabled := !!enabled
    MouseFocusSwitchLock := false
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
    global RequestedFoxholeHwnd, RequestedFoxholeAt, FoxholeActivationGraceMs
    global MouseFocusSwitchLock, MouseFocusSwitchX, MouseFocusSwitchY
    global CycleDesiredHwnd, CycleDesiredUntil

    if !MouseFocusEnabled
        return

    if CycleDesiredHwnd && A_TickCount < CycleDesiredUntil
        return

    if MouseFocusSwitchLock
    {
        mx := MouseFocusSwitchX
        my := MouseFocusSwitchY
        try MouseGetPos(&mx, &my)
        if Abs(mx - MouseFocusSwitchX) <= 2 && Abs(my - MouseFocusSwitchY) <= 2
            return
        MouseFocusSwitchLock := false
        HoverFocusedHwnd := 0
    }

    if RequestedFoxholeHwnd
    {
        elapsed := A_TickCount - RequestedFoxholeAt
        if elapsed >= 0 && elapsed < FoxholeActivationGraceMs
            return
    }

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
    {
        try WinActivate("ahk_id " rootHwnd)
    }
}

ForceForegroundWindow(hwnd)
{
    if !IsWindowAlive(hwnd)
        return false

    foregroundThread := 0
    targetThread := 0
    currentThread := DllCall("GetCurrentThreadId", "UInt")
    attachedForeground := false
    attachedTarget := false

    try
    {
        if WinGetMinMax("ahk_id " hwnd) = -1
            WinRestore("ahk_id " hwnd)

        foreground := DllCall("GetForegroundWindow", "Ptr")
        if foreground = hwnd
            return true

        targetThread := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", 0, "UInt")
        foregroundThread := foreground ? DllCall("GetWindowThreadProcessId", "Ptr", foreground, "UInt*", 0, "UInt") : 0

        if foregroundThread && foregroundThread != currentThread
            attachedForeground := !!DllCall("AttachThreadInput", "UInt", currentThread, "UInt", foregroundThread, "Int", 1)
        if targetThread && targetThread != currentThread && targetThread != foregroundThread
            attachedTarget := !!DllCall("AttachThreadInput", "UInt", currentThread, "UInt", targetThread, "Int", 1)

        WinActivate("ahk_id " hwnd)
        DllCall("SetForegroundWindow", "Ptr", hwnd)
        return DllCall("GetForegroundWindow", "Ptr") = hwnd
    }
    catch
    {
        try WinActivate("ahk_id " hwnd)
        return WinActive("ahk_id " hwnd)
    }
    finally
    {
        if attachedTarget
            try DllCall("AttachThreadInput", "UInt", currentThread, "UInt", targetThread, "Int", 0)
        if attachedForeground
            try DllCall("AttachThreadInput", "UInt", currentThread, "UInt", foregroundThread, "Int", 0)
    }
}

SetWindowsTaskbarVisible(taskbarHwnd, visible := true)
{
    if !taskbarHwnd || !DllCall("IsWindow", "Ptr", taskbarHwnd, "Int")
        return

    if visible
    {

        try DllCall("ShowWindowAsync", "Ptr", taskbarHwnd, "Int", 5)
        try WinShow("ahk_id " taskbarHwnd)
        try DllCall("SetWindowPos", "Ptr", taskbarHwnd, "Ptr", 0,
            "Int", 0, "Int", 0, "Int", 0, "Int", 0,
            "UInt", 0x0001 | 0x0002 | 0x0004 | 0x0010 | 0x0040)
    }
    else
    {
        try DllCall("ShowWindowAsync", "Ptr", taskbarHwnd, "Int", 0)
    }
}

GetWindowsTaskbarHwnds()
{
    taskbars := []

    mainTaskbar := DllCall("FindWindow", "Str", "Shell_TrayWnd", "Ptr", 0, "Ptr")
    if mainTaskbar
        taskbars.Push(mainTaskbar)

    previous := 0
    loop
    {
        secondary := DllCall("FindWindowEx", "Ptr", 0, "Ptr", previous,
            "Str", "Shell_SecondaryTrayWnd", "Ptr", 0, "Ptr")
        if !secondary
            break
        taskbars.Push(secondary)
        previous := secondary
    }

    return taskbars
}

EnsureWindowsTaskbarsVisible()
{
    for taskbarHwnd in GetWindowsTaskbarHwnds()
        SetWindowsTaskbarVisible(taskbarHwnd, true)
}

RestoreFoxholeTaskbars(forceAll := false)
{
    global FoxholeHiddenTaskbars, FoxholeTaskbarMonitor

    if forceAll
    {
        EnsureWindowsTaskbarsVisible()
    }
    else
    {
        for taskbarHwnd, _ in FoxholeHiddenTaskbars
            SetWindowsTaskbarVisible(taskbarHwnd, true)
    }

    FoxholeHiddenTaskbars := Map()
    FoxholeTaskbarMonitor := 0
}

MaintainFoxholeTaskbarCover(*)
{
    global FoxholeHiddenTaskbars, FoxholeTaskbarMonitor

    foreground := DllCall("GetForegroundWindow", "Ptr")
    if !foreground
    {
        RestoreFoxholeTaskbars()
        return
    }

    processName := ""
    try processName := WinGetProcessName("ahk_id " foreground)
    if StrLower(processName) != "war-win64-shipping.exe"
    {

        RestoreFoxholeTaskbars()
        return
    }

    gameMonitor := DllCall("MonitorFromWindow", "Ptr", foreground, "UInt", 2, "Ptr")
    if !gameMonitor
    {
        RestoreFoxholeTaskbars()
        return
    }

    seen := Map()
    for taskbarHwnd in GetWindowsTaskbarHwnds()
    {
        taskbarMonitor := DllCall("MonitorFromWindow", "Ptr", taskbarHwnd, "UInt", 2, "Ptr")
        if taskbarMonitor = gameMonitor
        {
            SetWindowsTaskbarVisible(taskbarHwnd, false)
            seen[taskbarHwnd] := true
            FoxholeHiddenTaskbars[taskbarHwnd] := true
        }
        else if FoxholeHiddenTaskbars.Has(taskbarHwnd)
        {
            SetWindowsTaskbarVisible(taskbarHwnd, true)
            FoxholeHiddenTaskbars.Delete(taskbarHwnd)
        }
    }

    stale := []
    for taskbarHwnd, _ in FoxholeHiddenTaskbars
        if !seen.Has(taskbarHwnd)
            stale.Push(taskbarHwnd)
    for taskbarHwnd in stale
        FoxholeHiddenTaskbars.Delete(taskbarHwnd)

    FoxholeTaskbarMonitor := gameMonitor
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
    sandboxedPids := Map()
    accountPidGroups := []
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

        steamPids := []
        for pid in GetSandboxieBoxPids(boxName)
        {
            sandboxedPids[pid] := true
            try
            {
                processName := StrLower(ProcessGetName(pid))
                if processName = "steam.exe" || processName = "steamwebhelper.exe"
                    steamPids.Push(pid)
            }
        }
        if steamPids.Length
            accountPidGroups.Push(steamPids)
    }

    if includeMain
    {
        mainSteamPids := []
        try
        {
            wmi := ComObjGet("winmgmts:")
            for process in wmi.ExecQuery("SELECT ProcessId, Name FROM Win32_Process WHERE Name='steam.exe' OR Name='steamwebhelper.exe'")
            {
                pid := Integer(process.ProcessId)
                if pid > 0 && !sandboxedPids.Has(pid)
                    mainSteamPids.Push(pid)
            }
        }
        if mainSteamPids.Length
            accountPidGroups.Push(mainSteamPids)
    }

    changed := 0
    oldDetectHidden := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    try
    {
        for steamPids in accountPidGroups
        {
            hwnd := FindMainSteamWindowForPids(steamPids, shouldCloseToTray)
            if !hwnd
                continue

            try
            {
                if shouldCloseToTray
                    PostMessage(0x0010, 0, 0, , "ahk_id " hwnd)
                else
                {
                    DllCall("ShowWindowAsync", "Ptr", hwnd, "Int", 9)
                    try WinActivate("ahk_id " hwnd)
                }
                changed++
            }
        }
    }
    finally
    {
        DetectHiddenWindows(oldDetectHidden)
    }

    if changed
        ShowSteamWindowsVisible := !shouldCloseToTray
    StatusText.Text := "Status: " (shouldCloseToTray ? "Closed " : "Restored ") changed " Steam client window(s) " (shouldCloseToTray ? "to the system tray." : "without restoring helper windows.")
}

FindMainSteamWindowForPids(pids, visibleOnly := false)
{
    bestHwnd := 0
    bestScore := -1
    seenWindows := Map()

    for pid in pids
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
                exStyle := WinGetExStyle("ahk_id " hwnd)
                if visibleOnly && !(style & 0x10000000)
                    continue
                if exStyle & 0x00000080
                    continue

                owner := DllCall("GetWindow", "Ptr", hwnd, "UInt", 4, "Ptr")
                if owner
                    continue

                className := ""
                try className := WinGetClass("ahk_id " hwnd)
                if className = "#32768"
                    continue

                WinGetPos(,, &windowWidth, &windowHeight, "ahk_id " hwnd)
                if windowWidth < 500 || windowHeight < 300
                    continue

                area := windowWidth * windowHeight
                title := ""
                try title := Trim(WinGetTitle("ahk_id " hwnd))
                score := area
                if title != ""
                    score += 100000
                if InStr(StrLower(title), "steam")
                    score += 250000

                if score > bestScore
                {
                    bestScore := score
                    bestHwnd := hwnd
                }
            }
        }
    }

    return bestHwnd
}

GetActiveFoxholeInstanceIndex()
{
    global Instances

    hwnd := WinExist("A")
    if !hwnd
        return 0

    return FindInstanceByHwnd(hwnd)
}

IsGameHotkeyAction(action)
{
    return action = "AutoClick" || action = "AutoWalk" || action = "AutoReverse" || action = "ClickHold" || action = "RightHold" || action = "VSpam" || action = "TrainSlow"
}

DisableAllHotkeys()
{
    global RegisteredHotkeyKeys

    for normalizedKey, actualKey in RegisteredHotkeyKeys
        try Hotkey(actualKey, "Off")
    RegisteredHotkeyKeys := Map()
}

EnableAllHotkeys()
{
    SyncHotkeyRegistrations()
}

SyncHotkeyRegistrations()
{
    global ActionNames, CurrentKeys, AccountSwapKeys, RegisteredHotkeyKeys, Settings

    desired := Map()
    for action in ActionNames
    {
        if IsGameHotkeyAction(action) && !Settings["GameHotkeysEnabled"]
            continue
        key := CurrentKeys[action]
        if key != ""
            desired[StrLower(key)] := key
    }
    for _, key in AccountSwapKeys
    {
        if key != ""
            desired[StrLower(key)] := key
    }

    stale := []
    for normalizedKey, actualKey in RegisteredHotkeyKeys
    {
        if !desired.Has(normalizedKey)
        {
            try Hotkey(actualKey, "Off")
            stale.Push(normalizedKey)
        }
    }
    for normalizedKey in stale
        RegisteredHotkeyKeys.Delete(normalizedKey)

    for normalizedKey, actualKey in desired
    {
        if RegisteredHotkeyKeys.Has(normalizedKey)
            continue
        try
        {
            hotkeyOptions := "On"
            if (CurrentKeys["NextGame"] != "" && StrLower(CurrentKeys["NextGame"]) = normalizedKey)
                || (CurrentKeys["LastGame"] != "" && StrLower(CurrentKeys["LastGame"]) = normalizedKey)
                hotkeyOptions := "On T255"
            Hotkey(actualKey, MakeSharedHotkeyHandler(actualKey), hotkeyOptions)
            RegisteredHotkeyKeys[normalizedKey] := actualKey
        }
        catch as e
        {
            MsgBox("Could not register " DisplayNameForHotkeyString(actualKey) ".`n" e.Message, APP_NAME, "Icon!")
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
    SaveHotkeyBindingsConfig()
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

    SaveHotkeyBindingsConfig()

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
    SyncHotkeyRegistrations()
}

SaveHotkeysConfig()
{
    global CONFIG_FILE, ActionNames, CurrentKeys

    for action in ActionNames
        IniWrite(CurrentKeys[action], CONFIG_FILE, "Hotkeys", action)
}

SaveHotkeyBindingsConfig()
{
    global CONFIG_FILE, AccountSwapKeys
    SaveHotkeysConfig()
    SaveAccountSwapKeysPreservingSlots()
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
    global DefaultIntervals, TrainSlowDefaultHoldDuration, Settings, IntervalEdits

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

    if action = "TrainSlow"
    {
        ApplyTrainSlowIntervalToAll(DefaultIntervals["TrainSlow"], true)
        SetTrainSlowHoldDuration(TrainSlowDefaultHoldDuration, true)
    }
    else if action = "AutoClick"
    {
        Settings["ClickInterval"] := DefaultIntervals["AutoClick"]
        if IntervalEdits.Has("AutoClick")
            IntervalEdits["AutoClick"].Value := String(DefaultIntervals["AutoClick"])
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
    global Instances, ActionLabels, StatusText

    if !IntervalSettings.Has(action)
        return

    interval := DefaultIntervals[action]
    Settings[IntervalSettings[action]] := interval
    IntervalEdits[action].Value := String(interval)

    if action = "TrainSlow"
    {
        ApplyTrainSlowIntervalToAll(interval, true)
        StatusText.Text := "Status: Train Slow interval reset to " interval " ms for all accounts."
        return
    }

    target := GetActiveFoxholeInstanceIndex()
    if target
    {
        inst := Instances[target]
        inst.clickInterval := interval
        inst.autoClickPaused := false
        SaveAccountInterval(inst.slot, action, interval)
        if IsHotkeysActionEnabled(inst, action)
            SetInstanceTimer(inst, "AutoClick", (*) => SendBackgroundClick(inst), inst.clickInterval)
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
    global Settings, GameIdentityShowCheck
    Settings["ShowOverlay"] := ctrl.Value = 1
    if IsObject(GameIdentityShowCheck)
        GameIdentityShowCheck.Value := ctrl.Value
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
    global MainGui, MainPageControls, MainTipText, SBGui, HotkeysGui, LayoutEditorGui, PreviewSettingsGui, CurrentMainPage, MainGuiFixedWidth
    global MainNavButtons, LayoutEditorEditingActive, LayoutWindowPositions, LayoutReapplyPending
    global LayoutEditorRequiredHeight, WorkflowEditorExpanded, WorkflowEditorControls
    global SettingsSectionExpanded, SettingsSectionControls
    global LayoutEditorContentInitialized, LayoutEditorNeedsRefresh, UiTransitionInProgress

    if !IsObject(MainGui)
        return

    if CurrentMainPage = page
        return

    if CurrentMainPage = "Main" && MainScrollOffset
        SetMainPageScroll(0)
    UiTransitionInProgress := true
    SetGuiRedraw(MainGui, false)
    try
    {
        CurrentMainPage := page
        if IsObject(MainTipText)
            MainTipText.Visible := page = "Main"
        for ctrl in MainPageControls
            try ctrl.Visible := page = "Main"
        if page = "Main" && !WorkflowEditorExpanded
            for ctrl in WorkflowEditorControls
                try ctrl.Visible := false
        if page = "Main" && !SettingsSectionExpanded
            for ctrl in SettingsSectionControls
                try ctrl.Visible := false

        for name, btn in MainNavButtons
            try btn.Enabled := name != page

        for guiObj in [SBGui, HotkeysGui, LayoutEditorGui, PreviewSettingsGui]
            if IsObject(guiObj) && guiObj.Hwnd
                try guiObj.Hide()

        pageY := GetEmbeddedPageY()
        if page = "Accounts"
        {
            LayoutEditorEditingActive := false
            StartSandboxieStatusWatcher()
            FitEmbeddedPageToContent(SBGui, 12, 535, 140, true)
        }
        else if page = "Hotkeys"
        {
            StopSandboxieStatusWatcher()
            LayoutEditorEditingActive := false
            FitEmbeddedPageToContent(HotkeysGui, 12, 500, 140, true)
        }
        else if page = "Layouts"
        {
            StopSandboxieStatusWatcher()
            LayoutEditorEditingActive := true
            LayoutReapplyPending := false
            LayoutWindowPositions := CaptureFoxholeWindowPositions()
            EnsureLastSelectedLayout()

            if !LayoutEditorContentInitialized || LayoutEditorNeedsRefresh
                RefreshLayoutEditorGui()
            FitEmbeddedPageToContent(LayoutEditorGui, 0, 559, 140, true)
        }
        else if page = "Previews"
        {
            StopSandboxieStatusWatcher()
            LayoutEditorEditingActive := false
            BuildPreviewSettingsGui()
            FitEmbeddedPageToContent(PreviewSettingsGui, 12, 535, 140, true)
        }
        else
        {
            StopSandboxieStatusWatcher()
            LayoutEditorEditingActive := false
            ResizeMainGuiToContentHeight(GetMainPageRequiredHeight())
            ResizeMainGuiForRows()
            KeepMainGuiInsideWorkArea()
        }
    }
    finally
    {
        SetGuiRedraw(MainGui, true)
        DllCall("RedrawWindow", "Ptr", MainGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0085)
        UiTransitionInProgress := false
    }
}

MeasureGuiVisibleContentHeight(guiObj, padding := 8, minHeight := 0)
{
    if !IsObject(guiObj) || !guiObj.Hwnd
        return minHeight

    bottom := 0
    try
    {
        for hwnd in WinGetControlsHwnd("ahk_id " guiObj.Hwnd)
        {
            if DllCall("GetParent", "Ptr", hwnd, "Ptr") != guiObj.Hwnd
                continue
            ctrl := GuiCtrlFromHwnd(hwnd)
            if !IsObject(ctrl)
                continue
            try
            {
                if !ctrl.Visible
                    continue
                ctrl.GetPos(&cx, &cy, &cw, &ch)
                bottom := Max(bottom, cy + ch)
            }
        }
    }
    return Max(minHeight, bottom + padding)
}


ResizeMainGuiToContentHeight(clientHeight)
{
    global MainGui, MainGuiFixedWidth
    if !IsObject(MainGui) || !MainGui.Hwnd
        return

    MainGui.Show("w" MainGuiFixedWidth " h" Max(1, Ceil(clientHeight)) " NoActivate")
    ClampMainGuiToMonitorHeight()
    UpdateMainPageScrollRange()
    KeepMainGuiInsideWorkArea()
}


ClampMainGuiToMonitorHeight()
{
    global MainGui, CurrentMainPage, SBGui, HotkeysGui, LayoutEditorGui, PreviewSettingsGui
    global EmbeddedPageContentHeights, EmbeddedPageViewportHeights, EmbeddedPageScrollOffsets
    if !IsObject(MainGui) || !MainGui.Hwnd
        return

    WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " MainGui.Hwnd)
    monitorNumber := GetMonitorForAbsolutePoint(wx + ww // 2, wy + 20)
    MonitorGetWorkArea(monitorNumber, &wl, &wt, &wr, &wb)
    maxWindowHeight := Min(800, Max(280, wb - wt - 8))
    if wh <= maxWindowHeight
        return

    WinMove(,,, maxWindowHeight, "ahk_id " MainGui.Hwnd)
    pageGui := ""
    switch CurrentMainPage
    {
        case "Accounts": pageGui := SBGui
        case "Hotkeys": pageGui := HotkeysGui
        case "Layouts": pageGui := LayoutEditorGui
        case "Previews": pageGui := PreviewSettingsGui
    }
    if !IsObject(pageGui) || !pageGui.Hwnd
        return

    clientRect := Buffer(16, 0)
    if !DllCall("GetClientRect", "Ptr", MainGui.Hwnd, "Ptr", clientRect)
        return
    clientPixels := NumGet(clientRect, 12, "Int")
    dpi := DllCall("GetDpiForWindow", "Ptr", MainGui.Hwnd, "UInt")
    scale := dpi ? dpi / 96.0 : 1.0
    availableHeight := Max(100, Floor(clientPixels / scale - GetEmbeddedPageY() - 18))
    hwnd := pageGui.Hwnd
    if !EmbeddedPageContentHeights.Has(hwnd)
        return
    viewportHeight := Min(EmbeddedPageContentHeights[hwnd], availableHeight)
    EmbeddedPageViewportHeights[hwnd] := viewportHeight
    oldOffset := EmbeddedPageScrollOffsets.Has(hwnd) ? EmbeddedPageScrollOffsets[hwnd] : 0
    pageGui.Move(,, , viewportHeight)
    if oldOffset > 0
        SetEmbeddedPageScroll(pageGui, Min(oldOffset, Max(0, EmbeddedPageContentHeights[hwnd] - viewportHeight)))
    UpdateEmbeddedPageScrollBar(pageGui)
}

GetEmbeddedPageMaxViewportHeight()
{
    global MainGui
    pageY := GetEmbeddedPageY()
    if !IsObject(MainGui) || !MainGui.Hwnd
        return 700

    gx := 0, gy := 0, gw := 559, gh := 0
    try WinGetPos(&gx, &gy, &gw, &gh, "ahk_id " MainGui.Hwnd)

    monitorNumber := MonitorGetPrimary()
    try monitorNumber := GetMonitorForAbsolutePoint(gx + (gw // 2), gy + 20)

    workLeft := 0, workTop := 0, workRight := A_ScreenWidth, workBottom := A_ScreenHeight
    try MonitorGetWorkArea(monitorNumber, &workLeft, &workTop, &workRight, &workBottom)

    dpi := 96
    try dpi := DllCall("GetDpiForWindow", "Ptr", MainGui.Hwnd, "UInt")
    scale := dpi > 0 ? dpi / 96.0 : 1.0
    workHeight := Max(320, (workBottom - workTop) / scale)
    maxClientHeight := Max(280, Min(workHeight - 80, 800 / scale - 90))
    return Max(140, Floor(maxClientHeight - pageY - 16))
}

CaptureEmbeddedPageBasePositions(guiObj)
{
    global EmbeddedPageBasePositions
    if !IsObject(guiObj) || !guiObj.Hwnd
        return

    positions := Map()
    try
    {
        for childHwnd in WinGetControlsHwnd("ahk_id " guiObj.Hwnd)
        {
            if DllCall("GetParent", "Ptr", childHwnd, "Ptr") != guiObj.Hwnd
                continue
            ctrl := GuiCtrlFromHwnd(childHwnd)
            if !IsObject(ctrl)
                continue
            ctrl.GetPos(&cx, &cy, &cw, &ch)
            positions[childHwnd] := cy
        }
    }
    EmbeddedPageBasePositions[guiObj.Hwnd] := positions
}

ResetEmbeddedPageScroll(guiObj)
{
    global EmbeddedPageScrollOffsets, EmbeddedPageBasePositions
    if !IsObject(guiObj) || !guiObj.Hwnd
        return

    hwnd := guiObj.Hwnd
    if EmbeddedPageBasePositions.Has(hwnd)
    {
        positions := EmbeddedPageBasePositions[hwnd]
        try
        {
            for childHwnd in WinGetControlsHwnd("ahk_id " hwnd)
            {
            if DllCall("GetParent", "Ptr", childHwnd, "Ptr") != guiObj.Hwnd
                continue
                if !positions.Has(childHwnd)
                    continue
                ctrl := GuiCtrlFromHwnd(childHwnd)
                if IsObject(ctrl)
                    ctrl.Move(, positions[childHwnd])
            }
        }
    }
    else if EmbeddedPageScrollOffsets.Has(hwnd) && EmbeddedPageScrollOffsets[hwnd] != 0
    {
        offset := EmbeddedPageScrollOffsets[hwnd]
        try
        {
            for childHwnd in WinGetControlsHwnd("ahk_id " hwnd)
            {
            if DllCall("GetParent", "Ptr", childHwnd, "Ptr") != guiObj.Hwnd
                continue
                ctrl := GuiCtrlFromHwnd(childHwnd)
                if IsObject(ctrl)
                {
                    ctrl.GetPos(&cx, &cy, &cw, &ch)
                    ctrl.Move(, cy + offset)
                }
            }
        }
    }
    EmbeddedPageScrollOffsets[hwnd] := 0
}

SetEmbeddedPageScroll(guiObj, newOffset)
{
    global EmbeddedPageScrollOffsets, EmbeddedPageContentHeights, EmbeddedPageViewportHeights, EmbeddedPageBasePositions
    if !IsObject(guiObj) || !guiObj.Hwnd
        return

    hwnd := guiObj.Hwnd
    contentHeight := EmbeddedPageContentHeights.Has(hwnd) ? EmbeddedPageContentHeights[hwnd] : 0
    viewportHeight := EmbeddedPageViewportHeights.Has(hwnd) ? EmbeddedPageViewportHeights[hwnd] : contentHeight
    maxOffset := Max(0, contentHeight - viewportHeight)
    newOffset := Max(0, Min(maxOffset, Round(newOffset)))
    oldOffset := EmbeddedPageScrollOffsets.Has(hwnd) ? EmbeddedPageScrollOffsets[hwnd] : 0
    if newOffset = oldOffset
        return

    if !EmbeddedPageBasePositions.Has(hwnd)
        CaptureEmbeddedPageBasePositions(guiObj)
    positions := EmbeddedPageBasePositions.Has(hwnd) ? EmbeddedPageBasePositions[hwnd] : Map()

    SetGuiRedraw(guiObj, false)
    try
    {
        children := []
        for childHwnd in WinGetControlsHwnd("ahk_id " hwnd)
        {
            if DllCall("GetParent", "Ptr", childHwnd, "Ptr") = hwnd && positions.Has(childHwnd)
                children.Push(childHwnd)
        }
        dpi := DllCall("GetDpiForWindow", "Ptr", hwnd, "UInt")
        scale := dpi ? dpi / 96.0 : 1.0
        batch := children.Length > 4 ? DllCall("BeginDeferWindowPos", "Int", children.Length, "Ptr") : 0
        if batch
        {
            for childHwnd in children
            {
                ctrl := GuiCtrlFromHwnd(childHwnd)
                if !IsObject(ctrl)
                    continue
                ctrl.GetPos(&xx, &yy, &ww, &hh)
                nextBatch := DllCall("DeferWindowPos", "Ptr", batch, "Ptr", childHwnd,
                    "Ptr", 0, "Int", Round(xx * scale), "Int", Round((positions[childHwnd] - newOffset) * scale),
                    "Int", 0, "Int", 0, "UInt", 0x0015, "Ptr")
                if !nextBatch
                {
                    DllCall("EndDeferWindowPos", "Ptr", batch)
                    batch := 0
                    break
                }
                batch := nextBatch
            }
            if batch
                DllCall("EndDeferWindowPos", "Ptr", batch)
        }
        if !batch
        {
            for childHwnd in children
            {
                ctrl := GuiCtrlFromHwnd(childHwnd)
                if IsObject(ctrl)
                    ctrl.Move(, positions[childHwnd] - newOffset)
            }
        }
        EmbeddedPageScrollOffsets[hwnd] := newOffset
        UpdateEmbeddedPageScrollBar(guiObj)
    }
    finally
    {
        SetGuiRedraw(guiObj, true)
    }
}

FitEmbeddedPageToContent(guiObj, pageX, pageWidth, minHeight := 140, showPage := true)
{
    global MainGui
    global EmbeddedPageScrollOffsets, EmbeddedPageContentHeights, EmbeddedPageViewportHeights
    if !IsObject(guiObj) || !guiObj.Hwnd || !IsObject(MainGui) || !MainGui.Hwnd
        return 0

    ResetEmbeddedPageScroll(guiObj)
    CaptureEmbeddedPageBasePositions(guiObj)

    contentHeight := MeasureGuiVisibleContentHeight(guiObj, 18, minHeight)
    viewportHeight := Min(contentHeight, GetEmbeddedPageMaxViewportHeight())
    hwnd := guiObj.Hwnd
    EmbeddedPageContentHeights[hwnd] := contentHeight
    EmbeddedPageViewportHeights[hwnd] := viewportHeight
    EmbeddedPageScrollOffsets[hwnd] := 0

    pageY := GetEmbeddedPageY()
    if showPage
        guiObj.Show("x" pageX " y" pageY " w" pageWidth " h" viewportHeight " NoActivate")
    else
        guiObj.Move(pageX, pageY, pageWidth, viewportHeight)

    UpdateEmbeddedPageScrollBar(guiObj)
    ResizeMainGuiToContentHeight(pageY + viewportHeight + 18)
    return viewportHeight
}

KeepMainGuiInsideWorkArea()
{
    global MainGui
    if !IsObject(MainGui) || !MainGui.Hwnd
        return

    gx := 0
    gy := 0
    gw := 0
    gh := 0
    left := 0
    top := 0
    right := A_ScreenWidth
    bottom := A_ScreenHeight
    try
    {
        WinGetPos(&gx, &gy, &gw, &gh, "ahk_id " MainGui.Hwnd)
        monitorNumber := GetMonitorForAbsolutePoint(gx + (gw // 2), gy + 20)
        MonitorGetWorkArea(monitorNumber, &left, &top, &right, &bottom)

        workWidth := right - left
        workHeight := bottom - top
        nx := gw >= workWidth ? left : Min(Max(gx, left), right - gw)
        ny := gh >= workHeight ? top : Min(Max(gy, top), bottom - gh)
        if nx != gx || ny != gy
            WinMove(nx, ny,,, "ahk_id " MainGui.Hwnd)
    }
}

MainGuiMouseActivate(wParam, lParam, msg, hwnd)
{
    global MainGui
    if !IsObject(MainGui) || !MainGui.Hwnd
        return

    root := 0
    try root := DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr")
    if hwnd = MainGui.Hwnd || root = MainGui.Hwnd
        return 1
}


MainNavMouseDown(wParam, lParam, msg, hwnd)
{
    global MainGui, MainNavButtons, UiTransitionInProgress
    if UiTransitionInProgress || !IsObject(MainGui) || !MainGui.Hwnd
        return
    for name, button in MainNavButtons
    {
        if IsObject(button) && button.Hwnd = hwnd
        {
            if !WinActive("ahk_id " MainGui.Hwnd)
                try WinActivate("ahk_id " MainGui.Hwnd)
            SetTimer(SwitchMainPage.Bind(name), -1)
            return 0
        }
    }
}

EmbeddedPageMouseWheel(wParam, lParam, msg, hwnd)
{
    global CurrentMainPage, SBGui, HotkeysGui, LayoutEditorGui, PreviewSettingsGui, UiTransitionInProgress
    global EmbeddedPageScrollOffsets, EmbeddedPageContentHeights, EmbeddedPageViewportHeights
    global MainScrollOffset, MainScrollContentHeight, MainScrollViewportHeight, MainPageControls
    if UiTransitionInProgress
        return

    pageGui := ""
    if CurrentMainPage = "Accounts"
        pageGui := SBGui
    else if CurrentMainPage = "Hotkeys"
        pageGui := HotkeysGui
    else if CurrentMainPage = "Layouts"
        pageGui := LayoutEditorGui
    else if CurrentMainPage = "Previews"
        pageGui := PreviewSettingsGui
    else if CurrentMainPage = "Main"
    {
        mousePoint := Buffer(8, 0)
        DllCall("GetCursorPos", "Ptr", mousePoint)
        DllCall("ScreenToClient", "Ptr", MainGui.Hwnd, "Ptr", mousePoint)
        mouseY := NumGet(mousePoint, 4, "Int")
        if mouseY < GetMainScrollTop()
            return
        for ctrl in MainPageControls
        {
            if (ctrl.Type = "DropDownList" || ctrl.Type = "ComboBox") && SendMessage(0x0157, 0, 0, ctrl)
                return
        }
        delta := (wParam >> 16) & 0xFFFF
        if delta & 0x8000
            delta -= 0x10000
        if delta && MainScrollContentHeight > MainScrollViewportHeight
        {
            SetMainPageScroll(MainScrollOffset + (delta < 0 ? 68 : -68))
            return 0
        }
        return
    }
    else
        return

    if !IsObject(pageGui) || !pageGui.Hwnd
        return
    pageHwnd := pageGui.Hwnd
    if !EmbeddedPageContentHeights.Has(pageHwnd) || !EmbeddedPageViewportHeights.Has(pageHwnd)
        return
    if EmbeddedPageContentHeights[pageHwnd] <= EmbeddedPageViewportHeights[pageHwnd]
        return

    pt := Buffer(8, 0)
    DllCall("GetCursorPos", "Ptr", pt)
    px := NumGet(pt, 0, "Int"), py := NumGet(pt, 4, "Int")
    rect := Buffer(16, 0)
    if !DllCall("GetWindowRect", "Ptr", pageHwnd, "Ptr", rect)
        return
    left := NumGet(rect, 0, "Int"), top := NumGet(rect, 4, "Int")
    right := NumGet(rect, 8, "Int"), bottom := NumGet(rect, 12, "Int")
    if px < left || px >= right || py < top || py >= bottom
        return

    for controlHwnd, ctrl in pageGui
        if (ctrl.Type = "DropDownList" || ctrl.Type = "ComboBox") && SendMessage(0x0157, 0, 0, ctrl)
            return

    delta := (wParam >> 16) & 0xFFFF
    if delta & 0x8000
        delta -= 0x10000
    if delta = 0
        return

    oldOffset := EmbeddedPageScrollOffsets.Has(pageHwnd) ? EmbeddedPageScrollOffsets[pageHwnd] : 0
    step := 68
    newOffset := oldOffset + (delta < 0 ? step : -step)
    SetEmbeddedPageScroll(pageGui, newOffset)
    return 0
}

UpdateMainPageScrollRange()
{
    global MainGui, CurrentMainPage, MainPageControls, MainScrollBase, MainScrollOffset
    global MainScrollContentHeight, MainScrollViewportHeight
    if !IsObject(MainGui) || !MainGui.Hwnd
        return
    if CurrentMainPage != "Main"
    {
        DllCall("ShowScrollBar", "Ptr", MainGui.Hwnd, "Int", 1, "Int", false)
        return
    }
    if MainScrollOffset
        SetMainPageScroll(0)
    base := Map()
    for ctrl in MainPageControls
    {
        if !IsObject(ctrl) || !ctrl.Hwnd
            continue
        ctrl.GetPos(&cx, &cy, &cw, &ch)
        base[ctrl.Hwnd] := cy
    }
    MainScrollBase := base
    MainScrollContentHeight := Max(0, GetMainPageRequiredHeight() - GetMainScrollTop())
    client := Buffer(16, 0)
    DllCall("GetClientRect", "Ptr", MainGui.Hwnd, "Ptr", client)
    dpi := DllCall("GetDpiForWindow", "Ptr", MainGui.Hwnd, "UInt")
    scale := dpi ? dpi / 96.0 : 1.0
    MainScrollViewportHeight := Max(1, Floor(NumGet(client, 12, "Int") / scale) - GetMainScrollTop())
    UpdateMainScrollBar()
    ClipMainPageScrollControls(MainScrollOffset)
}

UpdateMainScrollBar()
{
    global MainGui, MainScrollContentHeight, MainScrollViewportHeight, MainScrollOffset, CurrentMainPage
    if !IsObject(MainGui) || !MainGui.Hwnd
        return
    overflow := CurrentMainPage = "Main" && MainScrollContentHeight > MainScrollViewportHeight
    DllCall("ShowScrollBar", "Ptr", MainGui.Hwnd, "Int", 1, "Int", overflow)
    if !overflow
        return
    info := Buffer(28, 0)
    NumPut("UInt", 28, info, 0)
    NumPut("UInt", 0x17, info, 4)
    NumPut("Int", 0, info, 8)
    NumPut("Int", MainScrollContentHeight, info, 12)
    NumPut("UInt", Max(1, MainScrollViewportHeight), info, 16)
    NumPut("Int", MainScrollOffset, info, 20)
    DllCall("SetScrollInfo", "Ptr", MainGui.Hwnd, "Int", 1, "Ptr", info, "Int", true)
}

GetMainScrollTop()
{
    global BannerVisible, UpdateLinkVisible, UpdateLinkShift
    return (BannerVisible ? 275 : 88) + (UpdateLinkVisible ? UpdateLinkShift : 0)
}

ClipMainPageScrollControls(offset)
{
    global MainGui, MainPageControls
    if !IsObject(MainGui) || !MainGui.Hwnd
        return
    clientTop := GetMainScrollTop()
    clientRect := Buffer(16, 0)
    DllCall("GetClientRect", "Ptr", MainGui.Hwnd, "Ptr", clientRect)
    dpi := DllCall("GetDpiForWindow", "Ptr", MainGui.Hwnd, "UInt")
    factor := dpi ? dpi / 96.0 : 1.0
    clipTop := Round(clientTop * factor)
    clipBottom := NumGet(clientRect, 12, "Int")
    for ctrl in MainPageControls
    {
        if !IsObject(ctrl) || !ctrl.Hwnd
            continue
        rect := Buffer(16, 0)
        if !DllCall("GetWindowRect", "Ptr", ctrl.Hwnd, "Ptr", rect)
            continue
        origin := Buffer(8, 0)
        NumPut("Int", NumGet(rect, 0, "Int"), origin, 0)
        NumPut("Int", NumGet(rect, 4, "Int"), origin, 4)
        DllCall("ScreenToClient", "Ptr", MainGui.Hwnd, "Ptr", origin)
        top := NumGet(origin, 4, "Int")
        height := NumGet(rect, 12, "Int") - NumGet(rect, 4, "Int")
        width := NumGet(rect, 8, "Int") - NumGet(rect, 0, "Int")
        fromY := Min(height, Max(0, clipTop - top))
        toY := Min(height, Max(0, clipBottom - top))
        toY := Max(fromY, toY)
        region := DllCall("CreateRectRgn", "Int", 0, "Int", fromY, "Int", Max(0, width), "Int", toY, "Ptr")
        if region
        {
            if !DllCall("SetWindowRgn", "Ptr", ctrl.Hwnd, "Ptr", region, "Int", true)
                DllCall("DeleteObject", "Ptr", region)
        }
    }
}

SetMainPageScroll(offset)
{
    global MainGui, MainPageControls, MainScrollBase, MainScrollContentHeight, MainScrollViewportHeight, MainScrollOffset
    if !IsObject(MainGui) || !MainGui.Hwnd
        return
    offset := Min(Max(0, offset), Max(0, MainScrollContentHeight - MainScrollViewportHeight))
    if offset = MainScrollOffset
        return
    SetGuiRedraw(MainGui, false)
    try
    {
        for ctrl in MainPageControls
        {
            if !IsObject(ctrl) || !ctrl.Hwnd || !MainScrollBase.Has(ctrl.Hwnd)
                continue
            ctrl.Move(, MainScrollBase[ctrl.Hwnd] - offset)
        }
        MainScrollOffset := offset
        ClipMainPageScrollControls(offset)
        UpdateMainScrollBar()
    }
    finally
    {
        SetGuiRedraw(MainGui, true)
        DllCall("RedrawWindow", "Ptr", MainGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0185)
    }
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
    global BannerVisible, UpdateLinkVisible, UpdateLinkShift
    return (BannerVisible ? 235 : 44) + (UpdateLinkVisible ? UpdateLinkShift : 0)
}


ReflowCurrentPageAfterBannerChange()
{
    global MainGui, CurrentMainPage, SBGui, HotkeysGui, LayoutEditorGui, PreviewSettingsGui
    if !IsObject(MainGui) || !MainGui.Hwnd
        return

    if CurrentMainPage = "Accounts" && IsObject(SBGui) && SBGui.Hwnd
        FitEmbeddedPageToContent(SBGui, 12, 535, 140, true)
    else if CurrentMainPage = "Hotkeys" && IsObject(HotkeysGui) && HotkeysGui.Hwnd
        FitEmbeddedPageToContent(HotkeysGui, 12, 500, 140, true)
    else if CurrentMainPage = "Layouts" && IsObject(LayoutEditorGui) && LayoutEditorGui.Hwnd
        FitEmbeddedPageToContent(LayoutEditorGui, 0, 559, 140, true)
    else if CurrentMainPage = "Previews" && IsObject(PreviewSettingsGui) && PreviewSettingsGui.Hwnd
        FitEmbeddedPageToContent(PreviewSettingsGui, 12, 535, 140, true)
    else
    {
        ResizeMainGuiToContentHeight(GetMainPageRequiredHeight())
    }
}

GetSelectedAccountIndices()
{
    global SandboxieAccounts
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
    for savedName in WorkflowIncludedAccountNames
    {
        key := StrLower(savedName)
        if selectedNames.Has(key)
            result.Push(selectedNames[key])
    }
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
        label := GetSandboxieDisplayName(index)
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
    global MainGui, CurrentMainPage, MainLayoutCurrentSummaryHeight
    if !IsObject(WorkflowAccountSummary)
        return

    indices := GetIncludedAccountIndices()
    names := []
    for index in indices
    {
        names.Push(GetSandboxieDisplayName(index))
    }

    summaryText := indices.Length ? "Accounts: " indices.Length " included — " JoinText(names, ", ") : "Accounts: none included"
    WorkflowAccountSummary.Text := summaryText
    WorkflowAccountSummary.GetPos(&summaryX, &summaryY, &summaryW, &oldHeight)
    newHeight := Max(22, MeasureWrappedControlTextHeight(WorkflowAccountSummary, summaryText, summaryW, 22))
    WorkflowAccountSummaryHeight := newHeight
    MainLayoutCurrentSummaryHeight := newHeight

    if IsObject(MainGui) && MainGui.Hwnd
    {
        SetGuiRedraw(MainGui, false)
        try
        {
            ReflowMainPageLayout()
            if CurrentMainPage = "Main"
                ResizeMainGuiToContentHeight(GetMainPageRequiredHeight())
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
    global WorkflowResetSandboxesCheck, WorkflowVerifySandboxesCheck, WorkflowSequentialLoginCheck, WorkflowSequentialCountCombo, WorkflowIncludedAccountNames
    accountNames := []
    for accountName in WorkflowIncludedAccountNames
        accountNames.Push(accountName)
    sequentialCount := IsObject(WorkflowSequentialCountCombo) && WorkflowSequentialCountCombo.Value ? WorkflowSequentialCountCombo.Value : 1
    return {name:name, accountNames:accountNames, resetFoxhole:WorkflowResetFoxholeCheck.Value=1, launchFoxhole:WorkflowLaunchFoxholeCheck.Value=1,
        resetSteam:WorkflowResetSteamCheck.Value=1, launchSteam:WorkflowLaunchSteamCheck.Value=1,
        resetSandboxes:WorkflowResetSandboxesCheck.Value=1, verifySandboxes:WorkflowVerifySandboxesCheck.Value=1,
        sequentialLogin:WorkflowSequentialLoginCheck.Value=1, sequentialCount:Max(1, Min(10, Integer(sequentialCount)))}
}

ApplyWorkflowDefinition(def)
{
    global WorkflowResetFoxholeCheck, WorkflowLaunchFoxholeCheck, WorkflowResetSteamCheck, WorkflowLaunchSteamCheck
    global WorkflowResetSandboxesCheck, WorkflowVerifySandboxesCheck, WorkflowSequentialLoginCheck, WorkflowSequentialCountCombo, WorkflowIncludedAccountNames
    WorkflowIncludedAccountNames := []
    if def.HasOwnProp("accountNames")
        for accountName in def.accountNames
            WorkflowIncludedAccountNames.Push(accountName)
    WorkflowResetFoxholeCheck.Value := def.resetFoxhole ? 1 : 0
    WorkflowLaunchFoxholeCheck.Value := def.launchFoxhole ? 1 : 0
    WorkflowResetSteamCheck.Value := def.resetSteam ? 1 : 0
    WorkflowLaunchSteamCheck.Value := def.launchSteam ? 1 : 0
    WorkflowResetSandboxesCheck.Value := def.resetSandboxes ? 1 : 0
    WorkflowVerifySandboxesCheck.Value := def.verifySandboxes ? 1 : 0
    WorkflowSequentialLoginCheck.Value := def.HasOwnProp("sequentialLogin") && def.sequentialLogin ? 1 : 0
    WorkflowSequentialCountCombo.Choose(def.HasOwnProp("sequentialCount") ? Max(1, Min(10, Integer(def.sequentialCount))) : 1)
    ApplySequentialWorkflowControlState()
    UpdateWorkflowAccountSummary()
    UpdateWorkflowSequencePreview()
}

WorkflowOperationCheckboxChanged(ctrl, *)
{
    global WorkflowResetFoxholeCheck, WorkflowLaunchFoxholeCheck, WorkflowResetSteamCheck
    global WorkflowLaunchSteamCheck, WorkflowResetSandboxesCheck
    if ctrl.Value = 1
    {
        conflict := ""
        if ctrl.Hwnd = WorkflowLaunchFoxholeCheck.Hwnd && WorkflowLaunchSteamCheck.Value
        {
            WorkflowLaunchSteamCheck.Value := 0
            conflict := "Steam launch was deselected: Steam sign-in cannot be verified before Foxhole launch."
        }
        else if ctrl.Hwnd = WorkflowLaunchSteamCheck.Hwnd && WorkflowLaunchFoxholeCheck.Value
        {
            WorkflowLaunchFoxholeCheck.Value := 0
            conflict := "Foxhole launch was deselected: Steam readiness cannot be verified."
        }
        if ctrl.Hwnd = WorkflowResetSteamCheck.Hwnd && WorkflowLaunchSteamCheck.Value
        {
            WorkflowLaunchSteamCheck.Value := 0
            conflict := "Steam launch was deselected: Steam shutdown completion is not verified."
        }
        else if ctrl.Hwnd = WorkflowLaunchSteamCheck.Hwnd && WorkflowResetSteamCheck.Value
        {
            WorkflowResetSteamCheck.Value := 0
            conflict := "Close Steam was deselected: shutdown completion is not verified."
        }
        if ctrl.Hwnd = WorkflowResetFoxholeCheck.Hwnd && WorkflowLaunchFoxholeCheck.Value
        {
            WorkflowLaunchFoxholeCheck.Value := 0
            conflict := "Foxhole launch was deselected: Foxhole shutdown completion is not verified."
        }
        else if ctrl.Hwnd = WorkflowLaunchFoxholeCheck.Hwnd && WorkflowResetFoxholeCheck.Value
        {
            WorkflowResetFoxholeCheck.Value := 0
            conflict := "Close Foxhole was deselected: shutdown completion is not verified."
        }
        if conflict != ""
        {
            ToolTip(conflict, , , 18)
            SetTimer((*) => ToolTip("", , , 18), -4000)
        }
    }
    UpdateWorkflowSequencePreview()
}

GetWorkflowSequenceIssue(def)
{
    if def.HasOwnProp("sequentialLogin") && def.sequentialLogin
    {
        if def.resetFoxhole || def.launchFoxhole || def.resetSteam || def.launchSteam || def.resetSandboxes || def.verifySandboxes
            return "Sequential login is a standalone operation. Clear the other workflow operations."
        return ""
    }
    if def.launchSteam && def.launchFoxhole
        return "Steam launch cannot verify account sign-in. Run Steam and Foxhole separately."
    if def.resetSteam && def.launchSteam
        return "Close Steam does not verify process exit. Close and launch Steam in separate workflows."
    if def.resetFoxhole && def.launchFoxhole
        return "Close Foxhole does not verify full process exit. Close and launch Foxhole separately."
    return ""
}

UpdateWorkflowSequencePreview(*)
{
    global WorkflowSequenceText, WorkflowRunButton, WorkflowRunning
    if !IsObject(WorkflowSequenceText)
        return
    def := GetCurrentWorkflowDefinition()
    issue := GetWorkflowSequenceIssue(def)
    if IsObject(WorkflowRunButton) && !WorkflowRunning
        WorkflowRunButton.Enabled := issue = ""
    if issue != ""
    {
        WorkflowSequenceText.Text := "BLOCKED: " issue
        return
    }
    if def.sequentialLogin
    {
        WorkflowSequenceText.Text := "Next run: Keep " def.sequentialCount " account(s) online, rotating in account order."
        return
    }
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
    WorkflowSequenceText.Text := steps.Length ? "Next run: " JoinText(steps, " → ") (def.launchSteam ? " (Steam sign-in NOT verified)" : "") : "Next run: No operations selected."
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
    LogEvent("Workflow preset button clicked: " idx)
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
            sequentialLogin:IniRead(CONFIG_FILE, section, "SequentialLogin", "0")="1",
            sequentialCount:Max(1, Min(10, Integer(IniRead(CONFIG_FILE, section, "SequentialCount", "1")))),
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
        text .= "`nSequentialLogin=" (p.HasOwnProp("sequentialLogin") && p.sequentialLogin ? 1 : 0)
        text .= "`nSequentialCount=" (p.HasOwnProp("sequentialCount") ? Max(1, Min(10, Integer(p.sequentialCount))) : 1)
        text .= "`nAccountNames=" JoinText(p.HasOwnProp("accountNames") ? p.accountNames : [], "|")
        IniWrite(text, CONFIG_FILE, section)
    }
    IniWrite(WorkflowPresets.Length, CONFIG_FILE, "WorkflowPresets", "Count")
    Loop 8
        IniWrite(WorkflowFavorites[A_Index], CONFIG_FILE, "WorkflowPresets", "Favorite" A_Index)
}

RunSelectedWorkflow(*)
{
    LogEvent("Run Workflow button clicked")
    RunWorkflowDefinition(GetCurrentWorkflowDefinition())
}

RunWorkflowDefinition(def)
{
    global WorkflowRunning, WorkflowRunButton, WorkflowStopButton, StatusText, WorkflowIncludedAccountNames
    if WorkflowRunning
    {
        LogEvent("Workflow start ignored: a workflow is already running", "WARN")
        return
    }
    LogEvent("Workflow start requested")
    issue := GetWorkflowSequenceIssue(def)
    if issue != ""
    {
        StatusText.Text := "Status: Workflow blocked - " issue
        LogEvent("Workflow blocked: " issue, "WARN")
        MsgBox(issue, "Unsafe workflow sequence", "Icon!")
        return
    }
    if def.HasOwnProp("accountNames")
    {
        WorkflowIncludedAccountNames := []
        for accountName in def.accountNames
            WorkflowIncludedAccountNames.Push(accountName)
    }
    accounts := GetIncludedAccountIndices()
    LogEvent("Workflow resolved " accounts.Length " included account(s): " JoinLogNumbers(accounts))
    if accounts.Length = 0
    {
        StatusText.Text := "Status: No accounts included."
        LogEvent("Workflow skipped: no accounts included", "WARN")
        return
    }
    if !(def.HasOwnProp("sequentialLogin") && def.sequentialLogin) && !(def.resetFoxhole || def.launchFoxhole || def.resetSteam || def.launchSteam || def.resetSandboxes || def.verifySandboxes)
    {
        StatusText.Text := "Status: No workflow operations selected."
        LogEvent("Workflow skipped: no operations selected", "WARN")
        return
    }
    WorkflowRunning := true
    WorkflowRunButton.Enabled := false
    WorkflowStopButton.Enabled := true
    try
    {
        if def.HasOwnProp("sequentialLogin") && def.sequentialLogin
        {
            LogEvent("Workflow: starting sequential login")
            StartSequentialLoginWorkflow(accounts, def.HasOwnProp("sequentialCount") ? def.sequentialCount : 1)
            return
        }
        if def.resetFoxhole
        {
            LogEvent("Workflow: closing Foxhole")
            WorkflowCloseSelectedFoxhole(accounts)
        }
        if def.resetSteam
        {
            LogEvent("Workflow: closing Steam")
            WorkflowCloseSelectedSteam(accounts)
        }
        if def.resetSandboxes
        {
            LogEvent("Workflow: resetting selected sandboxes")
            WorkflowResetSelectedSandboxes(accounts)
        }
        if def.verifySandboxes
        {
            LogEvent("Workflow: verifying sandboxes")
            WorkflowVerifySelectedSandboxes(accounts)
        }

        if def.launchSteam && def.launchFoxhole
        {
            StatusText.Text := "Status: Launching Steam, waiting for readiness, then launching Foxhole..."
            LogEvent("Workflow: combined Steam/Foxhole launch")
            StartCombinedSteamFoxholeLaunch(accounts)
        }
        else if def.launchSteam
        {
            LogEvent("Workflow: launching Steam")
            StartSelectedSandboxieSteamLaunches(accounts)
            FinishWorkflow("Workflow completed. Steam launch commands were started.")
        }
        else if def.launchFoxhole
        {
            LogEvent("Workflow: launching Foxhole")
            if !StartFoxholeLaunchesForIndices(accounts, false)
                LogEvent("Foxhole launch did not start; check account and executable configuration", "WARN")
        }
        else
            FinishWorkflow("Workflow completed.")
    }
    catch as e
    {
        LogEvent("Workflow exception: " e.Message " at " e.File ":" e.Line, "ERROR")
        FinishWorkflow("Workflow failed — " e.Message)
    }
}

FinishWorkflow(message)
{
    global WorkflowRunning, WorkflowRunButton, WorkflowStopButton, StatusText, WorkflowStatusMessage
    WorkflowRunning := false
    WorkflowStatusMessage := ""
    if IsObject(WorkflowRunButton)
        WorkflowRunButton.Enabled := true
    if IsObject(WorkflowStopButton)
        WorkflowStopButton.Enabled := false
    StatusText.Text := "Status: " message
    LogEvent(message)
    UpdateWorkflowSequencePreview()
}

StopWorkflow(*)
{
    global CombinedLaunchActive
    LogEvent("Workflow stop requested")
    StopSequentialLoginWorkflow(false)
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
    global SandboxieAccounts
    for idx in indices
    {
        account := SandboxieAccounts[idx]
        boxName := Trim(account.name)
        if account.main || !IsValidSandboxieName(boxName)
            continue
        for pid in GetSandboxieBoxPids(boxName)
            try ProcessClose(pid)
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
    {
        result := DeleteSandboxieContentsFast(boxes)
        if result.failed.Length
            throw Error("Sandbox reset was not completed for: " JoinText(result.failed, "; "))
    }
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
    global LayoutEditorSelectedLayout, LayoutFavorites, TrainSlowHoldDuration

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
    Settings["TrainSlowInterval"] := Max(10, Min(5000, Integer(IniRead(CONFIG_FILE, "Settings", "TrainSlowInterval", "3400"))))
    Settings["TrainSlowHoldDuration"] := Max(10, Min(5000, Integer(IniRead(CONFIG_FILE, "Settings", "TrainSlowHoldDuration", "2000"))))
    TrainSlowHoldDuration := Settings["TrainSlowHoldDuration"]
    Settings["DefaultClickX"] := Integer(IniRead(CONFIG_FILE, "Settings", "DefaultClickX", "0"))
    Settings["DefaultClickY"] := Integer(IniRead(CONFIG_FILE, "Settings", "DefaultClickY", "0"))
    Settings["MainAlwaysOnTop"] := IniRead(CONFIG_FILE, "Settings", "MainAlwaysOnTop", "0") = "1"
    Settings["ShowOverlay"] := IniRead(CONFIG_FILE, "Settings", "ShowOverlay", "1") = "1"
    Settings["ShowStatusOverlay"] := IniRead(CONFIG_FILE, "Settings", "ShowStatusOverlay", "1") = "1"
    Settings["ShowHotkeyTooltips"] := IniRead(CONFIG_FILE, "Settings", "ShowHotkeyTooltips", "1") = "1"
    Settings["ShowUiTooltips"] := IniRead(CONFIG_FILE, "Settings", "ShowUiTooltips", "1") = "1"
    Settings["MouseFocusOn"] := IniRead(CONFIG_FILE, "Settings", "MouseFocusOn", "1") = "1"
    Settings["AutoResetSlots"] := IniRead(CONFIG_FILE, "Settings", "AutoResetSlots", "0") = "1"
    Settings["ChangeOutputKeys"] := IniRead(CONFIG_FILE, "Settings", "ChangeOutputKeys", "0") = "1"
    Settings["GameHotkeysEnabled"] := IniRead(CONFIG_FILE, "Settings", "GameHotkeysEnabled", "1") = "1"
    Settings["SwapByAccount"] := IniRead(CONFIG_FILE, "Settings", "SwapByAccount", "1") = "1"
    Settings["BringSwapToFront"] := IniRead(CONFIG_FILE, "Settings", "BringSwapToFront", "0") = "1"
    Settings["PreviewsVisible"] := IniRead(CONFIG_FILE, "Settings", "PreviewsVisible", "1") = "1"
    Settings["PreviewEditMode"] := IniRead(CONFIG_FILE, "Settings", "PreviewEditMode", "0") = "1"
    Settings["PreviewResizeAllEqual"] := IniRead(CONFIG_FILE, "Settings", "PreviewResizeAllEqual", "0") = "1"
    Settings["PreviewMoveAllTogether"] := IniRead(CONFIG_FILE, "Settings", "PreviewMoveAllTogether", "0") = "1"
    Settings["PreviewSnapTogether"] := IniRead(CONFIG_FILE, "Settings", "PreviewSnapTogether", "1") = "1"
    Settings["PreviewHorizontalGap"] := 0
    Settings["PreviewVerticalGap"] := 0
    Settings["IdentityShowSlot"] := IniRead(CONFIG_FILE, "Settings", "IdentityShowSlot", "1") = "1"
    Settings["IdentityShowAccount"] := IniRead(CONFIG_FILE, "Settings", "IdentityShowAccount", "1") = "1"
    Settings["PreviewShowActiveHotkeys"] := IniRead(CONFIG_FILE, "Settings", "PreviewShowActiveHotkeys", "1") = "1"
    Settings["PreviewShowWhenFoxholeUnfocused"] := IniRead(CONFIG_FILE, "Settings", "PreviewShowWhenFoxholeUnfocused", "1") = "1"
    Settings["PreviewHoverHotkeys"] := IniRead(CONFIG_FILE, "Settings", "PreviewHoverHotkeys", "0") = "1"
    Settings["PreviewHoverBringToFront"] := IniRead(CONFIG_FILE, "Settings", "PreviewHoverBringToFront", "0") = "1"
    Settings["PreviewIdentityPosition"] := IniRead(CONFIG_FILE, "Settings", "PreviewIdentityPosition", "Top")
    if Settings["PreviewIdentityPosition"] != "Middle" && Settings["PreviewIdentityPosition"] != "Bottom"
        Settings["PreviewIdentityPosition"] := "Top"

    Settings["PreviewIdentityHorizontal"] := IniRead(CONFIG_FILE, "Settings", "PreviewIdentityHorizontal", "Center")
    if Settings["PreviewIdentityHorizontal"] != "Left" && Settings["PreviewIdentityHorizontal"] != "Right"
        Settings["PreviewIdentityHorizontal"] := "Center"

    Settings["PreviewIdentityTextSize"] := Max(10, Min(40, Integer(IniRead(CONFIG_FILE, "Settings", "PreviewIdentityTextSize", "16"))))

    Settings["GameIdentityVertical"] := IniRead(CONFIG_FILE, "Settings", "GameIdentityVertical", "Top")
    if Settings["GameIdentityVertical"] != "Middle" && Settings["GameIdentityVertical"] != "Bottom"
        Settings["GameIdentityVertical"] := "Top"

    Settings["GameIdentityHorizontal"] := IniRead(CONFIG_FILE, "Settings", "GameIdentityHorizontal", "Left")
    if Settings["GameIdentityHorizontal"] != "Center" && Settings["GameIdentityHorizontal"] != "Right"
        Settings["GameIdentityHorizontal"] := "Left"

    Settings["GameIdentityTextSize"] := Max(10, Min(48, Integer(IniRead(CONFIG_FILE, "Settings", "GameIdentityTextSize", "18"))))
    Settings["MainGuiX"] := Integer(IniRead(CONFIG_FILE, "Settings", "MainGuiX", "2147483647"))
    Settings["MainGuiY"] := Integer(IniRead(CONFIG_FILE, "Settings", "MainGuiY", "2147483647"))
    Settings["FlashGameIdentity"] := IniRead(CONFIG_FILE, "Settings", "FlashGameIdentity", "0") = "1"
    Settings["PreviewOpacity"] := Max(20, Min(100, Integer(IniRead(CONFIG_FILE, "Settings", "PreviewOpacity", IniRead(CONFIG_FILE, "PreviewSlot1", "Opacity", "75")))))
    Settings["HotkeysAlwaysOnTop"] := IniRead(CONFIG_FILE, "Settings", "HotkeysAlwaysOnTop", "0") = "1"
    Settings["SandboxieAlwaysOnTop"] := IniRead(CONFIG_FILE, "Settings", "SandboxieAlwaysOnTop", "0") = "1"
    Settings["LayoutEditorAlwaysOnTop"] := IniRead(CONFIG_FILE, "Settings", "LayoutEditorAlwaysOnTop", "0") = "1"
    Settings["LastLayoutName"] := Trim(IniRead(CONFIG_FILE, "Settings", "LastLayoutName", ""))
    Settings["LastPreviewLayoutName"] := Trim(IniRead(CONFIG_FILE, "Settings", "LastPreviewLayoutName", ""))
    Settings["BannerSelection"] := Trim(IniRead(CONFIG_FILE, "Settings", "BannerSelection", "Random"))
    if Settings["BannerSelection"] = ""
        Settings["BannerSelection"] := "Random"
    savedStartExe := Trim(IniRead(CONFIG_FILE, "SandboxiePaths", "StartExe", ""))
    if savedStartExe = ""
    {
        legacySandManExe := Trim(IniRead(CONFIG_FILE, "SandboxiePaths", "SandManExe", ""))
        if legacySandManExe != ""
        {
            legacyDir := RegExReplace(legacySandManExe, "\\[^\\]+$", "")
            legacyStartExe := legacyDir "\Start.exe"
            savedStartExe := FileExist(legacyStartExe) ? legacyStartExe : legacySandManExe
        }
    }
    if savedStartExe != ""
        Settings["SandboxieStartExe"] := savedStartExe
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
            monitorLeft := Integer(IniRead(CONFIG_FILE, section, "Slot" slotNo "_MonitorLeft", "2147483647"))
            monitorTop := Integer(IniRead(CONFIG_FILE, section, "Slot" slotNo "_MonitorTop", "2147483647"))
            slot := {
                slot: slotNo,
                monitor: monitorNo,
                monitorWidth: monitorWidth,
                monitorHeight: monitorHeight,
                monitorLeft: monitorLeft,
                monitorTop: monitorTop,
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
            if slot.monitorLeft = 2147483647 || slot.monitorTop = 2147483647
            {
                identityBounds := GetLayoutMonitorBounds(slot)
                slot.monitorLeft := identityBounds.left
                slot.monitorTop := identityBounds.top
            }
            slot.width := Max(1, slot.width)
            slot.height := Max(1, slot.height)
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
    for index in Range(1, MaxSandboxieRows)
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
        SandboxieAccounts.Push({ name: accountName, selected: selected, main: isMain, steamUsername: steamUsername, displayName: IniRead(CONFIG_FILE, "Sandboxie", "Account" index "DisplayName", ""), useDisplayName: IniRead(CONFIG_FILE, "Sandboxie", "Account" index "UseDisplayName", "0") = "1" })
    }

    global SandboxieSavedAccounts, SandboxieSavedRowCount
    SandboxieSavedAccounts := Map()
    Loop MaxSandboxieRows
        SandboxieSavedAccounts[A_Index] := ReadSandboxieAccountRecord(CONFIG_FILE, A_Index)
    SandboxieSavedRowCount := SandboxieRowCount

    AccountSwapKeys := Map()
    for index, account in SandboxieAccounts
        AccountSwapKeys[index] := IniRead(CONFIG_FILE, "AccountSwapHotkeys", "Slot" index, "")

    LoadFoxholePreviewConfig()
    LoadPreviewLayoutsConfig()
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
            prefix := "Slot" slot.slot "_"
            sectionText .= "`n" prefix "Monitor=" slot.monitor
            resolvedBounds := GetLayoutMonitorBounds(slot)
            sectionText .= "`n" prefix "MonitorWidth=" resolvedBounds.width
            sectionText .= "`n" prefix "MonitorHeight=" resolvedBounds.height
            sectionText .= "`n" prefix "MonitorLeft=" resolvedBounds.left
            sectionText .= "`n" prefix "MonitorTop=" resolvedBounds.top
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

BackupExistingConfigBeforeUpgrade()
{
    global CONFIG_DIR, CONFIG_FILE
    if !FileExist(CONFIG_FILE)
        return
    backup := CONFIG_DIR "\Settings.pre-v1.1.0.ini"
    if FileExist(backup)
        return
    try
        FileCopy(CONFIG_FILE, backup)
    catch as err
    {
        MsgBox("Could not back up the existing settings before starting v1.1.0. The program will exit without changing them.`n`n" err.Message, "Foxhole Multiboxer — Settings Protection", "Icon!")
        ExitApp()
    }
}

SaveAccountSwapKeysPreservingSlots()
{
    global CONFIG_FILE, AccountSwapKeys, MaxSandboxieRows
    Loop MaxSandboxieRows
    {
        keyName := "Slot" A_Index
        desired := AccountSwapKeys.Has(A_Index) ? AccountSwapKeys[A_Index] : ""
        stored := IniRead(CONFIG_FILE, "AccountSwapHotkeys", keyName, "")
        if desired = stored
            continue
        if desired = ""
            IniDelete(CONFIG_FILE, "AccountSwapHotkeys", keyName)
        else
            IniWrite(desired, CONFIG_FILE, "AccountSwapHotkeys", keyName)
    }
}

ReadSandboxieAccountRecord(file, index)
{
    name := IniRead(file, "Sandboxie", "Account" index "Name", "")
    if StrLower(Trim(name)) = StrLower("Account " index)
        name := ""
    return {
        name: name,
        selected: IniRead(file, "Sandboxie", "Account" index "Selected", "0") = "1",
        main: IniRead(file, "Sandboxie", "Account" index "Main", "0") = "1",
        steamUsername: IniRead(file, "Sandboxie", "Account" index "SteamUsername", ""),
        displayName: IniRead(file, "Sandboxie", "Account" index "DisplayName", ""),
        useDisplayName: IniRead(file, "Sandboxie", "Account" index "UseDisplayName", "0") = "1"
    }
}

SandboxieAccountRecordMatches(a, b)
{
    return Trim(a.name) = Trim(b.name)
        && !!a.selected = !!b.selected
        && !!a.main = !!b.main
        && Trim(a.steamUsername) = Trim(b.steamUsername)
        && Trim(a.displayName) = Trim(b.displayName)
        && !!a.useDisplayName = !!b.useDisplayName
}

SaveSandboxieAccountsSafely()
{
    global CONFIG_FILE, CONFIG_DIR, MaxSandboxieRows, SandboxieRowCount, SandboxieAccounts
    global SandboxieSavedAccounts, SandboxieSavedRowCount

    changed := []
    for index, account in SandboxieAccounts
    {
        if index > MaxSandboxieRows
            break
        if !SandboxieSavedAccounts.Has(index)
            throw Error("Account snapshot missing for slot " index)
        if !SandboxieAccountRecordMatches(account, SandboxieSavedAccounts[index])
            changed.Push(index)
    }
    countChanged := SandboxieRowCount != SandboxieSavedRowCount
    if changed.Length = 0 && !countChanged
        return

    for index in changed
    {
        diskAccount := ReadSandboxieAccountRecord(CONFIG_FILE, index)
        if !SandboxieAccountRecordMatches(diskAccount, SandboxieSavedAccounts[index])
            throw Error("Account " index " changed on disk since startup. Save cancelled to protect existing data.")
    }
    if countChanged && FileExist(CONFIG_FILE)
    {
        diskRowCount := Integer(IniRead(CONFIG_FILE, "Sandboxie", "RowCount", "1"))
        if diskRowCount != SandboxieSavedRowCount
            throw Error("Account row count changed on disk since startup. Save cancelled to protect existing data.")
    }

    temp := CONFIG_DIR "\Settings.accounts.tmp.ini"
    backup := CONFIG_DIR "\Settings.backup." FormatTime(A_Now, "yyyyMMdd_HHmmss") "." A_TickCount ".ini"
    try
    {
        if FileExist(CONFIG_FILE)
        {
            FileCopy(CONFIG_FILE, backup)
            FileCopy(CONFIG_FILE, temp, 1)
        }
        else
            IniWrite(SandboxieRowCount, temp, "Sandboxie", "RowCount")

        for index in changed
        {
            account := SandboxieAccounts[index]
            if Trim(account.name) = ""
            {
                account.selected := false
                account.main := false
                account.steamUsername := ""
                account.displayName := ""
                account.useDisplayName := false
            }
            for key in ["Name", "Selected", "Main", "SteamUsername", "DisplayName", "UseDisplayName"]
                IniDelete(temp, "Sandboxie", "Account" index key)
            accountName := Trim(account.name)
            if accountName != ""
            {
                IniWrite(accountName, temp, "Sandboxie", "Account" index "Name")
                if account.selected
                    IniWrite("1", temp, "Sandboxie", "Account" index "Selected")
                if account.main
                    IniWrite("1", temp, "Sandboxie", "Account" index "Main")
                if Trim(account.steamUsername) != ""
                    IniWrite(Trim(account.steamUsername), temp, "Sandboxie", "Account" index "SteamUsername")
                if Trim(account.displayName) != ""
                    IniWrite(Trim(account.displayName), temp, "Sandboxie", "Account" index "DisplayName")
                if account.useDisplayName
                    IniWrite("1", temp, "Sandboxie", "Account" index "UseDisplayName")
            }
        }
        if countChanged
            IniWrite(SandboxieRowCount, temp, "Sandboxie", "RowCount")
        for index in changed
        {
            expected := SandboxieAccounts[index]
            actual := ReadSandboxieAccountRecord(temp, index)
            if Trim(expected.name) = ""
            {
                if Trim(actual.name) != "" || actual.selected || actual.main || actual.steamUsername != "" || actual.displayName != "" || actual.useDisplayName
                    throw Error("Account " index " failed validation before save.")
            }
            else if !SandboxieAccountRecordMatches(actual, expected)
                throw Error("Account " index " failed validation before save.")
        }
        if countChanged && Integer(IniRead(temp, "Sandboxie", "RowCount", "0")) != SandboxieRowCount
            throw Error("Account row count failed validation before save.")
        FileMove(temp, CONFIG_FILE, 1)
        for index in changed
            SandboxieSavedAccounts[index] := ReadSandboxieAccountRecord(CONFIG_FILE, index)
        SandboxieSavedRowCount := SandboxieRowCount
        if FileExist(backup)
            FileCopy(backup, CONFIG_DIR "\Settings.lastgood.ini", 1)
    }
    catch as err
    {
        try FileDelete(temp)
        MsgBox("Account changes could not be saved safely. The existing settings were preserved where possible.`n`n" err.Message, "Foxhole Multiboxer — Account Save Error", "Icon!")
        return
    }
}

SaveConfig()
{
    global CONFIG_FILE, ActionNames, CurrentKeys, Settings, TrainSlowHoldDuration
    global OutputActionNames, CurrentOutputKeys
    global SandboxieRowCount, SandboxieAccounts, MaxSandboxieRows, AccountSwapKeys
    static lastHotkeys := ""
    static lastOutputs := ""
    static lastSettings := ""
    static lastAccountSwap := ""

    hotkeySignature := ""
    for action in ActionNames
        hotkeySignature .= action "=" CurrentKeys[action] "`n"
    if hotkeySignature != lastHotkeys
    {
        for action in ActionNames
            IniWrite(CurrentKeys[action], CONFIG_FILE, "Hotkeys", action)
        lastHotkeys := hotkeySignature
    }

    outputSignature := ""
    for action in OutputActionNames
        outputSignature .= action "=" CurrentOutputKeys[action] "`n"
    if outputSignature != lastOutputs
    {
        for action in OutputActionNames
            IniWrite(CurrentOutputKeys[action], CONFIG_FILE, "OutputKeys", action)
        lastOutputs := outputSignature
    }

    settingsSignature := Settings["ClickInterval"] "|" Settings["TrainSlowInterval"] "|" TrainSlowHoldDuration "|"
        . Settings["DefaultClickX"] "|" Settings["DefaultClickY"] "|" Settings["MainAlwaysOnTop"] "|"
        . Settings["ShowOverlay"] "|" Settings["ShowStatusOverlay"] "|" Settings["ShowHotkeyTooltips"] "|"
        . Settings["ShowUiTooltips"] "|" Settings["GameHotkeysEnabled"] "|" Settings["MouseFocusOn"] "|" Settings["AutoResetSlots"] "|"
        . Settings["ChangeOutputKeys"] "|" Settings["SwapByAccount"] "|" Settings["BringSwapToFront"] "|"
        . Settings["PreviewsVisible"] "|" Settings["PreviewEditMode"] "|" Settings["PreviewResizeAllEqual"] "|" Settings["PreviewMoveAllTogether"] "|" Settings["PreviewSnapTogether"] "|" Settings["PreviewHorizontalGap"] "|" Settings["PreviewVerticalGap"] "|" Settings["IdentityShowSlot"] "|" Settings["IdentityShowAccount"] "|" Settings["PreviewShowActiveHotkeys"] "|" Settings["PreviewShowWhenFoxholeUnfocused"] "|" Settings["PreviewHoverHotkeys"] "|" Settings["PreviewHoverBringToFront"] "|" Settings["PreviewIdentityPosition"] "|" Settings["PreviewIdentityHorizontal"] "|" Settings["PreviewIdentityTextSize"] "|" Settings["GameIdentityVertical"] "|" Settings["GameIdentityHorizontal"] "|" Settings["GameIdentityTextSize"] "|" Settings["MainGuiX"] "|" Settings["MainGuiY"] "|" Settings["FlashGameIdentity"] "|" Settings["PreviewOpacity"] "|" Settings["HotkeysAlwaysOnTop"] "|"
        . Settings["SandboxieAlwaysOnTop"] "|" Settings["LayoutEditorAlwaysOnTop"] "|"
        . Settings["LastLayoutName"] "|" Settings["LastPreviewLayoutName"] "|" Settings["BannerSelection"] "|" Settings["SandboxieStartExe"] "|"
        . Settings["SandboxieSteamExe"] "|" Settings["SandboxieFoxholeExe"]
    if settingsSignature != lastSettings
    {
        IniWrite(Settings["ClickInterval"], CONFIG_FILE, "Settings", "ClickInterval")
        IniWrite(Settings["TrainSlowInterval"], CONFIG_FILE, "Settings", "TrainSlowInterval")
        IniWrite(TrainSlowHoldDuration, CONFIG_FILE, "Settings", "TrainSlowHoldDuration")
        IniWrite(Settings["DefaultClickX"], CONFIG_FILE, "Settings", "DefaultClickX")
        IniWrite(Settings["DefaultClickY"], CONFIG_FILE, "Settings", "DefaultClickY")
        IniDelete(CONFIG_FILE, "Settings", "AutoRename")
        IniWrite(Settings["MainAlwaysOnTop"] ? "1" : "0", CONFIG_FILE, "Settings", "MainAlwaysOnTop")
        IniWrite(Settings["ShowOverlay"] ? "1" : "0", CONFIG_FILE, "Settings", "ShowOverlay")
        IniWrite(Settings["ShowStatusOverlay"] ? "1" : "0", CONFIG_FILE, "Settings", "ShowStatusOverlay")
        IniWrite(Settings["ShowHotkeyTooltips"] ? "1" : "0", CONFIG_FILE, "Settings", "ShowHotkeyTooltips")
        IniWrite(Settings["ShowUiTooltips"] ? "1" : "0", CONFIG_FILE, "Settings", "ShowUiTooltips")
        IniWrite(Settings["MouseFocusOn"] ? "1" : "0", CONFIG_FILE, "Settings", "MouseFocusOn")
        IniWrite(Settings["AutoResetSlots"] ? "1" : "0", CONFIG_FILE, "Settings", "AutoResetSlots")
        IniWrite(Settings["ChangeOutputKeys"] ? "1" : "0", CONFIG_FILE, "Settings", "ChangeOutputKeys")
        IniWrite(Settings["GameHotkeysEnabled"] ? "1" : "0", CONFIG_FILE, "Settings", "GameHotkeysEnabled")
        IniWrite(Settings["SwapByAccount"] ? "1" : "0", CONFIG_FILE, "Settings", "SwapByAccount")
        IniWrite(Settings["BringSwapToFront"] ? "1" : "0", CONFIG_FILE, "Settings", "BringSwapToFront")
        IniWrite(Settings["PreviewsVisible"] ? "1" : "0", CONFIG_FILE, "Settings", "PreviewsVisible")
        IniWrite(Settings["PreviewEditMode"] ? "1" : "0", CONFIG_FILE, "Settings", "PreviewEditMode")
        IniWrite(Settings["PreviewResizeAllEqual"] ? "1" : "0", CONFIG_FILE, "Settings", "PreviewResizeAllEqual")
        IniWrite(Settings["PreviewMoveAllTogether"] ? "1" : "0", CONFIG_FILE, "Settings", "PreviewMoveAllTogether")
        IniWrite(Settings["PreviewSnapTogether"] ? "1" : "0", CONFIG_FILE, "Settings", "PreviewSnapTogether")
        IniWrite(Settings["PreviewHorizontalGap"], CONFIG_FILE, "Settings", "PreviewHorizontalGap")
        IniWrite(Settings["PreviewVerticalGap"], CONFIG_FILE, "Settings", "PreviewVerticalGap")
        IniWrite(Settings["IdentityShowSlot"] ? "1" : "0", CONFIG_FILE, "Settings", "IdentityShowSlot")
        IniWrite(Settings["IdentityShowAccount"] ? "1" : "0", CONFIG_FILE, "Settings", "IdentityShowAccount")
        IniWrite(Settings["PreviewShowActiveHotkeys"] ? "1" : "0", CONFIG_FILE, "Settings", "PreviewShowActiveHotkeys")
        IniWrite(Settings["PreviewShowWhenFoxholeUnfocused"] ? "1" : "0", CONFIG_FILE, "Settings", "PreviewShowWhenFoxholeUnfocused")
        IniWrite(Settings["PreviewHoverHotkeys"] ? "1" : "0", CONFIG_FILE, "Settings", "PreviewHoverHotkeys")
        IniWrite(Settings["PreviewHoverBringToFront"] ? "1" : "0", CONFIG_FILE, "Settings", "PreviewHoverBringToFront")
        IniWrite(Settings["PreviewIdentityPosition"], CONFIG_FILE, "Settings", "PreviewIdentityPosition")
        IniWrite(Settings["PreviewIdentityHorizontal"], CONFIG_FILE, "Settings", "PreviewIdentityHorizontal")
        IniWrite(Settings["PreviewIdentityTextSize"], CONFIG_FILE, "Settings", "PreviewIdentityTextSize")
        IniWrite(Settings["GameIdentityVertical"], CONFIG_FILE, "Settings", "GameIdentityVertical")
        IniWrite(Settings["GameIdentityHorizontal"], CONFIG_FILE, "Settings", "GameIdentityHorizontal")
        IniWrite(Settings["GameIdentityTextSize"], CONFIG_FILE, "Settings", "GameIdentityTextSize")
        IniWrite(Settings["MainGuiX"], CONFIG_FILE, "Settings", "MainGuiX")
        IniWrite(Settings["MainGuiY"], CONFIG_FILE, "Settings", "MainGuiY")
        IniWrite(Settings["FlashGameIdentity"] ? "1" : "0", CONFIG_FILE, "Settings", "FlashGameIdentity")
        IniWrite(Settings["PreviewOpacity"], CONFIG_FILE, "Settings", "PreviewOpacity")
        IniWrite(Settings["HotkeysAlwaysOnTop"] ? "1" : "0", CONFIG_FILE, "Settings", "HotkeysAlwaysOnTop")
        IniWrite(Settings["SandboxieAlwaysOnTop"] ? "1" : "0", CONFIG_FILE, "Settings", "SandboxieAlwaysOnTop")
        IniWrite(Settings["LayoutEditorAlwaysOnTop"] ? "1" : "0", CONFIG_FILE, "Settings", "LayoutEditorAlwaysOnTop")
        IniWrite(Settings["LastLayoutName"], CONFIG_FILE, "Settings", "LastLayoutName")
        IniWrite(Settings["LastPreviewLayoutName"], CONFIG_FILE, "Settings", "LastPreviewLayoutName")
        IniWrite(Settings["BannerSelection"], CONFIG_FILE, "Settings", "BannerSelection")
        IniWrite(Settings["SandboxieStartExe"], CONFIG_FILE, "SandboxiePaths", "StartExe")
        IniWrite(Settings["SandboxieSteamExe"], CONFIG_FILE, "SandboxiePaths", "SteamExe")
        IniWrite(Settings["SandboxieFoxholeExe"], CONFIG_FILE, "SandboxiePaths", "FoxholeExe")
        lastSettings := settingsSignature
    }

    accountSwapSignature := ""
    Loop MaxSandboxieRows
    {
        key := AccountSwapKeys.Has(A_Index) ? AccountSwapKeys[A_Index] : ""
        if key != ""
            accountSwapSignature .= A_Index "=" key "`n"
    }
    if accountSwapSignature != lastAccountSwap
    {
        SaveAccountSwapKeysPreservingSlots()
        lastAccountSwap := accountSwapSignature
    }

    SaveSandboxieAccountsSafely()
}

WorkflowSequentialLoginChanged(*)
{
    ApplySequentialWorkflowControlState()
    UpdateWorkflowSequencePreview()
}

ApplySequentialWorkflowControlState()
{
    global WorkflowSequentialLoginCheck, WorkflowSequentialCountCombo
    global WorkflowResetFoxholeCheck, WorkflowLaunchFoxholeCheck, WorkflowResetSteamCheck, WorkflowLaunchSteamCheck
    global WorkflowResetSandboxesCheck, WorkflowVerifySandboxesCheck
    if !IsObject(WorkflowSequentialLoginCheck)
        return
    enabled := WorkflowSequentialLoginCheck.Value = 1
    WorkflowSequentialCountCombo.Enabled := enabled
    for ctrl in [WorkflowResetFoxholeCheck, WorkflowLaunchFoxholeCheck, WorkflowResetSteamCheck, WorkflowLaunchSteamCheck, WorkflowResetSandboxesCheck, WorkflowVerifySandboxesCheck]
        ctrl.Enabled := !enabled
}

StartSequentialLoginWorkflow(accounts, maxOnline)
{
    global SequentialLoginActive, SequentialLoginAccounts, SequentialLoginMaxOnline, SequentialLoginNextPosition
    global SequentialLoginRefillPending
    SequentialLoginAccounts := []
    for idx in accounts
    {
        inserted := false
        for pos, existing in SequentialLoginAccounts
        {
            if idx < existing
            {
                SequentialLoginAccounts.InsertAt(pos, idx)
                inserted := true
                break
            }
        }
        if !inserted
            SequentialLoginAccounts.Push(idx)
    }
    SequentialLoginMaxOnline := Max(1, Min(10, Integer(maxOnline), SequentialLoginAccounts.Length))
    SequentialLoginNextPosition := 1
    SequentialLoginActive := true
    SequentialLoginRefillPending := false
    SetTimer(MonitorSequentialLoginWorkflow, 750)
    MonitorSequentialLoginWorkflow()
}

StopSequentialLoginWorkflow(finish := true)
{
    global SequentialLoginActive, SequentialLoginAccounts, SequentialLoginRefillPending
    SetTimer(MonitorSequentialLoginWorkflow, 0)
    SequentialLoginActive := false
    SequentialLoginAccounts := []
    SequentialLoginRefillPending := false
    if finish
        FinishWorkflow("Sequential login stopped.")
}

GetSequentialLoginOpenMap()
{
    global SequentialLoginAccounts, SandboxieAccounts
    open := Map()
    ScanWindows(false)
    for idx in SequentialLoginAccounts
        if idx >= 1 && idx <= SandboxieAccounts.Length && IsFoxholeAccountAlreadyOpen(idx, SandboxieAccounts[idx])
            open[idx] := true
    return open
}

MonitorSequentialLoginWorkflow(*)
{
    global SequentialLoginActive, SequentialLoginAccounts, SequentialLoginMaxOnline, SequentialLoginNextPosition
    global SequentialLoginRefillPending, SequentialLaunchActive, SandboxieAccounts
    if !SequentialLoginActive || SequentialLaunchActive || SequentialLoginRefillPending
        return
    if SequentialLoginAccounts.Length = 0
    {
        StopSequentialLoginWorkflow()
        return
    }
    open := GetSequentialLoginOpenMap()
    if open.Count >= SequentialLoginMaxOnline
    {
        UpdateSequentialLoginStatus(open.Count)
        return
    }
    attempts := 0
    while attempts < SequentialLoginAccounts.Length
    {
        if SequentialLoginNextPosition > SequentialLoginAccounts.Length
            SequentialLoginNextPosition := 1
        idx := SequentialLoginAccounts[SequentialLoginNextPosition]
        SequentialLoginNextPosition++
        attempts++
        if open.Has(idx)
            continue
        SequentialLoginRefillPending := true
        SetWorkflowStatus("Sequential login: launching account " idx " (" Trim(SandboxieAccounts[idx].name) ")...")
        if !StartFoxholeLaunchesForIndices([idx], false)
        {
            SequentialLoginRefillPending := false
            SetTimer(MonitorSequentialLoginWorkflow, -750)
        }
        return
    }
    UpdateSequentialLoginStatus(open.Count)
}

UpdateSequentialLoginStatus(openCount := -1)
{
    global SequentialLoginActive, SequentialLoginMaxOnline, SequentialLoginAccounts, SequentialLoginNextPosition, SandboxieAccounts
    if !SequentialLoginActive
        return
    if openCount < 0
        openCount := GetSequentialLoginOpenMap().Count
    nextText := ""
    if SequentialLoginAccounts.Length
    {
        pos := SequentialLoginNextPosition > SequentialLoginAccounts.Length ? 1 : SequentialLoginNextPosition
        idx := SequentialLoginAccounts[pos]
        nextText := "; next: account " idx " (" Trim(SandboxieAccounts[idx].name) ")"
    }
    SetWorkflowStatus("Sequential login active — " openCount "/" SequentialLoginMaxOnline " online" nextText ".")
}

SetWorkflowStatus(message)
{
    global WorkflowStatusMessage, StatusText, LastLogMessage
    if message != LastLogMessage
    {
        LogEvent(message)
        LastLogMessage := message
    }
    WorkflowStatusMessage := message
    if IsObject(StatusText)
        StatusText.Text := "Status: " message
}

ShowStatusOverlayChanged(ctrl, *)
{
    global Settings, CONFIG_FILE
    Settings["ShowStatusOverlay"] := ctrl.Value = 1
    IniWrite(Settings["ShowStatusOverlay"] ? "1" : "0", CONFIG_FILE, "Settings", "ShowStatusOverlay")
    UpdateStatusOverlay()
}

UpdateStatusOverlay(*)
{
    global Settings, StatusOverlayGui, StatusOverlayText, StatusText, WorkflowRunning, WorkflowStatusMessage, UiTransitionInProgress
    if UiTransitionInProgress
        return
    if !Settings["ShowStatusOverlay"]
    {
        if IsObject(StatusOverlayGui)
            try StatusOverlayGui.Hide()
        return
    }
    if !IsObject(StatusOverlayGui)
    {
        StatusOverlayGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
        StatusOverlayGui.BackColor := "202020"
        StatusOverlayGui.SetFont("s10 cFFFFFF", "Segoe UI Semibold")
        StatusOverlayText := StatusOverlayGui.AddText("x10 y5 w680 h24 +Center +0x200", "")
    }
    text := WorkflowRunning && WorkflowStatusMessage != "" ? WorkflowStatusMessage : (IsObject(StatusText) ? RegExReplace(StatusText.Text, "^Status:\\s*", "") : "Ready")
    StatusOverlayText.Text := text
    primary := MonitorGetPrimary()
    MonitorGetWorkArea(primary, &left, &top, &right, &bottom)
    width := Min(700, right-left)
    x := left + Floor(((right-left)-width)/2)
    try StatusOverlayGui.Show("NA x" x " y" top " w" width " h34")
}

CleanupAll(*)
{
    global StatusOverlayGui, Instances, TitleOverlays, LayoutEditorOverlays, PreviewIdentityOverlays, PreviewPositionOverlays
    SaveConfig()

    SetTimer(MaintainFoxholeTaskbarCover, 0)
    RestoreFoxholeTaskbars(true)
    SaveMainGuiPosition()
    DestroyAllFoxholePreviews()
    DestroyPreviewPositionOverlays()
    SetTimer(UpdateStatusOverlay, 0)
    SetTimer(MonitorSequentialLoginWorkflow, 0)
    if IsObject(StatusOverlayGui)
        try StatusOverlayGui.Destroy()

    for _, preview in LayoutEditorOverlays
        try preview.gui.Destroy()
    LayoutEditorOverlays := Map()

    SetTimer(EventDrivenFoxholeDiscovery, 0)
    SetTimer(InitialWindowDiscovery, 0)
    SetTimer(RestoreMainGuiAfterStartup, 0)
    SetTimer(MaintainTitleOverlays, 0)
    SetTimer(MaintainPreviewIdentityOverlays, 0)
    SetTimer(MaintainPreviewFocusVisibility, 0)
    SetTimer(MaintainPreviewHoverFront, 0)
    SetTimer(MonitorFoxholeFocusIdentity, 0)
    SetTimer(WarmFoxholeFocusIdentityCache, 0)
    CleanupFocusFlashResources()
    SetTimer(MonitorSandboxieSupporterPopup, 0)
    SetTimer(RotateMainTip, 0)
    StopLayoutPositionWatcher()
    StopFoxholeWindowWatcher()
    CloseSwitchSlotAccountMenu()
    CloseWindowSwapMenu()
    titleHwnds := []
    for hwnd, _ in TitleOverlays
        titleHwnds.Push(hwnd)
    for hwnd in titleHwnds
        RemoveTitleOverlay(hwnd)
    TitleOverlays := Map()
    for inst in Instances
    {
        try StopAllHotkeys(inst)
        catch
        {
        }
    }
}
