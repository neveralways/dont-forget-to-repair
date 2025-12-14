-- ================================================================================
-- Don't Forget to Repair - Configuration Panel (Standalone Window)
-- ================================================================================
local addonName, addon = ...

-- ================================================================================
-- Main Configuration Frame (Standalone Window like Leatrix Plus)
-- ================================================================================
local configFrame = CreateFrame("Frame", "DFTRConfigFrame", UIParent, "BackdropTemplate")
configFrame:SetSize(500, 480)
configFrame:SetPoint("CENTER")
configFrame:SetMovable(true)
configFrame:EnableMouse(true)
configFrame:RegisterForDrag("LeftButton")
configFrame:SetFrameStrata("DIALOG")
configFrame:SetClampedToScreen(true)
configFrame:Hide()

-- Make it closeable with Escape
tinsert(UISpecialFrames, "DFTRConfigFrame")

-- Backdrop
configFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
configFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)

-- Drag functionality
configFrame:SetScript("OnDragStart", configFrame.StartMoving)
configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)

-- ================================================================================
-- Header Section
-- ================================================================================
-- Header background bar
local headerBg = configFrame:CreateTexture(nil, "ARTWORK")
headerBg:SetSize(484, 50)
headerBg:SetPoint("TOP", configFrame, "TOP", 0, -8)
headerBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)

-- Addon icon
local headerIcon = configFrame:CreateTexture(nil, "OVERLAY")
headerIcon:SetSize(40, 40)
headerIcon:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, -13)
headerIcon:SetTexture("Interface\\Icons\\Trade_BlackSmithing")

-- Title
local headerTitle = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
headerTitle:SetPoint("LEFT", headerIcon, "RIGHT", 15, 5)
headerTitle:SetText("|cFFFFD100Don't Forget to Repair|r")

-- Subtitle/Version
local headerVersion = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
headerVersion:SetPoint("LEFT", headerIcon, "RIGHT", 15, -10)
headerVersion:SetText("|cFF888888Version " .. C_AddOns.GetAddOnMetadata("DontForgetToRepair", "Version") .. "|r")

-- Close button
local closeButton = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", configFrame, "TOPRIGHT", -5, -5)
closeButton:SetScript("OnClick", function() configFrame:Hide() end)

-- ================================================================================
-- Content Area
-- ================================================================================
local contentFrame = CreateFrame("Frame", nil, configFrame, "BackdropTemplate")
contentFrame:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 15, -65)
contentFrame:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -15, 50)
contentFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 14,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
contentFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.9)
contentFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

-- ================================================================================
-- Scroll Frame for Content
-- ================================================================================
local scrollFrame = CreateFrame("ScrollFrame", nil, contentFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, -8)
scrollFrame:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -28, 8)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(440, 600)
scrollFrame:SetScrollChild(scrollChild)

-- ================================================================================
-- Section: Durability Threshold
-- ================================================================================
local function CreateSectionHeader(parent, text, yOffset)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    header:SetText("|cFFFFD100" .. text .. "|r")
    
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetSize(420, 1)
    line:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
    line:SetColorTexture(0.6, 0.5, 0.2, 0.6)
    
    return header, line
end

local thresholdHeader = CreateSectionHeader(scrollChild, "Durability Threshold", -10)

local thresholdDesc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
thresholdDesc:SetPoint("TOPLEFT", thresholdHeader, "BOTTOMLEFT", 0, -15)
thresholdDesc:SetWidth(420)
thresholdDesc:SetJustifyH("LEFT")
thresholdDesc:SetText("Set the durability percentage at which the warning will trigger.")

local thresholdSlider = CreateFrame("Slider", "DFTRThresholdSlider", scrollChild, "OptionsSliderTemplate")
thresholdSlider:SetPoint("TOPLEFT", thresholdDesc, "BOTTOMLEFT", 10, -20)
thresholdSlider:SetMinMaxValues(1, 100)
thresholdSlider:SetValueStep(1)
thresholdSlider:SetWidth(300)
thresholdSlider:SetObeyStepOnDrag(true)

