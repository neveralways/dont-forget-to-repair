-- ================================================================================
-- Don't Forget to Repair - Enhanced Edition
-- ================================================================================
local addonName, addon = ...

-- ================================================================================
-- Local Variables & Defaults
-- ================================================================================
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

local defaults = {
    durabilityThreshold = 50,
    enableSound = true,
    soundFile = "RAID_WARNING",
    notificationType = "popup", -- "popup", "toast", "chat"
    enableToastAlso = false,
    framePosition = nil,
    minimapIcon = { hide = false },
    minimapAngle = 220,
}

local shownWarning = true
local currentLowestDurability = 100
local lowestDurabilitySlot = nil

-- Slot names for display
local slotNames = {
    [1] = "Head", [2] = "Neck", [3] = "Shoulder", [4] = "Shirt",
    [5] = "Chest", [6] = "Waist", [7] = "Legs", [8] = "Feet",
    [9] = "Wrist", [10] = "Hands", [11] = "Finger 1", [12] = "Finger 2",
    [13] = "Trinket 1", [14] = "Trinket 2", [15] = "Back", [16] = "Main Hand",
    [17] = "Off Hand", [18] = "Ranged"
}

-- ================================================================================
-- Database Initialization
-- ================================================================================
local function InitializeDB()
    if DurabilityWarningDB == nil then
        DurabilityWarningDB = {}
    end
    for key, value in pairs(defaults) do
        if DurabilityWarningDB[key] == nil then
            DurabilityWarningDB[key] = value
        end
    end
end

-- ================================================================================
-- Color Utility Functions
-- ================================================================================
local function GetDurabilityColor(percent)
    if percent >= 75 then
        return 0.2, 1, 0.2 -- Green
    elseif percent >= 50 then
        return 1, 1, 0.2 -- Yellow
    elseif percent >= 25 then
        return 1, 0.5, 0 -- Orange
    else
        return 1, 0.2, 0.2 -- Red
    end
end

local function GetDurabilityColorHex(percent)
    if percent >= 75 then
        return "|cFF33FF33" -- Green
    elseif percent >= 50 then
        return "|cFFFFFF33" -- Yellow
    elseif percent >= 25 then
        return "|cFFFF8000" -- Orange
    else
        return "|cFFFF3333" -- Red
    end
end

-- ================================================================================
-- Warning Frame (Popup) - Enhanced Design
-- ================================================================================
local warningFrame = CreateFrame("Frame", "DurabilityWarningFrame", UIParent, "BackdropTemplate")
warningFrame:SetSize(380, 180)
warningFrame:SetPoint("CENTER")
warningFrame:SetMovable(true)
warningFrame:EnableMouse(true)
warningFrame:RegisterForDrag("LeftButton")
warningFrame:SetFrameStrata("DIALOG")
warningFrame:SetClampedToScreen(true)

-- Custom backdrop
warningFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
warningFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)

warningFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
warningFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save position
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    DurabilityWarningDB.framePosition = { point = point, relativePoint = relativePoint, x = xOfs, y = yOfs }
end)

-- Warning icon
local warningIcon = warningFrame:CreateTexture(nil, "ARTWORK")
warningIcon:SetSize(48, 48)
warningIcon:SetPoint("TOP", warningFrame, "TOP", 0, -20)
warningIcon:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")

-- Title
warningFrame.title = warningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
warningFrame.title:SetPoint("TOP", warningIcon, "BOTTOM", 0, -5)
warningFrame.title:SetText("|cFFFF6600Durability Warning|r")

-- Durability percentage text (big)
warningFrame.percentText = warningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
warningFrame.percentText:SetPoint("CENTER", warningFrame, "CENTER", 0, -5)

-- Item info text
warningFrame.itemText = warningFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
warningFrame.itemText:SetPoint("TOP", warningFrame.percentText, "BOTTOM", 0, -5)

-- Message text
warningFrame.text = warningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
warningFrame.text:SetPoint("TOP", warningFrame.itemText, "BOTTOM", 0, -3)
warningFrame.text:SetText("|cFFAAAAFFDon't forget to repair!|r")

