local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

local defaultDurabilityThreshold = 50

local function InitializeDB()
    if DurabilityWarningDB == nil then
        DurabilityWarningDB = {
            durabilityThreshold = defaultDurabilityThreshold
        }
    end
end

local warningFrame = CreateFrame("Frame", "DurabilityWarningFrame", UIParent, "BasicFrameTemplateWithInset")
warningFrame:SetSize(400, 200)
warningFrame:SetPoint("CENTER")
warningFrame:SetMovable(true)
warningFrame:EnableMouse(true)
warningFrame:RegisterForDrag("LeftButton")
warningFrame:SetScript("OnDragStart", warningFrame.StartMoving)
warningFrame:SetScript("OnDragStop", warningFrame.StopMovingOrSizing)
warningFrame:Hide()

warningFrame.title = warningFrame:CreateFontString(nil, "OVERLAY")
warningFrame.title:SetFontObject("GameFontHighlightLarge")
warningFrame.title:SetPoint("CENTER", warningFrame, "TOP", 0, -10)
warningFrame.title:SetText("Durability Warning")

warningFrame.text = warningFrame:CreateFontString(nil, "OVERLAY")
warningFrame.text:SetFontObject("GameFontHighlightHuge")
warningFrame.text:SetPoint("CENTER", warningFrame, "CENTER", 0, 0)
warningFrame.text:SetText("Don't forget to repair")

local okButton = CreateFrame("Button", nil, warningFrame, "GameMenuButtonTemplate")
okButton:SetPoint("BOTTOM", warningFrame, "BOTTOM", 0, 20)
okButton:SetSize(120, 40)
okButton:SetText("OK")
okButton:SetNormalFontObject("GameFontNormalLarge")
okButton:SetHighlightFontObject("GameFontHighlightLarge")
okButton:SetScript("OnClick", function()
    warningFrame:Hide()
end)

local shownWarning = true

local function CheckDurability()
    if UnitAffectingCombat("player") then
        warningFrame:Hide()
        return
    end

    local inInstance, instanceType = IsInInstance()
    if inInstance and instanceType == "party" then
        local _, _, difficultyID = GetInstanceInfo()
        if difficultyID == 8 then
            warningFrame:Hide()
            return
        end
    end

    if shownWarning then
        local lowDurabilityFound = false
        for slot = 1, 18 do
            local current, maximum = GetInventoryItemDurability(slot)
            if current and maximum then
                local durability = (current / maximum) * 100
                if durability < DurabilityWarningDB.durabilityThreshold then
                    lowDurabilityFound = true
                    warningFrame.text:SetText("Don't forget to repair, " .. math.floor(durability) .. "% durability")
                    break
                end
            end
        end
        if lowDurabilityFound then
            warningFrame:Show()
            shownWarning = false
        else
            warningFrame:Hide()
        end
    end
end

local function ResetWarning()
    shownWarning = true
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "DontForgetToRepair" then
            InitializeDB()
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