DFTRThresholdSliderLow:SetText("|cFF88888810%|r")
DFTRThresholdSliderHigh:SetText("|cFF888888100%|r")

local thresholdValue = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
thresholdValue:SetPoint("LEFT", thresholdSlider, "RIGHT", 20, 0)

thresholdSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value)
    if DurabilityWarningDB then
        DurabilityWarningDB.durabilityThreshold = value
    end
    thresholdValue:SetText("|cFF00FF00" .. value .. "%|r")
    DFTRThresholdSliderText:SetText("")
end)

-- ================================================================================
-- Section: Notification Type
-- ================================================================================
local notifHeader = CreateSectionHeader(scrollChild, "Notification Type", -100)

local notifDesc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
notifDesc:SetPoint("TOPLEFT", notifHeader, "BOTTOMLEFT", 0, -15)
notifDesc:SetWidth(420)
notifDesc:SetJustifyH("LEFT")
notifDesc:SetText("Choose how you want to be notified when durability is low.")

-- Popup option
local popupCheck = CreateFrame("CheckButton", "DFTRPopupCheck", scrollChild, "UICheckButtonTemplate")
popupCheck:SetPoint("TOPLEFT", notifDesc, "BOTTOMLEFT", 5, -10)
popupCheck.text = popupCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
popupCheck.text:SetPoint("LEFT", popupCheck, "RIGHT", 5, 0)
popupCheck.text:SetText("Popup Window")

-- Toast option
local toastCheck = CreateFrame("CheckButton", "DFTRToastCheck", scrollChild, "UICheckButtonTemplate")
toastCheck:SetPoint("TOPLEFT", popupCheck, "BOTTOMLEFT", 0, -2)
toastCheck.text = toastCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
toastCheck.text:SetPoint("LEFT", toastCheck, "RIGHT", 5, 0)
toastCheck.text:SetText("Toast Notification")

-- Chat option
local chatCheck = CreateFrame("CheckButton", "DFTRChatCheck", scrollChild, "UICheckButtonTemplate")
chatCheck:SetPoint("TOPLEFT", toastCheck, "BOTTOMLEFT", 0, -2)
chatCheck.text = chatCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
chatCheck.text:SetPoint("LEFT", chatCheck, "RIGHT", 5, 0)
chatCheck.text:SetText("Chat Message")

-- Also toast checkbox (indent)
local alsoToastCheck = CreateFrame("CheckButton", "DFTRAlsoToastCheck", scrollChild, "UICheckButtonTemplate")
alsoToastCheck:SetPoint("TOPLEFT", chatCheck, "BOTTOMLEFT", 20, -2)
alsoToastCheck.text = alsoToastCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
alsoToastCheck.text:SetPoint("LEFT", alsoToastCheck, "RIGHT", 5, 0)
alsoToastCheck.text:SetText("|cFF888888Also show toast with popup|r")

-- Radio button behavior for notification options
local function UpdateNotificationOptions()
    local notifType = DurabilityWarningDB and DurabilityWarningDB.notificationType or "popup"
    popupCheck:SetChecked(notifType == "popup")
    toastCheck:SetChecked(notifType == "toast")
    chatCheck:SetChecked(notifType == "chat")
    alsoToastCheck:SetChecked(DurabilityWarningDB and DurabilityWarningDB.enableToastAlso or false)
    alsoToastCheck:SetEnabled(notifType == "popup")
    if notifType == "popup" then
        alsoToastCheck.text:SetText("|cFF888888Also show toast with popup|r")
    else
        alsoToastCheck.text:SetText("|cFF555555Also show toast with popup|r")
    end
end

popupCheck:SetScript("OnClick", function()
    DurabilityWarningDB.notificationType = "popup"
    UpdateNotificationOptions()
end)

toastCheck:SetScript("OnClick", function()
    DurabilityWarningDB.notificationType = "toast"
    UpdateNotificationOptions()
end)

chatCheck:SetScript("OnClick", function()
    DurabilityWarningDB.notificationType = "chat"
    UpdateNotificationOptions()
end)

