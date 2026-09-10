-------------------------------------------------------------------------------------------------------------
-- Azeroth Command custom layer
-- Keeps upstream AzerothAdmin internals intact while applying fork-specific behavior in one place.
-------------------------------------------------------------------------------------------------------------

local AC = {}
AzerothCommandCustom = AC

local function IsFrench()
    return GetLocale and GetLocale() == "frFR"
end

local function Text(fr, en)
    if IsFrench() then return fr end
    return en
end

local THEME = {
    backgrounds = { r = 0.018, g = 0.022, b = 0.030 },
    frames      = { r = 0.050, g = 0.060, b = 0.080 },
    buttons     = { r = 0.080, g = 0.105, b = 0.145 },
    linkifier   = { r = 0.871, g = 0.373, b = 0.141 },
}

function AC.ApplyDefaultTheme(reload)
    if not AzerothAdmin or not AzerothAdmin.db or not AzerothAdmin.db.profile then return end

    local profile = AzerothAdmin.db.profile
    profile.style = profile.style or {}
    profile.style.color = profile.style.color or {}
    profile.style.color.buffer = {}
    profile.style.color.backgrounds = { r = THEME.backgrounds.r, g = THEME.backgrounds.g, b = THEME.backgrounds.b }
    profile.style.color.frames      = { r = THEME.frames.r, g = THEME.frames.g, b = THEME.frames.b }
    profile.style.color.buttons     = { r = THEME.buttons.r, g = THEME.buttons.g, b = THEME.buttons.b }
    profile.style.color.linkifier   = { r = THEME.linkifier.r, g = THEME.linkifier.g, b = THEME.linkifier.b }
    profile.style.transparency = profile.style.transparency or {}
    profile.style.transparency.backgrounds = 0.96
    profile.style.transparency.frames = 0.96
    profile.style.transparency.buttons = 1.0
    profile.style.minimenuOrientation = profile.style.minimenuOrientation or "VERTICAL"
    profile.azerothCommandTheme = 1

    if reload then
        print(Text("Azeroth Command : thème sombre restauré.", "Azeroth Command: dark theme restored."))
        ReloadUI()
    end
end

local function EnsureThemeBeforeFrames()
    if not AzerothAdmin or not AzerothAdmin.db or not AzerothAdmin.db.profile then return end
    if AzerothAdmin.db.profile.azerothCommandTheme ~= 1 then
        AC.ApplyDefaultTheme(false)
    end
end

ROOT_PATH = "Interface\\AddOns\\AzerothCommand\\"
MAJOR_VERSION = "|cFF66D9FFAzeroth Command 3.3.5a|r"
MINOR_VERSION = tonumber(GetAddOnMetadata("AzerothCommand", "Version")) or 24

if AzerothAdmin and AzerothAdmin.RegisterChatCommand then
    AzerothAdmin:RegisterChatCommand("ac", "OnClick")
    AzerothAdmin:RegisterChatCommand("azerothcommand", "OnClick")
end

if AzerothAdminCommands then
    function AzerothAdminCommands.ReloadScripts()
        AzerothAdmin:ChatMsg(".reload ale")
    end

    local UpstreamReloadTable = AzerothAdminCommands.ReloadTable
    function AzerothAdminCommands.ReloadTable(tablename)
        if not tablename or tablename == "" then return end
        if string.lower(tablename) == "all" then
            print(Text(
                "Azeroth Command : '.reload all' est bloqué pour éviter un reload massif/crash.",
                "Azeroth Command: '.reload all' is blocked to avoid unsafe full reloads/crashes."
            ))
            return
        end
        return UpstreamReloadTable(tablename)
    end
end

local miniButtons = function()
    return {
        ma_mm_mainbutton, ma_mm_charbutton, ma_mm_npcbutton, ma_mm_gobutton,
        ma_mm_telebutton, ma_mm_ticketbutton, ma_mm_miscbutton, ma_mm_serverbutton
    }
end

local function SaveCurrentMiniAnchor()
    if not ma_minibgframe or not AzerothAdmin or not AzerothAdmin.db then return end
    local left, bottom = ma_minibgframe:GetLeft(), ma_minibgframe:GetBottom()
    if left and bottom then
        AzerothAdmin.db.profile.minimenuPosition = { free = true, x = left, y = bottom }
    end
end

