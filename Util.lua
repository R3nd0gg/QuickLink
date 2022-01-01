local addonName, ns = ...

local UNIT_TOKENS = {
    mouseover = true,
    player = true,
    target = true,
    focus = true,
    pet = true,
    vehicle = true,
}

do
    for i = 1, 40 do
        UNIT_TOKENS["raid" .. i] = true
        UNIT_TOKENS["raidpet" .. i] = true
        UNIT_TOKENS["nameplate" .. i] = true
    end

    for i = 1, 4 do
        UNIT_TOKENS["party" .. i] = true
        UNIT_TOKENS["partypet" .. i] = true
    end

    for i = 1, 5 do
        UNIT_TOKENS["arena" .. i] = true
        UNIT_TOKENS["arenapet" .. i] = true
    end

    for i = 1, MAX_BOSS_FRAMES do
        UNIT_TOKENS["boss" .. i] = true
    end

    for k, _ in pairs(UNIT_TOKENS) do
        UNIT_TOKENS[k .. "target"] = true
    end
end

function QuickLink:IsUnitToken(unit)
    return type(unit) == "string" and UNIT_TOKENS[unit]
end

function QuickLink:IsUnit(arg1, arg2)
    if not arg2 and type(arg1) == "string" and arg1:find("-", nil, true) then
        arg2 = true
    end
    local isUnit = not arg2 or QuickLink:IsUnitToken(arg1)
    return isUnit, isUnit and UnitExists(arg1), isUnit and UnitIsPlayer(arg1)
end

function QuickLink:IsMaxLevel(level, fallback)
	if level and type(level) == "number" then
		return level >= ns.MAX_LEVEL
	end
	return fallback
end

function QuickLink:GetNameRealm(arg1, arg2)
    local unit, name, realm
    local _, unitExists, unitIsPlayer = QuickLink:IsUnit(arg1, arg2)
    if unitExists then
        unit = arg1
        if unitIsPlayer then
            name, realm = UnitNameUnmodified(arg1)
            realm = realm and realm ~= "" and realm or GetNormalizedRealmName()
        end
        return name, realm, unit
    end
    if type(arg1) == "string" then
        if arg1:find("-", nil, true) then
            name, realm = ("-"):split(arg1)
        else
            name = arg1 -- assume this is the name
        end
        if not realm or realm == "" then
            if type(arg2) == "string" and arg2 ~= "" then
                realm = arg2
            else
                realm = GetNormalizedRealmName() -- assume they are on our realm
            end
        end
    end
    return name, realm, unit
end

function QuickLink:GetNameRealmForBNetFriend(bnetIDAccount, getAllChars)
    local index = BNGetFriendIndex(bnetIDAccount)
    if not index then
        return
    end
    local collection = {}
    local collectionIndex = 0
    for i = 1, C_BattleNet.GetFriendNumGameAccounts(index), 1 do
        local accountInfo = C_BattleNet.GetFriendGameAccountInfo(index, i)
        if accountInfo and accountInfo.clientProgram == BNET_CLIENT_WOW and (not accountInfo.wowProjectID or accountInfo.wowProjectID == WOW_PROJECT_MAINLINE) then
            if accountInfo.realmName then
                accountInfo.characterName = accountInfo.characterName .. "-" .. accountInfo.realmName:gsub("%s+", "")
            end
            collectionIndex = collectionIndex + 1
            collection[collectionIndex] = { accountInfo.characterName, ns.FACTION_TO_ID[accountInfo.factionName], tonumber(accountInfo.characterLevel) }
        end
    end
    if not getAllChars then
        for i = 1, collectionIndex do
            local profile = collection[collectionIndex]
            local name, faction, level = profile[1], profile[2], profile[3]
            if QuickLink:IsMaxLevel(level) then
                return name, faction, level
            end
        end
        return
    end
    return collection
end

function QuickLink:GetNameRealmFromPlayerLink(playerLink)
    local linkString, linkText = LinkUtil.SplitLink(playerLink)
    local linkType, linkData = ExtractLinkData(linkString)
    if linkType == "player" then
        return QuickLink:GetNameRealm(linkData)
    elseif linkType == "BNplayer" then
        local _, bnetIDAccount = strsplit(":", linkData)
        if bnetIDAccount then
            bnetIDAccount = tonumber(bnetIDAccount)
        end
        if bnetIDAccount then
            local fullName, _, level = QuickLink:GetNameRealmForBNetFriend(bnetIDAccount)
            local name, realm = QuickLink:GetNameRealm(fullName)
            return name, realm, level
        end
    end
end

function QuickLink:GetRealmSlug(realm, fallback)
    local realmSlug = ns.REALMS[realm]
    if fallback == true then
        return realmSlug or realm
    elseif fallback then
        return realmSlug or fallback
    end
    return realmSlug
end

local function GetPlayerInfo(...)
    local name, realm = QuickLink:GetNameRealm(...)
    local realmSlug = QuickLink:GetRealmSlug(realm, true)
    local playerRegion = ns.REGIONS[GetCurrentRegion()]
    return name, realm, realmSlug, playerRegion
end

function QuickLink:GetRaiderIOProfileUrl(...)
    local name, realm, realmSlug, playerRegion = GetPlayerInfo(...)
    return format("https://raider.io/characters/%s/%s/%s", playerRegion, realmSlug, name), name, realm, realmSlug
end

function QuickLink:GetArmoryUrl(...)
    local name, realm, realmSlug, playerRegion = GetPlayerInfo(...)
    return format("https://worldofwarcraft.com/en-gb/character/%s/%s/%s", playerRegion, realmSlug, name), name, realm, realmSlug
end

function QuickLink:GetCheckPvpUrl(...)
    local name, realm, realmSlug, playerRegion = GetPlayerInfo(...)
    local modifiedRealm = realm:gsub("(%u%l+)(%u%l+)", "%1 %2")
    return format("https://check-pvp.fr/%s/%s/%s", playerRegion, modifiedRealm, name), name, realm, realmSlug
end

function QuickLink:GetWarcraftLogsUrl(...)
    local name, realm, realmSlug, playerRegion = GetPlayerInfo(...)
    return format("https://www.warcraftlogs.com/character/%s/%s/%s", playerRegion, realmSlug, name), name, realm, realmSlug
end
