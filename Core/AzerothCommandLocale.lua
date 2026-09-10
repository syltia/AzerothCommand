-------------------------------------------------------------------------------------------------------------
-- Azeroth Command visible localization/branding layer.
-- Internal AceLocale namespaces intentionally remain AzerothAdmin for upstream compatibility.
-------------------------------------------------------------------------------------------------------------

if AzerothAdmin and AzerothAdmin.SetLanguage and not AzerothAdmin._AzerothCommandLanguageWrapped then
    local UpstreamSetLanguage = AzerothAdmin.SetLanguage

    function AzerothAdmin:SetLanguage(...)
        local result = { UpstreamSetLanguage(self, ...) }

        if Locale then
            -- Replace visible legacy branding without touching keys or internal addon identifiers.
            for key, value in pairs(Locale) do
                if type(value) == "string" then
                    Locale[key] = string.gsub(value, "AzerothAdmin", "Azeroth Command")
                end
            end

            if GetLocale and GetLocale() == "frFR" then
                Locale["ma_LanguageButton"] = "Recharger ALE"
                Locale["tt_LanguageButton"] = "Recharge les scripts ALE/Eluna côté serveur."
                Locale["ma_ReloadScriptsButton"] = "Recharger ALE"
            else
                Locale["ma_LanguageButton"] = "Reload ALE"
                Locale["tt_LanguageButton"] = "Reload server-side ALE/Eluna scripts."
                Locale["ma_ReloadScriptsButton"] = "Reload ALE"
            end
        end

        return unpack(result)
    end

    AzerothAdmin._AzerothCommandLanguageWrapped = true
end
