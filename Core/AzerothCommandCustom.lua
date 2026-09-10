-------------------------------------------------------------------------------------------------------------
-- Azeroth Command custom layer
-- Keeps upstream AzerothAdmin internals intact while applying fork-specific behavior in one place.
-------------------------------------------------------------------------------------------------------------

local AC = {}
AzerothCommandCustom = AC

local function Text(fr, en) return en end

local THEME = {
    backgrounds = { r = 0.018, g = 0.022, b = 0.030 },
    frames      = { r = 0.050, g = 0.060, b = 0.080 },
    buttons     = { r = 0.080, g = 0.105, b = 0.145 },
    linkifier   = { r = 0.871, g = 0.373, b = 0.141 },
}

function AC.ApplyDefaultTheme(reload)
    if not AzerothAdmin or not AzerothAdmin.db or not AzerothAdmin.db.profile then return end
    local profile = AzerothAdmin.db.profile
    profile.style = profile.style or {}; profile.style.color = profile.style.color or {}; profile.style.color.buffer = {}
    profile.style.color.backgrounds = { r=THEME.backgrounds.r, g=THEME.backgrounds.g, b=THEME.backgrounds.b }
    profile.style.color.frames = { r=THEME.frames.r, g=THEME.frames.g, b=THEME.frames.b }
    profile.style.color.buttons = { r=THEME.buttons.r, g=THEME.buttons.g, b=THEME.buttons.b }
    profile.style.color.linkifier = { r=THEME.linkifier.r, g=THEME.linkifier.g, b=THEME.linkifier.b }
    profile.style.transparency = profile.style.transparency or {}
    profile.style.transparency.backgrounds = 0.96; profile.style.transparency.frames = 0.96; profile.style.transparency.buttons = 1.0
    profile.style.minimenuOrientation = profile.style.minimenuOrientation or "VERTICAL"
    profile.azerothCommandTheme = 1
    if reload then print("Azeroth Command: dark theme restored."); ReloadUI() end
end

local function EnsureThemeBeforeFrames()
    if AzerothAdmin and AzerothAdmin.db and AzerothAdmin.db.profile and AzerothAdmin.db.profile.azerothCommandTheme ~= 1 then AC.ApplyDefaultTheme(false) end
end

ROOT_PATH = "Interface\\AddOns\\AzerothCommand\\"
MAJOR_VERSION = "|cFF66D9FFAzeroth Command 3.3.5a|r"
MINOR_VERSION = tonumber(GetAddOnMetadata("AzerothCommand", "Version")) or 24

if AzerothAdmin and AzerothAdmin.RegisterChatCommand then
    AzerothAdmin:RegisterChatCommand("ac", "OnClick"); AzerothAdmin:RegisterChatCommand("azerothcommand", "OnClick")
end

if AzerothAdminCommands then
    function AzerothAdminCommands.ReloadScripts() AzerothAdmin:ChatMsg(".reload ale") end
    local UpstreamReloadTable = AzerothAdminCommands.ReloadTable
    function AzerothAdminCommands.ReloadTable(tablename)
        if not tablename or tablename == "" then return end
        if string.lower(tablename) == "all" then print("Azeroth Command: '.reload all' is blocked."); return end
        return UpstreamReloadTable(tablename)
    end
end

local function MiniButtons() return { ma_mm_mainbutton,ma_mm_charbutton,ma_mm_npcbutton,ma_mm_gobutton,ma_mm_telebutton,ma_mm_ticketbutton,ma_mm_miscbutton,ma_mm_serverbutton } end
local function SaveCurrentMiniAnchor()
    if not ma_minibgframe or not AzerothAdmin or not AzerothAdmin.db then return end
    local left,bottom=ma_minibgframe:GetLeft(),ma_minibgframe:GetBottom()
    if left and bottom then AzerothAdmin.db.profile.minimenuPosition={free=true,x=left,y=bottom} end
