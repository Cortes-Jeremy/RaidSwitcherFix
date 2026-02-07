------------------------------------------------------------
-- RaidSwitcherFix (Ascension 3.3.5)
------------------------------------------------------------

local cfg = CreateFrame("Frame")
cfg.name = "RaidSwitcherFix"

------------------------------------------------------------
-- DEFAULTS
------------------------------------------------------------
cfg.defaults = {
    debugMode = false,
    onlyCheckWhenEnterNewZone = false,
}

------------------------------------------------------------
-- CopyTable (3.3.5 compatible)
------------------------------------------------------------
local function CopyTable(src)
    local t = {}
    for k, v in pairs(src) do
        t[k] = (type(v) == "table") and CopyTable(v) or v
    end
    return t
end

------------------------------------------------------------
-- CREATE TEXT LABEL
------------------------------------------------------------
local function CreateText(parent, text, anchor, x, y)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    -- Si on donne 'parent' comme relativeTo, on donne aussi relativePoint (ici on réutilise anchor)
    fs:SetPoint(anchor, parent, anchor, x, y)
    fs:SetJustifyH("LEFT")
    fs:SetText(text)
    return fs
end

------------------------------------------------------------
-- INIT EVENT
------------------------------------------------------------
cfg:SetScript("OnEvent", function(_, event, addon)
    if addon ~= "RaidSwitcherFix" then return end

    if not RaidSwitcherFixDB then
        RaidSwitcherFixDB = CopyTable(cfg.defaults)
    end

    cfg.db = RaidSwitcherFixDB
    cfg:CreateOptions()
end)
cfg:RegisterEvent("ADDON_LOADED")

------------------------------------------------------------
-- CREATE OPTIONS PANEL
------------------------------------------------------------
function cfg:CreateOptions()
    local panel = self
    local x = 20
    local y = -20

    ---------------------
    -- Big Action Button
    ---------------------
    local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btn:SetSize(300, 40)
    -- correction: fournir le relativePoint ("TOPLEFT")
    btn:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
    btn:SetText("Check raid profile activation")
    btn:SetScript("OnClick", function()
        if CheckProfiles then
            print("|cffffd000[RaidSwitcherFix]|r Manual check triggered.")
            CheckProfiles(true)
        else
            print("|cffff0000[RaidSwitcherFix ERROR]|r CheckProfiles() not found!")
        end
    end)

    ---------------------
    -- Debug Mode
    ---------------------
    local cb = CreateFrame("CheckButton", "RSFDebugCB", panel, "InterfaceOptionsCheckButtonTemplate")
    -- correction: préciser relativePoint
    cb:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y - 50)
    _G[cb:GetName() .. "Text"]:SetText("Enable debug mode")
    cb:SetChecked(self.db.debugMode)
    cb:SetScript("OnClick", function(self)
        cfg.db.debugMode = self:GetChecked() and true or false
    end)

    ---------------------
    -- (Optional) Only check on new zone
    ---------------------
    local cb2 = CreateFrame("CheckButton", "RSFZoneCB", panel, "InterfaceOptionsCheckButtonTemplate")
    cb2:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y - 80)
    _G[cb2:GetName() .. "Text"]:SetText("Check only when entering a new zone")
    cb2:SetChecked(self.db.onlyCheckWhenEnterNewZone)
    cb2:SetScript("OnClick", function(self)
        cfg.db.onlyCheckWhenEnterNewZone = self:GetChecked() and true or false
    end)

    ---------------------
    -- Description Block
    ---------------------
    local desc = CreateText(
        panel,
        "RaidSwitcherFix fixes the broken Blizzard auto-activation of raid profiles.\n\n" ..
        "The addon will automatically check your configured profiles when:\n" ..
        "  • You join a group or raid\n" ..
        "  • The raid size changes\n" ..
        "  • You enter a new zone",
        "TOPLEFT",
        x,
        y - 130
    )
    desc:SetWidth(500)
    desc:SetJustifyH("LEFT")

    ---------------------
    -- Open Blizzard Profiles Button
    ---------------------
    local btn2 = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btn2:SetSize(300, 25)
    -- correction: préciser relativePoint "BOTTOMLEFT"
    btn2:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", x, 20)
    btn2:SetText("Open Blizzard Raid Profiles")

    btn2:SetScript("OnClick", function()
        InterfaceOptionsFrame_OpenToCategory("Raid Profiles")
        InterfaceOptionsFrame_OpenToCategory("Raid Profiles")
    end)

    ---------------------
    -- Register Panel
    ---------------------
    InterfaceOptions_AddCategory(panel)
end

------------------------------------------------------------
-- Slash Command to open UI
------------------------------------------------------------
SLASH_RaidSwitcherFix1 = "/RaidSwitcherFix"
SlashCmdList["RaidSwitcherFix"] = function()
    InterfaceOptionsFrame_OpenToCategory("RaidSwitcherFix")
    InterfaceOptionsFrame_OpenToCategory("RaidSwitcherFix")
end