-- OK Button with enhanced style
local okButton = CreateFrame("Button", nil, warningFrame, "UIPanelButtonTemplate")
okButton:SetPoint("BOTTOM", warningFrame, "BOTTOM", 0, 15)
okButton:SetSize(100, 28)
okButton:SetText("OK")
okButton:SetScript("OnClick", function()
    warningFrame:Hide()
end)

-- Pulse animation
local pulseGroup = warningFrame:CreateAnimationGroup()
local pulse1 = pulseGroup:CreateAnimation("Scale")
pulse1:SetScale(1.02, 1.02)
pulse1:SetDuration(0.3)
pulse1:SetOrder(1)
local pulse2 = pulseGroup:CreateAnimation("Scale")
pulse2:SetScale(0.98, 0.98)
pulse2:SetDuration(0.3)
pulse2:SetOrder(2)
pulseGroup:SetLooping("REPEAT")

warningFrame:SetScript("OnShow", function(self)
    pulseGroup:Play()
end)
warningFrame:SetScript("OnHide", function(self)
    pulseGroup:Stop()
end)

warningFrame:Hide()

-- ================================================================================
-- Toast Notification Frame
-- ================================================================================
local toastFrame = CreateFrame("Frame", "DurabilityToastFrame", UIParent, "BackdropTemplate")
toastFrame:SetSize(280, 60)
toastFrame:SetPoint("TOP", UIParent, "TOP", 0, -100)
toastFrame:SetFrameStrata("HIGH")

toastFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
toastFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
toastFrame:SetBackdropBorderColor(1, 0.5, 0, 1)

-- Toast icon
local toastIcon = toastFrame:CreateTexture(nil, "ARTWORK")
toastIcon:SetSize(32, 32)
toastIcon:SetPoint("LEFT", toastFrame, "LEFT", 12, 0)
toastIcon:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")

-- Toast text
toastFrame.text = toastFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
toastFrame.text:SetPoint("LEFT", toastIcon, "RIGHT", 10, 5)

toastFrame.subtext = toastFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
toastFrame.subtext:SetPoint("LEFT", toastIcon, "RIGHT", 10, -10)
toastFrame.subtext:SetText("Don't forget to repair!")

-- Toast fade animation
local toastFadeIn = toastFrame:CreateAnimationGroup()
local fadeIn = toastFadeIn:CreateAnimation("Alpha")
fadeIn:SetFromAlpha(0)
fadeIn:SetToAlpha(1)
fadeIn:SetDuration(0.3)

local toastFadeOut = toastFrame:CreateAnimationGroup()
local fadeOut = toastFadeOut:CreateAnimation("Alpha")
fadeOut:SetFromAlpha(1)
fadeOut:SetToAlpha(0)
fadeOut:SetDuration(0.5)
fadeOut:SetStartDelay(4)
toastFadeOut:SetScript("OnFinished", function()
    toastFrame:Hide()
end)

toastFrame:Hide()

-- ================================================================================
-- Minimap Icon (LibDataBroker-like implementation without external libs)
-- ================================================================================
local minimapButton = CreateFrame("Button", "DFTRMinimapButton", Minimap)
minimapButton:SetSize(32, 32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
minimapButton:RegisterForDrag("LeftButton")

-- Minimap button background
local minimapBg = minimapButton:CreateTexture(nil, "BACKGROUND")
minimapBg:SetSize(20, 20)
minimapBg:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)
minimapBg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")

-- Minimap button icon (anvil/repair icon)
local minimapIconTex = minimapButton:CreateTexture(nil, "ARTWORK")
minimapIconTex:SetSize(18, 18)
minimapIconTex:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)
minimapIconTex:SetTexture("Interface\\Icons\\Trade_BlackSmithing")
minimapIconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Remove icon border
if minimapIconTex.SetMaskTexture then
    minimapIconTex:SetMaskTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
end