end
function AC.ApplyMiniMenuOrientation()
    if not ma_minibgframe or not ma_miniframe or not ma_mm_logoframe or not AzerothAdmin or not AzerothAdmin.db then return end
    local orientation=AzerothAdmin.db.profile.style.minimenuOrientation or "VERTICAL"; local saved=AzerothAdmin.db.profile.minimenuPosition
    ma_minibgframe:ClearAllPoints()
    if orientation=="HORIZONTAL" then
        ma_minibgframe:SetSize(198,28); ma_miniframe:SetSize(194,24); ma_mm_logoframe:ClearAllPoints(); ma_mm_logoframe:SetPoint("LEFT",ma_miniframe,"LEFT",3,0)
        local previous=ma_mm_logoframe; for _,button in ipairs(MiniButtons()) do if button then button:ClearAllPoints(); button:SetPoint("LEFT",previous,"RIGHT",2,0); previous=button end end
    else
        ma_minibgframe:SetSize(28,244); ma_miniframe:SetSize(24,240); ma_mm_logoframe:ClearAllPoints(); ma_mm_logoframe:SetPoint("TOP",ma_miniframe,"TOP",0,-2)
        local previous=ma_mm_logoframe; for _,button in ipairs(MiniButtons()) do if button then button:ClearAllPoints(); button:SetPoint("TOP",previous,"BOTTOM",0,-2); previous=button end end
    end
    if saved and type(saved)=="table" and saved.free and saved.x and saved.y then ma_minibgframe:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",saved.x,saved.y) else ma_minibgframe:SetPoint("RIGHT",UIParent,"RIGHT",0,0) end
end
function AC.ToggleMiniMenuOrientation()
    if not AzerothAdmin or not AzerothAdmin.db then return end
    SaveCurrentMiniAnchor(); local style=AzerothAdmin.db.profile.style; style.minimenuOrientation=(style.minimenuOrientation=="HORIZONTAL") and "VERTICAL" or "HORIZONTAL"; AC.ApplyMiniMenuOrientation()
    print("Azeroth Command: minimenu "..string.lower(style.minimenuOrientation)..".")
end

local function StyleCustomButton(button)
    if not button or not AzerothAdmin or not AzerothAdmin.db then return end
    local c=AzerothAdmin.db.profile.style.color.buttons or THEME.buttons
    local r,g,b=c.r or THEME.buttons.r,c.g or THEME.buttons.g,c.b or THEME.buttons.b
    button:SetBackdrop({
        bgFile="Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile="Interface\\Buttons\\WHITE8X8",
        tile=true,tileSize=8,edgeSize=1,
        insets={left=1,right=1,top=1,bottom=1}
    })
    button:SetBackdropColor(r,g,b,0.98)
    button:SetBackdropBorderColor(math.min(1,r+0.18),math.min(1,g+0.18),math.min(1,b+0.18),1)
    button:SetNormalTexture(nil); button:SetPushedTexture(nil); button:SetHighlightTexture(nil); button:SetDisabledTexture(nil)
    local fs=button:GetFontString()
    if fs then fs:SetTextColor(1,0.82,0,1) end
end

-- Custom controls live in the title area and use the exact same flat dark style as the addon buttons.
local function CreateCustomControls()
    if not ma_topframe then return end
    if not ma_ac_orientation_button then
        local b=CreateFrame("Button","ma_ac_orientation_button",ma_topframe)
        b:SetSize(105,20); b:SetPoint("TOPRIGHT",ma_topframe,"TOPRIGHT",-125,-45)
        local fs=b:CreateFontString(nil,"OVERLAY","GameFontNormal"); fs:SetPoint("CENTER"); b:SetFontString(fs); b:SetText("Mini: V/H")
        b:SetScript("OnClick",AC.ToggleMiniMenuOrientation)
        b:SetScript("OnEnter",function(self) GameTooltip:SetOwner(self,"ANCHOR_TOP"); GameTooltip:SetText("Minimenu orientation",1,.82,.25); GameTooltip:AddLine("Toggle vertical / horizontal minimenu.",1,1,1,true); GameTooltip:Show() end)
        b:SetScript("OnLeave",function() GameTooltip:Hide() end)
        StyleCustomButton(b)
    end
    if not ma_ac_reset_theme_button then
        local b=CreateFrame("Button","ma_ac_reset_theme_button",ma_topframe)
        b:SetSize(105,20); b:SetPoint("TOPRIGHT",ma_topframe,"TOPRIGHT",-15,-45)
        local fs=b:CreateFontString(nil,"OVERLAY","GameFontNormal"); fs:SetPoint("CENTER"); b:SetFontString(fs); b:SetText("Reset Theme")
        b:SetScript("OnClick",function() AC.ApplyDefaultTheme(true) end)
        StyleCustomButton(b)
    end
end