function AC.ApplyMiniMenuOrientation()
    if not ma_minibgframe or not ma_miniframe or not ma_mm_logoframe then return end
    local style = AzerothAdmin.db.profile.style
    local orientation = style.minimenuOrientation or "VERTICAL"
    local saved = AzerothAdmin.db.profile.minimenuPosition

    ma_minibgframe:ClearAllPoints()

    if orientation == "HORIZONTAL" then
        ma_minibgframe:SetSize(198, 28)
        ma_miniframe:SetSize(194, 24)
        ma_mm_logoframe:ClearAllPoints()
        ma_mm_logoframe:SetPoint("LEFT", ma_miniframe, "LEFT", 3, 0)
        local previous = ma_mm_logoframe
        for _, button in ipairs(miniButtons()) do
            if button then
                button:ClearAllPoints()
                button:SetPoint("LEFT", previous, "RIGHT", 2, 0)
                previous = button
            end
        end
    else
        ma_minibgframe:SetSize(28, 244)
        ma_miniframe:SetSize(24, 240)
        ma_mm_logoframe:ClearAllPoints()
        ma_mm_logoframe:SetPoint("TOP", ma_miniframe, "TOP", 0, -2)
        local previous = ma_mm_logoframe
        for _, button in ipairs(miniButtons()) do
            if button then
                button:ClearAllPoints()
                button:SetPoint("TOP", previous, "BOTTOM", 0, -2)
                previous = button
            end
        end
    end

    if saved and type(saved) == "table" and saved.free and saved.x and saved.y then
        ma_minibgframe:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", saved.x, saved.y)
    elseif saved and type(saved) == "table" and saved.side then
        ma_minibgframe:SetPoint(saved.side, UIParent, saved.side, 0, saved.yOffset or 0)
    elseif type(saved) == "string" then
        ma_minibgframe:SetPoint(saved, UIParent, saved, 0, 0)
    else
        ma_minibgframe:SetPoint("RIGHT", UIParent, "RIGHT", 0, 0)
    end

    if ma_ac_orientation_button then
        ma_ac_orientation_button:SetText(
            orientation == "HORIZONTAL"
            and Text("Barre : Horizontale", "Bar: Horizontal")
            or Text("Barre : Verticale", "Bar: Vertical")
        )
    end
end

function AC.ToggleMiniMenuOrientation()
    if not AzerothAdmin or not AzerothAdmin.db then return end
    SaveCurrentMiniAnchor()
    local style = AzerothAdmin.db.profile.style
    style.minimenuOrientation = (style.minimenuOrientation == "HORIZONTAL") and "VERTICAL" or "HORIZONTAL"
    AC.ApplyMiniMenuOrientation()
end

local function CreateCustomMiscButtons()
    if not ma_midframe or ma_ac_orientation_button then return end

    local orientation = CreateFrame("Button", "ma_ac_orientation_button", ma_midframe, "UIPanelButtonTemplate")
    orientation:SetWidth(150)
    orientation:SetHeight(22)
    orientation:SetPoint("TOPLEFT", ma_midframe, "TOPLEFT", 410, -24)
    orientation:SetScript("OnClick", AC.ToggleMiniMenuOrientation)
    orientation:SetText(Text("Barre : Verticale", "Bar: Vertical"))

    local reset = CreateFrame("Button", "ma_ac_reset_theme_button", ma_midframe, "UIPanelButtonTemplate")
    reset:SetWidth(120)
    reset:SetHeight(22)
    reset:SetPoint("TOPLEFT", ma_midframe, "TOPLEFT", 120, -225)
    reset:SetText(Text("Reset thème", "Reset theme"))
    reset:SetScript("OnClick", function() AC.ApplyDefaultTheme(true) end)
end

local function SkinActionButtons()
    if not FrameLib or not FrameLib.group or not AzerothAdmin or not AzerothAdmin.db then return end
    local c = AzerothAdmin.db.profile.style.color.buttons or THEME.buttons
    local r, g, b = c.r or c[1] or THEME.buttons.r, c.g or c[2] or THEME.buttons.g, c.b or c[3] or THEME.buttons.b
    if r > 1 then r = r / 255 end
    if g > 1 then g = g / 255 end
    if b > 1 then b = b / 255 end
    local br, bg, bb = math.min(1, r + 0.18), math.min(1, g + 0.18), math.min(1, b + 0.18)

    for _, group in pairs(FrameLib.group) do
        if type(group) == "table" then
            for _, frame in pairs(group) do
                if frame and frame.GetObjectType and frame:GetObjectType() == "Button" and frame.GetText and frame:GetText() then
                    local name = frame:GetName() or ""
                    if not string.find(name, "check") and not string.find(name, "dropdown") then
                        if frame.SetBackdrop then
                            frame:SetBackdrop({
                                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                                edgeFile = "Interface\\Buttons\\WHITE8X8",
                                tile = true, tileSize = 8, edgeSize = 1,
                                insets = { left = 1, right = 1, top = 1, bottom = 1 }
                            })
                            frame:SetBackdropColor(r, g, b, 0.98)
                            frame:SetBackdropBorderColor(br, bg, bb, 1)
                        end
                    end
                end
            end
        end
    end