-- Border
local minimapBorder = minimapButton:CreateTexture(nil, "OVERLAY")
minimapBorder:SetSize(54, 54)
-- This texture isn't centered in its own file; these offsets match Blizzard/LDB minimap buttons.
minimapBorder:SetPoint("TOPLEFT", minimapButton, "TOPLEFT", 0, 0)
minimapBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

-- Durability text on minimap (below the button)
local minimapText = minimapButton:CreateFontString(nil, "OVERLAY")
minimapText:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
minimapText:SetPoint("TOP", minimapButton, "BOTTOM", 0, 4)
minimapText:SetText("100%")

-- Minimap positioning
local minimapAngle = 220
local function UpdateMinimapPosition()
    local angle = math.rad(minimapAngle)
    local x = math.cos(angle) * 100
    local y = math.sin(angle) * 100
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

minimapButton:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function(self)
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        px, py = px / scale, py / scale
        minimapAngle = math.deg(math.atan2(py - my, px - mx))
        UpdateMinimapPosition()
    end)
end)

minimapButton:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
    -- Save minimap position
    DurabilityWarningDB.minimapAngle = minimapAngle
end)

minimapButton:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        if warningFrame:IsShown() then
            warningFrame:Hide()
        else
            -- Show current status
            local durability = currentLowestDurability
            local r, g, b = GetDurabilityColor(durability)
            warningFrame.percentText:SetTextColor(r, g, b)
            warningFrame.percentText:SetText(math.floor(durability) .. "%")
            if lowestDurabilitySlot then
                warningFrame.itemText:SetText("|cFFAAAAAA" .. (slotNames[lowestDurabilitySlot] or "Unknown") .. "|r")
            end
            warningFrame:Show()
        end
    elseif button == "RightButton" then
        if addon.ConfigFrame then
            addon.ConfigFrame:Show()
        end
    end
end)

minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("|cFF00FF00Don't Forget to Repair|r")
    GameTooltip:AddLine(" ")
    local colorHex = GetDurabilityColorHex(currentLowestDurability)
    GameTooltip:AddDoubleLine("Lowest Durability:", colorHex .. math.floor(currentLowestDurability) .. "%|r")
    if lowestDurabilitySlot then
        GameTooltip:AddDoubleLine("Item:", slotNames[lowestDurabilitySlot] or "Unknown")
    end
    GameTooltip:AddDoubleLine("Threshold:", DurabilityWarningDB.durabilityThreshold .. "%")
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cFFFFFF00Left-Click:|r Show warning")
    GameTooltip:AddLine("|cFFFFFF00Right-Click:|r Open settings")
    GameTooltip:AddLine("|cFFFFFF00Drag:|r Move icon")
    GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- Update minimap icon display
local function UpdateMinimapIcon()
    local durability = currentLowestDurability
    local r, g, b = GetDurabilityColor(durability)
    minimapText:SetTextColor(r, g, b)
    minimapText:SetText(math.floor(durability) .. "%")
    
    if DurabilityWarningDB and DurabilityWarningDB.minimapIcon and DurabilityWarningDB.minimapIcon.hide then
        minimapButton:Hide()
    else
        minimapButton:Show()
    end
end

-- ================================================================================
-- Sound System
-- ================================================================================
local soundFiles = {
    ["RAID_WARNING"] = 8959, -- RaidWarning
    ["ALARM"] = 8046, -- AlarmClockWarning3
    ["LEVELUP"] = 888, -- Level Up
    ["PVP_FLAG"] = 8174, -- PvP Flag
    ["READY_CHECK"] = 8960, -- ReadyCheck
}

local function PlayWarningSound()
    if DurabilityWarningDB.enableSound then
        local soundID = soundFiles[DurabilityWarningDB.soundFile] or 8959
        PlaySound(soundID, "Master")
    end
end

-- ================================================================================
-- Chat Message
-- ================================================================================
local function SendChatWarning(durability, slotName)
    local colorHex = GetDurabilityColorHex(durability)
    local message = string.format("|cFFFF6600[Don't Forget to Repair]|r %s%d%%|r durability on |cFFFFFFFF%s|r - Time to repair!",
        colorHex, math.floor(durability), slotName or "gear")
    print(message)