local function SkinActionButtons()
    if not FrameLib or not FrameLib.group or not AzerothAdmin or not AzerothAdmin.db then return end
    local c=AzerothAdmin.db.profile.style.color.buttons or THEME.buttons; local r,g,b=c.r or c[1] or THEME.buttons.r,c.g or c[2] or THEME.buttons.g,c.b or c[3] or THEME.buttons.b
    if r>1 then r=r/255 end; if g>1 then g=g/255 end; if b>1 then b=b/255 end
    for _,group in pairs(FrameLib.group) do if type(group)=="table" then for _,frame in pairs(group) do
        if frame and frame.GetObjectType and frame:GetObjectType()=="Button" and frame.GetText and frame:GetText() then local name=frame:GetName() or ""; if not string.find(name,"check") and not string.find(name,"dropdown") and frame.SetBackdrop then
            frame:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground",edgeFile="Interface\\Buttons\\WHITE8X8",tile=true,tileSize=8,edgeSize=1,insets={left=1,right=1,top=1,bottom=1}}); frame:SetBackdropColor(r,g,b,0.98); frame:SetBackdropBorderColor(math.min(1,r+0.18),math.min(1,g+0.18),math.min(1,b+0.18),1)
        end end
    end end end
end

local function ApplyBrandingAndSafety()
    if ma_logoframe then ma_logoframe:Hide(); if ma_logoframe.texture then ma_logoframe.texture:Hide() end; if ma_logoframe.GetRegions then for _,region in ipairs({ma_logoframe:GetRegions()}) do if region and region.Hide then region:Hide() end end end end
    if ma_topframe then
        if not ma_ac_brand then local brand=ma_topframe:CreateFontString("ma_ac_brand","OVERLAY","GameFontNormal"); brand:SetPoint("TOPLEFT",ma_topframe,"TOPLEFT",18,-16); brand:SetFont(STANDARD_TEXT_FONT,30,"OUTLINE"); brand:SetText("Azeroth Command"); brand:SetTextColor(.92,.72,.22,1) end
        ma_ac_brand:Show()
    end
    if ma_revtext then ma_revtext:ClearAllPoints(); ma_revtext:SetPoint("BOTTOMLEFT",ma_topframe,"BOTTOMLEFT",28,5) end
    if ma_languagebutton then ma_languagebutton:SetText("Reload ALE"); ma_languagebutton:SetScript("OnClick",function() AzerothAdmin:ChatMsg(".reload ale") end) end
    if ma_reloadscriptsbutton then ma_reloadscriptsbutton:SetText("Reload ALE") end
    if ma_reloadtabledropdown and UIDropDownMenu_SetSelectedValue then UIDropDownMenu_SetSelectedValue(ma_reloadtabledropdown,"creature_template"); UIDropDownMenu_SetText(ma_reloadtabledropdown,"creature_template") end
    if ma_bgframe and ma_bgframe.SetBackdrop then ma_bgframe:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",tile=true,tileSize=16,edgeSize=14,insets={left=4,right=4,top=4,bottom=4}}); ma_bgframe:SetBackdropColor(.015,.018,.025,.98); ma_bgframe:SetBackdropBorderColor(.42,.34,.12,1) end
    CreateCustomControls(); SkinActionButtons(); StyleCustomButton(ma_ac_orientation_button); StyleCustomButton(ma_ac_reset_theme_button); AC.ApplyMiniMenuOrientation()
    if ma_mm_logoframe then
        ma_mm_logoframe:RegisterForClicks("LeftButtonUp"); ma_mm_logoframe:SetScript("OnClick",function() if IsShiftKeyDown() then ReloadUI() else AzerothAdmin:ToggleMiniMenu() end end)
        ma_mm_logoframe:SetScript("OnEnter",function(self) GameTooltip:SetOwner(self,"ANCHOR_LEFT"); GameTooltip:SetText("Azeroth Command",1,.82,.25); GameTooltip:AddLine("Left click: open/close",1,1,1,true); GameTooltip:AddLine("Ctrl + drag: move",.7,.7,.7,true); GameTooltip:AddLine("Shift + click: Reload UI",.7,.7,.7,true); GameTooltip:Show() end); ma_mm_logoframe:SetScript("OnLeave",function() GameTooltip:Hide() end)
    end
end

if AzerothAdmin and AzerothAdmin.CreateFrames and not AzerothAdmin._AzerothCommandCreateFramesWrapped then
    local UpstreamCreateFrames=AzerothAdmin.CreateFrames
    function AzerothAdmin:CreateFrames(...) EnsureThemeBeforeFrames(); local result={UpstreamCreateFrames(self,...)}; ApplyBrandingAndSafety(); return unpack(result) end
    AzerothAdmin._AzerothCommandCreateFramesWrapped=true
end
local login=CreateFrame("Frame"); login:RegisterEvent("PLAYER_LOGIN"); login:SetScript("OnEvent",function() ApplyBrandingAndSafety() end)