end

local function ApplyBrandingAndSafety()
    if ma_logoframe then ma_logoframe:Hide() end
    if ma_topframe and not ma_ac_brand then
        local brand = ma_topframe:CreateFontString("ma_ac_brand", "ARTWORK", "GameFontNormal")
        brand:SetPoint("LEFT", ma_topframe, "LEFT", 18, 2)
        brand:SetFont(STANDARD_TEXT_FONT, 34, "OUTLINE")
        brand:SetText("Azeroth Command")
        brand:SetTextColor(0.92, 0.72, 0.22, 1)
    end

    if ma_languagebutton then
        ma_languagebutton:SetText("Reload ALE")
        ma_languagebutton:SetScript("OnClick", function()
            AzerothAdmin:ChatMsg(".reload ale")
        end)
        ma_languagebutton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Reload ALE", 1, 0.82, 0.25)
            GameTooltip:AddLine(Text("Recharge les scripts ALE/Eluna côté serveur.", "Reload server-side ALE/Eluna scripts."), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        ma_languagebutton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    if ma_reloadscriptsbutton then ma_reloadscriptsbutton:SetText("Reload ALE") end

    if ma_reloadtabledropdown and UIDropDownMenu_SetSelectedValue then
        UIDropDownMenu_SetSelectedValue(ma_reloadtabledropdown, "creature_template")
        UIDropDownMenu_SetText(ma_reloadtabledropdown, "creature_template")
    end

    if ma_bgframe and ma_bgframe.SetBackdrop then
        ma_bgframe:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 14,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        ma_bgframe:SetBackdropColor(0.015, 0.018, 0.025, 0.98)
        ma_bgframe:SetBackdropBorderColor(0.42, 0.34, 0.12, 1)
    end

    CreateCustomMiscButtons()
    SkinActionButtons()
    AC.ApplyMiniMenuOrientation()

    if ma_mm_logoframe then
        ma_mm_logoframe:RegisterForClicks("LeftButtonUp")
        ma_mm_logoframe:SetScript("OnClick", function()
            if IsShiftKeyDown() then
                ReloadUI()
            else
                AzerothAdmin:ToggleMiniMenu()
            end
        end)
        ma_mm_logoframe:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText("Azeroth Command", 1, 0.82, 0.25)
            GameTooltip:AddLine(Text("Clic gauche : ouvrir/fermer", "Left click: open/close"), 1, 1, 1, true)
            GameTooltip:AddLine(Text("Orientation : bouton dans MISC", "Orientation: button in MISC"), 0.4, 0.85, 1, true)
            GameTooltip:AddLine(Text("Ctrl + glisser : déplacer", "Ctrl + drag: move"), 0.7, 0.7, 0.7, true)
            GameTooltip:AddLine(Text("Shift + clic : Reload UI", "Shift + click: Reload UI"), 0.7, 0.7, 0.7, true)
            GameTooltip:Show()
        end)
        ma_mm_logoframe:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
end

if AzerothAdmin and AzerothAdmin.CreateFrames and not AzerothAdmin._AzerothCommandCreateFramesWrapped then
    local UpstreamCreateFrames = AzerothAdmin.CreateFrames
    function AzerothAdmin:CreateFrames(...)
        EnsureThemeBeforeFrames()
        local result = { UpstreamCreateFrames(self, ...) }
        ApplyBrandingAndSafety()
        return unpack(result)
    end
    AzerothAdmin._AzerothCommandCreateFramesWrapped = true
end

local login = CreateFrame("Frame")
login:RegisterEvent("PLAYER_LOGIN")
login:SetScript("OnEvent", function()
    ApplyBrandingAndSafety()
end)
