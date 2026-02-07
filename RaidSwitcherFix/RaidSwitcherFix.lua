------------------------------------------------------------
-- RaidSwitcherFix - Ascension 3.3.5
------------------------------------------------------------

local RSF = {}
local lastPlayerCount = -1
local lastEnemyType  = ""
RSF.pendingUpdate = false

------------------------------------------------------------
-- Backport API
------------------------------------------------------------
local function GetGroupMembers()
    if GetNumGroupMembers then
        return GetNumGroupMembers()
    end
    if GetNumRaidMembers() > 0 then
        return GetNumRaidMembers()
    end
    return GetNumPartyMembers() + 1
end

------------------------------------------------------------
-- NORMALISATION DES TAILLES DE GROUPE
------------------------------------------------------------
local function NormalizeGroupSize(members)
    if members <= 2 then return 2 end
    if members <= 3 then return 3 end
    if members <= 5 then return 5 end
    if members <= 10 then return 10 end
    if members <= 15 then return 15 end
    return 40
end

------------------------------------------------------------
-- PROFIL AUTO
------------------------------------------------------------
local function ProfileMatches(profile, numPlayers, enemyType)
    return GetRaidProfileOption(profile, "autoActivate" .. numPlayers .. "Players")
       and GetRaidProfileOption(profile, "autoActivate" .. enemyType)
end

------------------------------------------------------------
-- FONCTION PRINCIPALE
------------------------------------------------------------
function RSF.CheckProfiles(debug)

    if InCombatLockdown() then
        RSF.pendingUpdate = true
        if debug then print("|cffff0000[RSF]|r In combat → delayed") end
        return
    end

    if debug then print("|cffffd000[RaidSwitcherFix]|r Checking raid profile…") end

    ----------------------------------------
    -- DÉTECTION GROUPE
    ----------------------------------------
    local members = GetGroupMembers()
    if not members or members == 0 then return end

    ----------------------------------------
    -- INSTANCE / PvP
    ----------------------------------------
    local _, zoneType = IsInInstance()
    local pvpType = GetZonePVPInfo()

    local enemyType = "PvE"
    if zoneType == "arena"
        or zoneType == "pvp"
        or pvpType == "hostile"
        or pvpType == "contested"
    then
        enemyType = "PvP"
    end

    ----------------------------------------
    -- GROUPE NORMALISÉ
    ----------------------------------------
    local numPlayers = NormalizeGroupSize(members)

    ----------------------------------------
    -- ANTI-SPAM
    ----------------------------------------
    if numPlayers == lastPlayerCount and enemyType == lastEnemyType then
        if debug then print("[RSF] No change → skip") end
        return
    end

    ----------------------------------------
    -- ACTIVATION DU PROFIL
    ----------------------------------------
    if debug then
        print("[RSF] Scanning profiles for match…")
    end

    for i = 1, GetNumRaidProfiles() do
        local profile = GetRaidProfileName(i)

        if debug then print("→ Checking profile:", profile) end

        if ProfileMatches(profile, numPlayers, enemyType) then
            if GetActiveRaidProfile() ~= profile then
                CompactUnitFrameProfiles_ActivateRaidProfile(profile)

                print("|cff00ff00[RaidSwitcherFix]|r Activated profile:",
                    profile, "(Group:", numPlayers, "Type:", enemyType .. ")")
            else
                if debug then
                    print("[RSF] Profile already active:", profile)
                end
            end

            -- ⚠️ update ONLY after success
            lastPlayerCount = numPlayers
            lastEnemyType = enemyType
            RSF.pendingUpdate = false

        end
    end
end

------------------------------------------------------------
-- SLASH COMMAND
------------------------------------------------------------
SLASH_RSF1 = "/rsf"
SlashCmdList["RSF"] = function(msg)
    lastPlayerCount = -1
    lastEnemyType = ""
    RSF.pendingUpdate = false
    print("|cffffd000[RaidSwitcherFix]|r Manual check requested")
    RSF.CheckProfiles(true)
end

------------------------------------------------------------
-- EVENT HANDLER
------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("PARTY_MEMBERS_CHANGED")
ev:RegisterEvent("RAID_ROSTER_UPDATE")
ev:RegisterEvent("ZONE_CHANGED_NEW_AREA")
ev:RegisterEvent("PLAYER_ENTERING_WORLD")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
ev:SetScript("OnEvent", function(ev)
    if ev == "PLAYER_REGEN_ENABLED" and RSF.pendingUpdate then
        lastPlayerCount = -1
        lastEnemyType = ""
    end

    RSF.CheckProfiles(RaidSwitcherFixDB and RaidSwitcherFixDB.debugMode)
end)