alsoToastCheck:SetScript("OnClick", function(self)
    DurabilityWarningDB.enableToastAlso = self:GetChecked()
end)

-- ================================================================================
-- Section: Sound Settings
-- ================================================================================
local soundHeader = CreateSectionHeader(scrollChild, "Sound Settings", -280)

local soundDesc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
soundDesc:SetPoint("TOPLEFT", soundHeader, "BOTTOMLEFT", 0, -15)
soundDesc:SetWidth(420)
soundDesc:SetJustifyH("LEFT")
soundDesc:SetText("Configure the warning sound effect.")

-- Enable sound checkbox
local soundCheck = CreateFrame("CheckButton", "DFTRSoundCheck", scrollChild, "UICheckButtonTemplate")
soundCheck:SetPoint("TOPLEFT", soundDesc, "BOTTOMLEFT", 5, -10)
soundCheck.text = soundCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
soundCheck.text:SetPoint("LEFT", soundCheck, "RIGHT", 5, 0)
soundCheck.text:SetText("|cFFFFFFFFEnable warning sound|r")

soundCheck:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Play a sound when the durability warning is shown.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
soundCheck:SetScript("OnLeave", function() GameTooltip:Hide() end)

soundCheck:SetScript("OnClick", function(self)
    DurabilityWarningDB.enableSound = self:GetChecked()
end)

-- Sound dropdown label
local soundLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
soundLabel:SetPoint("TOPLEFT", soundCheck, "BOTTOMLEFT", 5, -15)
soundLabel:SetText("Sound effect:")

-- Sound dropdown
local soundDropdown = CreateFrame("Frame", "DFTRSoundDropdown", scrollChild, "UIDropDownMenuTemplate")
soundDropdown:SetPoint("LEFT", soundLabel, "RIGHT", -5, -2)

local soundOptions = {
    { text = "Raid Warning", value = "RAID_WARNING" },
    { text = "Alarm Clock", value = "ALARM" },
    { text = "Level Up", value = "LEVELUP" },
    { text = "PvP Flag", value = "PVP_FLAG" },
    { text = "Ready Check", value = "READY_CHECK" },
}

local function SoundDropdown_OnClick(self, arg1)
    DurabilityWarningDB.soundFile = arg1
    UIDropDownMenu_SetText(soundDropdown, self:GetText())
    if addon.PlayWarningSound then
        addon.PlayWarningSound()
    end
end

local function SoundDropdown_Initialize(self, level)
    local currentSound = DurabilityWarningDB and DurabilityWarningDB.soundFile or "RAID_WARNING"
    for i, option in ipairs(soundOptions) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = option.text
        info.arg1 = option.value
        info.func = SoundDropdown_OnClick
        info.checked = (currentSound == option.value)
        UIDropDownMenu_AddButton(info, level)
    end
end

UIDropDownMenu_SetWidth(soundDropdown, 140)
UIDropDownMenu_Initialize(soundDropdown, SoundDropdown_Initialize)

-- Test sound button
local testSoundBtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
testSoundBtn:SetPoint("LEFT", soundDropdown, "RIGHT", 5, 2)
testSoundBtn:SetSize(70, 24)
testSoundBtn:SetText("Test")
testSoundBtn:SetScript("OnClick", function()
    if addon.PlayWarningSound then
        addon.PlayWarningSound()
    end
end)

-- ================================================================================
-- Section: Minimap Icon
-- ================================================================================
local minimapHeader = CreateSectionHeader(scrollChild, "Minimap Icon", -400)

local minimapDesc = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
minimapDesc:SetPoint("TOPLEFT", minimapHeader, "BOTTOMLEFT", 0, -15)
minimapDesc:SetWidth(420)
minimapDesc:SetJustifyH("LEFT")
minimapDesc:SetText("Configure the minimap icon that shows your current durability.")

-- Show minimap checkbox
local minimapCheck = CreateFrame("CheckButton", "DFTRMinimapCheck", scrollChild, "UICheckButtonTemplate")
minimapCheck:SetPoint("TOPLEFT", minimapDesc, "BOTTOMLEFT", 5, -10)
minimapCheck.text = minimapCheck:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
minimapCheck.text:SetPoint("LEFT", minimapCheck, "RIGHT", 5, 0)
minimapCheck.text:SetText("|cFFFFFFFFShow minimap icon|r")