end

-- ================================================================================
-- Toast Notification
-- ================================================================================
local function ShowToast(durability, slotName)
    local r, g, b = GetDurabilityColor(durability)
    toastFrame.text:SetTextColor(r, g, b)
    toastFrame.text:SetText(math.floor(durability) .. "% Durability")
    toastFrame.subtext:SetText((slotName or "Gear") .. " needs repair!")
    toastFrame:SetAlpha(1)
    toastFrame:Show()
    toastFadeIn:Play()
    toastFadeOut:Play()
end

-- ================================================================================
-- Main Durability Check
-- ================================================================================
local function GetLowestDurability()
    local lowestPercent = 100
    local lowestSlot = nil
    
    for slot = 1, 18 do
        local current, maximum = GetInventoryItemDurability(slot)
        if current and maximum and maximum > 0 then
            local durability = (current / maximum) * 100
            if durability < lowestPercent then
                lowestPercent = durability
                lowestSlot = slot
            end
        end
    end
    
    return lowestPercent, lowestSlot
end

local function CheckDurability()
    -- Update lowest durability for minimap display
    currentLowestDurability, lowestDurabilitySlot = GetLowestDurability()
    UpdateMinimapIcon()
    
    -- Skip warning logic if in combat
    if UnitAffectingCombat("player") then
        warningFrame:Hide()
        return
    end

    -- Skip in Mythic+ dungeons
    local inInstance, instanceType = IsInInstance()
    if inInstance and instanceType == "party" then
        local _, _, difficultyID = GetInstanceInfo()
        if difficultyID == 8 then
            warningFrame:Hide()
            return
        end
    end

    -- Check if we should show warning
    if shownWarning then
        local threshold = DurabilityWarningDB.durabilityThreshold or 50
        
        if currentLowestDurability < threshold then
            local slotName = slotNames[lowestDurabilitySlot] or "Unknown"
            local r, g, b = GetDurabilityColor(currentLowestDurability)
            
            -- Handle different notification types
            local notifType = DurabilityWarningDB.notificationType or "popup"
            
            if notifType == "popup" then
                -- Update popup frame
                warningFrame.percentText:SetTextColor(r, g, b)
                warningFrame.percentText:SetText(math.floor(currentLowestDurability) .. "%")
                warningFrame.itemText:SetText("|cFFAAAAAA" .. slotName .. "|r")
                warningFrame:Show()
                PlayWarningSound()
            elseif notifType == "toast" then
                ShowToast(currentLowestDurability, slotName)
                PlayWarningSound()
            elseif notifType == "chat" then
                SendChatWarning(currentLowestDurability, slotName)
                PlayWarningSound()
            end
            
            -- Also show toast if enabled
            if DurabilityWarningDB.enableToastAlso and notifType == "popup" then
                ShowToast(currentLowestDurability, slotName)
            end
            
            shownWarning = false
        else
            warningFrame:Hide()
        end
    end
end

local function ResetWarning()
    shownWarning = true
end

