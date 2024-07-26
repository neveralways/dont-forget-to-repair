-- Create panel in game options panel
-- ------------------------------------------------------------------------------------------------------------------------------------------------
local optionsPanel = CreateFrame("Frame", "DontForgetToRepairOptionsPanel", UIParent)
optionsPanel.name = "DontForgetToRepair " .. GetAddOnMetadata("DontForgetToRepair", "Version")

local title = optionsPanel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText(optionsPanel.name)

local thresholdSlider = CreateFrame("Slider", "DurabilityThresholdSlider", optionsPanel, "OptionsSliderTemplate")
thresholdSlider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -40)
thresholdSlider:SetMinMaxValues(1, 100)
thresholdSlider:SetValueStep(1)
thresholdSlider:SetWidth(200)
thresholdSlider:SetObeyStepOnDrag(true)

thresholdSlider:SetScript("OnValueChanged", function(self, value)
    DurabilityWarningDB.durabilityThreshold = value
    DurabilityThresholdSliderText:SetText("Durability Threshold: " .. math.floor(value) .. "%")
end)

thresholdSlider:SetScript("OnShow", function(self)
    if DurabilityWarningDB then
        self:SetValue(DurabilityWarningDB.durabilityThreshold)
        DurabilityThresholdSliderText:SetText("Durability Threshold: " .. DurabilityWarningDB.durabilityThreshold .. "%")
    else
        print("DurabilityWarningDB is not initialized")
    end
end)

DurabilityThresholdSliderLow:SetText("1%")
DurabilityThresholdSliderHigh:SetText("100%")

if SettingsPanel then
    local category, layout = Settings.RegisterCanvasLayoutCategory(optionsPanel, "DontForgetToRepair")
    Settings.RegisterAddOnCategory(category)
end