minimapCheck:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Display a minimap icon showing the lowest durability percentage.", 1, 1, 1, 1, true)
    GameTooltip:Show()
end)
minimapCheck:SetScript("OnLeave", function() GameTooltip:Hide() end)

minimapCheck:SetScript("OnClick", function(self)
    DurabilityWarningDB.minimapIcon.hide = not self:GetChecked()
    if addon.UpdateMinimapIcon then
        addon.UpdateMinimapIcon()
    end
end)

-- ================================================================================
-- Section: Commands
-- ================================================================================
local cmdHeader = CreateSectionHeader(scrollChild, "Slash Commands", -480)

local cmdText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
cmdText:SetPoint("TOPLEFT", cmdHeader, "BOTTOMLEFT", 10, -15)
cmdText:SetJustifyH("LEFT")
cmdText:SetText(
    "|cFFFFD100/dftr|r - Show help\n" ..
    "|cFFFFD100/dftr config|r - Open this panel\n" ..
    "|cFFFFD100/dftr status|r - Show current durability\n" ..
    "|cFFFFD100/dftr test|r - Test current notification\n" ..
    "|cFFFFD100/dftr minimap|r - Toggle minimap icon"
)

-- ================================================================================
-- Footer Buttons
-- ================================================================================
local testBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
testBtn:SetPoint("BOTTOMLEFT", configFrame, "BOTTOMLEFT", 20, 15)
testBtn:SetSize(120, 26)
testBtn:SetText("Test Warning")
testBtn:SetScript("OnClick", function()
    if addon.TestWarning then
        addon.TestWarning()
    end
end)

local closeBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
closeBtn:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -20, 15)
closeBtn:SetSize(100, 26)
closeBtn:SetText("Close")
closeBtn:SetScript("OnClick", function()
    configFrame:Hide()
end)

-- ================================================================================
-- OnShow - Load saved values
-- ================================================================================
configFrame:SetScript("OnShow", function(self)
    if DurabilityWarningDB then
        thresholdSlider:SetValue(DurabilityWarningDB.durabilityThreshold or 50)
        thresholdValue:SetText("|cFF00FF00" .. (DurabilityWarningDB.durabilityThreshold or 50) .. "%|r")
        DFTRThresholdSliderText:SetText("")
        
        UpdateNotificationOptions()
        
        soundCheck:SetChecked(DurabilityWarningDB.enableSound)
        minimapCheck:SetChecked(not DurabilityWarningDB.minimapIcon.hide)
        
        -- Update sound dropdown text
        for _, option in ipairs(soundOptions) do
            if option.value == DurabilityWarningDB.soundFile then
                UIDropDownMenu_SetText(soundDropdown, option.text)
                break
            end
        end
    end
end)

-- ================================================================================
-- Export config frame for slash commands
-- ================================================================================
addon.ConfigFrame = configFrame

-- ================================================================================
-- Also register with Blizzard settings (optional fallback)
-- ================================================================================
if SettingsPanel then
    local optionsPanel = CreateFrame("Frame", "DontForgetToRepairOptionsPanel", UIParent)
    optionsPanel.name = "DontForgetToRepair"
    
    local openBtn = CreateFrame("Button", nil, optionsPanel, "UIPanelButtonTemplate")
    openBtn:SetPoint("CENTER")
    openBtn:SetSize(200, 30)
    openBtn:SetText("Open Configuration")
    openBtn:SetScript("OnClick", function()
        configFrame:Show()
        HideUIPanel(SettingsPanel)
    end)
    
    local infoText = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    infoText:SetPoint("BOTTOM", openBtn, "TOP", 0, 20)
    infoText:SetText("Click the button below or type |cFFFFD100/dftr|r to open settings")
    
    local category, layout = Settings.RegisterCanvasLayoutCategory(optionsPanel, "DontForgetToRepair")
    Settings.RegisterAddOnCategory(category)
end