-- ================================================================================
-- Slash Commands
-- ================================================================================
SLASH_DFTR1 = "/dftr"
SLASH_DFTR2 = "/dontforgettorepair"
SlashCmdList["DFTR"] = function(msg)
    msg = msg:lower():trim()
    
    if msg == "config" or msg == "options" or msg == "settings" then
        if addon.ConfigFrame then
            addon.ConfigFrame:Show()
        end
    elseif msg == "status" then
        local colorHex = GetDurabilityColorHex(currentLowestDurability)
        local slotName = slotNames[lowestDurabilitySlot] or "Unknown"
        print("|cFF00FF00[Don't Forget to Repair]|r Current lowest durability: " .. colorHex .. math.floor(currentLowestDurability) .. "%|r (" .. slotName .. ")")
    elseif msg == "show" then
        warningFrame:Show()
    elseif msg == "hide" then
        warningFrame:Hide()
    elseif msg == "minimap" then
        DurabilityWarningDB.minimapIcon.hide = not DurabilityWarningDB.minimapIcon.hide
        UpdateMinimapIcon()
        if DurabilityWarningDB.minimapIcon.hide then
            print("|cFF00FF00[Don't Forget to Repair]|r Minimap icon hidden")
        else
            print("|cFF00FF00[Don't Forget to Repair]|r Minimap icon shown")
        end
    elseif msg == "test" then
        -- Test notification with current settings
        local slotName = slotNames[lowestDurabilitySlot] or "Chest"
        local notifType = DurabilityWarningDB.notificationType or "popup"
        local r, g, b = GetDurabilityColor(currentLowestDurability)
        
        if notifType == "popup" then
            warningFrame.percentText:SetTextColor(r, g, b)
            warningFrame.percentText:SetText(math.floor(currentLowestDurability) .. "%")
            warningFrame.itemText:SetText("|cFFAAAAAA" .. slotName .. "|r")
            warningFrame:Show()
        elseif notifType == "toast" then
            ShowToast(currentLowestDurability, slotName)
        elseif notifType == "chat" then
            SendChatWarning(currentLowestDurability, slotName)
        end
        PlayWarningSound()
    else
        print("|cFF00FF00[Don't Forget to Repair]|r Commands:")
        print("  |cFFFFFF00/dftr|r - Show this help")
        print("  |cFFFFFF00/dftr config|r - Open settings")
        print("  |cFFFFFF00/dftr status|r - Show current durability")
        print("  |cFFFFFF00/dftr show|r - Show warning frame")
        print("  |cFFFFFF00/dftr hide|r - Hide warning frame")
        print("  |cFFFFFF00/dftr minimap|r - Toggle minimap icon")
        print("  |cFFFFFF00/dftr test|r - Test current notification")
    end
end

-- ================================================================================
-- Event Handler
-- ================================================================================
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == "DontForgetToRepair" then
            InitializeDB()
            
            -- Restore frame position
            if DurabilityWarningDB.framePosition then
                local pos = DurabilityWarningDB.framePosition
                warningFrame:ClearAllPoints()
                warningFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
            end
            
            -- Restore minimap button position
            if DurabilityWarningDB.minimapAngle then
                minimapAngle = DurabilityWarningDB.minimapAngle
            end
            
            UpdateMinimapPosition()
            UpdateMinimapIcon()
            
            -- Initial durability check
            C_Timer.After(2, function()
                currentLowestDurability, lowestDurabilitySlot = GetLowestDurability()
                UpdateMinimapIcon()
            end)
        end
    elseif event == "UPDATE_INVENTORY_DURABILITY" then
        CheckDurability()
    elseif event == "PLAYER_REGEN_ENABLED" then
        CheckDurability()
    elseif event == "MERCHANT_SHOW" then
        ResetWarning()
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        shownWarning = true
        CheckDurability()
    end
end)

-- Test warning function for config panel
local function TestWarning()
    local slotName = slotNames[lowestDurabilitySlot] or "Chest"
    local notifType = DurabilityWarningDB.notificationType or "popup"
    local r, g, b = GetDurabilityColor(currentLowestDurability)
    
    if notifType == "popup" then
        warningFrame.percentText:SetTextColor(r, g, b)
        warningFrame.percentText:SetText(math.floor(currentLowestDurability) .. "%")
        warningFrame.itemText:SetText("|cFFAAAAAA" .. slotName .. "|r")
        warningFrame:Show()
    elseif notifType == "toast" then
        ShowToast(currentLowestDurability, slotName)
    elseif notifType == "chat" then
        SendChatWarning(currentLowestDurability, slotName)
    end
    PlayWarningSound()
end

-- Export functions for config
addon.GetDurabilityColor = GetDurabilityColor
addon.GetDurabilityColorHex = GetDurabilityColorHex
addon.UpdateMinimapIcon = UpdateMinimapIcon
addon.PlayWarningSound = PlayWarningSound
addon.TestWarning = TestWarning
addon.soundFiles = soundFiles
